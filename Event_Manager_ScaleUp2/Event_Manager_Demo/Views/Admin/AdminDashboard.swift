//
//  AdminDashboard.swift
//  Event_Manager_Demo
//
//  Created by Sumi Sastri on 14/06/2026.
//

import SwiftUI
import SwiftData

struct AdminDashboard: View {
    // MARK: Refactor 2; adminVM drives CRUD
    @ObservedObject var authVM: AuthViewModel
    @ObservedObject var adminVM: AdminViewModel
    @ObservedObject var eventVM: EventViewModel
    
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
                NavigationLink(destination: CreateEventView(adminVM: adminVM)) {
                    Label("Create event", systemImage: "pencil")
                }
                
                EventsListView(eventVM: eventVM)
                //                 MARK: Refactor 2 - the new events come from admin created events list
//                NewEventsView(eventVM: eventVM)
                
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
    
    //     MARK: Refactor 2 VMs in preview
    let authVM = AuthViewModel(authCoordinator: AuthCoordinator(modelContext: container.mainContext))
    let adminVM = AdminViewModel(eventDataCoordinator: eventDataCoordinator)
    let eventVM = EventViewModel(eventDataCoordinator: eventDataCoordinator)
    
    AdminDashboard(
        authVM: authVM,
        adminVM:adminVM,
        eventVM:eventVM)
        .environmentObject(eventDataCoordinator)
        .modelContainer(container)
}
