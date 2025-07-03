import SwiftUI

struct DeportesView: View {
    @StateObject private var viewModel = DeportesViewModel()
    
    @State private var mostrandoOpcionesCreacion = false
    @State private var mostrandoCrearDeporteSheet = false
    @State private var mostrandoCrearPartidoSheet = false
    @State private var mostrandoCrearActividadSheet = false

    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                VStack(spacing: 0) {
                    Picker("Sección", selection: $viewModel.seccionSeleccionada.animation()) {
                        Text("Partidos").tag(SeccionDeportes.partidos)
                        Text("Actividades").tag(SeccionDeportes.actividades)
                    }
                    .pickerStyle(SegmentedPickerStyle()).padding()

                    ZStack {
                        switch viewModel.seccionSeleccionada {
                        case .partidos: vistaPartidos()
                        case .actividades: vistaActividades()
                        }
                        if viewModel.isLoading { ProgressView().scaleEffect(1.5) }
                    }
                }
                if viewModel.esAdmin { vistaBotonesAdmin().padding() }
            }
            .navigationTitle("Deportes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { Task { await viewModel.cargarDeportes() } }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .alert(item: $viewModel.errorMessage) { msg in Alert(title: Text("Error"), message: Text(msg), dismissButton: .default(Text("OK"))) }
            .sheet(isPresented: $mostrandoOpcionesCreacion) {
                OpcionesCreacionSheet(
                    onCrearDeporte: { mostrandoOpcionesCreacion = false; mostrandoCrearDeporteSheet = true },
                    onCrearPartido: { mostrandoOpcionesCreacion = false; mostrandoCrearPartidoSheet = true },
                    onCrearActividad: { mostrandoOpcionesCreacion = false; mostrandoCrearActividadSheet = true }
                )
            }
            .sheet(isPresented: $mostrandoCrearDeporteSheet, onDismiss: { Task { await viewModel.cargarDeportes() } }) { CrearDeporteView() }
            .sheet(isPresented: $mostrandoCrearPartidoSheet, onDismiss: { Task { await viewModel.manejarCambioDeSeccion(.partidos) } }) { CrearPartidoView(deportes: viewModel.deportes) }
            .sheet(isPresented: $mostrandoCrearActividadSheet, onDismiss: { Task { await viewModel.manejarCambioDeSeccion(.actividades) } }) { CrearActividadView() }
        }
        .accentColor(.blue)
    }
    
    // MARK: - Subvistas
    
    @ViewBuilder private func vistaPartidos() -> some View {
        VStack {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(viewModel.deportes) { deporte in
                        Button(action: { Task { await viewModel.seleccionarDeporte(deporte) } }) {
                            Text("\(deporte.emoji) \(deporte.nombre)")
                                .padding(.horizontal, 16).padding(.vertical, 8)
                                .background(viewModel.deporteSeleccionado == deporte ? Color.blue.opacity(0.2) : Color.gray.opacity(0.2))
                                .foregroundColor(viewModel.deporteSeleccionado == deporte ? .blue : .primary)
                                .cornerRadius(20)
                                .fontWeight(viewModel.deporteSeleccionado == deporte ? .bold : .regular)
                        }
                    }
                }.padding(.horizontal)
            }
            List($viewModel.partidos) { $partido in
                PartidoRowView(
                    partido: $partido,
                    modoEdicion: viewModel.modoEdicionPartidos,
                    isSelected: viewModel.seleccionPartidos.contains(partido),
                    onSelect: {
                        if viewModel.seleccionPartidos.contains(partido) { viewModel.seleccionPartidos.remove(partido) }
                        else { viewModel.seleccionPartidos.insert(partido) }
                    }
                )
            }.listStyle(PlainListStyle())
        }
    }

    @ViewBuilder private func vistaActividades() -> some View {
        List(viewModel.actividades) { actividad in
            DeportesActividadRowView(
                actividad: actividad,
                esAdmin: viewModel.esAdmin,
                isSelected: viewModel.seleccionActividades.contains(actividad),
                onSelect: {
                    if viewModel.seleccionActividades.contains(actividad) { viewModel.seleccionActividades.remove(actividad) }
                    else { viewModel.seleccionActividades.insert(actividad) }
                }
            )
        }.listStyle(PlainListStyle())
    }
    
    @ViewBuilder private func vistaBotonesAdmin() -> some View {
        HStack(spacing: 15) {
            Spacer()
            if (!viewModel.seleccionPartidos.isEmpty && viewModel.seccionSeleccionada == .partidos && viewModel.modoEdicionPartidos) ||
               (!viewModel.seleccionActividades.isEmpty && viewModel.seccionSeleccionada == .actividades) {
                 Button(action: { Task {
                    if viewModel.seccionSeleccionada == .partidos { await viewModel.borrarPartidosSeleccionados() }
                    else { await viewModel.borrarActividadesSeleccionadas() }
                 }}) { Image(systemName: "trash.fill") }.buttonStyle(FABStyle(backgroundColor: .red))
            }
            if viewModel.seccionSeleccionada == .partidos {
                if viewModel.modoEdicionPartidos {
                    Button(action: { Task { await viewModel.guardarResultadosPartidos() } }) {
                        Image(systemName: "checkmark")
                    }.buttonStyle(FABStyle(backgroundColor: .green))
                }
                Button(action: { viewModel.toggleModoEdicionPartidos() }) {
                    Image(systemName: viewModel.modoEdicionPartidos ? "xmark" : "pencil")
                }.buttonStyle(FABStyle(backgroundColor: viewModel.modoEdicionPartidos ? .orange : .gray))
            }
            Button(action: { mostrandoOpcionesCreacion = true }) {
                Image(systemName: "plus")
            }.buttonStyle(FABStyle(backgroundColor: .blue))
        }
    }
}

// MARK: - Estilos y Extensiones (Necesario para que compile)

struct FABStyle: ButtonStyle {
    var backgroundColor: Color = .gray
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.title2.bold())
            .padding().background(backgroundColor)
            .foregroundColor(.white).clipShape(Circle())
            .shadow(radius: 5)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

extension String: Identifiable {
    public var id: String { self }
}
