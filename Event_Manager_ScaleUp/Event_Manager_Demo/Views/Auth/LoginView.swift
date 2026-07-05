//
//  LoginView.swift
//  Event_Manager_Demo
//
//  Created by Sumi Sastri on 21/05/2026.
//

// USAGE: With Apple signin there is no reg-login

import SwiftUI
import SwiftData

//USAGE: 2 VMs drive different component states
// Auth drives view builder

struct LoginView: View {
    
    @ObservedObject var authVM: AuthViewModel
    @ObservedObject var eventVM: EventViewModel

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.white, Color.yellow.opacity(0.25)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
//MARK: Heading
            VStack(spacing: 32) {
                VStack(spacing: 8) {
                    Text("Welcome to Event Rabbit")
                        .font(.largeTitle.bold())
                    Text("Sign in to browse, save and register for events")
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 60)
// MARK: Login button logic
                if authVM.isLoading {
                    ProgressView("Signing you in...")
                }

                if authVM.statusType == .success {
                    HStack(spacing: 12) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.title2)
                            .foregroundColor(.green)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Sign in successful")
                                .font(.headline)
                            Text(authVM.statusMessage)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        Spacer()
                    }
                    .padding()
                    .background(Color.green.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .padding(.horizontal)
                    .transition(.opacity.combined(with: .scale))
                }
                if authVM.statusType == .failure {
                    HStack(spacing: 12) {
                        Image(systemName: "xmark.octagon.fill")
                            .font(.title2)
                            .foregroundColor(.red)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Sign in failed")
                                .font(.headline)
                            Text(authVM.statusMessage)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        Spacer()
                    }
                    .padding()
                    .background(Color.red.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .padding(.horizontal)
                    .transition(.opacity.combined(with: .scale))
                }
//                 MARK: Mock sign in

                if authVM.activeDashboardRoute == nil {
                    VStack(spacing: 12) {
                        Button {
                            authVM.mockAppleSignIn(
                                email: "admin@eventrabbit.demo",
                                name: "Admin User"
                            )
                        } label: {
                            Text("Demo Admin Sign In")
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.black)
                                .foregroundColor(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        }

                        Button {
                            authVM.mockAppleSignIn(
                                email: "attendee@eventrabbit.demo",
                                name: "Attendee User"
                            )
                        } label: {
                            Text("Demo Attendee Sign In")
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.black)
                                .foregroundColor(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        }

                        Text("Production Apple Sign in is hidden for this student demo.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal)
                }

                Spacer()
            }
            .padding()
            .animation(.spring(response: 0.35, dampingFraction: 0.85), value: authVM.statusType)
        }
//         MARK determine destination validate auth user is signed in with correct role
        .onChange(of: authVM.signedInRole) { _, newRole in
            eventVM.currentUserRole = newRole?.rawValue
        }
    }
}

#Preview {
    //    MARK: Container config
    let container = try! ModelContainer(
        for: EventModel.self,
        configurations: .init(isStoredInMemoryOnly: true)
    )
    //   MARK: Coordinators
    let eventDataCoordinator = EventDataCoordinator()
    
    let authCoordinator = AuthCoordinator(
        modelContext: container.mainContext
    )
    //   MARK: VMs
    let eventVM = EventViewModel(eventDataCoordinator: eventDataCoordinator)
    let authVM = AuthViewModel(authCoordinator: authCoordinator)
    
    LoginView(
        authVM: authVM,
        eventVM: eventVM,

    )
    .environmentObject(eventDataCoordinator)
    .modelContainer(container)
}


