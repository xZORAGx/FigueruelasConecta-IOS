import SwiftUI

struct InstalacionesListView: View {
    @EnvironmentObject var viewModel: HorariosViewModel

    // ✅ PASO 1: Creamos una propiedad calculada para la acción de eliminar.
    // Esta propiedad devuelve la función de eliminar si es admin, o nil si no lo es.
    private var deleteAction: ((IndexSet) -> Void)? {
        // Si no es admin, devolvemos nil para desactivar la función de eliminar.
        guard viewModel.esAdmin else { return nil }
        // Si es admin, devolvemos la función del ViewModel.
        return viewModel.eliminarInstalacion
    }

    var body: some View {
        List {
            ForEach(viewModel.instalaciones) { instalacion in
                InstalacionRowView(instalacion: instalacion)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            }
            // ✅ PASO 2: Usamos nuestra nueva propiedad, que es más simple para el compilador.
            .onDelete(perform: deleteAction)
        }
        .listStyle(PlainListStyle())
        .transition(.opacity.animation(.easeInOut))
    }
}
