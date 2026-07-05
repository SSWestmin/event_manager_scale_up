//
//  AttendeeDashboard.swift
//  Event_Manager_Demo
//
//  Created by Sumi Sastri on 20/06/2026.
//

import SwiftUI
import SwiftData

struct AttendeeDashboard: View {
// MARK: Maintain eventVM for attendee till EventKit refactor
    @ObservedObject var viewModel: EventViewModel
    @ObservedObject var authVM: AuthViewModel

    var body: some View {
        // MARK: Refactor auth navigation stack
        NavigationStack {
            VStack(spacing: 16) {
                HStack {
                    Text("Welcome to your dashboard where you can save your favorite events")
                        .font(.headline)

                    Spacer()

                    Button {
                        authVM.logout()
                    } label: {
                        Label("Logout", systemImage: "person.crop.circle.badge.xmark")
                    }
                }

                EventsListView(eventVM: viewModel)
            }
            .navigationDestination(isPresented: $viewModel.navigateToSavedEvents) {
                SavedEventsView(eventVM: viewModel)
            }
            .alert(isPresented: $viewModel.showAlert) {
                Alert(
                    title: Text("Saved Events"),
                    message: Text(viewModel.alertMessage),
                    dismissButton: .default(Text("OK")) {
                        if viewModel.alertMessage.starts(with: "Your event has been saved") {
                            viewModel.navigateToSavedEvents = true
                        }
                    }
                )
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
            let authVM = AuthViewModel(authCoordinator: AuthCoordinator(modelContext: container.mainContext))

        AttendeeDashboard(viewModel: viewModel, authVM: authVM)
        .environmentObject(coordinator)
        .modelContainer(container)
}
