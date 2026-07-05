// eventapi_DTO.swift
// Ticketmaster Event API response models (DTOs)
// See: https://developer.ticketmaster.com/products-and-docs/apis/discovery-api/v2/
// Created: 31/05/2026, Renamed: 31/05/2026

import Foundation

// MARK: - Ticketmaster Event Response - data structure
// data-contract set by the API
// DTO(Decodable or Transfer Object) Models
struct TicketmasterEventResponse: Codable {
    let embedded: TicketmasterEmbeddedEvents?
    enum CodingKeys: String, CodingKey {
        case embedded = "_embedded"
    }
}

struct TicketmasterEmbeddedEvents: Codable {
    let events: [TicketmasterEvent]?
}

// FIXME: What are the embedded details - description?
struct TicketmasterEvent: Codable {
    let id: String?
    let name: String?
    let url: String?
    let dates: TicketmasterEventDates?
    let info: String?
    let embedded: TicketmasterEmbeddedVenues?
    enum CodingKeys: String, CodingKey {
        case id, name, url, dates, info
        case embedded = "_embedded"
    }
}

// FIXME: Understand the mapping of start-end dates
struct TicketmasterEventDates: Codable {
    let start: TicketmasterEventStart?
}

struct TicketmasterEventStart: Codable {
    let dateTime: String?
    let localDate: String?
    let localTime: String?
}

struct TicketmasterEmbeddedVenues: Codable {
    let venues: [TicketmasterVenue]?
}

//FIXME: Event location does not map well to the ticketmaster venue details

struct TicketmasterVenue: Codable {
    let name: String?
    let address: TicketmasterAddress?
    let city: TicketmasterCity?
    let state: TicketmasterState?
    let country: TicketmasterCountry?
    let postalCode: String?
    let location: TicketmasterLocation?
}


struct TicketmasterAddress: Codable {
    let line1: String?
}

struct TicketmasterState: Codable {
    let name: String?
}

struct TicketmasterLocation: Codable {
    let latitude: String?
    let longitude: String?
}

struct TicketmasterCity: Codable {
    let name: String?
}

struct TicketmasterCountry: Codable {
    let name: String?
}
