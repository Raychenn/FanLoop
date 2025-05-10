//
//  shortsViewModel.swift
//  FanLoop
//
//  Created by Boray Chen on 2025/5/10.
//

import Foundation

final class VideoListViewModel {
    
    private let repository: VideoRepositoryProtocol
    
    private(set) var videos: [Video] = [] {
        didSet { videosUpdateHandler?(videos) }
    }
    private(set) var error: Error? {
        didSet { errorUpdateHandler?(error) }
    }
    private(set) var isLoading = false {
        didSet { loadingUpdateHandler?(isLoading) }
    }
    
    // Closure-based callbacks
    var videosUpdateHandler: (([Video]) -> Void)?
    var errorUpdateHandler: ((Error?) -> Void)?
    var loadingUpdateHandler: ((Bool) -> Void)?
    
    init(repository: VideoRepositoryProtocol) {
        self.repository = repository
    }
    
    func fetchVideos() {
        Task { @MainActor in
            isLoading = true
            do {
                videos = try await repository.fetchVideos()
                error = nil
            } catch {
                self.error = error
            }
            isLoading = false
        }
    }
}
