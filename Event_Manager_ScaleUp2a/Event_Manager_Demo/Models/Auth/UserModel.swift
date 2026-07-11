//
//  UserModel.swift
//  Event_Manager_Demo
//
//  Created by Sumi Sastri on 22/05/2026.
//

import Foundation
import SwiftData

// USAGE: Persisted user profile and role information.
// Auth handled by Sign in with Apple - no password storage required
// RBAC implemented via UserRole enum - default role is attendee

enum UserRole: String, Codable, CaseIterable, Identifiable {
    case attendee
    case admin
    var id: String { rawValue }
}

@Model
final class UserModel {
    // MARK: Apple provides the stable unique identifier
    @Attribute(.unique) var appleUserID: String
    var userName: String
    var userEmail: String
    var userCreatedAt: Date
    // MARK: Role stored locally - default attendee (principle of least privilege)
    private var userRoleRawValue: String
    
    var userRole: UserRole {
        get { UserRole(rawValue: userRoleRawValue) ?? .attendee }
        set { userRoleRawValue = newValue.rawValue }
    }
    
    init(
        appleUserID: String,
        userName: String,
        userEmail: String,
        userRole: UserRole = .attendee,
        userCreatedAt: Date = Date()
    ) {
        self.appleUserID = appleUserID
        self.userName = userName
        self.userEmail = userEmail
        self.userRoleRawValue = userRole.rawValue
        self.userCreatedAt = userCreatedAt
    }
    
    func touchUpdatedAt(_ date: Date = Date()) {
        userCreatedAt = date
    }
}


