//
//  FeedStore.swift
//  FPFeed
//
//  Created by Fernando Putallaz on 14/05/2021.
//  Copyright © 2021 eFePe. All rights reserved.
//

import Foundation

public protocol FeedStore {
  typealias DeletionCompletion = (Error?) -> Void
  typealias InsertionCompletion = (Error?) -> Void

  func deleteCachedFeed(completion: @escaping DeletionCompletion)
  func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion)
}

