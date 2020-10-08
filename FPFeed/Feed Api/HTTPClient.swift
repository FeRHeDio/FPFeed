//
//  HTTPClient.swift
//  FPFeed
//
//  Created by Fernando Putallaz on 08/10/2020.
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
