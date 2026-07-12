//
//  LocationViewModel.swift
//  Event_Manager_Demo
//
//  Created by Sumi Sastri on 11/07/2026.
//

import Foundation
import SwiftData
import Combine
import MapKit
import SwiftUI


//USAGE: VM drives Map views
// Business logic to use camera position for user device location
// Pins venue location on map sorts events by those closest to user device
// filtered map events (move from Event VM) in refactor
// 2 controllers - Directions controller
// Provides "legs" or route steps for each route driven by directions controller
// active route (user on which route)
// text steps can be used for text-to-voice feature

struct MapAnnotationItem: Identifiable {
    let id: UUID
    let title: String
    let coordinate: CLLocationCoordinate2D
}

@MainActor
class LocationViewModel: ObservableObject {

    let locationDataCoordinator: LocationDataCoordinator
    let eventDataCoordinator: EventDataCoordinator

    init(locationDataCoordinator: LocationDataCoordinator, eventDataCoordinator: EventDataCoordinator) {
        self.locationDataCoordinator = locationDataCoordinator
        self.eventDataCoordinator = eventDataCoordinator
    }
// Note: SwiftUI import required for camera postion even though this is the VM
    @Published var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 51.5074, longitude: -0.1278),
            span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
        )
    )

    @Published var searchText: String = ""

    // Joins event (what) + venue (where) into one thing the Map can render
    var mapAnnotations: [MapAnnotationItem] {
        let search = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        return eventDataCoordinator.events.compactMap { event -> MapAnnotationItem? in
            guard let venue = event.venue,
                  venue.latitude != 0.0, venue.longitude != 0.0 else { return nil }

            if !search.isEmpty {
                let matches = event.eventName.lowercased().contains(search)
                    || venue.venueName.lowercased().contains(search)
                guard matches else { return nil }
            }

            return MapAnnotationItem(
                id: event.event_id,
                title: event.eventName,
                coordinate: CLLocationCoordinate2D(latitude: venue.latitude, longitude: venue.longitude)
            )
        }
    }
}
