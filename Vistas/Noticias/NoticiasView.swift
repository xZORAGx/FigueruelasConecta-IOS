import SwiftUI

struct NoticiasView: View {
    @StateObject private var viewModel = NoticiasViewModel()
    @EnvironmentObject var authManager: AuthManager
    
    @State private var mostrandoCrearNoticiaSheet = false
    
    private var esAdmin: Bool {
        // La lógica para determinar si es admin ahora vive aquí,
        // usando el AuthManager que viene del entorno.
        authManager.usuario?.tipo == "Admin"
    }

    // El cuerpo de la vista ya no contiene un NavigationView propio.
    // Se asume que esta vista será presentada por una vista padre (como un AppTabView)
    // que ya gestiona la barra de navegación y el título.
    var body: some View {
        VStack(spacing: 0) {
            if esAdmin {
                AdminNoticiasActionView(isShowingAddSheet: $mostrandoCrearNoticiaSheet)
            }
            
            mainContentView
        }
        .task {
            await viewModel.cargarNoticias()
        }
        .sheet(isPresented: $mostrandoCrearNoticiaSheet) {
            // La vista para crear noticias se presenta como una hoja modal.
            NavigationView {
                CrearNoticiaView()
            }
        }
    }

    @ViewBuilder
    private var mainContentView: some View {
        if viewModel.isLoading {
            ProgressView("Cargando noticias...")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let errorMessage = viewModel.errorMessage {
            VStack(spacing: 20) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.largeTitle)
                    .foregroundColor(.red)
                Text(errorMessage)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                Button("Reintentar") {
                    Task { await viewModel.cargarNoticias() }
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if viewModel.noticias.isEmpty {
            Text("No hay noticias publicadas en este momento.")
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            List {
                ForEach(viewModel.noticias) { noticia in
                    // CORRECCIÓN FINAL: El NavigationLink ya no pasa el parámetro 'esAdmin'.
                    NavigationLink(destination: DetalleNoticiaView(noticia: noticia)) {
                        NoticiaRowView(noticia: noticia)
                    }
                }
                .onDelete(perform: esAdmin ? { indexSet in
                    viewModel.eliminarNoticia(at: indexSet)
                } : nil)
            }
            .listStyle(PlainListStyle())
            .refreshable {
                await viewModel.cargarNoticias()
            }
        }
    }
}


struct AdminNoticiasActionView: View {
    @Binding var isShowingAddSheet: Bool

    var body: some View {
        HStack {
            Button(action: { isShowingAddSheet = true }) {
                Label("Crear Noticia", systemImage: "plus.circle.fill")
            }
            .buttonStyle(.borderedProminent)
            .tint(.blue)
            
            Spacer()
            
            Button(action: { /* TODO: Lógica para el borrado múltiple */ }) {
                Label("Eliminar", systemImage: "trash.fill")
            }
            .buttonStyle(.borderedProminent)
            .tint(.red)
        }
        .padding()
        .background(Color(.systemGroupedBackground))
    }
}


struct NoticiasView_Previews: PreviewProvider {
    static var previews: some View {
        // La preview SÍ necesita un NavigationView y el standardToolbar
        // para que se visualice correctamente de forma aislada.
        NavigationView {
            NoticiasView()
                .environmentObject(AuthManager.shared) // Le damos un AuthManager para que no falle.
                .standardToolbar() // Aplicamos la barra aquí solo para la preview.
        }
    }
}
