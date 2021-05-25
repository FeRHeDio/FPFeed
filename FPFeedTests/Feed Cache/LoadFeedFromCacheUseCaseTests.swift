//
//  LoadFeedFromCacheUseCaseTests.swift
//  FPFeedTests
//
//  Created by Fernando Putallaz on 17/05/2021.
//  Copyright © 2021 eFePe. All rights reserved.
//

import XCTest
import FPFeed

class LoadFeedFromCacheUseCaseTests: XCTestCase {
  
  func test_init_DoesNotMessageStoreUponCreation() {
    let (_, store) = makeSUT()

    XCTAssertEqual(store.receivedMessages, [])
  }
  
  func test_load_requestsCacheRetrieval() {
    let (sut, store) = makeSUT()

    sut.load { _ in }
    
    XCTAssertEqual(store.receivedMessages, [.retrieve])
  }
  
  func test_load_failsOnRetrievalError() {
    let (sut, store) = makeSUT()
    let retrievalError = anyNSError()
    
    expect(sut, toCompleteWith: .failure(retrievalError), when: {
      store.completeRetrieval(with: retrievalError)
    })
  }
  
  func test_load_deliversNoImagesOnEmptyCache() {
    let (sut, store) = makeSUT()
    
    expect(sut, toCompleteWith: .success([]), when: {
      store.completeRetrievalWithEmptyCache()
    })
  }
  
  func test_load_deliversCachedImagesOnLessThanSevenDaysOldCache() {
    let feed = uniqueImageFeed()
    let fixedCurrentDate = Date()
    let lessThanSevenDayOldTimeStamp = fixedCurrentDate.adding(days: -7).adding(seconds: 1)
    let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
    
    expect(sut, toCompleteWith: .success(feed.models), when: {
      store.completeRetrieval(with: feed.local, timestamp: lessThanSevenDayOldTimeStamp)
    })
  }
  
  func test_load_deliversCachedImagesOnSevenDaysOldCache() {
    let feed = uniqueImageFeed()
    let fixedCurrentDate = Date()
    let sevenDayOldTimeStamp = fixedCurrentDate.adding(days: -7)
    let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
    
    expect(sut, toCompleteWith: .success([]), when: {
      store.completeRetrieval(with: feed.local, timestamp: sevenDayOldTimeStamp)
    })
  }
  
  func test_load_deliversNoImagesOnMoreThanSevenDaysOldCache() {
    let feed = uniqueImageFeed()
    let fixedCurrentDate = Date()
    let moreThanSevenDayOldTimeStamp = fixedCurrentDate.adding(days: -7).adding(days: -1)
    let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
    
    expect(sut, toCompleteWith: .success([]), when: {
      store.completeRetrieval(with: feed.local, timestamp: moreThanSevenDayOldTimeStamp)
    })
  }
  
  func test_load_hasNotSideEffectsOnRetrievalError() {
    let (sut, store) = makeSUT()
    
    sut.load { _ in }
    store.completeRetrieval(with: anyNSError())
    
    XCTAssertEqual(store.receivedMessages, [.retrieve])
  }
  
  func test_load_hasNotSideEffectOnEmptyCache() {
    let (sut, store) = makeSUT()
    
    sut.load { _ in }
    store.completeRetrievalWithEmptyCache()
    
    XCTAssertEqual(store.receivedMessages, [.retrieve])
  }
  
  func test_load_doesNotDeleteCacheOnLessThanSevenDaysOldCache() {
    let feed = uniqueImageFeed()
    let fixedCurrentDate = Date()
    let lessThanSevenDayOldTimeStamp = fixedCurrentDate.adding(days: -7).adding(seconds: 1)
    let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
    
    sut.load { _ in }
    store.completeRetrieval(with: feed.local, timestamp: lessThanSevenDayOldTimeStamp)
    
    XCTAssertEqual(store.receivedMessages, [.retrieve])
  }
  
  func test_load_doesNotDeleteCacheOnSevenDaysOldCache() {
    let feed = uniqueImageFeed()
    let fixedCurrentDate = Date()
    let sevenDayOldTimeStamp = fixedCurrentDate.adding(days: -7)
    let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
    
    sut.load { _ in }
    store.completeRetrieval(with: feed.local, timestamp: sevenDayOldTimeStamp)
    
    XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCachedFeed])
  }
  
  func test_load_deleteCacheOnMoreThanSevenDaysOldCache() {
    let feed = uniqueImageFeed()
    let fixedCurrentDate = Date()
    let moreThanSevenDayOldTimeStamp = fixedCurrentDate.adding(days: -7).adding(seconds: -1)
    let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
    
    sut.load { _ in }
    store.completeRetrieval(with: feed.local, timestamp: moreThanSevenDayOldTimeStamp)
    
    XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCachedFeed])
  }
  
  func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
    let store = FeedStoreSpy()
    var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
    
    var receivedResults = [LocalFeedLoader.LoadResult]()
    sut?.load { receivedResults.append($0)}
    
    sut = nil
    store.completeRetrievalWithEmptyCache()
    
    XCTAssertTrue(receivedResults.isEmpty)
  }
  
  //MARK: - Helpers.
  
  private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
    let store = FeedStoreSpy()
    let sut = LocalFeedLoader(store: store, currentDate: currentDate)
    trackForMemoryLeak(store, file: file, line: line)
    trackForMemoryLeak(sut, file: file, line: line)
    return (sut, store)
  }
  
  private func expect(_ sut: LocalFeedLoader, toCompleteWith expectedResult: LocalFeedLoader.LoadResult, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
    
    let exp = expectation(description: "Wait for loading to complete")
    
    sut.load { receivedResult in
      switch (receivedResult, expectedResult) {
        case let (.success(receivedImages), .success(expectedImages)):
          XCTAssertEqual(receivedImages, expectedImages, file: file, line: line)
      
      case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
        XCTAssertEqual(receivedError, expectedError, file: file, line: line)
    
      default:
        XCTFail("Expected result \(expectedResult) , got \(receivedResult) instead", file: file, line: line)
      }
      exp.fulfill()
    }
    
    action()
    wait(for: [exp], timeout: 1.0)
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
  
  
  private func anyNSError() -> NSError {
    return NSError(domain: "any error", code: 0)
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
