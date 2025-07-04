import Foundation
import UIKit

@MainActor
class CrearNegocioViewModel: ObservableObject {
    @Published var nombreNegocio = ""
    @Published var logo: UIImage?
    
    // Propiedades para la búsqueda
    @Published var searchTerm = ""
    @Published var usuariosFiltrados: [Usuario] = []
    @Published private var todosLosUsuarios: [Usuario] = []
    
    @Published var usuarioSeleccionado: Usuario?
    
    @Published var isLoading = false
    @Published var showAlert = false
    @Published var errorMessage = ""
    
    init() {
        Task {
            await fetchUsers()
        }
    }
    
    func fetchUsers() async {
        do {
            todosLosUsuarios = try await FirestoreManager.shared.fetchAllUsers()
            // Al principio, la lista filtrada es la lista completa
            usuariosFiltrados = todosLosUsuarios
        } catch {
            self.errorMessage = "Error al cargar la lista de usuarios."
            self.showAlert = true
        }
    }
    
    // Función que se llama cada vez que el texto de búsqueda cambia
    func filterUsers() {
        if searchTerm.isEmpty {
            usuariosFiltrados = todosLosUsuarios
        } else {
            usuariosFiltrados = todosLosUsuarios.filter {
                $0.nombre.localizedCaseInsensitiveContains(searchTerm) ||
                $0.correo.localizedCaseInsensitiveContains(searchTerm)
            }
        }
    }
    
    func crearNegocio() async -> Bool {
        guard !nombreNegocio.isEmpty else {
            errorMessage = "El nombre del negocio es obligatorio."; showAlert = true; return false
        }
        guard let logo = logo else {
            errorMessage = "Debes seleccionar un logo."; showAlert = true; return false
        }
        guard let usuarioSeleccionado = usuarioSeleccionado, let userId = usuarioSeleccionado.id else {
            errorMessage = "Debes seleccionar un usuario como dueño."; showAlert = true; return false
        }
        
        isLoading = true
        
        do {
            let urlLogo = try await StorageManager.shared.uploadBusinessImage(image: logo, folder: "logosNegocios")
            let nuevoNegocio = Negocio(titulo: nombreNegocio, logoUrl: urlLogo.absoluteString, adminUID: userId)
            try await FirestoreManager.shared.createBusiness(newBusinessData: nuevoNegocio, for: userId)
            isLoading = false
            return true
        } catch {
            self.errorMessage = "Error al crear el negocio: \(error.localizedDescription)"
            self.showAlert = true
            self.isLoading = false
            return false
        }
    }
}
