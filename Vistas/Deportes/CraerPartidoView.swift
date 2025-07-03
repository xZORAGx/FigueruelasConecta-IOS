//  FigueruelasConecta/Vistas/Deportes/CrearPartidoView.swift

import SwiftUI

struct CrearPartidoView: View {
    // Propiedades que pasamos desde la vista anterior
    let deportes: [Deporte]
    
    // Estados para los campos del formulario
    @State private var equipo1 = ""
    @State private var equipo2 = ""
    @State private var fecha = Date()
    @State private var deporteSeleccionado: String
    @State private var categoriaSeleccionada: String
    @State private var diaSemanaSeleccionado: String
    
    // Opciones estáticas para los Pickers
    let categorias = ["Senior", "Juvenil", "Cadete", "Infantil", "Alevín", "Benjamín"]
    let diasSemana = ["Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado", "Domingo"]
    
    // Estados de UI
    @State private var isSaving = false
    @State private var errorMessage: String?
    @Environment(\.dismiss) private var dismiss
    
    private var isFormValid: Bool {
        !equipo1.isEmpty && !equipo2.isEmpty && !deporteSeleccionado.isEmpty
    }
    
    // Inicializador para preseleccionar valores
    init(deportes: [Deporte]) {
        self.deportes = deportes
        // Pre-seleccionamos el primer valor de cada lista para evitar un estado vacío
        _deporteSeleccionado = State(initialValue: deportes.first?.nombre ?? "")
        _categoriaSeleccionada = State(initialValue: categorias.first ?? "")
        _diaSemanaSeleccionado = State(initialValue: diasSemana.first ?? "")
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Equipos")) {
                    TextField("Equipo Local", text: $equipo1)
                    TextField("Equipo Visitante", text: $equipo2)
                }
                
                Section(header: Text("Detalles del Partido")) {
                    Picker("Deporte", selection: $deporteSeleccionado) {
                        ForEach(deportes) { deporte in
                            Text(deporte.nombre).tag(deporte.nombre)
                        }
                    }
                    
                    Picker("Categoría", selection: $categoriaSeleccionada) {
                        ForEach(categorias, id: \.self) { categoria in
                            Text(categoria).tag(categoria)
                        }
                    }
                    
                    DatePicker("Fecha del partido", selection: $fecha, displayedComponents: .date)
                    
                    Picker("Día de la semana", selection: $diaSemanaSeleccionado) {
                        ForEach(diasSemana, id: \.self) { dia in
                            Text(dia).tag(dia)
                        }
                    }
                }
                
                Section {
                    if isSaving {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                    } else {
                        Button("Guardar Partido") {
                            Task { await guardarPartido() }
                        }
                        .disabled(!isFormValid)
                    }
                }
            }
            // --- ¡CAMBIO AQUÍ! ---
            // Aplicamos un tint azul a todo el formulario.
            // Esto colorea los valores de los pickers y el botón de guardar.
            .tint(.blue)
            .navigationTitle("Nuevo Partido")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") { dismiss() }
                        // --- ¡CAMBIO AQUÍ! ---
                        // Coloreamos el botón de cancelar en rojo.
                        .foregroundColor(.red)
                }
            }
            .alert("Error", isPresented: .constant(errorMessage != nil)) {
                Button("OK") { errorMessage = nil }
            } message: {
                Text(errorMessage ?? "Ocurrió un error.")
            }
        }
    }
    
    private func guardarPartido() async {
        isSaving = true
        do {
            try await FirestoreManager.shared.crearPartido(
                equipo1: equipo1,
                equipo2: equipo2,
                fecha: fecha,
                deporte: deporteSeleccionado,
                categoria: categoriaSeleccionada,
                diaSemana: diaSemanaSeleccionado
            )
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
        isSaving = false
    }
}
