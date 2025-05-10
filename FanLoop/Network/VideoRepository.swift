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
    private let httpClient: HTTPClientProtocol
    private let videoMetadata: [Video]
    
    init(httpClient: HTTPClientProtocol = HTTPClient(),
         videoMetadata: [Video] = VideoEndpoint.all) {
        self.httpClient = httpClient
        self.videoMetadata = videoMetadata
    }
    
    func fetchVideos() async throws -> [Video] {
        // Create a map of URLs to their corresponding metadata
        let urlToMetadata = Dictionary(uniqueKeysWithValues:
            videoMetadata.map { ($0.url, $0) }
        )
        
        // Fetch all videos in parallel
        let urls = videoMetadata.map { $0.url }
        let fetchedVideos: [Video] = try await httpClient.fetchMultiple(from: urls)
        
        // Map fetched videos with their metadata
        return fetchedVideos.compactMap { fetchedVideo in
            guard let metadata = urlToMetadata[fetchedVideo.url] else { return nil }
            return Video(
                id: metadata.id,
                title: metadata.title,
                subTitle: metadata.subTitle,
                url: fetchedVideo.url
            )
        }
    }
}
