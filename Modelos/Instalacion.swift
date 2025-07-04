import Foundation
import FirebaseFirestore

struct Instalacion: Identifiable, Codable {
    @DocumentID var id: String?
    let titulo: String
    let descripcion: String
    let imagenUrl: String
    // ✅ CORRECCIÓN: Cambiamos Date por Int64 para que coincida con el número en Firestore.
    let timestamp: Int64
    let horarios: [String: Horario]?

    struct Horario: Codable {
        let apertura: String
        let cierre: String
    }
    
    // Propiedad de ayuda para convertir el número a una fecha real cuando la necesitemos.
    var fechaCreacion: Date {
        // El timestamp de Firebase/Android suele estar en milisegundos.
        // Lo dividimos por 1000 para convertirlo a segundos.
        return Date(timeIntervalSince1970: TimeInterval(timestamp) / 1000)
    }
}
