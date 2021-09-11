//
//  SharedTestHelpers.swift
//  FPFeedTests
//
//  Created by Fernando Putallaz on 25/05/2021.
//  Copyright © 2021 eFePe. All rights reserved.
//

import Foundation

func anyNSError() -> NSError {
  return NSError(domain: "any error", code: 0)
}


func anyURL() -> URL {
  return URL(string: "any-url.com")!
}
