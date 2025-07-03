//
//  OpcionesCreacionSheet.swift.swift
//  FigueruelasConecta
//
//  Created by David Roger Alvarez on 3/7/25.
//

//  FigueruelasConecta/Vistas/Deportes/OpcionesCreacionSheet.swift

import SwiftUI

struct OpcionesCreacionSheet: View {
    
    // Acciones que se ejecutarán al pulsar los botones
    var onCrearDeporte: () -> Void
    var onCrearPartido: () -> Void
    var onCrearActividad: () -> Void
    
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            Text("Selecciona qué quieres crear")
                .font(.headline)
                .padding()

            Divider()
            
            // Usamos un ScrollView por si en el futuro hay más opciones
            ScrollView {
                VStack(spacing: 0) {
                    Button(action: onCrearDeporte) {
                        Text("Crear Nuevo Deporte")
                            .frame(maxWidth: .infinity, minHeight: 50)
                    }
                    Divider()
                    Button(action: onCrearPartido) {
                        Text("Crear Partido")
                            .frame(maxWidth: .infinity, minHeight: 50)
                    }
                    Divider()
                    Button(action: onCrearActividad) {
                        Text("Crear Actividad")
                            .frame(maxWidth: .infinity, minHeight: 50)
                    }
                }
            }
            
            // Botón de cancelar separado
            Button(action: { dismiss() }) {
                Text("Cancelar")
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
            }
            .padding()
        }
        // Este es el modificador clave para poner el texto azul
        .foregroundColor(.blue)
        .presentationDetents([.height(280)]) // Fija la altura del sheet
    }
}
