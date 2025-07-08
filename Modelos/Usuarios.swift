import Foundation
import FirebaseFirestore

struct Usuario: Identifiable, Codable, Hashable {
    // Esto le dice a Firebase que ponga aquí el ID del documento automáticamente.
    @DocumentID var id: String?
    
    var usuario: String
    var correo: String
    var tipo: String
    var pueblo: String
    var negocioId: String?
    
    // Al NO incluir "id" aquí, dejamos que @DocumentID haga su trabajo.
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

    var esAdmin: Bool {
           return self.tipo.lowercased() == "admin"
       }
}
