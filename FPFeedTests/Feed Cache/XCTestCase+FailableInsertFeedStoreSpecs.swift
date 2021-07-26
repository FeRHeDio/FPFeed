//
//  XCTestCase+FailableInsertFeedStoreSpecs.swift
//  FPFeedTests
//
//  Created by Fernando Putallaz on 26/07/2021.
//  Copyright © 2021 eFePe. All rights reserved.
//

import XCTest
import FPFeed

extension FailableInsertFeedStoreSpecs where Self: XCTestCase {
  func assertThatInsertDeliversErrorOnInsertionError(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
    let insertionError = insert((uniqueImageFeed().local, Date()), to: sut)
    
    XCTAssertNotNil(insertionError, "Expected cache insertion to fail with an error")
  }
  
  func assertThatInsertHasNoSideEffectsOnInsertionError(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
    insert((uniqueImageFeed().local, Date()), to: sut)
    
    expect(sut, toRetrieve: .empty)
  }
}
