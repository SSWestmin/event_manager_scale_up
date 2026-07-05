//
//  event-api.swift
//  Event_Manager_Demo
//
//  Created by Sumi Sastri on 31/05/2026.
//

import Foundation
// Ticketmaster models now in eventapi_DTO.swift

// MARK: - Event - API Service
@MainActor
class EventAPIService {
    private let baseURL = "https://app.ticketmaster.com/discovery/v2/events.json?"

    private var apiKey: String? {
        let possibleLocations: [(resource: String, subdirectory: String?)] = [
            ("Secrets", "Config"),
            ("Secrets", nil)
        ]

        for location in possibleLocations {
            guard let url = Bundle.main.url(forResource: location.resource,
                                            withExtension: "plist",
                                            subdirectory: location.subdirectory),
                  let data = try? Data(contentsOf: url),
                  let plist = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any],
                  let key = plist["TICKETMASTER_API_KEY"] as? String else {
                continue
            }

            return key
        }

        return nil
    }
        
    /// Fetch events from Ticketmaster API for a given city
    func fetchArtEventsInLondon() async throws -> [TicketmasterEvent] {
        guard var urlComponents = URLComponents(string: baseURL) else {
            throw NetworkError.invalidURL
        }
        // let apiKey=apiKey
        guard let apiKey = apiKey else {
            throw NetworkError.invalidURL // Or a custom error for missing API key
        }
        urlComponents.queryItems = [
            URLQueryItem(name: "apikey", value: apiKey),
            URLQueryItem(name: "city", value: "London"),
            URLQueryItem(name: "size", value: "200"),
            // NOTE: RESTRICT TO TEST
            // URLQueryItem(name: "classificationName", value: "arts")
            //            URLQueryItem(name: "countryCode", value: "GB"),

        ]
        guard let url = urlComponents.url else {
            throw NetworkError.invalidURL
        }
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NetworkError.invalidResponse
        }
        // MARK: DEBUG - check raw API response for location coordinates
//            if let raw = String(data: data, encoding: .utf8) {
//                print("[DEBUG] Raw API response: \(raw)")
//            }
        do {
            let decoded = try JSONDecoder().decode(TicketmasterEventResponse.self, from: data)
            return decoded.embedded?.events ?? []
        } catch {
            throw NetworkError.decodingError
        }
    }
}
