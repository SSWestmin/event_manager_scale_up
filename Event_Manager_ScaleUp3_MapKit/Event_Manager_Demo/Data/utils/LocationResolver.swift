////
////  LocationResolver.swift
////  Event_Manager_Demo
////
////  Created by Sumi Sastri on 12/07/2026.
////
//
//import Foundation
//
//
//// MARK: THROW AWAY CODE
//enum LocationResolver {
//    static func geocode(addressLine1: String, addressLine2: city: String, country: String, postalCode: String) async throws -> GeocodedAddress {
//        let address = [addressLine1, city, country, postalCode]
//            .filter { !$0.isEmpty }.joined(separator: ", ")
//        let placemarks = try await CLGeocoder().geocodeAddressString(address)
//        guard let loc = placemarks.first?.location else {
//            throw LocationError.notFound
//        }
//        return GeocodedAddress(latitude: loc.coordinate.latitude, longitude: loc.coordinate.longitude)
//    }
//}
//
//
//enum LocationNormalizer {
//    static func normalizePostcode(_ raw: String) -> String {
//        raw.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
//    }
//
//    static func normalizeAddressComponent(_ raw: String) -> String {
//        raw.trimmingCharacters(in: .whitespacesAndNewlines)
//    }
//
//    static func composeAddress(line1: String, city: String, country: String, postalCode: String) -> String {
//        [line1, city, country, postalCode]
//            .map(normalizeAddressComponent)
//            .filter { !$0.isEmpty }
//            .joined(separator: ", ")
//    }
//}
//
//
//enum EventLocationResolver {
//    static func applyVenue(_ venue: LocationModel, to event: inout EventDraft) {
//        event.venue = venue
//        event.latitude = venue.latitude
//        event.longitude = venue.longitude
//        event.eventLocation = venue.composedAddress
//    }
//}
//
//struct GeocodedAddress {
//    let latitude: Double
//    let longitude: Double
//}
//
//enum LocationError: Error {
//    case notFound
//}
//
//struct AddressSearchService {
//    func geocode(addressLine1: String, addressLine2: String, city: String, country: String, postalCode: String) async throws -> GeocodedAddress {
//        let address = LocationNormalizer.composeAddress(
//            line1: addressLine1,
//            city: city,
//            country: country,
//            postalCode: postalCode
//        )
//        let placemarks = try await CLGeocoder().geocodeAddressString(address)
//        guard let loc = placemarks.first?.location else {
//            throw LocationError.notFound
//        }
//        return GeocodedAddress(latitude: loc.coordinate.latitude, longitude: loc.coordinate.longitude)
//    }
//}
