//
//  ArchivedEventsView.swift
//  Event_Manager_Demo
//
//  Created by Sumi Sastri on 22/05/2026.
//

import SwiftUI
import SwiftData

// USAGE: Admin to archive and then delete events

struct ArchivedEventsView: View {
    @ObservedObject var eventVM: EventViewModel
    @Environment(\.modelContext) private var context
    
    var body: some View {
        Label("Archive Events", systemImage: "document")
            .font(.title)
            .padding()
        VStack{
            if let event = eventVM.adminCreatedEvents.first {
                EventCard(event: event, eventVM: eventVM)
                HStack {
                    Text("Keep or delete?")
                    Spacer()
                    Button {
                        eventVM.deleteAdminEvent(
                            id: event.event_id,
                            context:context
                        )
                    } label: {
                        Label("", systemImage: "trash")
                    }
                }
                .padding(.horizontal)
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
    
    ArchivedEventsView(eventVM: eventVM,)
        .environmentObject(eventDataCoordinator)
        .modelContainer(container)
}

