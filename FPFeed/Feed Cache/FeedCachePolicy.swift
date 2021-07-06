//
//  FeedCachePolicy.swift
//  FPFeed
//
//  Created by Fernando Putallaz on 06/07/2021.
//  Copyright © 2021 eFePe. All rights reserved.
//

import Foundation

internal final class FeedCachePolicy {
  private init() {}
  
  private static let calendar = Calendar(identifier: .gregorian)
  
  private static var maxCachedAgeInDays: Int {
    return 7
  }
  
  internal static func validate(_ timestamp: Date, against date: Date) -> Bool {
    guard let maxCacheAge = calendar.date(byAdding: .day, value: maxCachedAgeInDays, to: timestamp) else {
      return false
    }
    return date < maxCacheAge
  }
}
