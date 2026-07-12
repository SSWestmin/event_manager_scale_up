//
//  LocationDataCoordinator.swift
//  Event_Manager_Demo
//
//  Created by Sumi Sastri on 11/07/2026.
//

import Foundation
import CoreLocation
import Combine
import SwiftData
import MapKit

//USAGE: Pins venue location and user device location using camera location of device
//    MARK: Refactor 3 - fix location with venue location lat/long

@MainActor
class LocationDataCoordinator: ObservableObject {

    @Published var savedLocations: [LocationModel] = []

    private var modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadSavedLocations()
    }

    func loadSavedLocations() {
        let descriptor = FetchDescriptor<LocationModel>(
            sortBy: [SortDescriptor(\.postalCode)]
        )
        do {
            savedLocations = try modelContext.fetch(descriptor)
        } catch {
            savedLocations = []
        }
    }
}
