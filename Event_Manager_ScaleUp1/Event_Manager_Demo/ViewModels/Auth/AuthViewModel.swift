//
//  AuthViewModel.swift
//  Event_Manager_Demo
//
//  Created by Sumi Sastri on 15/06/2026.
//

import Foundation
import SwiftData
import Combine
import AuthenticationServices


// USAGE: Authentication for admin and attendee based on
// user role and email sign-in - manages session of "current user"
// current user becomes SSOT for session management coupled with role, email

class AuthViewModel: ObservableObject {
    enum DashboardRoute: String, Hashable, Identifiable {
        case admin
        case attendee
        
        var id: String { rawValue }
    }
    
    enum StatusType {
        case success
        case failure
    }
    
    // MARK: Apple SignIn vars
    @Published var isLoading: Bool = false
    @Published var isSignedIn: Bool = false
    @Published var signedInRole: UserRole? = nil
    //    MARK: Store session - who is the current user?
    @Published var currentUser: UserModel? = nil
    @Published var statusType: StatusType? = nil
    
    @Published var statusMessage: String = ""
    @Published var activeDashboardRoute: DashboardRoute? = nil
    
    //    MARK: whitelist user emails
    private let adminEmailWhitelist: Set<String> = ["admin@eventrabbit.demo"]
    private let attendeeEmailWhitelist: Set<String> = ["attendee@eventrabbit.demo"]
    
    // MARK: Initialise coordinator
    private let authCoordinator: AuthCoordinator
    
    init(authCoordinator: AuthCoordinator) {
        self.authCoordinator = authCoordinator
    }
    
    
    //    MARK: Assign roles - admin or attendee via emails
    private func resolvedRole(for email: String) -> UserRole {
        //        MARK: email validation rules
        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let role: UserRole = adminEmailWhitelist.contains(normalizedEmail) ? .admin : .attendee
        print("[Auth] resolved role for \(normalizedEmail): \(role.rawValue)")
        return role
    }
    
    private func logRouting(for role: UserRole, email: String) {
        let destination = role == .admin ? "AdminDashboard" : "AttendeeDashboard"
        print("[Auth] routing \(email) to \(destination)")
    }
    
    // MARK: Mock Apple Sign In for simulator testing without paid developer account
    func mockAppleSignIn(email: String, name: String = "Test User") {
        isLoading = true
        isSignedIn = false
        signedInRole = nil
        activeDashboardRoute = nil
        statusType = nil
        statusMessage = ""
        //        route user based on email (if email attendee to attendee route and if admin to admin route
        let mockAppleUserID = "mock.\(UUID().uuidString)"
        let userRole = resolvedRole(for: email)
        print("[Auth] login requested for \(email)")
        logRouting(for: userRole, email: email)
        
        //        MARK: Apple SignIn boiler plate for SSOT of authentication
        Task { @MainActor in
            do {
                let savedUser = try authCoordinator.saveUser(
                    appleUserID: mockAppleUserID,
                    userName: name,
                    userEmail: email,
                    userRole: userRole
                )
                self.signedInRole = savedUser.userRole
                self.currentUser = savedUser
                self.isSignedIn = true
                self.activeDashboardRoute = savedUser.userRole == .admin ? .admin : .attendee
                self.statusType = .success
                self.statusMessage = savedUser.userRole == .admin
                ? "You are now logged in as an admin user."
                : "You are now logged in as an attendee."
                self.isLoading = false
                print("[Auth] sign in completed for \(savedUser.userEmail) as \(savedUser.userRole.rawValue)")
            } catch {
                self.signedInRole = nil
                self.currentUser = nil
                self.isSignedIn = false
                self.activeDashboardRoute = nil
                self.statusType = .failure
                self.statusMessage = error.localizedDescription
                self.isLoading = false
                print("[Auth] sign in failed: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: Logout current user by role and email
    func logout() {
        let email = currentUser?.userEmail ?? "unknown"
        let role = currentUser?.userRole.rawValue ?? "unknown"

        print("[Auth] sign out completed for \(email) as \(role)")

        isLoading = false
        isSignedIn = false
        signedInRole = nil
        currentUser = nil
        activeDashboardRoute = nil
        statusType = nil
        statusMessage = ""
    }
    
}
//     MARK: Production code if paid version boiler plate - for marking reference only
//    func handleAppleSignIn(result: Result<ASAuthorization, Error>) {
//        switch result {
//        case .success(let auth):
//            guard let credential = auth.credential as? ASAuthorizationAppleIDCredential else {
//                errorMessage = "Invalid Apple credential"
//                return
//            }
//
//            isLoading = true
//            errorMessage = nil
//
//            let appleUserID = credential.user
//            let email = credential.email ?? ""
//            let name = credential.fullName?.givenName ?? "User"
//            let userRole = resolvedRole(for: email)
//            logRouting(for: userRole, email: email)
//
//            Task {
//                do {
//                    let savedUser = try authCoordinator.saveUser(
//                        appleUserID: appleUserID,
//                        userName: name,
//                        userEmail: email,
//                        userRole: userRole
//                    )
//
//                    await MainActor.run {
//                        self.signedInRole = savedUser.userRole
//                        self.isSignedIn = true
//                        self.isLoading = false
//                        print("[Auth] sign in completed for \(savedUser.userEmail) as \(savedUser.userRole.rawValue)")
//                    }
//                } catch {
//                    await MainActor.run {
//                        self.errorMessage = error.localizedDescription
//                        self.isLoading = false
//                        print("[Auth] sign in failed: \(error.localizedDescription)")
//                    }
//                }
//            }
//
//        case .failure(let error):
//            errorMessage = error.localizedDescription
//            print("[Auth] apple sign in failed: \(error.localizedDescription)")
//        }
//    }
//}

