
//
//  EventPreviewCard.swift
//  Event_Manager_Demo
//
//  Created by Sumi Sastri on 21/05/2026.
//

import SwiftUI
import SwiftData

// USAGE: Reusable card to see event preview and shorten list views

struct EventPreviewCard: View {
    var events: [EventModel]
    @ObservedObject var eventVM: EventViewModel
 
    var body: some View {
        VStack(spacing: 0) {
            // MARK: Scrollable event preview list
            ScrollView {
                VStack(spacing: 16) {
                    VStack {
                        // MARK: Insert search bar to search each card and search by data on the preview card
                        TextField("Search events by name or location", text: $eventVM.searchText)
                            .padding(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(.darkGray), lineWidth: 1.5)
                            )
                            .padding(.horizontal)
                            .padding(.bottom, 8)
                    }

//                    MARK: Show API events
                    ForEach(events, id: \.event_id) { event in
                        ZStack {
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(.yellow.withAlphaComponent(0.1))
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )

                            VStack(spacing: 20) {
                                Label {
                                    Text("Preview Event")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                } icon: {
                                    Image(systemName: "eye")
                                        .foregroundColor(.blue)
                                }

                                HStack {
                                    Label {
                                        Text(event.eventName)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    } icon: {
                                        Image(systemName: "pencil")
                                            .foregroundColor(.blue)
                                    }

                                    Label {
                                        Text(event.eventLocation)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    } icon: {
                                        Image(systemName: "pin.fill")
                                            .foregroundColor(.blue)
                                    }
                                }
                                .padding(.horizontal)

                                HStack {
                                    Label {
                                        Text("Start: \(event.eventStart.formatted(date: .abbreviated, time: .omitted))")
                                    } icon: {
                                        Image(systemName: "calendar")
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                    Label {
                                        Text("End: \(event.eventEnd.formatted(date: .abbreviated, time: .omitted))")
                                    } icon: {
                                        Image(systemName: "calendar")
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .padding(.horizontal)
// MARK: For details navigate to the correct event card
                                NavigationLink(
                                    destination: EventCard(
                                        event: event,
                                        eventVM: eventVM
                                    )
                                ) {
                                    Label("More details", systemImage: "arrow.right")
                                }
                                .frame(maxWidth: 500, alignment: .trailing)
                                .padding()
                            }
                        }
                        .cornerRadius(12)
                        .shadow(radius: 2)
                        .padding(.horizontal)
                        .padding(.vertical)
                    }
                }
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
        
        EventPreviewCard(events: [], eventVM: eventVM)
            .modelContainer(container)
    }

