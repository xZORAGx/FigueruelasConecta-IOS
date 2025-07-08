import Foundation
import Combine

class UsuariosViewModel: ObservableObject {
    
    @Published var usuarios = [Usuario]()
    @Published var filtroBusqueda = ""
    @Published var errorMensaje: String?

    private let firestoreManager = FirestoreManager.shared
    private var listenerCancelable: AnyCancellable?

    var usuariosFiltrados: [Usuario] {
        let textoBuscado = filtroBusqueda.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        // --- CORRECCIÓN DEL ERROR DE TIPEO ---
        if textoBuscado.isEmpty {
            return usuarios
        } else {
            return usuarios.filter { usuario in
                let nombreCoincide = usuario.nombre.lowercased().contains(textoBuscado)
                let correoCoincide = usuario.correo.lowercased().contains(textoBuscado)
                
                return nombreCoincide || correoCoincide
            }
        }
    }

    init() {
        escucharCambiosEnUsuarios()
    }

    func escucharCambiosEnUsuarios() {
        let path = "pueblos/Figueruelas/Usuarios"
        
        self.listenerCancelable = firestoreManager.listenForUsuarioChanges(path: path)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.errorMensaje = "Error al escuchar usuarios: \(error.localizedDescription)"
                }
            }, receiveValue: { [weak self] (usuariosRecibidos: [Usuario]) in
                self?.usuarios = usuariosRecibidos.sorted { $0.nombre.lowercased() < $1.nombre.lowercased() }
                self?.errorMensaje = nil
            })
    }

    deinit {
        listenerCancelable?.cancel()
    }
}

