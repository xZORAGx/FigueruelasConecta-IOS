import Foundation
import FirebaseFirestore

// CAMBIO: Añadimos 'Equatable' a la lista de protocolos.
struct Usuario: Identifiable, Codable, Hashable, Equatable {
    @DocumentID var id: String?
    var usuario: String
    var correo: String
    var tipo: String
    var pueblo: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case usuario = "Usuario"
        case correo = "Correo"
        case tipo = "Tipo"
        case pueblo = "Pueblo"
    }
}
