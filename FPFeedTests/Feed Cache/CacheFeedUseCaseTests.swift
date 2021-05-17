//
//  CacheFeedUseCaseTests.swift
//  FPFeedTests
//
//  Created by Fernando Putallaz on 20/04/2021.
//  Copyright © 2021 eFePe. All rights reserved.
//

import XCTest
import FPFeed

class CacheFeedUseCaseTests: XCTestCase {
  
  func test_init_DoesNotMessageStoreUponCreation() {
    let (_, store) = makeSUT()

    XCTAssertEqual(store.receivedMessages, [])
  }

  func test_save_requestCacheDeletion() {
    let (sut, store) = makeSUT()
   
    sut.save(uniqueImageFeed().models) { _ in }
    
    XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
  }
  
  func test_save_doesNotRequestNewCacheInsertionOnDeletionError() {
    let (sut, store) = makeSUT()
    let deletionError = anyNSError()
      
    sut.save(uniqueImageFeed().models) { _ in }
    store.completeDeletion(with: deletionError)
    
    XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
  }
  
  func test_save_requestNewCacheInsertionWithTimeStampOnSuccesfulDeletion() {
    let timestamp = Date()
    let feed = uniqueImageFeed()
    let (sut, store) = makeSUT(currentDate: { timestamp })
    
    sut.save(feed.models) { _ in }
    store.completeDeletionSuccesfuly()
    
    XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed, .insert(feed.local, timestamp)])
  }
  
  func test_save_failsOnDeletionError() {
    let (sut, store) = makeSUT()
    let deletionError = anyNSError()
  
    expect(sut, toCompletWithError: deletionError, when: {
      store.completeDeletion(with: deletionError)
    })
  }
  
  func test_save_failsOnInsertionError() {
    let (sut, store) = makeSUT()
    let insertionError = anyNSError()

    expect(sut, toCompletWithError: insertionError, when: {
      store.completeDeletionSuccesfuly()
      store.completeInsertion(with: insertionError)
    })
  }
  
  func test_save_SucceedsOnSuccesfulCacheInsertion() {
    let (sut, store) = makeSUT()
    
    expect(sut, toCompletWithError: nil, when: {
      store.completeDeletionSuccesfuly()
      store.completeinsertionSuccessfully()
    })
  }
  
  func test_save_doesNotDeliverDeletionErrorAfterSUTInstanceHasBeenDeallocated() {
    let store = FeedStoreSpy()
    var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
    
    var receivedResults = [LocalFeedLoader.SaveResult]()
    sut?.save(uniqueImageFeed().models) { receivedResults.append($0)}
    
    sut = nil
    store.completeDeletion(with: anyNSError())
    
    XCTAssertTrue(receivedResults.isEmpty)
  }
  
  func test_save_doesNotDeliverInsertionErrorAfterSUTInstanceHasBeenDeallocated() {
    let store = FeedStoreSpy()
    var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
    
    var receivedResults = [LocalFeedLoader.SaveResult]()
    sut?.save(uniqueImageFeed().models) { receivedResults.append($0)}
    
    store.completeDeletionSuccesfuly()
    sut = nil
    
    store.completeInsertion(with: anyNSError())
    
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
  
  private func expect(_ sut: LocalFeedLoader, toCompletWithError expectedError: NSError?, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
    let exp = expectation(description: "Wait for save completion")
    var receivedError: Error?
    
    sut.save(uniqueImageFeed().models) { error in
      receivedError = error
      exp.fulfill()
    }
    action()
    wait(for: [exp], timeout: 1.0)
    
    XCTAssertEqual(receivedError as NSError?, expectedError, file: file, line: line)
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
