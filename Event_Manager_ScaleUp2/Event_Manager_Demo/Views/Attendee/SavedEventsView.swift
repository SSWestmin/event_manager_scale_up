//
// SavedEventsView.swift
//  Event_Manager_MVP
//
//  Created by Sumi Sastri on 21/05/2026.
//

import SwiftUI
import SwiftData

// USAGE:  Refactor 1: Totally driven by attendeeVM, the event saved for persistence or removed
// Query is driven by event data model

struct SavedEventsView: View {
    @ObservedObject var attendeeVM: AttendeeViewModel
    @Query(sort: \EventModel.eventStart) var savedEvents: [EventModel]
    @Environment(\.modelContext) private var context
    
    var body: some View {
        VStack {
            Label("Saved Events", systemImage: "heart.fill")
                .font(.title)
            if attendeeVM.uniqueAttendeeSavedEvents.isEmpty {
                Text("No saved events yet.")
                    .foregroundColor(.gray)
            } else {
                List(attendeeVM.uniqueAttendeeSavedEvents, id: \.event_id) { event in
                    NavigationLink(value: event) {
                        Text(event.eventName)
                    }
                    Button() {
                        attendeeVM
                            .removeAttendeeEvent(id: event.event_id,   context: context)
                    } label: {
                        Image(systemName: "trash")
                    }
                }
                .listStyle(.plain)
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
    
    let attendeeVM = AttendeeViewModel(
        eventDataCoordinator: eventDataCoordinator
    )
    
    SavedEventsView(attendeeVM: attendeeVM)
        .environmentObject(eventDataCoordinator)
        .modelContainer(container)
}
