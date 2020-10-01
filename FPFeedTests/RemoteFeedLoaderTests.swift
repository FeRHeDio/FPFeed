//
//  RemoteFeedLoaderTests.swift
//  FPFeedTests
//
//  Created by Fernando Putallaz on 01/10/2020.
//  Copyright © 2020 eFePe. All rights reserved.
//

import XCTest

class RemoteFeedLoader {
    let client: HTTPClient
    let url: URL
    
    init(url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }
    
    func load() {
        client.get(from: url)
    }
}



protocol HTTPClient {
    func get(from url: URL)
}



class HTTPClientSpy: HTTPClient {
    func get(from url: URL){
        requestedURL = url
    }
    var requestedURL: URL?
}



class RemoteFeedLoaderTests: XCTestCase {

    func test_init_DoNotRequestDataFromURL() {
        let url = URL(string: "http://a-given-url.com")!
        let client = HTTPClientSpy()
        _ = RemoteFeedLoader(url: url, client: client)
        
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestDataFromURL() {
        //arrange -> GIVEN a client and a sut
        
        let url = URL(string: "http://a-given-url.com")
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url!, client: client)
        
        //act -> WHEN we invoke sut.load()
        sut.load()
        
        //assert -> THEN assert that a URL request was initiated in the client
        XCTAssertEqual(client.requestedURL, url)
    }
}
