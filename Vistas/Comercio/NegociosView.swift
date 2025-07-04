import SwiftUI

struct NegociosView: View {
    @StateObject private var viewModel = NegociosViewModel()
    
    @State private var mostrandoGestionarSheet = false
    @State private var mostrandoCrearSheet = false

    var body: some View {
        // El NavigationStack es el contenedor principal de la navegación
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                VStack {
                    Picker("Sección", selection: $viewModel.selectedTab) {
                        Text("Novedades").tag(NegociosViewModel.SelectedTab.novedades)
                        Text("Todos").tag(NegociosViewModel.SelectedTab.todos)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)

                    switch viewModel.selectedTab {
                    case .novedades:
                        NovedadesListView(viewModel: viewModel.novedadesVM)
                    case .todos:
                        ListaNegociosView(viewModel: viewModel.listaNegociosVM, puedeBorrar: viewModel.puedeCrearYBorrar)
                    }
                }
                
                fabLayer
            }
            .navigationTitle("Negocios y Comercios")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $mostrandoGestionarSheet) {
                if let negocioId = viewModel.negocioIdDelUsuario {
                    GestionarNegocioView(negocioId: negocioId)
                }
            }
            .sheet(isPresented: $mostrandoCrearSheet) {
                CrearNegocioView()
            }
        }
        // ✅ APLICA EL MODIFICADOR AQUÍ
        // Esto forza a que todos los botones de la barra (incluido "Atrás")
        // en esta pila de navegación sean azules.
        .tint(.blue)
    }
    
    @ViewBuilder
    private var fabLayer: some View {
        // El código de los botones flotantes no necesita cambios.
        VStack(spacing: 16) {
            
            if viewModel.listaNegociosVM.isSelectionActive {
                Button(action: {
                    Task { await viewModel.listaNegociosVM.deleteSelectedBusinesses() }
                }) { Image(systemName: "trash.fill") }
                .disabled(viewModel.listaNegociosVM.selectedBusinessIDs.isEmpty)
                .buttonStyle(FABStyle(backgroundColor: viewModel.listaNegociosVM.selectedBusinessIDs.isEmpty ? .gray : .red))

                Button(action: {
                    viewModel.listaNegociosVM.isSelectionActive = false
                    viewModel.listaNegociosVM.selectedBusinessIDs.removeAll()
                }) { Image(systemName: "xmark") }
                .buttonStyle(FABStyle(backgroundColor: .orange))
            } else {
                if viewModel.puedeCrearYBorrar && viewModel.selectedTab == .todos {
                    Button(action: { mostrandoCrearSheet = true }) { Image(systemName: "plus") }
                        .buttonStyle(FABStyle(backgroundColor: .blue))
                    
                    Button(action: { viewModel.listaNegociosVM.isSelectionActive = true }) { Image(systemName: "trash") }
                        .buttonStyle(FABStyle(backgroundColor: .gray))
                }
                
                if viewModel.negocioIdDelUsuario != nil {
                    Button(action: { mostrandoGestionarSheet = true }) { Image(systemName: "square.and.pencil") }
                        .buttonStyle(FABStyle(backgroundColor: .blue))
                }
            }
        }
        .padding()
        .animation(.spring(), value: viewModel.listaNegociosVM.isSelectionActive)
    }
}
