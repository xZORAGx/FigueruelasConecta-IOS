import Foundation

@MainActor
class ListadoUsuariosViewModel: ObservableObject {
    
    @Published var usuarios = [Usuario]()
    @Published var searchText = ""
    @Published var isLoading = false
    @Published var errorMessage: String?

    var usuariosFiltrados: [Usuario] {
        if searchText.isEmpty {
            return usuarios
        }
        return usuarios.filter {
            $0.correo.lowercased().contains(searchText.lowercased()) ||
            $0.usuario.lowercased().contains(searchText.lowercased())
        }
    }
    
    // Carga los usuarios una sola vez de forma directa
    func cargarUsuarios() async {
        // No recarga si ya hay usuarios, para evitar llamadas innecesarias
        guard usuarios.isEmpty else { return }
        
        self.isLoading = true
        self.errorMessage = nil
        
        do {
            self.usuarios = try await FirestoreManager.shared.fetchAllUsers()
        } catch {
            self.errorMessage = "Error al cargar usuarios: \(error.localizedDescription)"
        }
        
        self.isLoading = false
    }
}
