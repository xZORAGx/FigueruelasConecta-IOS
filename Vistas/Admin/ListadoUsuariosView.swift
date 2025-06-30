//
//  ListadoUsuariosView.swift
//  FigueruelasConecta
//
//  Created by David Roger Alvarez on 29/6/25.
//

import SwiftUI

struct ListadoUsuariosView: View {
    // Para poder cerrar la vista modal
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            Text("Aquí irá el listado de usuarios.")
                .navigationTitle("Usuarios Registrados")
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
