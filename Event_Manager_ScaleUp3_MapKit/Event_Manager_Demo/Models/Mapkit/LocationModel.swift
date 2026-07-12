//
//  LocationModel.swift
//  Event_Manager_Demo
//
//  Created by Sumi Sastri on 11/07/2026.
//

import Foundation
import SwiftData

// USAGE: Location of the venue to link to Event Model


@Model
class LocationModel: Identifiable, Equatable {
    @Attribute(.unique) var id: UUID = UUID()
    var venueName: String
    var latitude: Double
    var longitude: Double
    var addressLine1: String
    var addressLine2: String
    var city: String
    var country: String
    var postalCode: String
    var created: Date = Date()
    
//  Location model has an array of events
//  inverse 2-sided relationship of Swift data - venue is not venue in Event model
//  it points back to the location model via the events array
//  nullify deletion vs casade which deletes all information in the event data related to entry
    @Relationship(deleteRule: .nullify, inverse: \EventModel.venue)
    var events: [EventModel] = []
    
//  MARK: utitility that stiches the address parts together
    var composedAddress: String {
        [addressLine1, addressLine2, city, country, postalCode]
            .filter { !$0.isEmpty }
            .joined(separator: ", ")
    }
    
    init(id: UUID = UUID(),
         venueName: String,
         latitude: Double,
         longitude: Double,
         addressLine1: String,
         addressLine2: String,
         city: String,
         country: String,
         postalCode: String) {
        self.id = id
        self.venueName = venueName
        self.latitude = latitude
        self.longitude = longitude
        self.addressLine1 = addressLine1
        self.addressLine2 = addressLine2
        self.city = city
        self.country = country
        self.postalCode = postalCode
    }
    
    static func == (lhs: LocationModel, rhs: LocationModel) -> Bool {
        lhs.id == rhs.id
    }
}
