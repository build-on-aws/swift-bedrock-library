import SwiftUI

@main
struct MathSolverApp: App {
    @StateObject private var authManager = AuthenticationManager()
    
    var body: some Scene {
        WindowGroup {
            if authManager.isAuthenticated {
                VStack {
                    ContentView()
                        .environmentObject(authManager)
                        .onAppear {
                            // Ensure the view model is updated with the latest auth state
                            print("ContentView appeared with authenticated user")
                        }
                }
            } else {
                LoginView()
                    .environmentObject(authManager)
            }
        }
    }
}
