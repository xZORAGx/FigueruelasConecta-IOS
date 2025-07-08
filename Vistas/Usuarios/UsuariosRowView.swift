//
//  UsuariosRowView.swift
//  FigueruelasConecta
//
//  Created by David Roger Alvarez on 5/7/25.
//

import SwiftUI

struct UsuarioRowView: View {
    let usuario: Usuario
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                // ✅ CAMBIO: Usamos la propiedad `nombre` que definiste.
                Text(usuario.nombre)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(usuario.correo)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // ✅ CAMBIO: Usamos la propiedad `esAdmin` para la lógica del color.
            Text(usuario.tipo)
                .font(.caption)
                .fontWeight(.bold)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(usuario.esAdmin ? Color.blue.opacity(0.2) : Color.gray.opacity(0.2))
                .foregroundColor(usuario.esAdmin ? .blue : .secondary)
                .clipShape(Capsule())
        }
        .padding(.vertical, 8)
    }
}
