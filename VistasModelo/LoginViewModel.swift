//
//  LoginViewModel.swift
//  FigueruelasConecta
//
//  Created by TuPuebloConecta on 28/06/25.
//

import Foundation

@MainActor
class LoginViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var email = ""
    @Published var password = ""
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Dependencies
    
    private let authManager: AuthManager
    
    init(authManager: AuthManager = AuthManager.shared) {
        self.authManager = authManager
    }
    
    // MARK: - User Actions
    
    func iniciarSesion() async {
        guard validarCampos() else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            try await authManager.iniciarSesion(email: email, password: password)
            // La navegación se gestionará automáticamente al cambiar el estado en AuthManager
        } catch {
            print("Error al iniciar sesión: \(error.localizedDescription)")
            errorMessage = "Correo o contraseña incorrectos. Por favor, inténtalo de nuevo."
        }
        
        isLoading = false
    }
    
    func registrar() async {
        guard validarCampos(esRegistro: true) else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            try await authManager.registrarUsuario(email: email, password: password)
            // La navegación también será automática aquí
        } catch {
            print("Error al registrar: \(error.localizedDescription)")
            errorMessage = "No se pudo completar el registro. El correo podría estar ya en uso o la contraseña es demasiado débil."
        }
        
        isLoading = false
    }
    
    func iniciarSesionGoogle() async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await authManager.iniciarSesionGoogle()
        } catch {
            print("Error al iniciar sesión con Google: \(error.localizedDescription)")
            errorMessage = "No se pudo iniciar sesión con Google. Inténtalo de nuevo."
        }
        
        isLoading = false
    }
    
    func recuperarContrasena() async {
        guard !email.isEmpty else {
            errorMessage = "Introduce tu correo electrónico para recuperar la contraseña."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            try await authManager.restablecerContrasena(email: email)
            // Usamos el mismo mecanismo de alerta para mensajes de éxito
            errorMessage = "Si la dirección es correcta, recibirás un correo para restablecer tu contraseña."
        } catch {
            print("Error al recuperar contraseña: \(error.localizedDescription)")
            errorMessage = "No se pudo enviar el correo de recuperación. Verifica la dirección e inténtalo de nuevo."
        }
        
        isLoading = false
    }
    
    // MARK: - Validation
    
    // Equivalente a tu método `validarCampos` de Android
    private func validarCampos(esRegistro: Bool = false) -> Bool {
        if email.isEmpty || password.isEmpty {
            errorMessage = "Por favor, completa todos los campos."
            return false
        }
        
        if !email.contains("@") || !email.contains(".") {
            errorMessage = "El formato del correo electrónico no es válido."
            return false
        }
        
        if esRegistro && password.count < 6 {
            errorMessage = "La contraseña debe tener al menos 6 caracteres."
            return false
        }
        
        return true
    }
}
