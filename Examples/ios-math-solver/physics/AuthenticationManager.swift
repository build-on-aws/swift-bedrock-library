import AuthenticationServices
import AWSClientRuntime
import AWSSDKIdentity
import AWSSTS
import ClientRuntime
import SmithyIdentity
import Foundation
import SwiftUI

class AuthenticationManager: ObservableObject {
    @Published var isAuthenticated = true
    @Published var userId: String?
    @Published var error: String?

    // AWS configuration
    private let region = "us-east-1" // Replace with your AWS region
    private let awsAccountNumber = "486652066693" // Replace with your AWS account number
    private let awsIAMRoleName = "ios-swift-bedrock" // Replace with your IAM role name

    // Identity resolver for AWS credentials
    var identityResolver: STSWebIdentityAWSCredentialIdentityResolver?

    // Trigger for credential changes
    @Published var credentialsUpdated = false

    func signOut() {
        isAuthenticated = false
        userId = nil
        identityResolver = nil
    }

    func authenticate(with userIdentifier: String, identityToken: Data) {
        userId = userIdentifier

        // Convert identity token to string
        guard let tokenString = String(data: identityToken, encoding: .utf8) else {
            handleAuthError(NSError(domain: "AuthenticationError", code: 1001,
                                    userInfo: [NSLocalizedDescriptionKey: "Failed to convert identity token to string"]))
            return
        }

        // Get AWS credentials using the Apple identity token
        Task {
            do {
                try await authenticate(withWebIdentity: tokenString)

                // Update UI on main thread
                await MainActor.run {
                    self.isAuthenticated = true
                    self.error = nil
                }
            } catch {
                await MainActor.run {
                    self.handleAuthError(error)
                }
            }
        }
    }

    func handleAuthError(_ error: Error) {
        self.error = error.localizedDescription
        isAuthenticated = false
    }

    /// Convert the given JWT identity token string into temporary AWS credentials
    /// using the STSWebIdentityAWSCredentialIdentityResolver
    ///
    /// - Parameters:
    ///   - tokenString: The string version of the JWT identity token
    ///     returned by Sign In With Apple.
    ///   - region: An optional string specifying the AWS Region to
    ///     access. If not specified, "us-east-1" is assumed.
    private func authenticate(withWebIdentity tokenString: String,
                              region: String = "us-east-1") async throws
    {
        // Create the role ARN from the account number and role name
        let roleARN = "arn:aws:iam::\(awsAccountNumber):role/\(awsIAMRoleName)"

        // Write the token to a temporary file so it can be used by the resolver
        let tokenFileURL = createTokenFileURL()
        let tokenFilePath = tokenFileURL.path

        do {
            try tokenString.write(to: tokenFileURL, atomically: true, encoding: .utf8)
        } catch {
            throw NSError(domain: "AuthenticationError", code: 1002,
                          userInfo: [NSLocalizedDescriptionKey: "Failed to write token to file"])
        }

        // Create an identity resolver that uses the JWT token received
        // from Apple to create AWS credentials
        do {
            identityResolver = try STSWebIdentityAWSCredentialIdentityResolver(
                region: region,
                roleArn: roleARN,
                roleSessionName: "MathSolverSession-\(UUID().uuidString)",
                tokenFilePath: tokenFilePath
            )

            // Test the resolver by retrieving credentials to ensure it works
            if let resolver = identityResolver {
                _ = try await resolver.getCRTAWSCredentialIdentityResolver().getCredentials()
                print("Successfully verified AWS credential resolver")

                // Toggle the update flag to notify observers
                await MainActor.run {
                    self.credentialsUpdated.toggle()
                }
            }
        } catch {
            throw NSError(domain: "AuthenticationError", code: 1003,
                          userInfo: [NSLocalizedDescriptionKey: "Failed to assume role: \(error.localizedDescription)"])
        }
    }

    /// Creates a URL for a temporary file to store the identity token
    private func createTokenFileURL() -> URL {
        let tempDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        return tempDirectoryURL.appendingPathComponent("apple-identity-token.jwt")
    }
}
