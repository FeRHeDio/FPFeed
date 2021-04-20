//
//  CacheFeedUseCaseTests.swift
//  FPFeedTests
//
//  Created by Fernando Putallaz on 20/04/2021.
//  Copyright © 2021 eFePe. All rights reserved.
//

import XCTest

class LocalFeedLoader {
  
  init(store: FeedStore) {
    
  }
}

class FeedStore {
  
  var deleteCachedCallCount = 0
  
}

class CacheFeedUseCaseTests: XCTestCase {
  
  func test_init_DoesNotDeleteCacheUponCreation() {
    let store = FeedStore()
    
    _ = LocalFeedLoader(store: store)
    
    XCTAssertEqual(store.deleteCachedCallCount, 0)
    
  }
  
}
