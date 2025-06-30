import SwiftUI

struct StandardToolbarModifier: ViewModifier {
    
    @EnvironmentObject var authManager: AuthManager
    
    @State private var mostrarListadoUsuarios = false
    @State private var mostrarListadoIncidencias = false

    func body(content: Content) -> some View {
        content
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack {
                        Image("escudofigueruelas").resizable().scaledToFit().frame(height: 32)
                        Text("Figueruelas Conecta").font(.headline)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        // CAMBIO: La comprobación de admin ahora es más simple y directa
                        if let usuario = authManager.usuario, usuario.tipo == "Admin" {
                            Section(header: Text("Panel de Administrador")) {
                                Button(action: { mostrarListadoUsuarios.toggle() }) {
                                    Label("Listado Usuarios", systemImage: "person.3.fill")
                                }
                                Button(action: { mostrarListadoIncidencias.toggle() }) {
                                    Label("Listado Incidencias", systemImage: "exclamationmark.bubble.fill")
                                }
                            }
                            Divider()
                        }
                        
                        Button(role: .destructive, action: { authManager.cerrarSesion() }) {
                            Label("Cerrar Sesión", systemImage: "rectangle.portrait.and.arrow.right")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle.fill").imageScale(.large)
                    }
                }
            }
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color.black, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .sheet(isPresented: $mostrarListadoUsuarios) { ListadoUsuariosView() }
            .sheet(isPresented: $mostrarListadoIncidencias) { ListadoIncidenciasView() }
    }
}

extension View {
    func standardToolbar() -> some View {
        self.modifier(StandardToolbarModifier())
    }
}
