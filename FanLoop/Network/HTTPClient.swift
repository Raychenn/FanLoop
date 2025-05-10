//
//  HTTPClient.swift
//  FanLoop
//
//  Created by Boray Chen on 2025/5/10.
//
import Foundation

protocol HTTPClientProtocol {
    func fetch<T: Decodable>(from url: String) async throws -> T
    func fetchMultiple<T: Decodable>(from urls: [String]) async throws -> [T]
}

final class HTTPClient: HTTPClientProtocol {
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func fetch<T: Decodable>(from url: String) async throws -> T {
        guard let url = URL(string: url) else {
            throw NetworkError.invalidURL
        }
        
        do {
            let (data, response) = try await session.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw NetworkError.invalidResponse
            }
            
            do {
                return try JSONDecoder().decode(T.self, from: data)
            } catch {
                throw NetworkError.decodingError(error)
            }
        } catch {
            throw NetworkError.requestFailed(error)
        }
    }
    
    func fetchMultiple<T: Decodable>(from urls: [String]) async throws -> [T] {
        try await withThrowingTaskGroup(of: T.self) { group in
            var results: [T] = []
            results.reserveCapacity(urls.count)
            
            for url in urls {
                group.addTask {
                    try await self.fetch(from: url)
                }
            }
            
            for try await result in group {
                results.append(result)
            }
            
            return results
        }
    }
}
