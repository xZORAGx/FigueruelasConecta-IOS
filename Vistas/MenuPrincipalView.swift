import SwiftUI

struct MenuPrincipalView: View {
    
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
        // El NavigationStack y su toolbar se aplican desde AppTabView,
        // por lo que este código está limpio.
        ZStack {
            Image("fondopantallaprincipal")
                .resizable().scaledToFill().edgesIgnoringSafeArea(.all).blur(radius: 3)
            Color.black.opacity(0.2).edgesIgnoringSafeArea(.all)

            VStack {
                Spacer()
                
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(menuItems) { item in
                        
                        // --- CAMBIO AQUÍ ---
                        // Le decimos al NavigationLink que la vista de destino
                        // TAMBIÉN debe usar nuestra barra de herramientas estándar.
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
    }
}

// La preview no cambia
#Preview {
    AppTabView()
        .environmentObject(AuthManager.shared)
}
