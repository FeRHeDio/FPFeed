//
//  FeedItemsMapper.swift
//  FPFeed
//
//  Created by Fernando Putallaz on 08/10/2020.
//  Copyright © 2020 eFePe. All rights reserved.
//

import Foundation

internal final class FeedItemsMapper {
  struct Root: Decodable {
    let items: [RemoteFeedItem]

  }
  
  private static var OK_200: Int { return 200 }
  
  internal static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [RemoteFeedItem] {
    guard response.statusCode == OK_200,
          let root = try? JSONDecoder().decode(Root.self, from: data) else {
      throw RemoteFeedLoader.Error.invalidData
    }
    
    return root.items
  }
}
