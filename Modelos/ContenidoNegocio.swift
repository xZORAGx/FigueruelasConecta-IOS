import Foundation
import FirebaseFirestore


struct ContenidoNegocio: Identifiable, Codable {
    @DocumentID var id: String?
    
    var titulo: String
    var descripcion: String
    var imagenUrl: String?
    
    // ✅ LÍNEA MODIFICADA: Cambiamos Timestamp? por Double?
    // Esto aceptará el número largo de milisegundos.
    var timestamp: Double?
    
    var nombreNegocio: String
    var logoNegocioUrl: String?
}
