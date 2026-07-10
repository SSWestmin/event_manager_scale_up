//
//  EventDetailView.swift
//  Event_Manager_Demo
//
//  Created by Sumi Sastri on 05/07/2026.
//

import SwiftUI
import SwiftData

// USAGE: Detail of every event displayed
// Attendee can either view the detail or save individual event


struct EventDetailView: View {
    var events: [EventModel]
    // MARK: Refactor 1 - attendeeVM drives saving of API event data
    @ObservedObject var attendeeVM: AttendeeViewModel
    @ObservedObject var eventVM: EventViewModel
    
    @EnvironmentObject var eventDataCoordinator: EventDataCoordinator
    @Environment(\.modelContext) private var context
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 16) {
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
                        
                        // MARK: For details navigate to the correct event card or save to faves
                        NavigationLink(
                            destination: EventCard(
                                event: event,
                                eventVM: eventVM
                            )
                        ) {
                            Label("More details", systemImage: "arrow.right")
                        }
                        //                                 MARK: Save the event and navigate
                        Button {
                            attendeeVM.navigateToSavedEvents = false
                            if attendeeVM.saveAttendeeEvent(
                                event,
                                context: context
                            ) {
                                attendeeVM.showAlert = true
                            } else {
                                attendeeVM.showAlert = true
                            }
                        } label: {
                            Label("Save to faves", systemImage: "heart.fill")
                        }
                    }
                    .frame(maxWidth: 500, alignment: .trailing)
                    .padding()
                }
                .cornerRadius(12)
                .shadow(radius: 2)
                .padding(.horizontal)
                .padding(.vertical)
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
    
    let attendeeVM=AttendeeViewModel(eventDataCoordinator: eventDataCoordinator)
    let eventVM = EventViewModel(eventDataCoordinator: eventDataCoordinator)
    
    //    MARK: Refactor 1 - display one event from event array
    EventDetailView(events: eventVM.apiEvents,
                    attendeeVM:attendeeVM,
                    eventVM: eventVM)
    .environmentObject(eventDataCoordinator)
    .modelContainer(container)
}
