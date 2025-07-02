import Foundation
import FirebaseFirestore // Importación necesaria

@MainActor
class CelebracionesViewModel: ObservableObject {
    @Published var celebraciones: [Celebracion] = []
    @Published var seleccionados = Set<String>()
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // FirestoreManager y StorageManager no cambian
    private let firestoreManager = FirestoreManager.shared
    private let storageManager = StorageManager.shared
    
    func fetchCelebraciones() async {
        isLoading = true
        errorMessage = nil
        do {
            // --- LÍNEA CORREGIDA ---
            // Ahora llamamos a la nueva función del manager. ¡Mucho más limpio!
            self.celebraciones = try await firestoreManager.fetchCelebraciones()
            
        } catch {
            errorMessage = "Error al cargar celebraciones: \(error.localizedDescription)"
        }
        isLoading = false
    }
    
    // El resto de las funciones (toggleSeleccion, eliminarSeleccionados) no necesitan cambios.
    // ...
    func toggleSeleccion(id: String) {
        if seleccionados.contains(id) {
            seleccionados.remove(id)
        } else {
            seleccionados.insert(id)
        }
    }
    
    func eliminarSeleccionados() async {
        isLoading = true
        let idsParaBorrar = seleccionados
        
        for id in idsParaBorrar {
            guard let celebracion = celebraciones.first(where: { $0.id == id }) else { continue }
            do {
                try await storageManager.deleteImage(fromURL: celebracion.pdfUrl)
                try await firestoreManager.deleteDocument(in: .celebraciones(pueblo: "Figueruelas"), withId: id)
                celebraciones.removeAll { $0.id == id }
                seleccionados.remove(id)
            } catch {
                errorMessage = "Error al borrar '\(celebracion.titulo)': \(error.localizedDescription)"
                isLoading = false
                return
            }
        }
        isLoading = false
    }
}
