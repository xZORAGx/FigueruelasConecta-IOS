//
//  UsuarioRowView.swift
//  FigueruelasConecta
//
//  Created by David Roger Alvarez on 2/7/25.
//

import SwiftUI

struct UsuarioRowView: View {
    let usuario: Usuario

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "person.circle.fill")
                .font(.system(size: 44))
                .foregroundColor(.gray.opacity(0.8))

            VStack(alignment: .leading, spacing: 5) {
                Text(usuario.usuario)
                    .font(.headline)
                
                Text(usuario.correo)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                // Mostramos el tipo y el pueblo, que ahora siempre existe.
                HStack(spacing: 8) {
                    Text(usuario.tipo)
                        .font(.caption2)
                        .fontWeight(.bold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(backgroundColorForType(usuario.tipo))
                        .foregroundColor(foregroundColorForType(usuario.tipo))
                        .clipShape(Capsule())
                    
                    Text(usuario.pueblo)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            Spacer()
        }
        .padding(.vertical, 6)
    }

    // Funciones de ayuda para un estilo más dinámico y limpio.
    private func backgroundColorForType(_ type: String) -> Color {
        return type.lowercased() == "admin" ? .blue.opacity(0.15) : .green.opacity(0.15)
    }

    private func foregroundColorForType(_ type: String) -> Color {
        return type.lowercased() == "admin" ? .blue : .green
    }
}
