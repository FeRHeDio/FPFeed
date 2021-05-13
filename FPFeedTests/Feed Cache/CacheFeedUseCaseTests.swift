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
  
  func save(_ items: [FeedItem]) {
    store.deleteCachedFeed { [unowned self] error in
      if error == nil {
        self.store.insert(items, timestamp: self.currentDate())
      }
    }
  }
}

class FeedStore {
  typealias DeletionCompletion = (Error?) -> Void
  
  var deleteCachedCallCount = 0
  var instertCallCount = 0
  var insertions = [(items: [FeedItem], timestamp: Date)]()
  
  var deletionCompletions = [DeletionCompletion]()
  
  
  func deleteCachedFeed(completion: @escaping DeletionCompletion) {
    deleteCachedCallCount += 1
    deletionCompletions.append(completion)
  }
  
  func completeDeletion(with error: Error, at index: Int = 0) {
    deletionCompletions[index](error)
  }
  
  func completeDeletionSuccesfuly(at index: Int = 0) {
    deletionCompletions[index](nil)
  }
  
  func insert(_ items: [FeedItem], timestamp: Date) {
    instertCallCount += 1
    insertions.append((items, timestamp))
  }
}

class CacheFeedUseCaseTests: XCTestCase {
  
  func test_init_DoesNotDeleteCacheUponCreation() {
    let (_, store) = makeSUT()

    XCTAssertEqual(store.deleteCachedCallCount, 0)
  }

  func test_save_requestCacheDeletion() {
    let (sut, store) = makeSUT()
    let items = [uniqueItem(), uniqueItem()]
    
    sut.save(items)
    
    XCTAssertEqual(store.deleteCachedCallCount, 1)
  }
  
  func test_save_doesNotRequestNewCacheInsertionOnDeletionError() {
    let (sut, store) = makeSUT()
    let items = [uniqueItem(), uniqueItem()]
    let deletionError = anyNSError()
      
    sut.save(items)
    store.completeDeletion(with: deletionError)
    
    XCTAssertEqual(store.instertCallCount, 0)
  }
  
  func test_save_requestNewCacheInsertionOnSuccesfulDeletion() {
    let (sut, store) = makeSUT()
    let items = [uniqueItem(), uniqueItem()]
      
    sut.save(items)
    store.completeDeletionSuccesfuly()
    
    XCTAssertEqual(store.instertCallCount, 1)
  }
  
  func test_save_requestNewCacheInsertionWithTimeStampOnSuccesfulDeletion() {
    let timestamp = Date()
    let items = [uniqueItem(), uniqueItem()]
    let (sut, store) = makeSUT(currentDate: { timestamp })
    
    sut.save(items)
    store.completeDeletionSuccesfuly()
    
    XCTAssertEqual(store.insertions.count, 1)
    XCTAssertEqual(store.insertions.first?.items, items)
    XCTAssertEqual(store.insertions.first?.timestamp, timestamp)
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
