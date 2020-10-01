//
//  RemoteFeedLoaderTests.swift
//  FPFeedTests
//
//  Created by Fernando Putallaz on 01/10/2020.
//  Copyright © 2020 eFePe. All rights reserved.
//

import XCTest

class RemoteFeedLoader {
    func load() {
        HTTPClient.shared.requestedURL = URL(string: "https://a-url.com")
    }
}

class HTTPClient {
    static let shared = HTTPClient()
    private init() {}
    var requestedURL: URL?
}

class RemoteFeedLoaderTests: XCTestCase {

    func test_init_DoNotRequestDataFromURL() {
        let client = HTTPClient.shared
        
        _ = RemoteFeedLoader()
        
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestDataFromURL() {
        //arrange -> Given a client and a sut
        
        let client = HTTPClient.shared
        let sut = RemoteFeedLoader()
        
        //act -> when we invoke sut.load()
        sut.load()
        
        
        //assert -> then assert that a URL request was initiated in the client
        XCTAssertNotNil(client.requestedURL)
    }
    
}
