import SwiftUI

struct ListadoUsuariosView: View {
    @StateObject private var viewModel = ListadoUsuariosViewModel()

    var body: some View {
        NavigationStack { // <--- El NavigationStack está aquí
            Group {
                if viewModel.isLoading {
                    ProgressView("Cargando...")
                } else if let error = viewModel.errorMessage {
                    Text(error).foregroundColor(.red).padding()
                } else {
                    List(viewModel.usuariosFiltrados) { usuario in
                        NavigationLink(destination: DetallesUsuarioView(usuarioId: usuario.id ?? "")) {
                            UsuarioRowView(usuario: usuario)
                        }
                    }
                }
            }
            .navigationTitle("Gestión de Usuarios")
            .searchable(text: $viewModel.searchText, prompt: "Buscar por correo...")
        }
        .tint(.blue) // <-- APLÍCALO AQUÍ
    }
}
