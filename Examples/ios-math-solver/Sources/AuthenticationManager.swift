//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift Bedrock Library open source project
//
// Copyright (c) 2025 Amazon.com, Inc. or its affiliates
//                    and the Swift Bedrock Library project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of Swift Bedrock Library project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

import AuthenticationServices
import Foundation
import SwiftUI

class AuthenticationManager: ObservableObject {
    @Published var isAuthenticated = false  // FIXME: check if the token is still valid
    @Published var userId: String? = nil
    @Published var error: String? = nil

    var jwtToken: String? = nil

    // Trigger for credential changes
    @Published var credentialsUpdated = false

    func signOut() {
        isAuthenticated = false
        userId = nil
    }

    func authenticate(with userIdentifier: String, identityToken: Data) {
        userId = userIdentifier

        // Convert identity token to string
        guard let tokenString = String(data: identityToken, encoding: .utf8) else {
            handleAuthError(
                NSError(
                    domain: "AuthenticationError",
                    code: 1001,
                    userInfo: [NSLocalizedDescriptionKey: "Failed to convert identity token to string"]
                )
            )
            return
        }

        self.jwtToken = tokenString

        // Get AWS credentials using the Apple identity token
        Task {
            // Update UI on main thread
            await MainActor.run {
                self.isAuthenticated = true
                self.error = nil
            }
        }
    }

    func handleAuthError(_ error: Error) {
        self.error = error.localizedDescription
        isAuthenticated = false
    }
}
