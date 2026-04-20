//
//  Environment.swift
//  PruebaMeli
//

import Foundation

enum Environment {
    static var baseURL: String {
        ProcessInfo.processInfo.environment["BASE_URL"] ?? "http://localhost:8080"
    }
}
