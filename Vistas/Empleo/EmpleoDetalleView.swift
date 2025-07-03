import SwiftUI

struct EmpleoDetalleView: View {
    let empleo: Empleo
    
    // 👇 AÑADIDO: Obtenemos la acción para cerrar la vista actual.
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                // ... (el contenido de la imagen se queda igual)
                AsyncImage(url: URL(string: empleo.imagenUrl ?? "")) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                    case .failure:
                        ZStack {
                            Rectangle()
                                .fill(Color.gray.opacity(0.1))
                                .aspectRatio(16/9, contentMode: .fit)
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                        }
                    case .empty:
                        ZStack {
                            Rectangle()
                                .fill(Color.gray.opacity(0.1))
                                .aspectRatio(16/9, contentMode: .fit)
                            ProgressView()
                        }
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(maxHeight: 300)
                .clipped()

                // ... (el resto del VStack se queda igual)
                VStack(alignment: .leading, spacing: 16) {
                    Text(empleo.titulo)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    if let fecha = empleo.fechaCreacion?.dateValue() {
                        Text("Publicado el \(fecha, style: .date)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Divider()
                    
                    Text(empleo.descripcion)
                        .font(.body)

                }
                .padding()
            }
        }
        .navigationTitle("Detalle de la Oferta")
        .navigationBarTitleDisplayMode(.inline)
        // 👇 AÑADIDO: Ocultamos el botón de "Atrás" automático.
        .navigationBarBackButtonHidden(true)
        // 👇 AÑADIDO: Creamos nuestra propia barra de herramientas.
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss() // Al pulsarlo, cerramos la vista.
                }) {
                    HStack {
                        Image(systemName: "chevron.left") // El icono de la flecha
                        Text("Empleo") // El texto que acompaña
                    }
                    .foregroundColor(.red) // Aplicamos el color rojo aquí.
                }
            }
        }
    }
}
