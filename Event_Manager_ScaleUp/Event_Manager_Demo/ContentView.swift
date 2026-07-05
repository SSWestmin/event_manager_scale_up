//
//  ContentView.swift
//  Event_Manager_Demo
//
//  Created by Sumi Sastri on 21/05/2026.
//


// USAGE: Public views to browse - with search view
// Provides nav to auth, map, calendar searches and details of events
//  COMMAND K (CLEAR CONSOLE)/ COMMAND+ SHIFT + K CLEAN BUILD

import SwiftUI
import SwiftData


struct ContentView: View {
    // MARK: VMs, eventVM is observable, auth is native
    @ObservedObject var eventVM: EventViewModel
    @ObservedObject var authVM: AuthViewModel
    
// MARK: Coordinator
    @EnvironmentObject var eventDataCoordinator: EventDataCoordinator
    
    var body: some View {
        Group {
            if authVM.activeDashboardRoute == .attendee {
                // MARK: Refactor auth navigation stack
                AttendeeDashboard(viewModel: eventVM, authVM: authVM)
            } else if authVM.activeDashboardRoute == .admin {
                // MARK: Refactor auth navigation stack
                AdminDashboard(eventVM: eventVM, authVM: authVM)
            } else {
                NavigationStack {
                    ScrollView {
                        VStack {
                            Image(systemName: "globe")
                                .imageScale(.large)
                                .foregroundStyle(.tint)
                            Text("Welcome to Event Rabbit")
                            Spacer()
                            Spacer()
                            NavigationLink(destination: LoginView(authVM: authVM, eventVM: eventVM)) {
                                Label("Login", systemImage: "person.crop.circle")
                                    .foregroundColor(.blue)
                                    .underline()
                            }
                        }
                        Spacer()
                        EventsListView(eventVM: eventVM)
                    }
                    .padding()
                }
            }
        }
        .onChange(of: authVM.signedInRole) { _, newRole in
            eventVM.currentUserRole = newRole?.rawValue
        }
    }
}

//  MARK: Refactor, pass data (coordinators and VMs into Content views to preview + import SwiftData)

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
    
    ContentView(
        eventVM: eventVM,
        authVM: authVM
    )
    .environmentObject(eventDataCoordinator)
    .modelContainer(container)
}


