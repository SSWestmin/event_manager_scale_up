//
//  EventDataCoordinator.swift
//  Event_Manager_Demo
//
//  Created by Sumi Sastri on 14/06/2026.
//

import Foundation
import SwiftData
import Combine

// USAGE:
// Handles API fetching and event state management (READ ONLY).
// Acts as a network data provider for EventViewModel.
// No SwiftData persistence or write operations.

@MainActor
class EventDataCoordinator: ObservableObject {
    
    // MARK: - API Events (READ ONLY SOURCE OF TRUTH - makes sure fetch works)
    @Published var events: [EventModel] = []
    
    // MARK: - Loading State - not purely stateless required to check API call
    @Published var isLoading: Bool = false
    @Published var apiError: String? = nil
    // MARK: - Network Service
    private let apiService = EventAPIService()
    
    init() {}
    
    // MARK: - Fetch Events from API
    func fetchEventsFromAPI() async {
        isLoading = true
        apiError = nil
        
        do {
            let ticketmasterEvents = try await apiService.fetchArtEventsInLondon()
            
            let mappedEvents = ticketmasterEvents.compactMap {
                EventModel(from: $0)
            }
            
            self.events = mappedEvents
            
        } catch {
            self.apiError = mapError(error)
            self.events = []
        }
        
        isLoading = false
    }
        
    // MARK: - Error Mapping (clean UX layer)
    private func mapError(_ error: Error) -> String {
        switch error {
        case URLError.notConnectedToInternet:
            return "No internet connection. Please check your network."
            
        case URLError.timedOut:
            return "Request timed out. Please try again."
            
        default:
            return error.localizedDescription
        }
    }
}
