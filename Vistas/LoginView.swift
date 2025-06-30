import SwiftUI

struct LoginView: View {
    
    @StateObject private var viewModel = LoginViewModel()
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color(hex: "#141E30"), Color(hex: "#243B55")]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Image("escudofigueruelas").resizable().scaledToFit().frame(height: 120).padding(.vertical, 40)
                
                VStack(spacing: 20) {
                    // Campo de Correo
                    TextField("", text: $viewModel.email)
                        .placeholder(when: viewModel.email.isEmpty) {
                            // CAMBIO: Eliminamos la opacidad para que el texto sea blanco sólido.
                            Text("Correo electrónico").foregroundColor(.white)
                        }
                        .modifier(CustomTextFieldModifier())
                    
                    // Campo de Contraseña
                    SecureField("", text: $viewModel.password)
                        .placeholder(when: viewModel.password.isEmpty) {
                            // CAMBIO: Eliminamos la opacidad para que el texto sea blanco sólido.
                            Text("Contraseña").foregroundColor(.white)
                        }
                        .modifier(CustomTextFieldModifier())
                }
                .padding(.horizontal, 32)
                
                Button(action: { Task { await viewModel.recuperarContrasena() } }) {
                    Text("¿Olvidaste tu contraseña?").font(.footnote).foregroundColor(.white.opacity(0.8)).padding(.top, 15)
                }
                
                Button(action: { Task { await viewModel.iniciarSesionGoogle() } }) {
                    HStack {
                        Image("google").resizable().scaledToFit().frame(width: 22, height: 22)
                        Text("Iniciar sesión con Google").fontWeight(.semibold).foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity).padding().background(.white).cornerRadius(12).shadow(color: .black.opacity(0.1), radius: 5, y: 3)
                }
                .padding(.horizontal, 32).padding(.top, 30)

                Spacer()
                
                HStack(spacing: 16) {
                    Button(action: { Task { await viewModel.iniciarSesion() } }) {
                        Text("Iniciar Sesión").frame(maxWidth: .infinity)
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    
                    Button(action: { Task { await viewModel.registrar() } }) {
                        Text("Registrar").frame(maxWidth: .infinity)
                    }
                    .buttonStyle(PrimaryButtonStyle())
                }
                .padding(.horizontal, 32).padding(.bottom, 30)
            }
            .disabled(viewModel.isLoading)
            
            if viewModel.isLoading {
                Color.black.opacity(0.6).edgesIgnoringSafeArea(.all)
                ProgressView().tint(.white).scaleEffect(2)
            }
        }
        .alert("Atención", isPresented: .constant(viewModel.errorMessage != nil), actions: {
            Button("OK") { viewModel.errorMessage = nil }
        }, message: { Text(viewModel.errorMessage ?? "") })
    }
}

// Asegúrate de que tienes esta extensión en algún lugar de tu proyecto
// (por ejemplo, en un archivo 'View+Extensions.swift' dentro de 'Utilidades')
// para que el modificador .placeholder funcione.
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {

        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}


#Preview {
    LoginView()
}
