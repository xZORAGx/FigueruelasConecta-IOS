import Foundation
import FirebaseFirestore
import FirebaseAuth

@MainActor
class DetallesUsuarioViewModel: ObservableObject {
    
    @Published var usuario: Usuario?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var usuarioEliminado = false

    // Carga los datos del usuario la primera vez que aparece la vista
    func fetchUsuario(conId id: String) async {
        self.isLoading = true
        self.errorMessage = nil
        guard !id.isEmpty else {
            self.errorMessage = "ID de usuario no encontrado"
            self.isLoading = false
            return
        }
        
        do {
            // ✅ --- CAMBIO CLAVE ---
            // Llamamos a la nueva función que asigna el ID manualmente
            self.usuario = try await FirestoreManager.shared.fetchUserManually(byId: id)
        } catch {
            self.errorMessage = "Error al cargar datos: \(error.localizedDescription)"
        }
        self.isLoading = false
    }
    // Cambia el rol del usuario que se le pasa como parámetro
    func cambiarTipo(usuario: Usuario) async {
        guard let id = usuario.id else {
            self.errorMessage = "El usuario no tiene un ID válido."
            return
        }
        
        let tipoActual = usuario.tipo.trimmingCharacters(in: .whitespacesAndNewlines)
        let nuevoTipo = tipoActual.lowercased() == "admin" ? "User" : "Admin"
        let data: [String: Any] = ["Tipo": nuevoTipo]
        let path = "pueblos/Figueruelas/Usuarios"
        
        do {
            try await FirestoreManager.shared.updateDocument(in: path, withId: id, data: data)
            await self.fetchUsuario(conId: id) // Recargamos para ver el cambio
        } catch {
            self.errorMessage = "Error al actualizar tipo: \(error.localizedDescription)"
        }
    }

    // Elimina el usuario que se le pasa como parámetro
    func eliminarUsuario(usuario: Usuario) async {
        guard let id = usuario.id else {
            self.errorMessage = "El usuario no tiene un ID válido."
            return
        }
        
        // Comprobación de seguridad para no eliminar al programador
        if usuario.tipo.lowercased() == "programador" {
            self.errorMessage = "No se puede eliminar al programador."
            return
        }
        
        let path = "pueblos/Figueruelas/Usuarios"
        do {
            try await FirestoreManager.shared.deleteDocument(in: path, withId: id)
            self.usuarioEliminado = true
        } catch {
            self.errorMessage = "Error al eliminar usuario: \(error.localizedDescription)"
        }
    }
}
