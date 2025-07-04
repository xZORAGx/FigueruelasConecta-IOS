import SwiftUI

struct NovedadesListView: View {
    @StateObject var viewModel: NovedadesViewModel

    var body: some View {
        ScrollView {
            if viewModel.isLoading {
                ProgressView().padding()
            } else {
                LazyVStack(spacing: 16) {
                    ForEach(viewModel.novedades) { novedad in
                        NavigationLink(destination: ContenidoDetailView(contenido: novedad)) {
                            NovedadRowView(novedad: novedad)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
        }
        .task { await viewModel.fetchNovedades() }
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
