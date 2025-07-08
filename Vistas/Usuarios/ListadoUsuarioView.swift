import SwiftUI

struct ListadoUsuariosView: View {
    
    @StateObject private var viewModel = UsuariosViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                if let errorMessage = viewModel.errorMensaje {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
                
                List(viewModel.usuariosFiltrados) { usuario in
                    NavigationLink(destination: DetallesUsuarioView(usuarioId: usuario.id ?? "")) {
                        UsuarioRowView(usuario: usuario)                     }
                }
                .listStyle(PlainListStyle())
                .navigationTitle("Usuarios")
                // --- TEXTO DEL BUSCADOR ACTUALIZADO ---
                .searchable(text: $viewModel.filtroBusqueda, prompt: "Buscar por nombre o correo")
            }
        }
    }
}
