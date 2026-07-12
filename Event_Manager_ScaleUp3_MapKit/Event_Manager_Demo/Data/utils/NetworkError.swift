//
//  NetworkError.swift
//  travel-nomads-app
//

//  Created by Sumi Sastri on 06/04/2026.


import Foundation

//  USEAGE: Define shared error enum for API/service layer 
// to standardize failure states across network calls.

enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case invalidData
    case decodingError
}
