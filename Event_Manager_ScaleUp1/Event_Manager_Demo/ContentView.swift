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
    // MARK: Refactor 1 - add observable maintain orderr
    @ObservedObject var authVM: AuthViewModel
    @ObservedObject var attendeeVM: AttendeeViewModel
    @ObservedObject var eventVM: EventViewModel
    
// MARK: Coordinator
    @EnvironmentObject var eventDataCoordinator: EventDataCoordinator
    
    var body: some View {
        Group {
            if authVM.activeDashboardRoute == .attendee {
                // MARK: Refactor 1 - insert attendeeVM
                AttendeeDashboard(
                    authVM: authVM,
                    attendeeVM: attendeeVM,
                    eventVM:eventVM
                )
            } else if authVM.activeDashboardRoute == .admin {
                // MARK: Refactor 1 - authVM drives admin
                AdminDashboard ( eventVM:eventVM,authVM:authVM,)
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
                            NavigationLink(destination: LoginView(authVM: authVM, eventVM: eventVM,)) {
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

//  MARK: Refactor 1 - add attendeeVM

#Preview {
    //    MARK: Container config
    let container = try! ModelContainer(
        for: EventModel.self,
        configurations: .init(isStoredInMemoryOnly: true)
    )
    //   MARK: Coordinators
    let authCoordinator = AuthCoordinator(
        modelContext: container.mainContext
    )
    let eventDataCoordinator = EventDataCoordinator()
    
    //   MARK: VMs
    let authVM = AuthViewModel(authCoordinator: authCoordinator)
    let attendeeVM = AttendeeViewModel(eventDataCoordinator: eventDataCoordinator)
    let eventVM = EventViewModel(eventDataCoordinator: eventDataCoordinator)
    
    ContentView(
        authVM: authVM,
        attendeeVM:attendeeVM,
        eventVM: eventVM,
    )
    .environmentObject(eventDataCoordinator)
    .modelContainer(container)
}


