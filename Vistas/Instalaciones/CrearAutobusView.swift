//
//  CrearAutobusView.swift
//  FigueruelasConecta
//
//  Created by David Roger Alvarez on 4/7/25.
//

import SwiftUI

struct CrearAutobusView: View {
    @StateObject private var viewModel = CrearAutobusViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Datos del Horario")) {
                    TextField("Nombre de línea (ej: Lunes a Viernes)", text: $viewModel.nombreLinea)
                    
                    Picker("Dirección del viaje", selection: $viewModel.direccionSeleccionada) {
                        ForEach(CrearAutobusViewModel.DireccionBus.allCases, id: \.self) { direccion in
                            Text(direccion.rawValue)
                        }
                    }
                    
                    TextField("Horarios (ej: 06:40, 08:30, 12:55)", text: $viewModel.horarios)
                }
                
                if let errorMessage = viewModel.errorMessage {
                    Section {
                        Text(errorMessage).foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Nuevo Horario de Autobús")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar", action: { dismiss() })
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    if viewModel.isSaving {
                        ProgressView()
                    } else {
                        Button("Guardar") {
                            Task {
                                await viewModel.guardarAutobus()
                            }
                        }
                    }
                }
            }
            .onChange(of: viewModel.saveCompleted) { completed in
                if completed {
                    dismiss()
                }
            }
        }
    }
}
