//
//  IncidenciaRowView.swift
//  FigueruelasConecta
//
//  Created by David Roger Alvarez on 2/7/25.
//

import SwiftUI

struct IncidenciaRowView: View {
    let incidencia: Incidencia
    let estaSeleccionada: Bool
    let onToggleSeleccion: () -> Void

    var body: some View {
        HStack(spacing: 15) {
            // Botón que actúa como Checkbox
            Button(action: onToggleSeleccion) {
                Image(systemName: estaSeleccionada ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(estaSeleccionada ? .blue : .gray)
            }
            .buttonStyle(.plain) // Evita que todo el H-Stack sea azul

            // Contenido de la incidencia
            VStack(alignment: .leading, spacing: 8) {
                if let urlString = incidencia.fotoUrl, let url = URL(string: urlString) {
                    // Usamos AsyncImage para cargar la imagen desde la URL
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(height: 150)
                        case .success(let image):
                            image.resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 150)
                                .clipped()
                                .cornerRadius(8)
                        case .failure:
                            Image(systemName: "photo.fill") // Icono de error
                                .frame(height: 150)
                                .background(Color.gray.opacity(0.1))
                        @unknown default:
                            EmptyView()
                        }
                    }
                }
                
                Text(incidencia.titulo)
                    .font(.headline)
                    .fontWeight(.bold)
                
                Text(incidencia.descripcion)
                    .font(.body)
                    .lineLimit(3)
                    .foregroundColor(.secondary)
                
                Text("Reportado por: \(incidencia.correo)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 8)
    }
}
