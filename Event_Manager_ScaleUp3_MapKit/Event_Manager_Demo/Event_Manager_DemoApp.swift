//
//  Event_Manager_DemoApp.swift
//  Event_Manager_Demo
//
//  Created by Sumi Sastri on 21/05/2026.
//

import SwiftUI
import SwiftData

// ROOT FILE - creates the model container and
// injects it into the environment for app-wide access

@main
struct Event_Manager_DemoApp: App {
    //    MARK: Model schemas in container
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            EventModel.self,
            UserModel.self,
            LocationModel.self
        ])
        
        let config = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )
        
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    // MARK: Coordinators ensure coordinaators are stateless
    private let authCoordinator: AuthCoordinator
    private let eventDataCoordinator: EventDataCoordinator
    private let locationDataCoordinator: LocationDataCoordinator
    
    //    MARK: Stateful VMs data from coordinators drive views
    @StateObject private var authViewModel: AuthViewModel
    @StateObject private var adminViewModel:AdminViewModel
    @StateObject private var attendeeViewModel:AttendeeViewModel
    @StateObject private var eventViewModel: EventViewModel
    @StateObject private var locationViewModel: LocationViewModel
    
    
    // MARK: Initialisation of coordinators and VMS
    init() {
        let context = sharedModelContainer.mainContext
        
        let authCoordinator = AuthCoordinator(modelContext: context)
        let eventDataCoordinator = EventDataCoordinator()
        let locationDataCoordinator = LocationDataCoordinator(modelContext: context)
        
        self.authCoordinator = authCoordinator
        self.eventDataCoordinator = eventDataCoordinator
        self.locationDataCoordinator = locationDataCoordinator
        //        MARK: VMs
        _authViewModel = StateObject(wrappedValue: AuthViewModel(authCoordinator: authCoordinator))
        _adminViewModel = StateObject(wrappedValue: AdminViewModel(eventDataCoordinator: eventDataCoordinator))
        _attendeeViewModel = StateObject(wrappedValue: AttendeeViewModel(eventDataCoordinator: eventDataCoordinator))
        _eventViewModel = StateObject(wrappedValue: EventViewModel(eventDataCoordinator: eventDataCoordinator))
        _locationViewModel = StateObject(wrappedValue: LocationViewModel(
            locationDataCoordinator: locationDataCoordinator,
            eventDataCoordinator: eventDataCoordinator
        ))
        
    }
//     MARK: Pass VMs with views
    var body: some Scene {
        WindowGroup {
            // MARK: VMs
            ContentView(
                authVM: authViewModel,
                adminVM: adminViewModel,
                attendeeVM: attendeeViewModel,
                eventVM: eventViewModel,
                locationVM: locationViewModel
            )
            .environmentObject(eventDataCoordinator)
            .modelContainer(sharedModelContainer)
        }
    }
}
