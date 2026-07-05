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
//    MARK: schemas in model container
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            EventModel.self,
            UserModel.self
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
    
    // MARK: Coordinators - refactor make coordinators stateless
    private let authCoordinator: AuthCoordinator
    private let eventDataCoordinator: EventDataCoordinator
    
//    MARK: VMs and their data coordinator drivers
    @StateObject private var authViewModel: AuthViewModel
    @StateObject private var attendeeViewModel:AttendeeViewModel
    @StateObject private var eventViewModel: EventViewModel
  
    
    // MARK: Initialisation of coordinators and VMS
    init() {
        let context = sharedModelContainer.mainContext
        
        let authCoordinator = AuthCoordinator(modelContext: context)
        let eventDataCoordinator = EventDataCoordinator()

        self.authCoordinator = authCoordinator
        self.eventDataCoordinator = eventDataCoordinator
//        MARK: VMs
        _authViewModel = StateObject(wrappedValue: AuthViewModel(authCoordinator: authCoordinator))
        _attendeeViewModel = StateObject(wrappedValue: AttendeeViewModel(eventDataCoordinator: eventDataCoordinator))
        _eventViewModel = StateObject(wrappedValue: EventViewModel(eventDataCoordinator: eventDataCoordinator))

    }
    
    var body: some Scene {
        WindowGroup {
            // MARK: coordinators that drive VMs
            ContentView(
                authVM: authViewModel,
                attendeeVM: attendeeViewModel,
                eventVM: eventViewModel,
                        )
                        .environmentObject(eventDataCoordinator)
                        .modelContainer(sharedModelContainer)
                    }
                }
            }
