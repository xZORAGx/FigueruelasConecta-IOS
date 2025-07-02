import Foundation
import FirebaseFirestore


struct Instalacion: Codable, Identifiable, Hashable {
    @DocumentID var id: String?
    let titulo: String
    let descripcion: String
    let imagenUrl: String
    let horarios: [String: Horario]?
    
    // CORREGIDO: Le decimos que lea el timestamp como un Número (Double).
    let timestamp: Double
    
    // AÑADIDO: Una variable extra para convertir ese número a una Fecha normal
    // y poder usarla cómodamente en la vista si lo necesitas.
    var fechaCreacion: Date {
        // Dividimos por 1000 porque Android guarda milisegundos.
        Date(timeIntervalSince1970: timestamp / 1000)
    }

    struct Horario: Codable, Hashable {
        let apertura: String
        let cierre: String
    }
}
