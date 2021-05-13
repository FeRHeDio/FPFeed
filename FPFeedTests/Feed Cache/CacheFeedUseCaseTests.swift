//
//  CacheFeedUseCaseTests.swift
//  FPFeedTests
//
//  Created by Fernando Putallaz on 20/04/2021.
//  Copyright © 2021 eFePe. All rights reserved.
//

import XCTest
import FPFeed

class LocalFeedLoader {
  private let store: FeedStore
  private let currentDate: () -> Date
  
  init(store: FeedStore, currentDate: @escaping () -> Date) {
    self.store = store
    self.currentDate = currentDate
  }
  
  func save(_ items: [FeedItem], completion: @escaping (Error?) -> Void) {
    store.deleteCachedFeed { [unowned self] error in
      if error == nil {
        self.store.insert(items, timestamp: self.currentDate(), completion: completion)
      } else {
        completion(error)
      }
    }
  }
}

class FeedStore {
  typealias DeletionCompletion = (Error?) -> Void
  typealias InsertionCompletion = (Error?) -> Void
  
  enum ReceivedMessage: Equatable {
    case deleteCachedFeed
    case insert([FeedItem], Date)
  }
  
  private(set) var receivedMessages = [ReceivedMessage]()
  
  var deletionCompletions = [DeletionCompletion]()
  var insertionCompletions = [InsertionCompletion]()
  
  func deleteCachedFeed(completion: @escaping DeletionCompletion) {
    deletionCompletions.append(completion)
    receivedMessages.append(.deleteCachedFeed )
  }
  
  func completeDeletion(with error: Error, at index: Int = 0) {
    deletionCompletions[index](error)
  }
  
  func completeDeletionSuccesfuly(at index: Int = 0) {
    deletionCompletions[index](nil)
  }
  
  func insert(_ items: [FeedItem], timestamp: Date, completion: @escaping InsertionCompletion) {
    insertionCompletions.append(completion)
    receivedMessages.append(.insert(items, timestamp))
  }
  
  func completeInsertion(with error: Error, at index: Int = 0) {
    insertionCompletions[index](error)
  }
  
  func completeinsertionSuccessfully(at index: Int = 0) {
    insertionCompletions[index](nil)
  }
  
}

class CacheFeedUseCaseTests: XCTestCase {
  
  func test_init_DoesNotMessageStoreUponCreation() {
    let (_, store) = makeSUT()

    XCTAssertEqual(store.receivedMessages, [])
  }

  func test_save_requestCacheDeletion() {
    let (sut, store) = makeSUT()
    let items = [uniqueItem(), uniqueItem()]
    
    sut.save(items) { _ in }
    
    XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
  }
  
  func test_save_doesNotRequestNewCacheInsertionOnDeletionError() {
    let (sut, store) = makeSUT()
    let items = [uniqueItem(), uniqueItem()]
    let deletionError = anyNSError()
      
    sut.save(items) { _ in }
    store.completeDeletion(with: deletionError)
    
    XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
  }
  
  func test_save_requestNewCacheInsertionWithTimeStampOnSuccesfulDeletion() {
    let timestamp = Date()
    let items = [uniqueItem(), uniqueItem()]
    let (sut, store) = makeSUT(currentDate: { timestamp })
    
    sut.save(items) { _ in }
    store.completeDeletionSuccesfuly()
    
    XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed, .insert(items, timestamp)])
  }
  
  func test_save_failsOnDeletionError() {
    let (sut, store) = makeSUT()
    let items = [uniqueItem(), uniqueItem()]
    let deletionError = anyNSError()
    let exp = expectation(description: "Wait for save completion")
    var receivedError: Error?
    
    sut.save(items) { error in
      receivedError = error
      exp.fulfill()
    }
    store.completeDeletion(with: deletionError)
    wait(for: [exp], timeout: 1.0)
    
    XCTAssertEqual(receivedError as NSError?, deletionError)
  }
  
  func test_save_failsOnInsertionError() {
    let (sut, store) = makeSUT()
    let items = [uniqueItem(), uniqueItem()]
    let insertionError = anyNSError()
    let exp = expectation(description: "Wait for save completion")
    var receivedError: Error?
    
    sut.save(items) { error in
      receivedError = error
      exp.fulfill()
    }
    store.completeDeletionSuccesfuly()
    store.completeInsertion(with: insertionError)
    wait(for: [exp], timeout: 1.0)
    
    XCTAssertEqual(receivedError as NSError?, insertionError)
  }
  
  func test_save_SucceedsOnSuccesfulCacheInsertion() {
    let (sut, store) = makeSUT()
    let items = [uniqueItem(), uniqueItem()]
    let insertionError = anyNSError()
    let exp = expectation(description: "Wait for save completion")
    var receivedError: Error?
    
    sut.save(items) { error in
      receivedError = error
      exp.fulfill()
    }
    store.completeDeletionSuccesfuly()
    store.completeinsertionSuccessfully()
    wait(for: [exp], timeout: 1.0)
    
    XCTAssertNil(receivedError)
  }
  
  //MARK: - Helpers.
  
  private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStore) {
    let store = FeedStore()
    let sut = LocalFeedLoader(store: store, currentDate: currentDate)
    trackForMemoryLeak(store, file: file, line: line)
    trackForMemoryLeak(sut, file: file, line: line)
    return (sut, store)
  }
  
  private func uniqueItem() -> FeedItem {
    return FeedItem(id: UUID(), description: "any", location: "any", imageURL: anyURL())
  }
  
  private func anyURL() -> URL {
    return URL(string: "any-url.com")!
  }
  
  private func anyNSError() -> NSError {
    return NSError(domain: "any error", code: 0)
  }
}
