//
//  CreateEventView.swift
//  Event_Manager_Demo
//
//  Created by Sumi Sastri on 22/05/2026.
//

import SwiftUI
import SwiftData

// USAGE: Admin create new event for admin users only

struct CreateEventView: View {
    // MARK: Refactor 2 - adminVM now drives views
    @ObservedObject var adminVM: AdminViewModel
    
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(.white),
                    Color(.blue.withAlphaComponent(0.25))
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            VStack(spacing: 20) {
                
                //        MARK: title
                Text("Create New Event")
                    .font(.title)
                
                //        MARK: FORM FIELDS
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
                
                //              MARK: Bottom nav add event button
                Button {
                    guard adminVM.validateEventForm() else {
                        adminVM.alertTitle = "Validation Error"
                        adminVM.alertMessage = adminVM.formValidationMessage
                        adminVM.showAlert = true
                        return
                    }
                    
                    let eventLocation = [
                        adminVM.addressLine1,
                        adminVM.city,
                        adminVM.country,
                        adminVM.postalCode
                    ].filter { !$0.isEmpty }.joined(separator: ", ")
                    let newEvent = EventModel(
                        user_id: adminVM.currentUserID ?? adminVM.user_id,
                        eventName: adminVM.eventName,
                        eventDescription: adminVM.eventDescription,
                        eventStart: adminVM.eventStart,
                        eventEnd: adminVM.eventEnd,
                        //                        bind location to the filtered and joined version
                        eventLocation: eventLocation,
                        ticketPrice: adminVM.ticketPrice,
                        latitude: adminVM.latitude,
                        longitude: adminVM.longitude,
                    )
                    
                    // MARK: Success alert
                    guard adminVM.createAdminEvent(newEvent, context: context) else {
                        adminVM.alertTitle = "Save Failed"
                        adminVM.alertMessage = adminVM.operationErrorMessage
                        adminVM.showAlert = true
                        return
                    }
                    
                    adminVM.resetEventForm()
                    adminVM.alertTitle = "Success"
                    adminVM.alertMessage = "Event created successfully."
                    adminVM.showAlert = true
                    dismiss()
                    
                } label: {
                    Label("Add Event", systemImage: "arrow.right")
                }
                //                MARK: DISPLAY ALERT
                .alert(adminVM.alertTitle, isPresented: $adminVM.showAlert) {
                    Button("OK") { }
                } message: {
                    Text(adminVM.alertMessage)
                }
                
                .frame(maxWidth: 500, alignment: .trailing)
            }
            .onAppear {
                adminVM.resetEventForm()
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
    CreateEventView(
        adminVM:adminVM,
    )
    .environmentObject(eventDataCoordinator)
    .modelContainer(container)
}
