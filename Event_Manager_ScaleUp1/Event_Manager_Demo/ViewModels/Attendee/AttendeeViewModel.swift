//
//  AttendeeViewModel.swift
//  Event_Manager_Demo
//
//  Created by Sumi Sastri on 05/07/2026.
//


import Foundation
import SwiftData
import Combine


// USAGE: Scale-up Refactor 1 - separataion of concerns
// Attendee views to be driven by attendee view model

@MainActor
class AttendeeViewModel: ObservableObject {
//    MARK: Refactor 1 - attendee view model gets data from event Data as well as auth
    
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
    
    
    // MARK: Refactor 1 - Driven only by authorised attendees removing all admin
    @Published var attendeeSavedEvents: [EventModel] = []

    // MARK: Refactor 1 - No forms validations removed
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
    
    //    MARK: Location matches ticket master
    var composedLocation: String {
        [addressLine1, city, country, postalCode]
            .filter { !$0.isEmpty }
            .joined(separator: ", ")
    }
    
    // MARK: - Alerts / Navigation - remove navigation for admin
    @Published var showAlert: Bool = false
    @Published var alertTitle = ""
    @Published var alertMessage: String = ""
    @Published var navigateToSavedEvents: Bool = false

    
//  MARK: Refactor 1 - removes all forms from attendee view
    // MARK: - ATTENDEE: CHECK SAVED EVENT
    func isAttendeeSavedEvents(ticketmasterID: String) -> Bool {
        attendeeSavedEvents.contains {
            $0.ticketMasterID == ticketmasterID
        }
    }

    var uniqueAttendeeSavedEvents: [EventModel] {
        var seenKeys = Set<String>()

        return attendeeSavedEvents.filter { event in
            let key = attendeeSaveKey(for: event)
            guard !seenKeys.contains(key) else { return false }
            seenKeys.insert(key)
            return true
        }
    }

    private func attendeeSaveKey(for event: EventModel) -> String {
        event.ticketMasterID ?? event.event_id.uuidString
    }

    // MARK: - ATTENDEE: SAVE EVENT
    func saveAttendeeEvent(_ event: EventModel, context: ModelContext) -> Bool {
        let saveKey = attendeeSaveKey(for: event)

        if let ticketMasterID = event.ticketMasterID {
            let descriptor = FetchDescriptor<EventModel>(
                predicate: #Predicate { $0.ticketMasterID == ticketMasterID }
            )

            if let existing = try? context.fetch(descriptor), !existing.isEmpty {
                alertMessage = "This event has already been saved"
                return false
            }
        }

        guard !attendeeSavedEvents.contains(where: {
            attendeeSaveKey(for: $0) == saveKey
        }) else {
            alertMessage = "This event has already been saved"
            return false
        }

        attendeeSavedEvents.append(event)
        context.insert(event)
        try? context.save()
        alertMessage = "Your event has been saved: \(event.eventName)"
        return true
    }

    // MARK: - ATTENDEE: REMOVE SAVED EVENT
    func removeAttendeeEvent(id: UUID, context: ModelContext) {
        attendeeSavedEvents.removeAll { $0.event_id == id }
        let eventID = id

        let descriptor = FetchDescriptor<EventModel>(
            predicate: #Predicate { $0.event_id == eventID }
        )

        if let event = try? context.fetch(descriptor).first {
            context.delete(event)
        }

        try? context.save()
    }
    
    // MARK: Refactor 1 - Remove core event business logic driven by event VM
    
  
}


