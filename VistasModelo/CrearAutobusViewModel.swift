import Foundation

@MainActor
class CrearAutobusViewModel: ObservableObject {
    @Published var nombreLinea = ""
    @Published var horarios = ""
    @Published var direccionSeleccionada: DireccionBus = .ida
    
    @Published var isSaving = false
    @Published var errorMessage: String?
    @Published var saveCompleted = false
    
    // Enum para el selector de dirección
    enum DireccionBus: String, CaseIterable {
        case ida = "Figueruelas → Zaragoza"
        case vuelta = "Zaragoza → Figueruelas"
    }

    func guardarAutobus() async {
        isSaving = true
        errorMessage = nil
        
        guard !nombreLinea.isEmpty, !horarios.isEmpty else {
            errorMessage = "Todos los campos son obligatorios."
            isSaving = false
            return
        }
        
        do {
            // ✅ CORRECCIÓN: Convertimos la fecha a un número Int64.
            let timestampNumero = Int64(Date().timeIntervalSince1970 * 1000)
            
            let nuevoAutobus = Autobus(
                nombreLinea: nombreLinea,
                direccion: direccionSeleccionada.rawValue,
                horarios: horarios,
                timestamp: timestampNumero // Usamos el número
            )
            
            try await FirestoreManager.shared.añadirDocumento(codable: nuevoAutobus, en: "Autobuses")
            
            isSaving = false
            saveCompleted = true
        } catch {
            errorMessage = "Error al guardar el horario: \(error.localizedDescription)"
            isSaving = false
        }
    }
}
