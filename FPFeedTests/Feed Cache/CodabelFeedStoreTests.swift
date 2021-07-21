//
//  CodabelFeedStoreTests.swift
//  FPFeedTests
//
//  Created by Fernando Putallaz on 08/07/2021.
//  Copyright © 2021 eFePe. All rights reserved.
//

import XCTest
import FPFeed

class CodabelFeedStoreTests: XCTestCase, FailableFeedStore {
  
  override func setUp() {
    super.setUp()
    
    setupEmptyStoreState()
  }
    
  override func tearDown() {
    super.tearDown()
   
    undoStoreSideEffects()
  }
  
  //MARK: Retrieve
  
  func test_retrieve_deliversEmptyOnEmptyCache() {
    let sut = makeSUT()
   
    expect(sut, toRetrieve: .empty)
  }
  
  func test_retrieve_hasNoSideEffectsOnEmptyCache() {
    let sut = makeSUT()
    
    expect(sut, toRetrieveTwice: .empty)
  }
  
  func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
    let sut = makeSUT()
    let feed = uniqueImageFeed().local
    let timestamp = Date()
    
    insert((feed, timestamp), to: sut)
    
    expect(sut, toRetrieve: .found(feed: feed, timestamp: timestamp))
  }
    
  func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
    let sut = makeSUT()
    let feed = uniqueImageFeed().local
    let timestamp = Date()
    
    insert((feed, timestamp), to: sut)
    
    expect(sut, toRetrieve: .found(feed: feed, timestamp: timestamp))
  }
   
  func test_retrieve_deliversFailureOnRetrievalError() {
    let storeURL = testSpecificStoreURL()
    let sut = makeSUT(storeURL: storeURL)
    
    try! "invalid data".write(to: storeURL, atomically: false, encoding: .utf8)
    
    expect(sut, toRetrieve: .failure(anyNSError()))
  }
  
  func test_retrieve_hasNoSideEffectsOnFailure() {
    let storeURL = testSpecificStoreURL()
    let sut = makeSUT(storeURL: storeURL)
    
    try! "invalid data".write(to: storeURL, atomically: false, encoding: .utf8)
    
    expect(sut, toRetrieveTwice: .failure(anyNSError()))
  }
  
  //MARK: Insert
  
  func test_insert_deliversNoErrorOnEmptyCache() {
    let sut = makeSUT()
    
    let insertionError = insert((uniqueImageFeed().local, Date()), to: sut)
    
    XCTAssertNil(insertionError, "Expected to override cache succesfully")
  }
  
  func test_insert_deliversNoErrorOnNonEmptyCache() {
    let sut = makeSUT()
    insert((uniqueImageFeed().local, Date()), to: sut)
    
    let insertionError = insert((uniqueImageFeed().local, Date()), to: sut)
    
    XCTAssertNil(insertionError, "Expected to override cache succesfully")
  }
  
  func test_insert_overridesPreviouslyInsertedCacheValues() {
    let sut = makeSUT()
    insert((uniqueImageFeed().local, Date()), to: sut)
    
    let latestFeed = uniqueImageFeed().local
    let latestTimestamp = Date()
    
    insert((latestFeed, latestTimestamp), to: sut)
    expect(sut, toRetrieve: .found(feed: latestFeed, timestamp: latestTimestamp))
  }
  
  func test_insert_deliversErrorOnInsertionError() {
    let invalidStoreURL = URL(string: "invalid://store-url")!
    let sut = makeSUT(storeURL: invalidStoreURL)
    let feed = uniqueImageFeed().local
    let timestamp = Date()
    
    let insertionError = insert((feed, timestamp), to: sut)
    
    XCTAssertNotNil(insertionError, "Expected cache insertion to fail with an error")
  }
  

  func test_insert_hasNoSideEffectsOnInsertionError() {
    let invalidStoreURL = URL(string: "invalid://store-url")
    let sut = makeSUT(storeURL: invalidStoreURL)
    let feed = uniqueImageFeed().local
    let timestamp = Date()

    insert((feed, timestamp), to: sut)

    expect(sut, toRetrieve: .empty)
  }
  
  //MARK: Delete
  
  func test_delete_deliversNoErrorOnEmptyCache() {
    let sut = makeSUT()
    
    let deletionError = deleteCache(from: sut)
    
    XCTAssertNil(deletionError, "Expected empty cache deletion to succeed")
  }
  
  func test_delete_hasNoSideEffectsOnEmptyCache() {
    let sut = makeSUT()
    
    deleteCache(from: sut)
    
    expect(sut, toRetrieve: .empty)
  }
  
  func test_delete_deliversNoErrorOnNonEmptyCache() {
    let sut = makeSUT()
    insert((uniqueImageFeed().local, Date()), to: sut)
    
    let deletionError = deleteCache(from: sut)
    
    XCTAssertNil(deletionError, "Expected non-empty cache deletion to succeed")
  }
  
  func test_delete_emptiesPreviouslyInsertedCache() {
    let sut = makeSUT()
    insert((uniqueImageFeed().local, Date()), to: sut)
    
    let deletionError = deleteCache(from: sut)
    
    expect(sut, toRetrieve: .empty)
  }
  
  func test_delete_deliversErrorOnDeletionError() {
    let nonDeletePermissionURL = cachesDirectory()
    let sut = makeSUT(storeURL: nonDeletePermissionURL)
    
    let deletionError = deleteCache(from: sut)
    
    XCTAssertNotNil(deletionError, "Expected cache deletion to fail")
  }
  
  func test_delete_hasNoSideEffectsOnDeletionError() {
    let nonDeletePermissionURL = cachesDirectory()
    let sut = makeSUT(storeURL: nonDeletePermissionURL)
    
    deleteCache(from: sut)
    
    expect(sut, toRetrieve: .empty)
  }
    
  func test_storeSideEffects_runSerially() {
    let sut = makeSUT()
    var completedOperationsInOrder = [XCTestExpectation]()
    
    let op1 = expectation(description: "Operation 1")
    sut.insert(uniqueImageFeed().local, timestamp: Date()) { _ in
      op1.fulfill()
      completedOperationsInOrder.append(op1)
    }
    
    let op2 = expectation(description: "Operation 2")
    sut.deleteCachedFeed { _ in
      completedOperationsInOrder.append(op2)
      op2.fulfill()
    }
    
    let op3 = expectation(description: "Operation 3")
    sut.insert(uniqueImageFeed().local, timestamp: Date()) { _ in
      completedOperationsInOrder.append(op3)
      op3.fulfill()
    }
    
    waitForExpectations(timeout: 5.0)
    
    XCTAssertEqual(completedOperationsInOrder, [op1, op2, op3])
  }

  // MARK: - Helpers
  
  private func makeSUT(storeURL: URL? = nil, file: StaticString = #file, line: UInt = #line) -> FeedStore {
    let sut = CodableFeedStore(storeURL: storeURL ?? testSpecificStoreURL())
    trackForMemoryLeak(sut, file: file, line: line)
    return sut
  }
  
  @discardableResult
  private func insert(_ cache: (feed: [LocalFeedImage], timestamp: Date), to sut: FeedStore) -> Error? {
    let exp = expectation(description: "Wait for cache retrieval")
    var insertionError: Error?
    sut.insert (cache.feed, timestamp: cache.timestamp){ receivedInsertionError in
      insertionError = receivedInsertionError
      exp.fulfill()
    }
    wait(for: [exp], timeout: 1.0)
    return insertionError
  }
  
  private func deleteCache(from sut: FeedStore) -> Error? {
    let exp = expectation(description: "Wait for cache deletion")
    var deletionError: Error?
    sut.deleteCachedFeed { receivedError in
      deletionError = receivedError
      exp.fulfill()
    }
    wait(for: [exp], timeout: 1.0)
    return deletionError
  }
  
  private func expect(_ sut: FeedStore, toRetrieveTwice expectedResult: RetrieveCachedFeedResult, file: StaticString = #file, line: UInt = #line) {
    expect(sut, toRetrieve: expectedResult, file: file, line: line)
    expect(sut, toRetrieve: expectedResult, file: file, line: line)
  }

  private func expect(_ sut: FeedStore, toRetrieve expectedResult: RetrieveCachedFeedResult, file: StaticString = #file, line: UInt = #line) {
    let exp = expectation(description: "Wait for cache retrieval")
    
    sut.retrieve { retrieveResult in
      switch (expectedResult, retrieveResult) {
      case (.empty, .empty),
           (.failure, .failure):
        break
        
      case let (.found(expectedFeed, expectedTimestamp), .found(retrievedFeed, retrievedTimestamp)):
        XCTAssertEqual(retrievedFeed, expectedFeed, file: file, line: line)
        XCTAssertEqual(retrievedTimestamp, expectedTimestamp, file: file, line: line)
        
      default:
        XCTFail("Expected to retrieve \(expectedResult), got \(retrieveResult) instead", file: file, line: line)
      }
      
      exp.fulfill()
    }
    wait(for: [exp], timeout: 1.0)
    
  }
  
  private func setupEmptyStoreState() {
    deleteStoreArtifacts()
  }
  
  private func undoStoreSideEffects() {
    deleteStoreArtifacts()
  }
  
  private func deleteStoreArtifacts() {
    try? FileManager.default.removeItem(at: testSpecificStoreURL())
  }
  
  private func testSpecificStoreURL() -> URL {
    return cachesDirectory().appendingPathComponent("\(type(of: self)).store")
  }
  
  private func cachesDirectory() -> URL {
    return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
  }
}
