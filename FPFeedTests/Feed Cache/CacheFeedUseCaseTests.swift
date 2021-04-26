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
  
  init(store: FeedStore) {
    self.store = store
  }
  
  func save(_ items: [FeedItem]) {
    store.deleteCachedFeed()
  }
}

class FeedStore {
  var deleteCachedCallCount = 0
  var instertCallCount = 0
  
  func deleteCachedFeed() {
    deleteCachedCallCount += 1
  }
  
  func completeDeletion(with error: Error, at index: Int = 0) {
    
  }
}

class CacheFeedUseCaseTests: XCTestCase {
  
  func test_init_DoesNotDeleteCacheUponCreation() {
    let (_, store) = makeSUT()
    _ = LocalFeedLoader(store: store)
    
    XCTAssertEqual(store.deleteCachedCallCount, 0)
  }

  func test_save_requestCacheDeletion() {
    let (sut, store) = makeSUT()
    let items = [uniqueItem(), uniqueItem()]
    
    sut.save(items)
    
    XCTAssertEqual(store.deleteCachedCallCount, 1)
  }
  
  func test_save_doesNotRequestCacheInsertionOnDeletionError() {
    let (sut, store) = makeSUT()
    let items = [uniqueItem(), uniqueItem()]
    let deletionError = anyNSError()
      
    sut.save(items)
    store.completeDeletion(with: deletionError)
    
    XCTAssertEqual(store.instertCallCount, 0)
  }
  
  //MARK: - Helpers.
  
  private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStore) {
    let store = FeedStore()
    let sut = LocalFeedLoader(store: store)
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
