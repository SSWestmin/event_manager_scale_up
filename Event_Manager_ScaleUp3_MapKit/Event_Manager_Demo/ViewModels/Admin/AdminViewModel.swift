//
//  AdminViewModel.swift
//  Event_Manager_Demo
//
//  Created by Sumi Sastri on 05/07/2026.
//

import Foundation
import SwiftData
import Combine


// USAGE: Refactor 2: Retains admin/ event business logic to drive admin views

@MainActor
class AdminViewModel: ObservableObject {
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
    
    
    // MARK: - Refactor 2: SwiftData state - separate attendee and admin states
    @Published var adminCreatedEvents: [EventModel] = []
    @Published var archivedEvents: [EventModel] = []
    
    // MARK: - Form State
    @Published var eventName: String = ""
    @Published var eventDescription: String = ""
    @Published var eventStart: Date = Date()
    @Published var eventEnd: Date = Date()
// MARK: location
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

    func normalizedEventText(_ value: String) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmed.isEmpty else { return "" }

        if trimmed == trimmed.uppercased() {
            return trimmed.lowercased().capitalized
        }

        return trimmed
    }

    var normalizedComposedLocation: String {
        [addressLine1, city, country, postalCode]
            .map(normalizedEventText)
            .filter { !$0.isEmpty }
            .joined(separator: ", ")
    }
    
    // MARK: - Alerts / Navigation - remove navigation for attendee
    @Published var showAlert: Bool = false
    @Published var alertTitle = ""
    @Published var alertMessage: String = ""
    @Published var navigateToCreatedEvents: Bool = false
    // MARK: Refactor 2 - route archived events from the active list
    @Published var navigateToArchivedEvents: Bool = false
    
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

    func loadAdminCreatedEvents(context: ModelContext) {
        let descriptor = FetchDescriptor<EventModel>(
            predicate: #Predicate { !$0.isArchived },
            sortBy: [SortDescriptor(\EventModel.eventStart)]
        )

        do {
            adminCreatedEvents = try context.fetch(descriptor)
        } catch {
            operationErrorMessage = "Unable to load events: \(error.localizedDescription)"
        }
    }

    func loadArchivedEvents(context: ModelContext) {
        let descriptor = FetchDescriptor<EventModel>(
            predicate: #Predicate { $0.isArchived },
            sortBy: [SortDescriptor(\EventModel.eventStart)]
        )

        do {
            archivedEvents = try context.fetch(descriptor)
        } catch {
            operationErrorMessage = "Unable to load archived events: \(error.localizedDescription)"
        }
    }

    // MARK: Refactor 2 - archive event decide delete later
    func archiveAdminEvent(id: UUID, context: ModelContext) {
        guard let index = adminCreatedEvents.firstIndex(where: { $0.event_id == id }) else {
            operationErrorMessage = "Unable to archive event: the event could not be found."
            return
        }

        let event = adminCreatedEvents[index]
        event.isArchived = true

        do {
            try context.save()
            adminCreatedEvents.remove(at: index)
            archivedEvents.insert(event, at: 0)
            navigateToArchivedEvents = true
            operationErrorMessage = ""
        } catch {
            event.isArchived = false
            operationErrorMessage = "Unable to archive event: \(error.localizedDescription)"
        }
    }

    // MARK: Refactor 2 - keep the view as a thin action trigger
    func archiveAndShowArchivedEvents(id: UUID, context: ModelContext) {
        archiveAdminEvent(id: id, context: context)
    }

    func deleteArchivedEvent(id: UUID, context: ModelContext) {
        guard let index = archivedEvents.firstIndex(where: { $0.event_id == id }) else {
            operationErrorMessage = "Unable to delete event: the archived event could not be found."
            return
        }

        let event = archivedEvents[index]
        context.delete(event)

        do {
            try context.save()
            archivedEvents.remove(at: index)
            operationErrorMessage = ""
        } catch {
            operationErrorMessage = "Unable to delete event: \(error.localizedDescription)"
        }
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
    
    // MARK: Refactor 2 - separate admin from attendee and event models
}

