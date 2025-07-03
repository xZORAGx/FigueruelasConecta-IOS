import SwiftUI

struct PartidoRowView: View {
    // Usamos @Binding para que los cambios en esta vista
    // se reflejen directamente en el objeto original del ViewModel.
    @Binding var partido: Partido
    
    // Propiedades para gestionar el estado de la UI
    let modoEdicion: Bool
    let isSelected: Bool
    let onSelect: () -> Void
    
    // Estados locales para manejar los TextFields de los goles
    @State private var golesEquipo1: String = ""
    @State private var golesEquipo2: String = ""

    var body: some View {
        HStack(spacing: 12) {
            // MARK: - Checkbox de selección (solo en modo edición)
            if modoEdicion {
                Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                    .font(.title2)
                    .foregroundColor(.blue) // <-- ¡CAMBIO REALIZADO AQUÍ!
                    .onTapGesture {
                        onSelect()
                    }
            }
            
            // MARK: - Contenido Principal
            VStack(alignment: .leading, spacing: 8) {
                // Fila superior con categoría y fecha
                HStack {
                    Text(partido.categoria)
                        .font(.caption)
                        .fontWeight(.bold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                    
                    Spacer()
                    
                    Text("\(partido.diaSemana), \(partido.fecha)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Equipos
                Text(partido.equipo1)
                    .font(.headline)
                Text(partido.equipo2)
                    .font(.headline)
            }
            
            Spacer()
            
            // MARK: - Resultado (vista normal o edición)
            if modoEdicion {
                VStack(spacing: 8) {
                    TextField("Goles", text: $golesEquipo1)
                        .keyboardType(.numberPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 50)
                    
                    TextField("Goles", text: $golesEquipo2)
                        .keyboardType(.numberPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 50)
                }
            } else {
                Text(partido.resultado)
                    .font(.title)
                    .fontWeight(.bold)
                    .frame(minWidth: 60)
            }
        }
        .padding(.vertical, 8)
        .onAppear(perform: parsearResultado)
        .onChange(of: golesEquipo1) { _ in actualizarResultado() }
        .onChange(of: golesEquipo2) { _ in actualizarResultado() }
        .background(isSelected ? Color.blue.opacity(0.1) : Color.clear) // Resaltar si está seleccionado
    }
    
    /// Separa el string "X - Y" en dos variables para los TextFields.
    private func parsearResultado() {
        let componentes = partido.resultado.split(separator: "-").map { $0.trimmingCharacters(in: .whitespaces) }
        golesEquipo1 = componentes.indices.contains(0) ? componentes[0] : ""
        golesEquipo2 = componentes.indices.contains(1) ? componentes[1] : ""
    }
    
    /// Une los valores de los TextFields en un solo string "X - Y".
    private func actualizarResultado() {
        let resultadoFinal = "\(golesEquipo1.isEmpty ? "0" : golesEquipo1) - \(golesEquipo2.isEmpty ? "0" : golesEquipo2)"
        // Como 'partido' es un @Binding, este cambio se propaga hacia arriba, al ViewModel.
        partido.resultado = resultadoFinal
    }
}
