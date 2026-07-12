//
//  EventViewModel.swift
//  Event_Manager_Demo
//
//  Created by Sumi Sastri on 21/05/2026.
//

import Foundation
import SwiftData
import Combine


// USAGE: Refactor 1: Attendee save event business logic moved to attendeeVM
// Refactor 2: Admin crud business logic moved to adminVM
// Refactor 3: Map business logic moved to locationVM

@MainActor
class EventViewModel: ObservableObject {
    //    MARK: initialise and link data coordinator - refactor rename to eventDataCoordinator
    
    let eventDataCoordinator: EventDataCoordinator
    init(eventDataCoordinator: EventDataCoordinator) {
        self.eventDataCoordinator = eventDataCoordinator
    }
    
    
    // MARK: - API (read only)
    var apiEvents: [EventModel] {
        eventDataCoordinator.events
    }
    
    // MARK: - Auth State (who is in the session - check for API data redundancy)
    @Published var user_id: UUID = UUID()
    @Published var currentUserID: UUID?
    @Published var currentUserRole: String?
    
    
    // MARK: - Search State
    @Published var searchText: String = ""
    
    // MARK: - Calendar State
    @Published var calendarSelectedDate: Date = Date()
    
    
    // MARK: Event states (may not be required)
    @Published var eventName: String = ""
    @Published var eventDescription: String = ""
    @Published var eventStart: Date = Date()
    @Published var eventEnd: Date = Date()
    @Published var eventLocation: String = ""
    @Published var addressLine1: String = ""
    @Published var city: String = ""
    @Published var country: String = ""
    @Published var postalCode: String = ""
    @Published var ticketPrice: Double = 0.0
    @Published var latitude: Double = 51.5074
    @Published var longitude: Double = -0.1278
    @Published var formValidationMessage: String = ""
    @Published var operationErrorMessage: String = ""
    //    MARK: Refactor address to match TicketMaster structure
    var composedLocation: String {
        [addressLine1, city, country, postalCode]
            .filter { !$0.isEmpty }
            .joined(separator: ", ")
    }
    
    // MARK: - Refactor 2 Alerts - remove attendee and admin laerts
    @Published var showAlert: Bool = false
    @Published var alertTitle = ""
    @Published var alertMessage: String = ""
    
    
    //  MARK: Refactor 2 - remove all form logic
    // MARK: Refactor 1 - remove attendee from Event VM
    
    
    // MARK: Refactor 3 Core filter logic shared calendars, and lists remove map
    
    var filteredMapEvents: [EventModel] {
        filter(events: eventDataCoordinator.events.filter {
            $0.latitude != 0.0 && $0.longitude != 0.0
        })
    }
    
    // MARK: - Calendar Filter - refactor to add co-ordinator
    var eventsForSelectedDate: [EventModel] {
        eventDataCoordinator.events.filter { event in
            Calendar.current.isDate(calendarSelectedDate, inSameDayAs: event.eventStart) ||
            (calendarSelectedDate > event.eventStart && calendarSelectedDate <= event.eventEnd)
        }
    }
    
    // MARK: - Update Calendar to First Match - refactor add co-ordinator
    func updateCalendarDateToFirstMatch() {
        let search = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !search.isEmpty else { return }
        
        if let match = eventDataCoordinator.events.first(where: {
            $0.eventName.localizedCaseInsensitiveContains(search) ||
            $0.eventLocation.localizedCaseInsensitiveContains(search)
        }) {
            calendarSelectedDate = match.eventStart
        }
    }
    
    private func filter(events: [EventModel]) -> [EventModel] {
        let search = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        guard !search.isEmpty else { return events }
        
        return events.filter {
            $0.eventName.lowercased().contains(search) ||
            $0.eventLocation.lowercased().contains(search)
        }
    }
    
    
    
    
    
    // MARK: - Date Formatter
    private let formatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        return f
    }()
    
    func formatted(date: Date) -> String {
        formatter.string(from: date)
    }
    
    var formattedCalendarDate: String {
        formatted(date: calendarSelectedDate)
    }
}
