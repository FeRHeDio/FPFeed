//
//  XCTestCase+FailableRetrieveFeedStoreSpecs.swift
//  FPFeedTests
//
//  Created by Fernando Putallaz on 24/07/2021.
//  Copyright © 2021 eFePe. All rights reserved.
//

import XCTest
import FPFeed

extension FailableRetrieveFeedStoreSpecs where Self: XCTestCase {
  
  func assertThatRetrieveDeliversFailureOnRetrievalError(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
    expect(sut, toRetrieve: .failure(anyNSError()), file: file, line: line)
  }
  
  func assertThatRetrieveHasNoSideEffectOnFailure(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
    expect(sut, toRetrieveTwice: .failure(anyNSError()), file: file, line: line)
  }
}
