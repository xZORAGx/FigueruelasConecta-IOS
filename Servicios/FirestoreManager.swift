import Foundation
import FirebaseFirestore


class FirestoreManager {
    
    // Suponemos que ya tienes una instancia compartida (singleton)
    static let shared = FirestoreManager()
    private let db = Firestore.firestore()
    
    private init() {} // Constructor privado para el singleton
    
    // --- NUEVA FUNCIÓN ---
    // Esta función obtiene los documentos de la colección de noticias.
    // Es 'async' porque la llamada a la red no es instantánea.
    // Lanza ('throws') errores si algo va mal (p.ej. sin conexión).
    func fetchNoticias() async throws -> [Noticia] {
        let pueblo = "Figueruelas" // Podríamos hacerlo dinámico en el futuro
        let collectionPath = "pueblos/\(pueblo)/Noticias"
        
        // Obtenemos los documentos de la colección, ordenados por fecha de creación descendente.
        let querySnapshot = try await db.collection(collectionPath)
                                         .order(by: "timestamp", descending: true)
                                         .getDocuments()
        
        // Mapeamos los documentos a nuestro modelo 'Noticia' usando 'compactMap'.
        // 'compactMap' es genial porque si un documento no se puede decodificar,
        // simplemente lo ignora en lugar de crashear la app.
        let noticias = querySnapshot.documents.compactMap { document -> Noticia? in
            do {
                return try document.data(as: Noticia.self)
            } catch {
                print("Error decodificando la noticia con ID \(document.documentID): \(error)")
                return nil
            }
        }
        
        return noticias
    }

    // Aquí irían otras funciones para fetchEmpleos, fetchActividades, etc.
}
