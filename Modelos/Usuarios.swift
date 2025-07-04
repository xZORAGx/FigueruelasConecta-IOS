import Foundation
import FirebaseFirestore

// ✅ AÑADIDO: Hashable
struct Usuario: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    
    var usuario: String
    var correo: String
    var tipo: String
    var pueblo: String
    var negocioId: String?
    
    enum CodingKeys: String, CodingKey {
        case usuario = "Usuario"
        case correo = "Correo"
        case tipo = "Tipo"
        case pueblo = "Pueblo"
        case negocioId
    }
    
    var nombre: String {
        return self.usuario
    }
}
