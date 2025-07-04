import SwiftUI

struct DetalleInstalacionView: View {
    let instalacion: Instalacion
    
    private let diasDeLaSemana = ["lunes", "martes", "miércoles", "jueves", "viernes", "sábado", "domingo"]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // ... El contenido del VStack no cambia ...
                AsyncImage(url: URL(string: instalacion.imagenUrl)) { image in
                    image.resizable().aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle().fill(Color.gray.opacity(0.3)).overlay(ProgressView())
                }
                .frame(height: 220)
                .clipped()

                VStack(alignment: .leading, spacing: 8) {
                    Text(instalacion.titulo)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text(instalacion.descripcion)
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)

                if let horarios = instalacion.horarios, !horarios.isEmpty {
                    VStack(alignment: .leading) {
                        Text("Horarios")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .padding(.bottom, 5)

                        ForEach(diasDeLaSemana, id: \.self) { dia in
                            if let horarioDia = horarios[dia] {
                                HStack {
                                    Text(dia.capitalized)
                                        .fontWeight(.medium)
                                    Spacer()
                                    Text("\(horarioDia.apertura) - \(horarioDia.cierre)")
                                        .foregroundColor(.secondary)
                                }
                                Divider()
                            }
                        }
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
            }
        }
        .navigationTitle(instalacion.titulo)
        .navigationBarTitleDisplayMode(.inline)
        // ❌ ELIMINA ESTA LÍNEA
        // .ignoresSafeArea(edges: .top)
    }
}
