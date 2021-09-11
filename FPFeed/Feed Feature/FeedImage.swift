//
//  FeedItem.swift
//  FPFeed
//
//  Created by Fernando Putallaz on 01/10/2020.
//  Copyright © 2020 eFePe. All rights reserved.
//

import Foundation

public struct FeedImage: Equatable {
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

extension FeedImage: Decodable {
  private enum CodingKeys: String, CodingKey {
    case id
    case description
    case location
    case url = "image"
  }
}
