import SwiftUI

struct TelefonosView: View {
    
    @StateObject private var viewModel = TelefonosViewModel()
    @EnvironmentObject var authManager: AuthManager
    
    @State private var showingAddSheet = false
    
    private var esAdmin: Bool {
        authManager.usuario?.tipo == "Admin"
    }
    
    @ViewBuilder
    private var listContent: some View {
        ForEach(viewModel.telefonos) { telefono in
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(telefono.nombre)
                        .fontWeight(.bold)
                    Link(telefono.numero, destination: URL(string: "tel:\(telefono.numero)")!)
                        .foregroundColor(.blue)
                }
                Spacer()
            }
            .padding(.vertical, 8)
        }
        .onDelete(perform: esAdmin ? { indexSet in
            viewModel.deleteTelefono(at: indexSet)
        } : nil)
    }
    
    var body: some View {
        // ================================================================
        // LA SOLUCIÓN DEFINITIVA ESTÁ AQUÍ:
        // El cuerpo de esta vista NO debe empezar con 'NavigationStack'.
        // Debe empezar directamente con el 'VStack'.
        // ================================================================
        VStack {
            if esAdmin {
                List {
                    listContent
                }
                .listStyle(InsetGroupedListStyle())
                .environment(\.editMode, .constant(.active))
            } else {
                List {
                    listContent
                }
                .listStyle(InsetGroupedListStyle())
            }

            if esAdmin {
                VStack {
                    Button(action: { showingAddSheet.toggle() }) {
                        Label("Añadir Teléfono", systemImage: "plus.circle.fill")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding()
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            AddTelefonoView(viewModel: viewModel)
        }
        .onAppear {
            Task {
                await viewModel.fetchTelefonos()
            }
        }
    }
}

#Preview {
    NavigationStack {
        TelefonosView()
            .standardToolbar()
            .environmentObject(AuthManager.shared)
    }
}
