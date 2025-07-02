import Foundation
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn

// Este enum ahora solo representa el estado de Firebase Auth, no nuestro perfil.
enum EstadoAutenticacion: Equatable {
    case indeterminado
    case noAutenticado
    case autenticado(User)
}

@MainActor
class AuthManager: ObservableObject {
    
    @Published var estadoAutenticacion: EstadoAutenticacion = .indeterminado
    
    // Esta es la nueva "fuente de la verdad" para la UI de la app.
    @Published var usuario: Usuario?
    
    // --- PROPIEDAD AÑADIDA ---
    // Devuelve el email del usuario logueado o nil si no hay nadie.
    var currentUserEmail: String? {
        return auth.currentUser?.email
    }
    
    static let shared = AuthManager()
    
    private let auth = Auth.auth()
    private let db = Firestore.firestore()
    private var authStateHandle: AuthStateDidChangeListenerHandle?
    private let pueblo = "Figueruelas"
    
    private init() {
        escucharEstadoAutenticacion()
    }
    
    func escucharEstadoAutenticacion() {
        if authStateHandle == nil {
            authStateHandle = auth.addStateDidChangeListener { [weak self] _, user in
                guard let self = self else { return }
                
                Task {
                    let firebaseUser = user
                    self.estadoAutenticacion = firebaseUser != nil ? .autenticado(firebaseUser!) : .noAutenticado
                    
                    if let firebaseUser = firebaseUser {
                        // Si hay un usuario de Firebase, cargamos su perfil de Firestore.
                        await self.fetchUserProfile(for: firebaseUser)
                        self.guardarSesionLocalmente()
                    } else {
                        // Si no hay usuario, nos aseguramos de que nuestro perfil local sea nulo.
                        self.usuario = nil
                        self.limpiarSesionLocalmente()
                    }
                }
            }
        }
    }
    
    private func fetchUserProfile(for user: User) async {
        let userDocRef = db.collection("pueblos").document(pueblo).collection("Usuarios").document(user.uid)
        do {
            self.usuario = try await userDocRef.getDocument(as: Usuario.self)
        } catch {
            // No cerramos sesión para evitar la condición de carrera durante el registro.
            self.usuario = nil
            print("No se encontró el perfil para el usuario \(user.uid). Esto es normal durante un nuevo registro.")
        }
    }
    
    // MARK: - Core Auth Functions
    
    func iniciarSesion(email: String, password: String) async throws {
        let authResult = try await auth.signIn(withEmail: email, password: password)
        await fetchUserProfile(for: authResult.user)
    }

    func registrarUsuario(email: String, password: String) async throws {
        let result = try await auth.createUser(withEmail: email, password: password)
        try await chequearUsuarioEnFirestoreYCrearSiNoExiste(user: result.user)
        await fetchUserProfile(for: result.user)
    }
    
    func iniciarSesionGoogle() async throws {
        guard let topVC = await UIApplication.shared.topViewController() else { throw URLError(.cannotFindHost) }
        let gidUser = try await GIDSignIn.sharedInstance.signIn(withPresenting: topVC)
        guard let idToken = gidUser.user.idToken?.tokenString else { throw URLError(.badServerResponse) }
        
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: gidUser.user.accessToken.tokenString)
        let result = try await auth.signIn(with: credential)
        try await chequearUsuarioEnFirestoreYCrearSiNoExiste(user: result.user)
        await fetchUserProfile(for: result.user)
    }

    func cerrarSesion() {
        do {
            try auth.signOut()
            GIDSignIn.sharedInstance.signOut()
        } catch let signOutError as NSError {
            print("Error cerrando sesión: %@", signOutError)
        }
    }

    private func chequearUsuarioEnFirestoreYCrearSiNoExiste(user: User) async throws {
        let userDocRef = db.collection("pueblos").document(pueblo).collection("Usuarios").document(user.uid)
        let document = try await userDocRef.getDocument()
        if !document.exists {
            let datosUsuario: [String: Any] = [
                "Usuario": user.displayName ?? "Usuario Desconocido",
                "Correo": user.email ?? "", "Tipo": "User", "Pueblo": self.pueblo
            ]
            try await userDocRef.setData(datosUsuario)
        }
    }
    
    private func guardarSesionLocalmente() { UserDefaults.standard.set(true, forKey: "sesionActiva") }
    private func limpiarSesionLocalmente() { UserDefaults.standard.removeObject(forKey: "sesionActiva") }
    func restablecerContrasena(email: String) async throws { try await auth.sendPasswordReset(withEmail: email) }
}


extension UIApplication {
    @MainActor
    func topViewController(base: UIViewController? = nil) -> UIViewController? {
        let base = base ?? connectedScenes.filter { $0.activationState == .foregroundActive }.compactMap { $0 as? UIWindowScene }.first?.windows.filter { $0.isKeyWindow }.first?.rootViewController
        if let nav = base as? UINavigationController { return topViewController(base: nav.visibleViewController) }
        if let tab = base as? UITabBarController, let selected = tab.selectedViewController { return topViewController(base: selected) }
        if let presented = base?.presentedViewController { return topViewController(base: presented) }
        return base
    }
}
