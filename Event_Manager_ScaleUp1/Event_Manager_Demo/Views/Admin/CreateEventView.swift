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
    // MARK: State object changes to Observed Object of VM
    @ObservedObject var eventVM: EventViewModel
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

                    TextField("Event name", text: $eventVM.eventName)
                        .textFieldStyle(.roundedBorder)
                }
                .padding(.horizontal)
                //        MARK: event description
                HStack(alignment: .top) {
                    Image(systemName: "list.bullet")
                        .foregroundColor(.blue)

                    TextField("Event description", text: $eventVM.eventDescription, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                //        MARK: date picker fields
                HStack {
                    Image(systemName: "calendar")

                    DatePicker(
                        "Start",
                        selection: $eventVM.eventStart,
                        displayedComponents: .date
                    )
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal)
                HStack {
                    Image(systemName: "calendar")

                    DatePicker(
                        "End",
                        selection: $eventVM.eventEnd,
                        displayedComponents: .date
                    )
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal)
                //              MARK: location - computed value
                
                HStack {
                    Label {
                        //                        MARK: refactor composed location
                        Text(eventVM.composedLocation.isEmpty ? "Address will appear here" : eventVM.composedLocation)
                            .foregroundColor(eventVM.eventLocation.isEmpty ? .gray : .primary)
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

                        TextField("Address line 1", text: $eventVM.addressLine1)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    HStack {
                        Image(systemName: "")
                            .foregroundColor(.blue)

                        TextField("City", text: $eventVM.city)
                            .textFieldStyle(.roundedBorder)
                    }
                    HStack {
                        Image(systemName: "")
                            .foregroundColor(.blue)

                        TextField("Country", text: $eventVM.country)
                            .textFieldStyle(.roundedBorder)
                    }
                    HStack {
                        Image(systemName: "")
                            .foregroundColor(.blue)

                        TextField("Postal code", text: $eventVM.postalCode)
                            .textFieldStyle(.roundedBorder)
                    }
                }
                .padding(.horizontal)
                
                //              MARK: Bottom nav add event button
                Button {
                    guard eventVM.validateEventForm() else {
                        eventVM.alertTitle = "Validation Error"
                        eventVM.alertMessage = eventVM.formValidationMessage
                        eventVM.showAlert = true
                        return
                    }

                    let eventLocation = [
                        eventVM.addressLine1,
                        eventVM.city,
                        eventVM.country,
                        eventVM.postalCode
                    ].filter { !$0.isEmpty }.joined(separator: ", ")
                    let newEvent = EventModel(
                        user_id: eventVM.currentUserID ?? eventVM.user_id,
                        eventName: eventVM.eventName,
                        eventDescription: eventVM.eventDescription,
                        eventStart: eventVM.eventStart,
                        eventEnd: eventVM.eventEnd,
                        //                        bind location to the filtered and joined version
                        eventLocation: eventLocation,
                        ticketPrice: eventVM.ticketPrice,
                        latitude: eventVM.latitude,
                        longitude: eventVM.longitude,
                    )
                    //                    eventVM.createEvent(newEvent)
                    // MARK: Success alert
                    guard eventVM.createAdminEvent(newEvent, context: context) else {
                        eventVM.alertTitle = "Save Failed"
                        eventVM.alertMessage = eventVM.operationErrorMessage
                        eventVM.showAlert = true
                        return
                    }

                    eventVM.resetEventForm()
                    eventVM.alertTitle = "Success"
                    eventVM.alertMessage = "Event created successfully."
                    eventVM.showAlert = true
                    dismiss()
                    
                } label: {
                    Label("Add Event", systemImage: "arrow.right")
                }
                //                MARK: DISPLAY ALERT
                .alert(eventVM.alertTitle, isPresented: $eventVM.showAlert) {
                    Button("OK") { }
                } message: {
                    Text(eventVM.alertMessage)
                }
                
                .frame(maxWidth: 500, alignment: .trailing)
            }
            .onAppear {
                eventVM.resetEventForm()
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
    
    let eventVM = EventViewModel(
        eventDataCoordinator: eventDataCoordinator
    )
    
    CreateEventView(eventVM: eventVM,)
        .environmentObject(eventDataCoordinator)
        .modelContainer(container)
}

