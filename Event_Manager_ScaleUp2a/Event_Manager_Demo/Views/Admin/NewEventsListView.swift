//
//  NewEventsListView.swift
//  Event_Manager_Demo
//
//  Created by Sumi Sastri on 11/07/2026.
//

import SwiftUI
import SwiftData

// USAGE: A list of events created by admin that can be updated or deleted later - ID must be unique and different from the API IDs

struct NewEventsView: View {
    // MARK: Refactor 2 - adminVM now drives views
    @ObservedObject var adminVM: AdminViewModel
    @ObservedObject var eventVM: EventViewModel
    @Environment(\.modelContext) private var context
    @EnvironmentObject var eventDataCoordinator: EventDataCoordinator
    
    var body: some View {
        let events = adminVM.adminCreatedEvents.sorted { $0.eventStart < $1.eventStart }
        
        VStack(spacing: 12) {
            Label("New Events", systemImage: "calendar.badge.plus")
                .font(.title)
                .padding(.top)
            
            if events.isEmpty {
                Text("No events created yet.")
                    .foregroundColor(.gray)
            } else {
                VStack(spacing: 16) {
                    // MARK: Refactor 2 - remove duplicate search bar and show admin-created events
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
                                    Text("New Event")
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

                                HStack {
                                    NavigationLink(
                                        destination: EventCard(
                                            event: event,
                                            eventVM: eventVM
                                        )
                                    ) {
                                        Label("More details", systemImage: "arrow.right")
                                    }
                                    
                                    Spacer()
                                    
                                    NavigationLink(destination: UpdateEventView(
                                        adminVM: adminVM,
                                        event: event
                                    )) {
                                        Label("Update event", systemImage: "pencil")
                                    }
    // MARK: Refactor 2 - archive event decide delete later
                                    Button {
                                        adminVM.archiveAndShowArchivedEvents(id: event.event_id, context: context)
                                    } label: {
                                        Label("Archive event", systemImage: "archivebox")
                                    }
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
        .onAppear {
            adminVM.loadAdminCreatedEvents(context: context)
        }
        .navigationDestination(isPresented: $adminVM.navigateToArchivedEvents) {
            ArchivedEventsView(adminVM: adminVM)
        }
    }
}
#Preview {
   let container = try! ModelContainer(
       for: EventModel.self,
       configurations: .init(isStoredInMemoryOnly: true)
   )
   let eventDataCoordinator = EventDataCoordinator()
   //     MARK: Refactor 2 only adminVM
   let adminVM = AdminViewModel(eventDataCoordinator: eventDataCoordinator)
   let eventVM = EventViewModel(eventDataCoordinator: eventDataCoordinator)

   NewEventsView(adminVM: adminVM, eventVM: eventVM)
       .environmentObject(eventDataCoordinator)
       .modelContainer(container)
}

