//
//  NewEventsView.swift
//  Event_Manager_Demo
//
//  Created by Sumi Sastri on 22/06/2026.
//

import SwiftUI

//
//  NewEventsView.swift
//  Event_Manager_Demo
//
//  Created by Sumi Sastri on 22/06/2026.
//

import SwiftUI
import SwiftData

// USAGE: Read only list of admin created events

struct NewEventsView: View {
    @ObservedObject var eventVM: EventViewModel
    @Environment(\.modelContext) private var context

    var body: some View {
        let events = eventVM.adminCreatedEvents.sorted { $0.eventStart < $1.eventStart }

        VStack(spacing: 12) {
            Label("New Events", systemImage: "calendar.badge.plus")
                .font(.title)
                .padding(.top)

            if events.isEmpty {
                Text("No events created yet.")
                    .foregroundColor(.gray)
            } else {
                List {
                    ForEach(events) { event in
                        VStack(alignment: .leading, spacing: 12) {
                            EventCard(event: event, eventVM: eventVM)

                            HStack {
                                NavigationLink(destination: UpdateEventView(event: event, eventVM: eventVM)) {
                                    Label("Update event", systemImage: "pencil")
                                }

                                Spacer()

                                Button(role: .destructive) {
                                    _ = eventVM.deleteAdminEvent(id: event.event_id, context: context)
                                } label: {
                                    Label("Delete event", systemImage: "trash")
                                }
                            }
                            .padding(.horizontal)
                    }
                        .padding(.vertical, 4)
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

    let eventVM = EventViewModel(
           eventDataCoordinator: eventDataCoordinator
       )

    NewEventsView(eventVM: eventVM)
        .environmentObject(eventDataCoordinator)
        .modelContainer(container)
}

