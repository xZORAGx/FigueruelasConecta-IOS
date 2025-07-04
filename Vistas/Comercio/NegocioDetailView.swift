import SwiftUI

struct NegocioDetailView: View {
    @StateObject private var viewModel: NegocioDetailViewModel

    init(negocio: Negocio) {
        _viewModel = StateObject(wrappedValue: NegocioDetailViewModel(negocio: negocio))
    }

    var body: some View {
        ScrollView {
            // ✅ El 'if let error' se ha quitado de aquí
            if viewModel.isLoading {
                ProgressView()
            } else {
                LazyVStack(spacing: 16) {
                    if viewModel.contenido.isEmpty {
                        Text("Este negocio aún no ha publicado nada.")
                            .foregroundColor(.secondary)
                            .padding(.top, 50)
                    } else {
                        ForEach(viewModel.contenido) { item in
                            NavigationLink(destination: ContenidoDetailView(contenido: item)) {
                                NovedadRowView(novedad: item)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle(viewModel.negocio.titulo)
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.fetchContenido() }
        // ✅ Usa isPresented y muestra el errorMessage directamente
        .alert(isPresented: $viewModel.showAlert) {
            Alert(
                title: Text("Error"),
                message: Text(viewModel.errorMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}
