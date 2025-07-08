// 📂 Vistas (Views)
// └── MenuPrincipalView.swift

import SwiftUI

struct MenuPrincipalView: View {
    
    // --- CORRECCIÓN AQUÍ ---
    // Reducimos los @State a solo las secciones con notificaciones.
    @State private var irANoticias: Bool = false
    @State private var irAEmpleo: Bool = false
    @State private var irACelebraciones: Bool = false
    @State private var irAActividades: Bool = false

    // Propiedades de tu vista (sin cambios)
    let columns: [GridItem] = [GridItem(.flexible()), GridItem(.flexible())]
    
    let menuItems: [MenuItem] = [
        MenuItem(title: "Noticias", imageName: "botonnoticias", destination: AnyView(NoticiasView())),
        MenuItem(title: "Deportes", imageName: "botondeportes", destination: AnyView(DeportesView())),
        MenuItem(title: "Servicios", imageName: "servicios", destination: AnyView(HorariosView())),
        MenuItem(title: "Fiestas", imageName: "botonfiestas", destination: AnyView(CelebracionesView())),
        MenuItem(title: "Empleo", imageName: "botonempleo", destination: AnyView(EmpleoView())),
        MenuItem(title: "Incidencias", imageName: "botonincidencias", destination: AnyView(CrearIncidenciaView()))
    ]

    var body: some View {
        ZStack {
            Image("fondopantallaprincipal")
                .resizable().scaledToFill().edgesIgnoringSafeArea(.all).blur(radius: 3)
            Color.black.opacity(0.2).edgesIgnoringSafeArea(.all)

            VStack {
                // --- CORRECCIÓN AQUÍ ---
                // Reducimos los NavigationLink invisibles a solo los necesarios.
                NavigationLink(destination: NoticiasView().standardToolbar().navigationTitle("Noticias"), isActive: $irANoticias) { EmptyView() }
                NavigationLink(destination: EmpleoView().standardToolbar().navigationTitle("Empleo"), isActive: $irAEmpleo) { EmptyView() }
                NavigationLink(destination: CelebracionesView().standardToolbar().navigationTitle("Fiestas"), isActive: $irACelebraciones) { EmptyView() }
                NavigationLink(destination: DeportesView().standardToolbar().navigationTitle("Deportes"), isActive: $irAActividades) { EmptyView() }
                
                Spacer()
                
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(menuItems) { item in
                        NavigationLink(destination: item.destination
                            .standardToolbar()
                            .navigationTitle(item.title)
                        ) {
                            MenuButtonView(item: item)
                                .padding(5)
                        }
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, 30)
        }
        .onReceive(NavigationManager.shared.$destination) { destination in
            guard let destination = destination else { return }
            
            // --- CORRECCIÓN AQUÍ ---
            // El switch ahora es más simple y no incluye el caso de 'incidencias'.
            switch destination {
            case .noticias:
                self.irANoticias = true
            case .empleo:
                self.irAEmpleo = true
            case .celebraciones:
                self.irACelebraciones = true
            case .actividades:
                self.irAActividades = true
            }
            
            NavigationManager.shared.destination = nil
        }
    }
}

// La preview no cambia
#Preview {
    AppTabView()
        .environmentObject(AuthManager.shared)
}
