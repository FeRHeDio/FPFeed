//
//  FeedItem.swift
//  FPFeed
//
//  Created by Fernando Putallaz on 01/10/2020.
//  Copyright © 2020 eFePe. All rights reserved.
//

import Foundation

public struct FeedItem: Equatable{
    let id: UUID
    let description: String?
    let location: String?
    let imageURL: URL
}
