import SwiftUI

struct AutobusesListView: View {
    @EnvironmentObject var viewModel: HorariosViewModel
    
    // 1. Añadimos la misma propiedad calculada que en la vista anterior.
    // Esta vez, apunta a la función de eliminar autobuses.
    private var deleteAction: ((IndexSet) -> Void)? {
        guard viewModel.esAdmin else { return nil }
        return viewModel.eliminarAutobus
    }
    
    var body: some View {
        VStack {
            Picker("Filtrar por", selection: $viewModel.filtroBus.animation()) {
                ForEach(HorariosViewModel.FiltroBus.allCases, id: \.self) { filtro in
                    Text(filtro.rawValue)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            
            List {
                ForEach(viewModel.autobusesFiltrados) { autobus in
                    AutobusRowView(autobus: autobus)
                }
                // 2. Usamos la nueva propiedad, que es más limpia.
                .onDelete(perform: deleteAction)
            }
            .listStyle(PlainListStyle())
        }
        .transition(.opacity.animation(.easeInOut))
    }
}
