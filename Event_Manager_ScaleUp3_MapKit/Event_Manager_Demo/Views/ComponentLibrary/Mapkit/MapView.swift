//
//  MapView.swift
//  Event_Manager_Demo
//
//  Created by Sumi Sastri on 26/05/2026.
//

import SwiftUI
import MapKit
import SwiftData

// USAGE: View a map and see events from API call in markers
// As well as events from Admin user newly created events list


struct MapView: View {
    // MARK: Refactor 3 - move to locationVM and locationDataCoordinator
    // NOTE: The component requires both event and map data to coordinate pins
    
    @ObservedObject var locationVM: LocationViewModel
    @ObservedObject var eventVM: EventViewModel
    
    // MARK: Refactor 3 - move cameraPosition to locationVM
    
    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: 51.5074,
                longitude: -0.1278
            ),
            span: MKCoordinateSpan(
                latitudeDelta: 0.2,
                longitudeDelta: 0.2
            )
        )
    )
    
    
    // MARK: - Body
    var body: some View {
        
        VStack(spacing: 0) {
            
            // MARK: - Title - driven by events?
            Text("Find Events Near You")
                .font(.title)
                .padding(.top)
            
            // MARK: Search - driven by events?
            TextField(
                "Search for events by title",
                text: $locationVM.searchText
            )
            .padding(10)
            .background(Color.gray.opacity(0.15))
            .cornerRadius(8)
            .padding([.horizontal, .bottom])
            
            // MARK: - Map + Overlay
            ZStack {
                
                // MARK: Refactor 3 - data driven by 2 coordinators
                // API events and location annotations are rendered together on one map layer.
                Map(position: $cameraPosition) {
                    ForEach(eventVM.apiEvents.filter {
                        $0.latitude != 0.0 && $0.longitude != 0.0
                    }.filter { event in
                        let search = locationVM.searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                        guard !search.isEmpty else { return true }
                        return event.eventName.lowercased().contains(search) ||
                        event.eventLocation.lowercased().contains(search)
                    }, id: \.event_id) { event in
                        Marker(event.eventName,
                               coordinate: CLLocationCoordinate2D(
                                latitude: event.latitude,
                                longitude: event.longitude
                               ))
                    }

                    // MARK: Refactor 3 - location coordinator for admin created events
                    ForEach(locationVM.mapAnnotations) { item in
                        Marker(item.title, coordinate: item.coordinate)
                    }
                }
                .ignoresSafeArea()
                
                // MARK: - Empty State Overlay  - if either no data in API or Swift Data
                if eventVM.apiEvents.isEmpty && locationVM.mapAnnotations.isEmpty {
                    Text("No events found.")
                        .font(.callout)
                        .foregroundColor(.secondary)
                        .padding(12)
                        .background(.white.opacity(0.9))
                        .cornerRadius(10)
                        .shadow(radius: 2)
                }
            }
        }
    }
}


#Preview {
    let container = try! ModelContainer(
        for: EventModel.self,
        configurations: .init(isStoredInMemoryOnly: true)
    )
    let eventDataCoordinator = EventDataCoordinator()
    let locationDataCoordinator = LocationDataCoordinator(
        modelContext: container.mainContext)
    
    
    let eventVM = EventViewModel(eventDataCoordinator: eventDataCoordinator)
    let locationVM = LocationViewModel(
        locationDataCoordinator: locationDataCoordinator,
        eventDataCoordinator: eventDataCoordinator
    )
    
    MapView(locationVM: locationVM, eventVM:eventVM)
        .modelContainer(container)
}

