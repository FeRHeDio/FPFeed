//
//  FeedLoader.swift
//  FPFeed
//
//  Created by Fernando Putallaz on 01/10/2020.
//  Copyright © 2020 eFePe. All rights reserved.
//

import Foundation

enum LoadFeedResult {
    case success([FeedItem])
    case error(Error)
}

protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
