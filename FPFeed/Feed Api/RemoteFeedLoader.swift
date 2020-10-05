//
//  RemoteFeedLoader.swift
//  FPFeed
//
//  Created by Fernando Putallaz on 05/10/2020.
//  Copyright © 2020 eFePe. All rights reserved.
//

import Foundation


public protocol HTTPClient {
    func get(from url: URL)
}

public final class RemoteFeedLoader {
    private let url: URL
    private let client: HTTPClient
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load() {
        client.get(from: url)
    }
}

