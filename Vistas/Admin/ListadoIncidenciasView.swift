//
//  ListadoIncidenciasView.swift
//  FigueruelasConecta
//
//  Created by David Roger Alvarez on 29/6/25.
//

import SwiftUI

struct ListadoIncidenciasView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            Text("Aquí irá el listado de incidencias.")
                .navigationTitle("Incidencias Recibidas")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cerrar") {
                            dismiss()
                        }
                    }
                }
        }
    }
}
