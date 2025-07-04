import SwiftUI

struct AppTabView: View {
    // El bloque init para dar estilo a la TabBar no cambia.
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.black
        let itemAppearance = UITabBarItemAppearance()
        itemAppearance.normal.iconColor = UIColor.white.withAlphaComponent(0.6)
        itemAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white.withAlphaComponent(0.6)]
        itemAppearance.selected.iconColor = UIColor.white
        itemAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.stackedLayoutAppearance = itemAppearance
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        TabView {
            
            // Pestaña 1: Inicio
            NavigationStack {
                MenuPrincipalView()
                    .standardToolbar()
            }
            .tabItem {
                Label("Inicio", systemImage: "house.fill")
            }
            
            // Pestaña 2: Tiempo
            NavigationStack {
                TiempoView()
                    .standardToolbar()
            }
            .tabItem {
                Label("Tiempo", systemImage: "sun.max.fill")
            }

            // Pestaña 3: Comercio
            NavigationStack {
                NegociosView()
                    // No hace falta el .standardToolbar() aquí si ya está en NegociosView
            }
            .tabItem {
                Label("Comercio", systemImage: "cart.fill")
            }
            
            // Pestaña 4: Teléfonos
            NavigationStack {
                TelefonosView()
                    .standardToolbar()
            }
            .tabItem {
                Label("Teléfonos", systemImage: "phone.fill")
            }

            // Pestaña 5: Mi Cuenta
            NavigationStack {
                MiCuentaView()
                    .standardToolbar()
            }
            .tabItem {
                Label("Mi Cuenta", systemImage: "person.fill")
            }
        }
        // ✅ LÍNEA CORREGIDA: Cambiamos el color a azul.
        .tint(.blue)
    }
}
