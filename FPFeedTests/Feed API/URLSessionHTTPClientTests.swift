//
//  URLSessionHTTPClientTests.swift
//  FPFeedTests
//
//  Created by Fernando Putallaz on 16/11/2020.
//  Copyright © 2020 eFePe. All rights reserved.
//

import XCTest

class URLSessionHTTPClient {
    
    private let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    func get(from url: URL) {
        session.dataTask(with: url, completionHandler: { _, _, _ in })
    }
    
}


class URLSessionHTTPClientTests: XCTestCase {

    func test_getFromURL_createsDataTaskWithURL() {
        
        let url = URL(string: "any-url.com")!
        let session = URLSessionSpy()
        let sut = URLSessionHTTPClient(session: session)
        
        sut.get(from: url)
        
        XCTAssertEqual(session.receivedURLs, [url])
        
    }
    
    //MARK: 
    
    private class URLSessionSpy: URLSession {
        var receivedURLs = [URL]()
        
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            receivedURLs.append(url)
            
            return URLSessionDataTask()
        }
        
    }
    
    private class FakeURLSessinDataTask: URLSessionDataTask {}

}
