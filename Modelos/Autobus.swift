import Foundation
import FirebaseFirestore

struct Autobus: Identifiable, Codable {
    @DocumentID var id: String?
    let nombreLinea: String
    let direccion: String
    let horarios: String
    // ✅ CORRECCIÓN: Cambiamos Date por Int64.
    let timestamp: Int64
    
    // Enum para facilitar la lógica del filtro en la vista
    enum DireccionBus: String {
        case ida = "Figueruelas → Zaragoza"
        case vuelta = "Zaragoza → Figueruelas"
        case desconocida = "No especificada"
    }

    var tipoDireccion: DireccionBus {
        if direccion.lowercased().contains("zaragoza") && direccion.lowercased().contains("figueruelas") {
            if let range = direccion.range(of: "→") {
                let origen = direccion[..<range.lowerBound].trimmingCharacters(in: .whitespaces)
                if origen.lowercased() == "figueruelas" {
                    return .ida
                } else {
                    return .vuelta
                }
            }
            return .desconocida
        } else if direccion.lowercased().contains("zaragoza") {
            return .ida
        } else if direccion.lowercased().contains("figueruelas") {
            return .vuelta
        }
        return .desconocida
    }
}
