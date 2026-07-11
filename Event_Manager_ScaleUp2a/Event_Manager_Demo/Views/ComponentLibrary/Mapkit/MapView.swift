//
//  MapView.swift
//  Event_Manager_Demo
//
//  Created by Sumi Sastri on 26/05/2026.
//

import SwiftUI
import MapKit
import SwiftData

// USAGE: Public views to search by and name of event and find event on the map
// nav back to list view (refactor remove mapkit VM and data model)

struct MapView: View {
    // MARK: State object changes to Observed Object of VM (remove MapkitVM - redundant)
    @ObservedObject var eventVM: EventViewModel
   @EnvironmentObject var coordinator: EventDataCoordinator
    
    // MARK: - Camera Position (modern SwiftUI Map API)
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
            
            // MARK: - Title
            Text("Find Events Near You")
                .font(.title)
                .padding(.top)
            
            // MARK: - Search Field FIXME (FILTER BY LOCATION TEXT NOT WORKING - SHOULD VM BE USED?)
            TextField(
                "Search for events by title",
                text: $eventVM.searchText
            )
            .padding(10)
            .background(Color.gray.opacity(0.15))
            .cornerRadius(8)
            .padding([.horizontal, .bottom])
            
            // MARK: - Map + Overlay
            ZStack {
                
                // MARK: Refactor - filter through events using data from coordinator
//                 filter out zero coordinates that mapping returns from API call
                Map(position: $cameraPosition) {
//                    MARK: refactor use coordinator
                    ForEach(coordinator.events.filter {
                        $0.latitude != 0.0 && $0.longitude != 0.0
                    }.filter { event in
                        let search = eventVM.searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
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
                }
                .ignoresSafeArea()
                
                // MARK: - Empty State Overlay - using coordinator refactor
                if coordinator.events.isEmpty {
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
        let coordinator = EventDataCoordinator()
        let viewModel = EventViewModel(eventDataCoordinator: coordinator)

    MapView(eventVM: viewModel)
        .environmentObject(coordinator)
        .modelContainer(container)
}
