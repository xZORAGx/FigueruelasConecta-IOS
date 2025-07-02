import Foundation
import FirebaseFirestore // Necesaria para el getDocument(as:)

@MainActor
class DetallesUsuarioViewModel: ObservableObject {
    @Published var usuario: Usuario?
    @Published var isLoading = true
    @Published var errorMessage: String?

    // Carga los datos de un usuario específico
    func fetchUsuario(conId id: String) async {
        guard !id.isEmpty else { return }
        self.isLoading = true
        self.errorMessage = nil
        
        let pueblo = "Figueruelas"
        let docRef = Firestore.firestore().collection(FirestoreCollection.usuarios(pueblo: pueblo).path).document(id)
        
        do {
            self.usuario = try await docRef.getDocument(as: Usuario.self)
        } catch {
            self.errorMessage = "Error al cargar el usuario: \(error.localizedDescription)"
        }
        self.isLoading = false
    }

    // Cambia el tipo de usuario
    func cambiarTipo() async {
        guard let usuario = usuario, let id = usuario.id else { return }
        
        let nuevoTipo = usuario.tipo == "Admin" ? "User" : "Admin"
        let data: [String: Any] = ["Tipo": nuevoTipo]
        
        do {
            try await FirestoreManager.shared.updateDocument(in: .usuarios(pueblo: "Figueruelas"), withId: id, data: data)
            // ESTA LÍNEA ES LA MAGIA: Vuelve a cargar los datos tras el cambio
            await self.fetchUsuario(conId: id)
        } catch {
            self.errorMessage = "Error al actualizar: \(error.localizedDescription)"
        }
    }

    // Elimina el usuario
    func eliminarUsuario() async throws {
        guard let id = usuario?.id else { return }
        try await FirestoreManager.shared.deleteDocument(in: .usuarios(pueblo: "Figueruelas"), withId: id)
    }
}
