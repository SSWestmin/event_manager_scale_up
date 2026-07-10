////
////  NewEventsView.swift
////  Event_Manager_Demo
////
////  Created by Sumi Sastri on 22/06/2026.
////
//
//import SwiftUI
//import SwiftData
//
//// USAGE: Read only list of admin created events
//
//struct NewEventsView: View {
//    // MARK: Refactor 2 - adminVM now drives views
//    @ObservedObject var adminVM: AdminViewModel
//    
//    @Environment(\.modelContext) private var context
//
//    var body: some View {
//        let events = adminVM.adminCreatedEvents.sorted { $0.eventStart < $1.eventStart }
//
//        VStack(spacing: 12) {
//            Label("New Events", systemImage: "calendar.badge.plus")
//                .font(.title)
//                .padding(.top)
//
//            if events.isEmpty {
//                Text("No events created yet.")
//                    .foregroundColor(.gray)
//            } else {
//                List {
//                    ForEach(events) { event in
//                        VStack(alignment: .leading, spacing: 12) {
////                            FIXME - ARGUMENTS OF EVENT CARD FOR ADMIN VIEW
//                            EventCard(adminVM: adminVM,
//                                      event: event )
//
//                            HStack {
//                                NavigationLink(destination: UpdateEventView(event: event, adminVM: adminVM)) {
//                                    Label("Update event", systemImage: "pencil")
//                                }
//
//                                Spacer()
//
//                                Button(role: .destructive) {
//                                    _ = adminVM.deleteAdminEvent(id: event.event_id, context: context)
//                                } label: {
//                                    Label("Delete event", systemImage: "trash")
//                                }
//                            }
//                            .padding(.horizontal)
//                    }
//                        .padding(.vertical, 4)
//                    }
//                }
//                .listStyle(.plain)
//            }
//        }
//    }
//}
//
//#Preview {
//    let container = try! ModelContainer(
//        for: EventModel.self,
//        configurations: .init(isStoredInMemoryOnly: true)
//    )
//    let eventDataCoordinator = EventDataCoordinator()
//    //     MARK: Refactor 2 only adminVM
//    let adminVM = EventViewModel(
//           eventDataCoordinator: eventDataCoordinator
//       )
//
//    NewEventsView(adminVM: adminVM,)
//        .environmentObject(eventDataCoordinator)
//        .modelContainer(container)
//}
//
//
//
