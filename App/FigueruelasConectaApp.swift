import SwiftUI

@main
struct FigueruelasConectaApp: App {
    
    // Aquí solo se hace referencia al AppDelegate, no se define.
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            MainView()
        }
    }
}
