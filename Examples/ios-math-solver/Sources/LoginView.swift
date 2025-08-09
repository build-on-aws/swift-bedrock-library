import AuthenticationServices
import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authManager: AuthenticationManager

    var body: some View {
        VStack(spacing: 20) {
            // App logo and title
            VStack {
                Image(systemName: "function")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)

                Text("Math & Physics Problem Solver")
                    .font(.title)
                    .fontWeight(.bold)

                Text("Sign in to start solving problems")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.bottom, 40)

            Spacer()
            
            // Error message
            if let error = authManager.error {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
            }

            // Sign in with Apple button
            SignInWithAppleButton(
                .signIn,
                onRequest: { request in
                    request.requestedScopes = [.fullName, .email]
                },
                onCompletion: { result in
                    switch result {
                    case let .success(authResults):
                        if let appleIDCredential = authResults.credential as? ASAuthorizationAppleIDCredential,
                           let identityToken = appleIDCredential.identityToken
                        {
                            // Get user identifier and identity token
                            let userIdentifier = appleIDCredential.user
                            authManager.authenticate(with: userIdentifier, identityToken: identityToken)
                        } else {
                            authManager.handleAuthError(NSError(domain: "LoginError", code: 1002,
                                                                userInfo: [NSLocalizedDescriptionKey: "Failed to get identity token"]))
                        }
                    case let .failure(error):
                        authManager.handleAuthError(error)
                    }
                }
            )
            .frame(height: 50)
            .padding(.horizontal, 40)
            .cornerRadius(8)

            // App info
            VStack(spacing: 5) {
                Text("Powered by")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text("Amazon Bedrock & Claude")
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.bottom, 20)
        }
        .padding()
    }
}

struct SignInWithAppleButton: UIViewRepresentable {
    let type: ASAuthorizationAppleIDButton.ButtonType
    let onRequest: (ASAuthorizationAppleIDRequest) -> Void
    let onCompletion: (Result<ASAuthorization, Error>) -> Void

    init(_ type: ASAuthorizationAppleIDButton.ButtonType, onRequest: @escaping ((ASAuthorizationAppleIDRequest) -> Void), onCompletion: @escaping ((Result<ASAuthorization, Error>) -> Void)) {
        self.type = type
        self.onRequest = onRequest
        self.onCompletion = onCompletion
    }

    func makeUIView(context: Context) -> ASAuthorizationAppleIDButton {
        let button = ASAuthorizationAppleIDButton(type: type, style: .black)
        button.addTarget(context.coordinator, action: #selector(Coordinator.handleAuthorizationAppleIDButtonPress), for: .touchUpInside)
        return button
    }

    func updateUIView(_: ASAuthorizationAppleIDButton, context _: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
        let parent: SignInWithAppleButton

        init(_ parent: SignInWithAppleButton) {
            self.parent = parent
        }

        @objc func handleAuthorizationAppleIDButtonPress() {
            let request = ASAuthorizationAppleIDProvider().createRequest()
            parent.onRequest(request)

            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = self
            authorizationController.presentationContextProvider = self
            authorizationController.performRequests()
        }

        func authorizationController(controller _: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
            parent.onCompletion(.success(authorization))
        }

        func authorizationController(controller _: ASAuthorizationController, didCompleteWithError error: Error) {
            parent.onCompletion(.failure(error))
        }

        func presentationAnchor(for _: ASAuthorizationController) -> ASPresentationAnchor {
            let scenes = UIApplication.shared.connectedScenes
            let windowScene = scenes.first as? UIWindowScene
            let window = windowScene?.windows.first
            return window ?? UIWindow()
        }
    }
}
