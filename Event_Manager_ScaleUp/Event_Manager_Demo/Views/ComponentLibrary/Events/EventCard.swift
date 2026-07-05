//
//  EventCard.swift
//  Event_Manager_Demo
//
//  Created by Sumi Sastri on 21/05/2026.
//

import SwiftUI
import SwiftData

// USAGE: Reusable card to see event details from a preview
// Note: nav not required auto toggle with nav stack
// conditionally renders card to admin or attendee based on role

struct EventCard: View {
    var event: EventModel
    @ObservedObject var eventVM: EventViewModel
    @EnvironmentObject var eventDataCoordinator: EventDataCoordinator
    @Environment(\.modelContext) private var context
    
    // MARK: Session based assignment of role
    private var userRole: String? {
        eventVM.currentUserRole
    }
    
    var body: some View {
        // MARK: Refactor auth navigation stack
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(.white),
                    Color(.yellow.withAlphaComponent(0.5))
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            VStack(spacing: 20) {
                Text("Event Details")
                    .font(.title)
                HStack {
                    // MARK: Event name
                    Label {
                        Text(event.eventName)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    } icon: {
                        Image(systemName: "pencil")
                            .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal)
                HStack {
                    // MARK: Event description
                    Label {
                        Text(event.eventDescription)
                            .frame(maxWidth: 350, alignment: .leading)
                    } icon: {
                        Image(systemName: "list.bullet")
                            .foregroundColor(.blue)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                HStack {
                    // MARK: Event start date
                    Label {
                        Text("Start: \(event.eventStart.formatted(date: .abbreviated, time: .omitted))")
                    } icon: {
                        Image(systemName: "calendar")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal)
                HStack{
                    // MARK: Event end date
                    Label {
                        Text("End: \(event.eventEnd.formatted(date: .abbreviated, time: .omitted))")
                    } icon: {
                        Image(systemName: "calendar")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal)
                HStack {
                    // MARK: Event location
                    Label {
                        Text(event.eventLocation)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    } icon: {
                        Image(systemName: "pin.fill")
                            .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal)
                // MARK: Event price (note only for prototype
                // To be refactored with ticket model and purchase flow)
                HStack {
                    Label {
                        Text(event.ticketPrice, format: .currency(code: "GBP"))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    } icon: {
                        Image(systemName: "ticket")
                            .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal)
                if userRole == "attendee" {
                    Button {
                        eventVM.navigateToSavedEvents = false
                        if eventVM.saveAttendeeEvent(
                            event,
                            context: context
                        ) {
                            eventVM.showAlert = true
                        } else {
                            eventVM.showAlert = true
                        }
                    } label: {
                        Label("Save to faves", systemImage: "heart.fill")
                    }
                }
            }
        }
    }
}

    #Preview {
    // MARK: Container config
    let container = try! ModelContainer(
        for: EventModel.self,
        configurations: .init(isStoredInMemoryOnly: true)
    )

    // MARK: Coordinators
    let eventDataCoordinator = EventDataCoordinator()

    let authCoordinator = AuthCoordinator(
        modelContext: container.mainContext
    )
    // MARK: VMs
    let eventVM = EventViewModel(eventDataCoordinator: eventDataCoordinator)
    let _ = AuthViewModel(authCoordinator: authCoordinator)

    // MARK: Default sample event
    let sampleEvent = EventModel(
        eventName: "Sample Event",
        eventDescription: "A test event",
        eventStart: Date(),
        eventEnd: Date().addingTimeInterval(3600),
        eventLocation: "London",
        ticketPrice: 10.0,
        latitude: 51.5074,
        longitude: -0.1278
    )
    // View requires a sample event as argument
    EventCard(event: sampleEvent, eventVM: eventVM)
        .environmentObject(eventDataCoordinator)
        .modelContainer(container)
    }
