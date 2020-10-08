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
        let items: [Item]
    }
    
    struct Item: Decodable {
        public let id: UUID
        public let description: String?
        public let location: String?
        public let image: URL
        
        var item: FeedItem {
            return FeedItem(id: id, description: description, location: location, imageURL: image)
        }
    }
    
    private static var OK_200: Int { return 200 }
    
    internal static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [FeedItem] {
        guard response.statusCode == OK_200 else {
            throw RemoteFeedLoader.Error.invalidData
        }
        
        let root = try JSONDecoder().decode(Root.self, from: data)
        return root.items.map { $0.item }
    }
}
