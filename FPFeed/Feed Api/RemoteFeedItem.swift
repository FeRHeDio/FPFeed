//
//  RemoteFeedItem.swift
//  FPFeed
//
//  Created by Fernando Putallaz on 15/05/2021.
//  Copyright © 2021 eFePe. All rights reserved.
//

import Foundation

internal struct RemoteFeedItem: Decodable {
  internal let id: UUID
  internal let description: String?
  internal let location: String?
  internal let image: URL
}
