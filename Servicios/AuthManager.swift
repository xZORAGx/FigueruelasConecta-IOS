import Foundation
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn
import Combine

// Este enum ahora solo representa el estado de Firebase Auth, no nuestro perfil.
enum EstadoAutenticacion: Equatable {
    case indeterminado
    case noAutenticado
    case autenticado(User)
}

@MainActor
class AuthManager: ObservableObject {
    
    @Published var estadoAutenticacion: EstadoAutenticacion = .indeterminado
    @Published var usuario: Usuario?
    
    // La propiedad que nuestras vistas de módulos observarán.
    @Published var esAdmin: Bool = false
    
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
    
    
    // ===================================================================
    // FUNCIÓN INDEPENDIENTE PARA PERMISOS
    // ===================================================================
    /// Comprueba los permisos del usuario actual para módulos específicos (como Instalaciones).
    /// Esta función es independiente del flujo de login principal.
    func verificarPermisosParaModulos() {
        // 1. Asegurarnos de que hay un usuario logueado en Firebase.
        guard let currentUser = auth.currentUser else {
            // Si no hay nadie logueado, nos aseguramos de que no sea admin.
            self.esAdmin = false
            return
        }
        
        // 2. Realizamos la consulta a Firestore para obtener el perfil del usuario.
        let userDocRef = db.collection("pueblos").document(pueblo).collection("Usuarios").document(currentUser.uid)
        
        userDocRef.getDocument { (document, error) in
            // 3. Comprobamos si el documento existe y si el campo "Tipo" es "Admin" o "Programador".
            if let document = document, document.exists {
                let tipoUsuario = document.data()?["Tipo"] as? String ?? "User"
                // Hacemos la comprobación más robusta
                self.esAdmin = (tipoUsuario.lowercased() == "admin" || tipoUsuario.lowercased() == "programador")
            } else {
                // Si el documento no existe o hay un error, no es admin.
                self.esAdmin = false
                if let error = error {
                    print("Error al verificar permisos de módulo: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // --- TU CÓDIGO ORIGINAL (SIN MODIFICACIONES) ---
    
    func escucharEstadoAutenticacion() {
        if authStateHandle == nil {
            authStateHandle = auth.addStateDidChangeListener { [weak self] _, user in
                guard let self = self else { return }
                
                Task {
                    let firebaseUser = user
                    self.estadoAutenticacion = firebaseUser != nil ? .autenticado(firebaseUser!) : .noAutenticado
                    
                    if let firebaseUser = firebaseUser {
                        await self.fetchUserProfile(for: firebaseUser)
                        self.guardarSesionLocalmente()
                    } else {
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
    
    
    // ===================================================================
    // ✅ NUEVAS FUNCIONES AÑADIDAS PARA EL MÓDULO DE NEGOCIOS
    // ===================================================================

    /// Devuelve el usuario de Firebase actualmente autenticado.
    /// - Returns: Un objeto `User` de Firebase Auth, o `nil` si no hay nadie logueado.
    func getCurrentUser() -> User? {
        return auth.currentUser
    }

    /// Obtiene el documento del usuario actual desde la colección "Usuarios" en Firestore.
    /// - Throws: Un error si no hay un usuario logueado o si no se encuentra el documento.
    /// - Returns: El objeto `Usuario` con los datos de la base de datos (tipo, negocioId, etc.).
    func fetchCurrentUserFromFirestore() async throws -> Usuario {
        // Primero, nos aseguramos de tener el UID del usuario logueado
        guard let uid = auth.currentUser?.uid else {
            throw NSError(domain: "AuthError", code: -1, userInfo: [NSLocalizedDescriptionKey: "No hay usuario logueado."])
        }
        
        // Obtenemos el documento del usuario de Firestore
        let document = try await db.collection("pueblos")
                                 .document(self.pueblo)
                                 .collection("Usuarios")
                                 .document(uid)
                                 .getDocument()
                                
        // Convertimos el documento al modelo `Usuario` y lo devolvemos
        let usuario = try document.data(as: Usuario.self)
        return usuario
    }
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
