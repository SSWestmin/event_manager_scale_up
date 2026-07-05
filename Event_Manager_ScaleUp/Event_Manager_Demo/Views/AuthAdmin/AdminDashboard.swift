//
//  AdminDashboard.swift
//  Event_Manager_Demo
//
//  Created by Sumi Sastri on 14/06/2026.
//

import SwiftUI
import SwiftData

struct AdminDashboard: View {
    @ObservedObject var eventVM: EventViewModel
    @ObservedObject var authVM: AuthViewModel
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("Welcome to your dashboard where you can create, update, archive or delete events")
                    .font(.headline)
                 HStack {
                        Button {
                            authVM.logout()
                        } label: {
                            Label("Logout", systemImage: "person.crop.circle.badge.xmark")
                        }
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    Text("Manage events")
                        .font(.title)
                    NavigationLink(destination: CreateEventView(eventVM: eventVM)) {
                        Label("Create event", systemImage: "pencil")
                    }
                
                EventsListView(eventVM: eventVM)
                NewEventsView(eventVM: eventVM)
                
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

    let eventVM = EventViewModel(
           eventDataCoordinator: eventDataCoordinator
       )
AdminDashboard(eventVM: eventVM, authVM: AuthViewModel(authCoordinator: AuthCoordinator(modelContext: container.mainContext)))
    .environmentObject(eventDataCoordinator)
    .modelContainer(container)
}

