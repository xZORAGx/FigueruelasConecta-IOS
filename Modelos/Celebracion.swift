import Foundation
import FirebaseFirestore

struct Celebracion: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    let titulo: String
    let mimeType: String
    let pdfUrl: String
    let storagePath: String
    
    // --- CORRECCIÓN AQUÍ ---
    // Volvemos a ponerlo como Double para que pueda leer el número de la base de datos.
    let timestamp: Double
    let fechaExpiracion: Timestamp // Este se queda como Timestamp
    
    enum CodingKeys: String, CodingKey {
        case id, titulo, mimeType, pdfUrl, storagePath, timestamp, fechaExpiracion
    }
}
