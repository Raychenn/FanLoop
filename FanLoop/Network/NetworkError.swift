//
//  NetworkError.swift
//  FanLoop
//
//  Created by Boray Chen on 2025/5/10.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case requestFailed(Error)
    case invalidResponse
    case decodingError(Error)
}
