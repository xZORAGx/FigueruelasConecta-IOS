import Foundation

@MainActor // Importante: asegura que los cambios de UI se hagan en el hilo principal
class ListadoUsuariosViewModel: ObservableObject {
    
    @Published var usuarios = [Usuario]()
    @Published var searchText = ""
    @Published var isLoading = true
    @Published var errorMessage: String?
    
    private var task: Task<Void, Never>? = nil

    var usuariosFiltrados: [Usuario] {
        if searchText.isEmpty { return usuarios }
        return usuarios.filter { $0.correo.lowercased().contains(searchText.lowercased()) }
    }
    
    init() {
        // Inicia la escucha de usuarios
        listenForUserChanges()
    }
    
    func listenForUserChanges() {
        task?.cancel() // Cancela cualquier escucha anterior
        
        task = Task {
            self.isLoading = true
            self.errorMessage = nil
            do {
                let stream = FirestoreManager.shared.listenForUsers()
                for try await usuariosRecibidos in stream {
                    self.usuarios = usuariosRecibidos
                    self.isLoading = false
                }
            } catch {
                self.errorMessage = "Error: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    
    deinit {
        // Asegura que la tarea se cancele cuando el objeto se destruya
        task?.cancel()
    }
}
