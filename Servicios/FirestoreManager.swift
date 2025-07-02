import Foundation
import FirebaseFirestore

enum FirestoreCollection {
    case noticias(pueblo: String)
    case usuarios(pueblo: String)
    case incidencias(pueblo: String)
    case celebraciones(pueblo: String)
    
    var path: String {
        switch self {
        case .noticias(let pueblo):
            return "pueblos/\(pueblo)/Noticias"
        case .usuarios(let pueblo):
            return "pueblos/\(pueblo)/Usuarios"
        case .incidencias(let pueblo): // <-- AÑADE ESTE CASO
                    return "pueblos/\(pueblo)/Incidencias"
        case .celebraciones(let pueblo): // <-- AÑADE ESTE CASO
                   return "pueblos/\(pueblo)/Celebraciones"
        }
    }
}

class FirestoreManager {
    static let shared = FirestoreManager()
    private let db = Firestore.firestore()
    private init() {}
    
    // Tu función de noticias
    func fetchNoticias() async throws -> [Noticia] {
        let pueblo = "Figueruelas"
        let collectionPath = FirestoreCollection.noticias(pueblo: pueblo).path
        let querySnapshot = try await db.collection(collectionPath)
                                          .order(by: "timestamp", descending: true)
                                          .getDocuments()
        
        return querySnapshot.documents.compactMap { try? $0.data(as: Noticia.self) }
    }

    // MARK: - GESTIÓN DE USUARIOS (async/await)

    func listenForUsers() -> AsyncThrowingStream<[Usuario], Error> {
        let pueblo = "Figueruelas"
        let path = FirestoreCollection.usuarios(pueblo: pueblo).path
        
        return AsyncThrowingStream { continuation in
            let listener = db.collection(path).addSnapshotListener { querySnapshot, error in
                if let error = error {
                    continuation.finish(throwing: error)
                    return
                }
                guard let documents = querySnapshot?.documents else {
                    continuation.yield([])
                    return
                }
                let usuarios = documents.compactMap { try? $0.data(as: Usuario.self) }
                continuation.yield(usuarios)
            }
            continuation.onTermination = { @Sendable _ in listener.remove() }
        }
    }
    
    func updateDocument(in collection: FirestoreCollection, withId id: String, data: [String: Any]) async throws {
        try await db.collection(collection.path).document(id).updateData(data)
    }

    func deleteDocument(in collection: FirestoreCollection, withId id: String) async throws {
        try await db.collection(collection.path).document(id).delete()
    }
    func fetchCollection<T: Decodable>(from collection: FirestoreCollection) async throws -> [T] {
            let snapshot = try await db.collection(collection.path).getDocuments()
            
            // Usamos compactMap para decodificar y descartar los documentos con errores.
            let result = snapshot.documents.compactMap { doc -> T? in
                do {
                    return try doc.data(as: T.self)
                } catch {
                    print("Error decodificando documento \(doc.documentID): \(error)")
                    return nil
                }
            }
            return result
        }
    func addDocument(data: [String: Any], to collection: FirestoreCollection) async throws {
        // Simplemente añade el documento. Firestore se encarga del resto.
        try await db.collection(collection.path).addDocument(data: data)
    }
    func fetchCelebraciones() async throws -> [Celebracion] {
        let collectionPath = FirestoreCollection.celebraciones(pueblo: "Figueruelas").path
        
        // 1. Obtenemos los documentos de la colección
        let querySnapshot = try await db.collection(collectionPath)
            .order(by: "timestamp", descending: true)
            .getDocuments() // <-- Se llama sin argumentos
        
        // 2. Mapeamos y decodificamos cada documento a nuestro modelo 'Celebracion'
        let celebraciones = querySnapshot.documents.compactMap { document -> Celebracion? in
            return try? document.data(as: Celebracion.self)
        }
        
        return celebraciones
    }
    
    }

