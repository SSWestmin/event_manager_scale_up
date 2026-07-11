//
//  AuthCoordinator.swift
//  Event_Manager_Demo
//
//  Created by Sumi Sastri on 17/06/2026.
//

import Foundation
import SwiftData

// USAGE: Handles Apple-authenticated user persistence using SwiftData (no API calls).
// Fetches existing users by appleUserID to update details, or creates a new user if none exists.
// Encapsulates all database operations with no UI or state management responsibilities.


@MainActor
final class AuthCoordinator {

    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func saveUser(
        appleUserID: String,
        userName: String,
        userEmail: String,
        userRole: UserRole
    ) throws -> UserModel {

        let descriptor = FetchDescriptor<UserModel>(
            predicate: #Predicate {
                $0.appleUserID == appleUserID
            }
        )

        if let existingUser = try modelContext.fetch(descriptor).first {
            existingUser.userName = userName
            existingUser.userEmail = userEmail
            existingUser.userRole = userRole
            existingUser.touchUpdatedAt()
            try modelContext.save()
            return existingUser
        }

        let user = UserModel(
            appleUserID: appleUserID,
            userName: userName,
            userEmail: userEmail,
            userRole: userRole
        )

        modelContext.insert(user)
        try modelContext.save()

        return user
    }
}
