//
//  CalendarView.swift
//  Event_Manager_Demo
//
//  Created by Sumi Sastri on 26/05/2026.
//


import SwiftUI
import EventKit
import Foundation
import SwiftData


// USAGE: Public views to search by date and name of event
// nav back to list view


struct CalendarView: View {
//     Refactored to use eventVM and authVM
    @ObservedObject var eventVM: EventViewModel
    @EnvironmentObject var eventDataCoordinator: EventDataCoordinator
    @Query(sort: \EventModel.eventStart) var events: [EventModel]
    
    var body: some View {
        VStack {
            // MARK: Date picker
            DatePicker(
                "Select Date",
                selection: $eventVM.calendarSelectedDate,
                displayedComponents: [.date]
            )
            .datePickerStyle(.graphical)
            .padding()
            
            // MARK: Search bar for event name
            TextField("Search for event by name", text: $eventVM.searchText, onCommit: eventVM.updateCalendarDateToFirstMatch)
                .padding(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(.darkGray), lineWidth: 1.5)
                )
                .padding(.horizontal)
                .padding(.bottom, 8)
            
            // MARK: Event display
            Text("Events on \(eventVM.formattedCalendarDate):")
                .font(.headline)
                .padding(.top)
            // MARK: Error if no events for the selected date
            if eventVM.eventsForSelectedDate.isEmpty {
                Text("No events scheduled today")
                    .foregroundColor(.secondary)
                    .padding()
                // MARK:Show events for the selected date
            } else {
                List(eventVM.eventsForSelectedDate, id: \.event_id) { event in
                    VStack(alignment: .leading) {
                        Text("\(event.eventName) (\(event.eventLocation))")
                            .font(.body)
                        Text(event.eventDescription)
                            .font(.subheadline)
                        Text("£\(String(format: "%.2f", event.ticketPrice))")
                            .font(.caption)
                        Text("\(eventVM.formatted(date: event.eventStart)) - \(eventVM.formatted(date: event.eventEnd))")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        //        refactor - use coordinator
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
    
    CalendarView(eventVM: eventVM)
        .environmentObject(eventDataCoordinator)
        .modelContainer(container)
}
