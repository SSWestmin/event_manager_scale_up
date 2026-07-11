//
//  EventModel.swift
//  Event_Manager_Demo
//
//  Created by Sumi Sastri on 21/05/2026.
//

import Foundation
import SwiftData


// USAGE: Model contract for event views and (event) location views
// Note: maintain var order - CHECK ticketMasterID application in View Model and Coordinator

@Model
class EventModel: Identifiable, Equatable {

    // MARK: - Identifiable Support
    @Attribute(.unique) var event_id: UUID = UUID()   // backend / external ID
    var id: UUID { event_id } // SwiftData ID
    var user_id: UUID = UUID()
    var ticketMasterID: String? // Add ticketMasterID - for non-auth views
    var eventName: String
    var eventDescription: String
    var eventStart: Date
    var eventEnd: Date
    var eventLocation: String
    var ticketPrice: Double
    var latitude: Double
    var longitude: Double
    var isArchived: Bool
    var created: Date
    var changed: Date

    // MARK: - Initialisation
    init(
        event_id: UUID = UUID(),
        user_id: UUID = UUID(),
        ticketMasterID: String? = nil,
        eventName: String,
        eventDescription: String,
        eventStart: Date,
        eventEnd: Date,
        eventLocation: String,
        ticketPrice: Double,
        latitude: Double,
        longitude: Double,
        isArchived: Bool = false,
        created: Date = Date(),
        changed: Date = Date()
    ) {
        self.event_id = event_id
        self.user_id = user_id
        self.ticketMasterID = ticketMasterID
        self.eventName = eventName
        self.eventDescription = eventDescription
        self.eventStart = eventStart
        self.eventEnd = eventEnd
        self.eventLocation = eventLocation
        self.ticketPrice = ticketPrice
        self.latitude = latitude
        self.longitude = longitude
        self.isArchived = isArchived
        self.created = created
        self.changed = changed
    }

    // MARK: - Equatable Support
    static func == (lhs: EventModel, rhs: EventModel) -> Bool {
        lhs.event_id == rhs.event_id
    }
}
