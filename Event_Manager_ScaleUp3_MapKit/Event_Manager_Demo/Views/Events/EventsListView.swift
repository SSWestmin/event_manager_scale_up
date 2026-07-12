//
//  EventsListView.swift
//  Event_Manager_MVP
//
//  Created by Sumi Sastri on 21/05/2026.
//

import SwiftUI
import SwiftData

// USAGE: List view navs to map and calendar view with search bar
// Nav stack provides immediate nav back to this view

struct EventsListView: View {
    @ObservedObject var locationVM: LocationViewModel
    @ObservedObject var eventVM: EventViewModel
    @EnvironmentObject var eventDataCoordinator: EventDataCoordinator
    @Query(sort: \EventModel.eventStart) var events: [EventModel]
    
    var body: some View {
        NavigationStack {
            Text("Browse Events")
                .font(.title)
//             MARK: Navigate to Map view
            HStack{
                NavigationLink(destination: MapView(locationVM: locationVM, eventVM: eventVM)) {
                    Label("Map View", systemImage: "arrow.left")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()
//              MARK: Navigate to Calendar View
                NavigationLink(destination: CalendarView(eventVM: eventVM)) {
                    Label("Calendar View", systemImage: "arrow.right")
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
//     MARK: preview card
            EventPreviewCard(
                events: eventVM.apiEvents,
                eventVM: eventVM
            )
            
        }
        .task {
            await eventDataCoordinator.fetchEventsFromAPI()
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

    let locationDataCoordinator = LocationDataCoordinator(modelContext: container.mainContext)
    let locationVM = LocationViewModel(
        locationDataCoordinator: locationDataCoordinator,
        eventDataCoordinator: eventDataCoordinator
    )

    EventsListView(locationVM: locationVM, eventVM: eventVM)
        .environmentObject(eventDataCoordinator)
        .modelContainer(container)
}




