import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    // Inicializamos nuestro AuthManager para que empiece a escuchar el estado.
    _ = AuthManager.shared
    return true
  }
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        
        // Leemos el tipo de pantalla a abrir desde los datos de la notificación.
        // Asegúrate de que tu Cloud Function envíe "tipo" en vez de "screen_to_open"
        // o ajusta la clave aquí a "screen_to_open". Usaré "tipo" por consistencia.
        if let screenTypeString = userInfo["tipo"] as? String {
            
            // Convertimos el string a nuestro enum para mayor seguridad.
            if let destination = ScreenDestination(rawValue: screenTypeString) {
                print("Notificación pulsada. Navegando a: \(destination.rawValue)")
                
                // Le decimos a nuestro gestor de navegación cuál es el nuevo destino.
                NavigationManager.shared.destination = destination
            }
        }
        
        completionHandler()
    }
}
