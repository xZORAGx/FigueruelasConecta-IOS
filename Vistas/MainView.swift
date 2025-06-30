import SwiftUI

struct MainView: View {
    
    @StateObject private var authManager = AuthManager.shared

    var body: some View {
        // Usamos un switch para manejar los 3 estados principales
        switch authManager.estadoAutenticacion {
            
        case .autenticado:
            // El usuario está autenticado en Firebase.
            // Ahora comprobamos si ya tenemos su perfil de Firestore.
            if authManager.usuario != nil {
                // Si SÍ tenemos el perfil, mostramos la app.
                AppTabView()
                    .environmentObject(authManager)
            } else {
                // Si NO tenemos el perfil todavía, es que se está cargando.
                // Mostramos la pantalla de carga en este breve instante.
                LoadingView()
            }
            
        case .noAutenticado:
            // El usuario no tiene una sesión activa.
            LoginView()
            
        case .indeterminado:
            // La app acaba de arrancar y no sabe si hay sesión o no.
            // Mostramos la pantalla de carga mientras lo averigua.
            LoadingView()
        }
    }
}

#Preview {
    MainView()
}
