//  FigueruelasConecta/Servicios/FirestoreManager.swift

import Foundation
import FirebaseFirestore
import FirebaseFirestore

enum FirestoreCollection {
    case noticias(pueblo: String)
    case usuarios(pueblo: String)
    case incidencias(pueblo: String)
    case celebraciones(pueblo: String)
    case empleo(pueblo: String)
    // --- AÑADIDO PARA DEPORTES ---
    case deportes(pueblo: String)
    case partidos(pueblo: String)
    case actividades(pueblo: String)
    
    var path: String {
        switch self {
        case .noticias(let pueblo):
            return "pueblos/\(pueblo)/Noticias"
        case .usuarios(let pueblo):
            return "pueblos/\(pueblo)/Usuarios"
        case .incidencias(let pueblo):
            return "pueblos/\(pueblo)/Incidencias"
        case .celebraciones(let pueblo):
            return "pueblos/\(pueblo)/Celebraciones"
        case .empleo(let pueblo):
            return "pueblos/\(pueblo)/Empleo"
        // --- AÑADIDO PARA DEPORTES ---
        case .deportes(let pueblo):
            return "pueblos/\(pueblo)/Deportes"
        case .partidos(let pueblo):
            return "pueblos/\(pueblo)/Partidos"
        case .actividades(let pueblo):
            return "pueblos/\(pueblo)/Actividades"
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
        try await db.collection(collection.path).addDocument(data: data)
    }
    
    func fetchCelebraciones() async throws -> [Celebracion] {
        let collectionPath = FirestoreCollection.celebraciones(pueblo: "Figueruelas").path
        
        let querySnapshot = try await db.collection(collectionPath)
            .order(by: "timestamp", descending: true)
            .getDocuments()
        
        let celebraciones = querySnapshot.documents.compactMap { document -> Celebracion? in
            return try? document.data(as: Celebracion.self)
        }
        
        return celebraciones
    }
    
    // MARK: - EMPLEO
    private var empleoRef: CollectionReference {
        return db.collection(FirestoreCollection.empleo(pueblo: "Figueruelas").path)
    }

    func fetchEmpleos() async throws -> [Empleo] {
        let querySnapshot = try await empleoRef
            .order(by: "fechaCreacion", descending: true)
            .getDocuments()
        
        let empleos = querySnapshot.documents.compactMap { document -> Empleo? in
            try? document.data(as: Empleo.self)
        }
        
        return empleos
    }

    func createEmpleo(titulo: String, descripcion: String, imagenUrl: String?) async throws {
        let calendar = Calendar.current
        guard let tresMesesDespues = calendar.date(byAdding: .month, value: 3, to: Date()) else {
            throw NSError(domain: "DateError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No se pudo calcular la fecha de expiración."])
        }
        let expiracionTimestamp = Timestamp(date: tresMesesDespues)
        
        let nuevoEmpleo = Empleo(
            titulo: titulo,
            descripcion: descripcion,
            imagenUrl: imagenUrl,
            fechaCreacion: nil, // Firestore lo rellena con @ServerTimestamp
            fechaExpiracion: expiracionTimestamp
        )
        
        try empleoRef.document().setData(from: nuevoEmpleo)
    }

    func deleteEmpleo(empleoId: String) async throws {
        try await empleoRef.document(empleoId).delete()
    }
    
    // MARK: - DEPORTES (AÑADIDO)
    
    /// Crea un nuevo documento en la colección de Deportes.
    /// - Throws: Lanza un error si la escritura en Firestore falla.
    func crearDeporte(nombre: String, emoji: String, filtro: String) async throws {
        let nuevoDeporte: [String: Any] = [
            "nombre": nombre,
            "emoji": emoji,
            "filtro": filtro
        ]
        
        // Usamos nuestro enum para mantener la consistencia
        let collection = FirestoreCollection.deportes(pueblo: "Figueruelas")
        try await db.collection(collection.path).addDocument(data: nuevoDeporte)
    }
    func crearPartido(equipo1: String, equipo2: String, fecha: Date, deporte: String, categoria: String, diaSemana: String) async throws {
        // Calculamos la fecha de expiración para autolimpieza (1 mes desde la fecha del partido)
        guard let fechaExpiracion = Calendar.current.date(byAdding: .month, value: 1, to: fecha) else {
            throw NSError(domain: "DateError", code: 1, userInfo: [NSLocalizedDescriptionKey: "No se pudo calcular la fecha de expiración."])
        }
        
        // Formateamos la fecha a un string legible "dd/MM/yyyy"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let fechaString = dateFormatter.string(from: fecha)

        let nuevoPartido = Partido(
            equipo1: equipo1,
            equipo2: equipo2,
            fecha: fechaString,
            deporte: deporte,
            categoria: categoria,
            diaSemana: diaSemana,
            resultado: "0 - 0", // Resultado inicial por defecto
            fechaExpiracion: Timestamp(date: fechaExpiracion)
        )
        
        let collection = FirestoreCollection.partidos(pueblo: "Figueruelas")
        // Usamos setData(from:) que codifica nuestro objeto Partido automáticamente
        try db.collection(collection.path).document().setData(from: nuevoPartido)
    }
    func crearActividad(titulo: String, downloadUrl: URL) async throws {
        guard let fechaExpiracion = Calendar.current.date(byAdding: .month, value: 3, to: Date()) else {
            throw NSError(domain: "DateError", code: 2, userInfo: [NSLocalizedDescriptionKey: "No se pudo calcular la fecha de expiración."])
        }
        
        let nuevaActividad = Actividad(
            titulo: titulo,
            imageUrl: downloadUrl.absoluteString,
            fechaExpiracion: Timestamp(date: fechaExpiracion)
        )
        
        let collection = FirestoreCollection.actividades(pueblo: "Figueruelas")
        try db.collection(collection.path).document().setData(from: nuevaActividad)
    }
    func actualizarResultadosPartidos(partidos: [Partido]) async throws {
        let batch = db.batch()
        let collection = FirestoreCollection.partidos(pueblo: "Figueruelas")
        
        print("MANAGER: Creando una operación por lotes (batch write).")
        
        for partido in partidos {
            guard let partidoId = partido.id else {
                print("MANAGER AVISO: Se ha omitido un partido porque no tiene ID.")
                continue
            }
            let docRef = db.collection(collection.path).document(partidoId)
            print("  - MANAGER: Añadiendo al lote -> Documento '\(partidoId)' actualizar resultado a '\(partido.resultado)'")
            batch.updateData(["resultado": partido.resultado], forDocument: docRef)
        }
        
        print("MANAGER: Enviando el lote de actualizaciones a Firebase...")
        try await batch.commit()
        print("MANAGER: El lote se ha completado en Firebase con éxito.")
    }
    func borrarDocumentos(ids: [String], en coleccion: FirestoreCollection) async throws {
        guard !ids.isEmpty else { return } // No hace nada si no hay IDs
        
        let batch = db.batch()
        let collectionPath = coleccion.path
        
        for id in ids {
            let docRef = db.collection(collectionPath).document(id)
            batch.deleteDocument(docRef)
        }
        
        try await batch.commit()
    }
}
