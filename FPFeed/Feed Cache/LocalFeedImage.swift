//
//  LocalFeedItem.swift
//  FPFeed
//
//  Created by Fernando Putallaz on 15/05/2021.
//  Copyright © 2021 eFePe. All rights reserved.
//

import Foundation

public struct LocalFeedImage: Equatable {
  public let id: UUID
  public let description: String?
  public let location: String?
  public let url: URL
  
  public init(id: UUID, description: String?, location: String?, url: URL) {
    self.id = id
    self.description = description
    self.location = location
    self.url = url
  }
}
