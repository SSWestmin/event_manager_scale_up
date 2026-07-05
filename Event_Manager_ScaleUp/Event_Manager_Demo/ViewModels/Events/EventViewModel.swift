//
//  EventViewModel.swift
//  Event_Manager_Demo
//
//  Created by Sumi Sastri on 21/05/2026.
//

import Foundation
import SwiftData
import Combine


// USAGE: Manages UI state, user input, and presentation logic for event-related views.
// Delegates all data operations to the EventDataCoordinator.
// Provides filtered, formatted, and derived data for lists, maps, and calendar views.


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
    
    
    // MARK: - SwiftData state - separate attendee and admin states
    @Published var attendeeSavedEvents: [EventModel] = []
    @Published var adminCreatedEvents: [EventModel] = []
    
    // MARK: - Form State CHECK FOR CLASHES WITH NON-FORM STATES
    @Published var eventName: String = ""
    @Published var eventDescription: String = ""
    @Published var eventStart: Date = Date()
    @Published var eventEnd: Date = Date()
    //    MARK: Refactor address to match TicketMaster structure
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
    
    // MARK: - Alerts / Navigation
    @Published var showAlert: Bool = false
    @Published var alertTitle = ""
    @Published var alertMessage: String = ""
    @Published var navigateToSavedEvents: Bool = false
    @Published var navigateToCreatedEvents: Bool = false
    
//  MARK: - Form Validation
    var eventFormValidationMessage: String? {
        let name = eventName.trimmingCharacters(in: .whitespacesAndNewlines)
        let description = eventDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        let location = composedLocation.trimmingCharacters(in: .whitespacesAndNewlines)

        if name.isEmpty {
            return "Event name is required."
        }

        if description.isEmpty {
            return "Event description is required."
        }
    // MARK: location fields are required for admin-created events
        if location.isEmpty {
            return "At least one location field is required."
        }

        if eventEnd < eventStart {
            return "Event end date must be on or after the start date."
        }

        return nil
    }

    var isEventFormValid: Bool {
        eventFormValidationMessage == nil
    }

    func validateEventForm() -> Bool {
        formValidationMessage = eventFormValidationMessage ?? ""
        return formValidationMessage.isEmpty
    }

    func resetEventForm() {
        eventName = ""
        eventDescription = ""
        eventStart = Date()
        eventEnd = Date()
        eventLocation = ""
        addressLine1 = ""
        city = ""
        country = ""
        postalCode = ""
        formValidationMessage = ""
        alertTitle = ""
        alertMessage = ""
        showAlert = false
    }

    func seedEventForm(from event: EventModel) {
        eventName = event.eventName
        eventDescription = event.eventDescription
        eventStart = event.eventStart
        eventEnd = event.eventEnd
        eventLocation = event.eventLocation

        let locationParts = event.eventLocation
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }

        addressLine1 = locationParts.indices.contains(0) ? locationParts[0] : ""
        city = locationParts.indices.contains(1) ? locationParts[1] : ""
        country = locationParts.indices.contains(2) ? locationParts[2] : ""
        postalCode = locationParts.indices.contains(3) ? locationParts[3] : ""
        formValidationMessage = ""
    }
    // MARK: - ADMIN: CREATE EVENT () no requirement for TickemasterID
    func createAdminEvent(_ event: EventModel, context: ModelContext) -> Bool {
        event.event_id = UUID()
        context.insert(event)
        do {
            try context.save()
            adminCreatedEvents.append(event)
            operationErrorMessage = ""
            return true
        } catch {
            context.delete(event)
            operationErrorMessage = "Unable to save event: \(error.localizedDescription)"
            return false
        }
    }

    // MARK: - ADMIN: UPDATE EVENT
    func updateAdminEvent(_ existingEvent: EventModel, updatedEvent: EventModel, context: ModelContext) -> Bool {
        let originalEvent = EventModel(
            event_id: existingEvent.event_id,
            user_id: existingEvent.user_id,
//            ticketMasterID: existingEvent.ticketMasterID,
            eventName: existingEvent.eventName,
            eventDescription: existingEvent.eventDescription,
            eventStart: existingEvent.eventStart,
            eventEnd: existingEvent.eventEnd,
            eventLocation: existingEvent.eventLocation,
            ticketPrice: existingEvent.ticketPrice,
            latitude: existingEvent.latitude,
            longitude: existingEvent.longitude,
            created: existingEvent.created,
            changed: existingEvent.changed
        )

        existingEvent.user_id = updatedEvent.user_id
        existingEvent.eventName = updatedEvent.eventName
        existingEvent.eventDescription = updatedEvent.eventDescription
        existingEvent.eventStart = updatedEvent.eventStart
        existingEvent.eventEnd = updatedEvent.eventEnd
        existingEvent.eventLocation = updatedEvent.eventLocation
        existingEvent.ticketPrice = updatedEvent.ticketPrice
        existingEvent.latitude = updatedEvent.latitude
        existingEvent.longitude = updatedEvent.longitude
        existingEvent.changed = Date()

        do {
            try context.save()
            if let index = adminCreatedEvents.firstIndex(where: { $0.event_id == existingEvent.event_id }) {
                adminCreatedEvents[index] = existingEvent
            } else {
                adminCreatedEvents.append(existingEvent)
            }
            operationErrorMessage = ""
            return true
        } catch {
            existingEvent.user_id = originalEvent.user_id
            existingEvent.eventName = originalEvent.eventName
            existingEvent.eventDescription = originalEvent.eventDescription
            existingEvent.eventStart = originalEvent.eventStart
            existingEvent.eventEnd = originalEvent.eventEnd
            existingEvent.eventLocation = originalEvent.eventLocation
            existingEvent.ticketPrice = originalEvent.ticketPrice
            existingEvent.latitude = originalEvent.latitude
            existingEvent.longitude = originalEvent.longitude
            existingEvent.changed = originalEvent.changed

            if let index = adminCreatedEvents.firstIndex(where: { $0.event_id == originalEvent.event_id }) {
                adminCreatedEvents[index] = originalEvent
            }

            operationErrorMessage = "Unable to save event: \(error.localizedDescription)"
            return false
        }
    }

    // MARK: - ADMIN: DELETE EVENT
    func deleteAdminEvent(id: UUID, context: ModelContext) -> Bool {
        guard let index = adminCreatedEvents.firstIndex(where: { $0.event_id == id }) else {
            operationErrorMessage = "Unable to delete event: the event could not be found."
            return false
        }
        let descriptor = FetchDescriptor<EventModel>(
            predicate: #Predicate { $0.event_id == id }
        )

        if let event = try? context.fetch(descriptor).first {
            context.delete(event)
            do {
                try context.save()
                adminCreatedEvents.remove(at: index)
                operationErrorMessage = ""
                return true
            } catch {
                operationErrorMessage = "Unable to delete event: \(error.localizedDescription)"
                return false
            }
        }

        operationErrorMessage = "Unable to delete event: the event could not be loaded from storage."
        return false
    }
    
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
    // MARK: Core filter logic shared by maps, calendars, and lists
    
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


