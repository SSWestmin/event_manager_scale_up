//
//  ArchivedEventsView.swift
//  Event_Manager_Demo
//
//  Created by Sumi Sastri on 22/05/2026.
//

import SwiftUI
import SwiftData

// USAGE: Admin to archive and then delete events - future refactor perhaps add status live or inactive/ delete with a rule if inactive for 2 years delete

struct ArchivedEventsView: View {
   
   // MARK: Refactor 2 - adminVM now drives views
   @ObservedObject var adminVM: AdminViewModel
   
   @Environment(\.modelContext) private var context
   
   var body: some View {
       let events = adminVM.archivedEvents.sorted { $0.eventStart < $1.eventStart }

       VStack(spacing: 12) {
           Label("Archive Events", systemImage: "document")
               .font(.title)
               .padding()

           if events.isEmpty {
               Text("No archived events yet.")
                   .foregroundColor(.gray)
           } else {
               ScrollView {
                   VStack(spacing: 16) {
                       ForEach(events, id: \.event_id) { event in
                           ZStack {
                               LinearGradient(
                                   gradient: Gradient(colors: [
                                       Color(.yellow.withAlphaComponent(0.1))
                                   ]),
                                   startPoint: .topLeading,
                                   endPoint: .bottomTrailing
                               )

                               VStack(spacing: 20) {
                                   Label {
                                       Text("Archived Event")
                                           .frame(maxWidth: .infinity, alignment: .leading)
                                   } icon: {
                                       Image(systemName: "archivebox")
                                           .foregroundColor(.blue)
                                   }

                                   HStack {
                                       Label {
                                           Text(event.eventName)
                                               .frame(maxWidth: .infinity, alignment: .leading)
                                       } icon: {
                                           Image(systemName: "pencil")
                                               .foregroundColor(.blue)
                                       }

                                       Label {
                                           Text(event.eventLocation)
                                               .frame(maxWidth: .infinity, alignment: .leading)
                                       } icon: {
                                           Image(systemName: "pin.fill")
                                               .foregroundColor(.blue)
                                       }
                                   }
                                   .padding(.horizontal)

                                   HStack {
                                       Label {
                                           Text("Start: \(event.eventStart.formatted(date: .abbreviated, time: .omitted))")
                                       } icon: {
                                           Image(systemName: "calendar")
                                       }
                                       .frame(maxWidth: .infinity, alignment: .leading)

                                       Label {
                                           Text("End: \(event.eventEnd.formatted(date: .abbreviated, time: .omitted))")
                                       } icon: {
                                           Image(systemName: "calendar")
                                       }
                                       .frame(maxWidth: .infinity, alignment: .leading)
                                   }
                                   .padding(.horizontal)

                                   HStack {
                                       Button(role: .destructive) {
                                           adminVM.deleteArchivedEvent(id: event.event_id, context: context)
                                       } label: {
                                           Label("Delete event", systemImage: "trash")
                                       }
                                   }
                                   .frame(maxWidth: 500, alignment: .trailing)
                                   .padding()
                               }
                           }
                           .cornerRadius(12)
                           .shadow(radius: 2)
                           .padding(.horizontal)
                           .padding(.vertical)
                       }
                   }
               }
           }
       }
       .onAppear {
           adminVM.loadArchivedEvents(context: context)
       }
       
   }
}


#Preview {
   let container = try! ModelContainer(
       for: EventModel.self,
       configurations: .init(isStoredInMemoryOnly: true)
   )
   let eventDataCoordinator = EventDataCoordinator()
    
   //     MARK: Refactor 2 only adminVM
   let adminVM = AdminViewModel(eventDataCoordinator: eventDataCoordinator)
   
   ArchivedEventsView(adminVM: adminVM)
       .environmentObject(eventDataCoordinator)
       .modelContainer(container)
}


    
