//
//  RemoteFeedLoader.swift
//  FPFeed
//
//  Created by Fernando Putallaz on 05/10/2020.
//  Copyright © 2020 eFePe. All rights reserved.
//

import Foundation


public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}

public final class RemoteFeedLoader {
    private let url: URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completion: @escaping (Error) -> Void) {
        client.get(from: url) { clientResult in
            
            switch clientResult {
            case .success:
                completion(.invalidData)
                
            case .failure:
                completion(.connectivity)
            }
        }
    }
}

