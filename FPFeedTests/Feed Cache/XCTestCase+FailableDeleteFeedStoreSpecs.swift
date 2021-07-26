//
//  XCTestCase+FailableDeleteFeedStoreSpecs.swift
//  FPFeedTests
//
//  Created by Fernando Putallaz on 26/07/2021.
//  Copyright © 2021 eFePe. All rights reserved.
//

import XCTest
import FPFeed

extension FailableDeleteFeedStoreSpecs where Self: XCTestCase {
  func assertThatDeleteDeliversErrorOnDeletionError(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
    let deletionError = deleteCache(from: sut)
    
    XCTAssertNotNil(deletionError, "Expected cache deletion to fail", file: file, line: line)
  }
  
  func assertThatDeleteHasNoSideEffectsOnDeletionError(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
    deleteCache(from: sut)
  
    expect(sut, toRetrieve: .empty, file: file, line: line)
  }
}
