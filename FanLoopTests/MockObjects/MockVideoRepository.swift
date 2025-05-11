//
//  MockVideoRepository.swift
//  FanLoopTests
//
//  Created by Boray Chen on 2025/5/11.
//

import Foundation
@testable import FanLoop

class MockVideoRepository: VideoRepositoryProtocol {
    var shouldFail = false
    var fetchVideosCalled = false
    
    func fetchVideos() async throws -> [Video] {
        fetchVideosCalled = true
        if shouldFail {
            throw NSError.testError
        }
        return [
            .stub(),  // Uses default values
            .stub(id: "2",
                  title: "Test Video 2",
                  subTitle: "Test Subtitle 2",
                  url: "test_url")  // Make sure URL matches
        ]
    }
}
