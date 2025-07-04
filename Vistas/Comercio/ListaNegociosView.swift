import SwiftUI

struct ListaNegociosView: View {
    @StateObject var viewModel: ListaNegociosViewModel
    // ✅ Propiedad actualizada para reflejar el permiso correcto
    let puedeBorrar: Bool

    var body: some View {
        List {
            if viewModel.isLoading {
                ProgressView()
            } else {
                ForEach($viewModel.negocios) { $negocio in
                    // Lógica para separar la navegación de la selección
                    if viewModel.isSelectionActive {
                        // Si estamos en modo borrado, la fila solo selecciona
                        NegocioRowView(
                            negocio: negocio,
                            isSelectionActive: viewModel.isSelectionActive,
                            isSelected: viewModel.selectedBusinessIDs.contains(negocio.id ?? "")
                        )
                        .onTapGesture {
                            viewModel.toggleSelection(for: negocio.id ?? "")
                        }
                    } else {
                        // Si NO estamos en modo borrado, la fila navega
                        NavigationLink(destination: NegocioDetailView(negocio: negocio)) {
                            NegocioRowView(
                                negocio: negocio,
                                isSelectionActive: viewModel.isSelectionActive,
                                isSelected: false
                            )
                        }
                    }
                }
            }
        }
        .listStyle(.plain)
        .task {
            await viewModel.fetchNegocios()
        }
        .toolbar {
            // ✅ Condición del toolbar actualizada
            if puedeBorrar && viewModel.isSelectionActive {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        viewModel.isSelectionActive = false
                        viewModel.selectedBusinessIDs.removeAll()
                    }
                }
            }
        }
        .alert(isPresented: $viewModel.showAlert) {
            Alert(
                title: Text("Error"),
                message: Text(viewModel.errorMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}
