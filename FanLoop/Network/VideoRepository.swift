//
//  VideoRepository.swift
//  FanLoop
//
//  Created by Boray Chen on 2025/5/10.
//

import Foundation

protocol VideoRepositoryProtocol {
    func fetchVideos() async throws -> [Video]
}

final class VideoRepository: VideoRepositoryProtocol {
    func fetchVideos() async throws -> [Video] {
        // Simulate network delay
        try await Task.sleep(for: .seconds(1))
        
        return VideoEndpoint.all
    }
}
