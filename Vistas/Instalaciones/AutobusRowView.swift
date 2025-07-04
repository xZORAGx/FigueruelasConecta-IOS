//
//  AutobusRowView.swift
//  FigueruelasConecta
//
//  Created by David Roger Alvarez on 4/7/25.
//

import SwiftUI

struct AutobusRowView: View {
    let autobus: Autobus
    
    var body: some View {
        HStack {
            // Icono para dar un toque visual
            Image(systemName: "bus.fill")
                .font(.title)
                .foregroundColor(.accentColor)
                .padding(.trailing, 8)
            
            VStack(alignment: .leading, spacing: 4) {
                // Nombre de la línea (p. ej., "Lunes a Viernes")
                Text(autobus.nombreLinea)
                    .fontWeight(.bold)
                
                // Dirección (p. ej., "Figueruelas -> Zaragoza")
                Text(autobus.direccion)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                // Horarios
                Text("Salidas: \(autobus.horarios)")
                    .font(.caption)
                    .foregroundColor(.primary.opacity(0.8))
            }
            Spacer() // Empuja todo a la izquierda
        }
        .padding(.vertical, 8)
    }
}
