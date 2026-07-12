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
    // MARK: Refactor 1 & 2 - add observable maintain orderr
    @ObservedObject var authVM: AuthViewModel
    @ObservedObject var adminVM: AdminViewModel
    @ObservedObject var attendeeVM: AttendeeViewModel
    @ObservedObject var eventVM: EventViewModel
    @ObservedObject var locationVM: LocationViewModel
    
// MARK: Coordinator
    @EnvironmentObject var eventDataCoordinator: EventDataCoordinator
    
    var body: some View {
        Group {
            if authVM.activeDashboardRoute == .attendee {
                // MARK: Refactor 1 - insert attendeeVM
                AttendeeDashboard(
                    authVM: authVM,
                    attendeeVM: attendeeVM,
                    locationVM: locationVM,
                    eventVM:eventVM
                )
            } else if authVM.activeDashboardRoute == .admin {
                // MARK: Refactor 2 - insert adminVM
                AdminDashboard (
                    authVM:authVM,
                    adminVM: adminVM,
                    locationVM: locationVM,
                    eventVM: eventVM
                )
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
                        EventsListView(locationVM: locationVM, eventVM: eventVM)
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
    let locationDataCoordinator = LocationDataCoordinator(
        modelContext: container.mainContext)
    
    //   MARK: VMs
    let authVM = AuthViewModel(authCoordinator: authCoordinator)
    let adminVM = AdminViewModel(eventDataCoordinator: eventDataCoordinator)
    let attendeeVM = AttendeeViewModel(eventDataCoordinator: eventDataCoordinator)
    let eventVM = EventViewModel(eventDataCoordinator: eventDataCoordinator)
//   MARK: Dependent on location and event data
    let locationVM = LocationViewModel(
        locationDataCoordinator: locationDataCoordinator,
        eventDataCoordinator: eventDataCoordinator
    )
    
    ContentView(
        authVM: authVM,
        adminVM: adminVM,
        attendeeVM:attendeeVM,
        eventVM: eventVM,
        locationVM: locationVM
    )
    .environmentObject(eventDataCoordinator)
    .modelContainer(container)
}


