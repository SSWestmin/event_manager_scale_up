////
////  ArchivedEventsView.swift
////  Event_Manager_Demo
////
////  Created by Sumi Sastri on 22/05/2026.
////
//
//import SwiftUI
//import SwiftData
//
//// USAGE: Admin to archive and then delete events
//
//struct ArchivedEventsView: View {
//    
//    // MARK: Refactor 2 - adminVM now drives views
//    @ObservedObject var adminVM: AdminViewModel
//    
//    @Environment(\.modelContext) private var context
//    
//    var body: some View {
//        Label("Archive Events", systemImage: "document")
//            .font(.title)
//            .padding()
//        VStack{
//            if let event = adminVM.adminCreatedEvents.first {
//                //                            FIXME - ARGUMENTS OF EVENT CARD FOR ADMIN VIEW
//                EventCard(
//                    event: event,
//                    adminVM: adminVM,
//                    attendeeVM: nil
//                )
//                HStack {
//                    Text("Keep or delete?")
//                    Spacer()
//                    Button {
//                        adminVM.deleteAdminEvent(
//                            id: event.event_id,
//                            context:context
//                        )
//                    } label: {
//                        Label("", systemImage: "trash")
//                    }
//                }
//                .padding(.horizontal)
//            }
//        }
//        
//    }
//}
//
//
//#Preview {
//    let container = try! ModelContainer(
//        for: EventModel.self,
//        configurations: .init(isStoredInMemoryOnly: true)
//    )
//    let eventDataCoordinator = EventDataCoordinator()
//    //     MARK: Refactor 2 only adminVM
//    let adminVM = EventViewModel(
//        eventDataCoordinator: eventDataCoordinator
//    )
//    
//    ArchivedEventsView(adminVM: adminVM,)
//        .environmentObject(eventDataCoordinator)
//        .modelContainer(container)
//}
//
