//
//  FanLoopTests.swift
//  FanLoopTests
//
//  Created by Boray Chen on 2025/5/10.
//

import XCTest
@testable import FanLoop

final class VideoListViewModelTests: XCTestCase {
    
    // MARK: - System Under Test
    
    private var sut: VideoListViewModel!
    private var mockRepository: MockVideoRepository!
    
    // MARK: - Life Cycle
    
    override func setUp() {
        super.setUp()
        mockRepository = MockVideoRepository()
        sut = VideoListViewModel(repository: mockRepository)
    }
    
    override func tearDown() {
        sut = nil
        mockRepository = nil
        super.tearDown()
    }
    
    // MARK: - Tests
    
    func test_initialState() {
        XCTAssertTrue(sut.videos.isEmpty)
        XCTAssertNil(sut.error)
        XCTAssertFalse(sut.isLoading)
    }
    
    func test_fetchVideos_success() async throws {
        // Given
        var receivedVideos: [Video]?
        var loadingStates: [Bool] = []
        let expectedVideos: [Video] = [
            .stub(),
            .stub(id: "2", title: "Test Video 2", subTitle: "Test Subtitle 2")
        ]
        
        sut.videosUpdateHandler = { videos in
            receivedVideos = videos
        }
        sut.loadingUpdateHandler = { isLoading in
            loadingStates.append(isLoading)
        }
        
        // When
        sut.fetchVideos()
        
        try await Task.sleep(for: .milliseconds(100))
        
        // Then
        XCTAssertTrue(mockRepository.fetchVideosCalled)
        XCTAssertEqual(receivedVideos, expectedVideos)
        XCTAssertEqual(loadingStates, [true, false])
        XCTAssertNil(sut.error)
    }
     
     func test_fetchVideos_failure() async throws {
         // Given
         mockRepository.shouldFail = true
         var receivedError: Error?
         var loadingStates: [Bool] = []
         
         sut.errorUpdateHandler = { error in
             receivedError = error
         }
         sut.loadingUpdateHandler = { isLoading in
             loadingStates.append(isLoading)
         }
         
         // When
         sut.fetchVideos()
         
         // Then
         try await Task.sleep(for: .milliseconds(100))
         
         XCTAssertTrue(mockRepository.fetchVideosCalled)
         XCTAssertNotNil(receivedError)
         XCTAssertEqual((receivedError as NSError?)?.domain, NSError.testError.domain)
         XCTAssertEqual(loadingStates, [true, false])
         XCTAssertTrue(sut.videos.isEmpty)
     }
     
     func test_loadingState_updatesCorrectly() async throws {
         // Given
         var loadingStates: [Bool] = []
         sut.loadingUpdateHandler = { isLoading in
             loadingStates.append(isLoading)
         }
         
         // When
         sut.fetchVideos()
         
         // Then
         try await Task.sleep(for: .milliseconds(100))
         
         XCTAssertEqual(loadingStates, [true, false], "Loading states should transition from true to false")
     }
}
