//
//  ValidateFeedCacheUseCaseTests.swift
//  FPFeedTests
//
//  Created by Fernando Putallaz on 25/05/2021.
//  Copyright © 2021 eFePe. All rights reserved.
//

import XCTest
import FPFeed

class ValidateFeedCacheUseCaseTests: XCTestCase {
  
  func test_init_DoesNotMessageStoreUponCreation() {
    let (_, store) = makeSUT()

    XCTAssertEqual(store.receivedMessages, [])
  }

  func test_validateCache_deletesCacheOnRetrievalError() {
    let (sut, store) = makeSUT()
    
    sut.validateCache()
    store.completeRetrieval(with: anyNSError())
    
    XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCachedFeed])
  }
  
  func test_validateCache_doesNotDeleteCacheOnEmptyCache() {
    let (sut, store) = makeSUT()
    
    sut.validateCache()
    store.completeRetrievalWithEmptyCache()
    
    XCTAssertEqual(store.receivedMessages, [.retrieve])
  }
  
  func test_validateCache_doesNotDeleteLessThanSevenDaysOldCache() {
    let feed = uniqueImageFeed()
    let fixedCurrentDate = Date()
    let lessThanSevenDayOldTimeStamp = fixedCurrentDate.adding(days: -7).adding(seconds: 1)
    let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
    
    sut.validateCache()
    store.completeRetrieval(with: feed.local, timestamp: lessThanSevenDayOldTimeStamp)
    
    XCTAssertEqual(store.receivedMessages, [.retrieve])
  }
  
  //MARK: - Helpers.
  
  private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
    let store = FeedStoreSpy()
    let sut = LocalFeedLoader(store: store, currentDate: currentDate)
    trackForMemoryLeak(store, file: file, line: line)
    trackForMemoryLeak(sut, file: file, line: line)
    return (sut, store)
  }
  
  private func anyNSError() -> NSError {
    return NSError(domain: "any error", code: 0)
  }
  
  private func uniqueImage() -> FeedImage {
    return FeedImage(id: UUID(), description: "any", location: "any", url: anyURL())
  }
  
  private func uniqueImageFeed() -> (models: [FeedImage], local: [LocalFeedImage]) {
    let models = [uniqueImage(), uniqueImage()]
    let local = models.map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
    return (models, local)
  }
  
  private func anyURL() -> URL {
    return URL(string: "any-url.com")!
  }
}

private extension Date {
  func adding(days: Int) -> Date {
    return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
  }
  
  func adding(seconds: TimeInterval) -> Date {
    return self + seconds
  }
  
}

