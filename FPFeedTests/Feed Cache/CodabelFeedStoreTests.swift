//
//  CodabelFeedStoreTests.swift
//  FPFeedTests
//
//  Created by Fernando Putallaz on 08/07/2021.
//  Copyright © 2021 eFePe. All rights reserved.
//

import XCTest
import FPFeed

class CodableFeedStore {
  func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
    completion(.empty)
  }
}

class CodabelFeedStoreTests: XCTestCase {
  
  func test_retrieve_deliversEmptyOnEmptyCache() {
    let sut = CodableFeedStore()
    let exp = expectation(description: "Wait for cache retrieval")
    sut.retrieve { result in
      switch result {
      case .empty:
        break
      
      default:
          XCTFail("Expected empty result, got \(result) instead")
      }
      
      exp.fulfill()
    }
    
    wait(for: [exp], timeout: 1.0)
  }
  
  
}
