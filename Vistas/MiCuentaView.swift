import SwiftUI

struct MiCuentaView: View {
    @EnvironmentObject var authManager: AuthManager

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.crop.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.gray)

            if let usuario = authManager.usuario {
                Text("Conectado como:")
                Text(usuario.correo)
                    .font(.headline)
                    .bold()
                
                // CAMBIO: La siguiente línea que mostraba el rol ha sido eliminada.
            }
            
            Spacer()
            
            Button("Cerrar Sesión", role: .destructive) {
                authManager.cerrarSesion()
            }
            .padding()
        }
        .padding()
    }
}

#Preview {
    NavigationStack {
        MiCuentaView()
            .standardToolbar()
            .environmentObject(AuthManager.shared)
    }
}
