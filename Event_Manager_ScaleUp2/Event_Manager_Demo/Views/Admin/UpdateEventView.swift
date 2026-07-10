//
//  UpdateEventView.swift
//  Event_Manager_Demo
//
//  Created by Sumi Sastri on 22/05/2026.
//

import SwiftUI
import SwiftData

// USAGE: Admin update existing event

struct UpdateEventView: View {
    // MARK: Refactor 2 - adminVM now drives views
    @ObservedObject var adminVM: AdminViewModel
    
    let event: EventModel
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(.white),
                    Color(.blue.withAlphaComponent(0.1))
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                //        MARK: title
                Text("Update Event")
                    .font(.title)
                    .padding()
                
                //            MARK: FORM FIELDS
                HStack {
                    Image(systemName: "pencil")
                        .foregroundColor(.blue)
                    
                    TextField("Event name", text: $adminVM.eventName)
                        .textFieldStyle(.roundedBorder)
                }
                .padding(.horizontal)
                //        MARK: event description
                HStack(alignment: .top) {
                    Image(systemName: "list.bullet")
                        .foregroundColor(.blue)
                    
                    TextField("Event description", text: $adminVM.eventDescription, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                //        MARK: date picker fields
                HStack {
                    Image(systemName: "calendar")
                    
                    DatePicker(
                        "Start",
                        selection: $adminVM.eventStart,
                        displayedComponents: .date
                    )
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal)
                HStack {
                    Image(systemName: "calendar")
                    
                    DatePicker(
                        "End",
                        selection: $adminVM.eventEnd,
                        displayedComponents: .date
                    )
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal)
                //              MARK: location - computed value
                
                HStack {
                    Label {
                        //                        MARK: refactor composed location
                        Text(adminVM.composedLocation.isEmpty ? "Address will appear here" : adminVM.composedLocation)
                            .foregroundColor(adminVM.eventLocation.isEmpty ? .gray : .primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    } icon: {
                        Image(systemName: "pin.fill")
                            .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal)
                //                MARK: Refactor to concat location based on TicketMaster API data
                VStack {
                    HStack {
                        Image(systemName: "")
                            .foregroundColor(.blue)
                        
                        TextField("Address line 1", text: $adminVM.addressLine1)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    HStack {
                        Image(systemName: "")
                            .foregroundColor(.blue)
                        
                        TextField("City", text: $adminVM.city)
                            .textFieldStyle(.roundedBorder)
                    }
                    HStack {
                        Image(systemName: "")
                            .foregroundColor(.blue)
                        
                        TextField("Country", text: $adminVM.country)
                            .textFieldStyle(.roundedBorder)
                    }
                    HStack {
                        Image(systemName: "")
                            .foregroundColor(.blue)
                        
                        TextField("Postal code", text: $adminVM.postalCode)
                            .textFieldStyle(.roundedBorder)
                    }
                }
                .padding(.horizontal)
                
                //                MARK: Bottom update button with ID of selected event
                
                Button {
                    guard adminVM.validateEventForm() else {
                        adminVM.alertTitle = "Validation Error"
                        adminVM.alertMessage = adminVM.formValidationMessage
                        adminVM.showAlert = true
                        return
                    }
                    
                    //                    MARK: Refactor of location to match TicketMaster data structure
                    let eventLocation = [
                        adminVM.addressLine1,
                        adminVM.city,
                        adminVM.country,
                        adminVM.postalCode
                    ].filter { !$0.isEmpty }.joined(separator: ", ")
                    
                    let updatedEvent = EventModel(
                        //                        prevent generating a new ID keep existing ID
                        event_id: event.event_id,
                        user_id: adminVM.currentUserID ?? adminVM.user_id,
                        eventName: adminVM.eventName,
                        eventDescription: adminVM.eventDescription,
                        eventStart: adminVM.eventStart,
                        eventEnd: adminVM.eventEnd,
                        //                        bind location to the filtered and joined version
                        eventLocation: eventLocation,
                        //                        eventLocation: eventVM.eventLocation,
                        ticketPrice: adminVM.ticketPrice,
                        latitude: adminVM.latitude,
                        longitude: adminVM.longitude,
                    )
                    guard adminVM.updateAdminEvent(event, updatedEvent: updatedEvent, context: context) else {
                        adminVM.alertTitle = "Save Failed"
                        adminVM.alertMessage = adminVM.operationErrorMessage
                        adminVM.showAlert = true
                        return
                    }
                    
                    adminVM.alertTitle = "Success"
                    adminVM.alertMessage = "Event updated successfully."
                    adminVM.showAlert = true
                    dismiss()
                } label: {
                    Label("Update", systemImage: "arrow.right")
                }
                .alert(adminVM.alertTitle, isPresented: $adminVM.showAlert) {
                    Button("OK") { }
                } message: {
                    Text(adminVM.alertMessage)
                }
                .frame(maxWidth: 500, alignment: .trailing)
            }
            .onAppear {
                adminVM.seedEventForm(from: event)
            }
        } // End of V Stack
    } // End of Z stack
}


#Preview {
    let container = try! ModelContainer(
        for: EventModel.self,
        configurations: .init(isStoredInMemoryOnly: true)
    )
    let eventDataCoordinator = EventDataCoordinator()
    
    //     MARK: Refactor 2 only adminVM
    let adminVM = AdminViewModel(eventDataCoordinator: eventDataCoordinator)
    
    let sampleEvent = EventModel(
        eventName: "Sample Event",
        eventDescription: "Sample description",
        eventStart: Date(),
        eventEnd: Date(),
        eventLocation: "Sample location",
        ticketPrice: 0,
        latitude: 0,
        longitude: 0
    )
    
    UpdateEventView(
        adminVM:adminVM,
        event: sampleEvent)
    .environmentObject(eventDataCoordinator)
    .modelContainer(container)
}


