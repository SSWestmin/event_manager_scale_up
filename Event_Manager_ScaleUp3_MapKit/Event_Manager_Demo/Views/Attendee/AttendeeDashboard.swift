//
//  AttendeeDashboard.swift
//  Event_Manager_Demo
//
//  Created by Sumi Sastri on 20/06/2026.
//

import SwiftUI
import SwiftData

// USAGE: Refactor 1 - Attendee sees dashboard with API & saved events (default)
// API in AttendeeListview and SavedEventsView populated on save click
// Preview card shows detail of event and allows event to be saved

struct AttendeeDashboard: View {
    // MARK: Refactor 1: VMs - auth drives logout, eventVM drives API call
    // attendeeVM drives the save to faves and saved events view
    @ObservedObject var authVM: AuthViewModel
    @ObservedObject var attendeeVM: AttendeeViewModel
    @ObservedObject var locationVM: LocationViewModel
    @ObservedObject var eventVM: EventViewModel
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                HStack {
                    Text("Welcome to your dashboard where you can save your favorite events")
                        .font(.headline)
                    Spacer()
                    Button {
                        authVM.logout()
                    } label: {
                        Label("Logout", systemImage: "person.crop.circle.badge.xmark")
                    }
                }
                
                //                MARK: Refactor 1 eventVM drives API
                //                MARK: Refactor 1 attendeeVM drives persistence - saved events
                AttendeeListView(attendeeVM: attendeeVM, locationVM: locationVM, eventVM: eventVM)
                SavedEventsView(attendeeVM: attendeeVM)
            }
        }
    }
}

#Preview {
    let container = try! ModelContainer(
        for: EventModel.self,
        configurations: .init(isStoredInMemoryOnly: true)
    )
    let eventDataCoordinator = EventDataCoordinator()
    //     MARK: Refactor 1 VMs in preview
    let authVM = AuthViewModel(authCoordinator: AuthCoordinator(modelContext: container.mainContext))
    let attendeeVM = AttendeeViewModel(eventDataCoordinator: eventDataCoordinator)
    let locationDataCoordinator = LocationDataCoordinator(modelContext: container.mainContext)
    let locationVM = LocationViewModel(
        locationDataCoordinator: locationDataCoordinator,
        eventDataCoordinator: eventDataCoordinator
    )
    let eventVM = EventViewModel(eventDataCoordinator: eventDataCoordinator)
    
    AttendeeDashboard(authVM: authVM, attendeeVM:attendeeVM, locationVM: locationVM, eventVM:eventVM)
        .environmentObject(eventDataCoordinator)
        .modelContainer(container)
}
