import SwiftUI

struct HorariosView: View {
    @StateObject private var viewModel = HorariosViewModel()
    
    @State private var mostrandoCrearInstalacion = false
    @State private var mostrandoCrearAutobus = false
    
    var body: some View {
        // ❌ ELIMINAMOS LA NavigationView DE AQUÍ
        
        VStack(spacing: 0) {
            Picker("Selecciona una opción", selection: $viewModel.seleccionDeVista) {
                ForEach(HorariosViewModel.VistaSeleccionada.allCases, id: \.self) { vista in
                    Text(vista.rawValue).tag(vista)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            ZStack {
                if viewModel.isLoading {
                    ProgressView("Cargando...")
                } else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                } else {
                    switch viewModel.seleccionDeVista {
                    case .instalaciones:
                        InstalacionesListView()
                    case .autobuses:
                        AutobusesListView()
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .navigationTitle("Horarios y Servicios")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if viewModel.esAdmin {
                    Button(action: {
                        switch viewModel.seleccionDeVista {
                        case .instalaciones:
                            mostrandoCrearInstalacion = true
                        case .autobuses:
                            mostrandoCrearAutobus = true
                        }
                    }) {
                        Image(systemName: "plus")
                    }
                    .tint(.blue) // <-- Añadimos el tint aquí para asegurar el color del '+'
                }
            }
        }
        .sheet(isPresented: $mostrandoCrearInstalacion, onDismiss: {
            Task { await viewModel.cargarDatosIniciales() }
        }) {
            CrearInstalacionView()
        }
        .sheet(isPresented: $mostrandoCrearAutobus, onDismiss: {
            Task { await viewModel.cargarDatosIniciales() }
        }) {
            CrearAutobusView()
        }
        .environmentObject(viewModel)
        // El .accentColor o .tint principal lo debe tener la NavigationView
        // de la pantalla "Servicios" para que se propague a esta y a la de detalle.
    }
}

// ... La preview puede necesitar una NavigationView para verse bien ...
struct HorariosView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HorariosView()
        }
        .environmentObject(HorariosViewModel())
    }
}
