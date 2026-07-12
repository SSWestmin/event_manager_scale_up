//
//  AttendeeListView.swift
//  Event_Manager_Demo
//
//  Created by Sumi Sastri on 05/07/2026.
//


import SwiftUI
import SwiftData

// USAGE: List view from API call navigates to the event details
// The details can be saved for persistence with the attendeeVM

struct AttendeeListView: View {
    
    @ObservedObject var attendeeVM: AttendeeViewModel
    @ObservedObject var locationVM: LocationViewModel
    @ObservedObject var eventVM: EventViewModel
    
    @EnvironmentObject var eventDataCoordinator: EventDataCoordinator
    @Query(sort: \EventModel.eventStart) var events: [EventModel]
    
    var body: some View {
        //        MARK: Refactor remove conflicting nav stacks add scroll view
        ScrollView{
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
            
            //     MARK: detail of event to be saved card
            EventDetailView(   events: eventVM.apiEvents,
                               attendeeVM: attendeeVM,
                               eventVM: eventVM)
            
            .task {
                await eventDataCoordinator.fetchEventsFromAPI()
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
    
    let locationDataCoordinator = LocationDataCoordinator(modelContext: container.mainContext)
    let locationVM = LocationViewModel(
        locationDataCoordinator: locationDataCoordinator,
        eventDataCoordinator: eventDataCoordinator
    )

    AttendeeListView(attendeeVM: attendeeVM, locationVM: locationVM, eventVM:eventVM)
        .environmentObject(eventDataCoordinator)
        .modelContainer(container)
}




