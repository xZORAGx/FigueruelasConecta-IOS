import Foundation

@MainActor
class NegociosViewModel: ObservableObject {
    
    enum SelectedTab {
        case novedades, todos
    }
    
    @Published var selectedTab: SelectedTab = .novedades
    
    @Published var novedadesVM = NovedadesViewModel()
    @Published var listaNegociosVM = ListaNegociosViewModel()
    
    @Published var puedeCrearYBorrar: Bool = false
    @Published var negocioIdDelUsuario: String?
    
    private let authManager = AuthManager.shared

    init() {
        Task {
            await verificarRolUsuario()
        }
    }
    
    func verificarRolUsuario() async {
        // ✅ DEPURACIÓN: 1. Comprobamos si la función se ejecuta
        print("🕵️‍♂️ Verificando roles de usuario...")
        
        guard let firebaseUser = authManager.getCurrentUser() else {
            self.puedeCrearYBorrar = false
            self.negocioIdDelUsuario = nil
            return
        }
        
        do {
            let usuario = try await authManager.fetchCurrentUserFromFirestore()
            
            // ✅ DEPURACIÓN: 2. Mostramos la información que hemos obtenido
            print("✅ Usuario encontrado: \(usuario.correo), Tipo: \(usuario.tipo)")
            print("   > ID de Negocio asociado: \(usuario.negocioId ?? "Ninguno")")
            
            self.puedeCrearYBorrar = (usuario.tipo == "Programador")
            self.negocioIdDelUsuario = usuario.negocioId
            
        } catch {
            // ✅ DEPURACIÓN: 3. Vemos si ha ocurrido un error
            print("❌ Error al verificar el rol del usuario: \(error.localizedDescription)")
            self.puedeCrearYBorrar = false
            self.negocioIdDelUsuario = nil
        }
    }
}
