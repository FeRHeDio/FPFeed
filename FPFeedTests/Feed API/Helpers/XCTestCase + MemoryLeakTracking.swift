//
//  XCTestCase + MemoryLeakTracking.swift
//  FPFeedTests
//
//  Created by Fernando Putallaz on 27/01/2021.
//  Copyright © 2021 eFePe. All rights reserved.
//

import XCTest

extension XCTestCase {
  func trackForMemoryLeak(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
    addTeardownBlock { [weak instance] in
      XCTAssertNil(instance, "Instance should be deallocated, potential memory leak", file: file, line: line)
    }
  }
}
