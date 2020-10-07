//
//  RemoteFeedLoaderTests.swift
//  FPFeedTests
//
//  Created by Fernando Putallaz on 01/10/2020.
//  Copyright © 2020 eFePe. All rights reserved.
//

import XCTest
import FPFeed

class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestsDataFromURL() {
        let url = URL(string: "http://a-given_url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_load_requestsDataFromURLTwice() {
        let url = URL(string: "http://a-given_url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load { _ in }
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWithResult: .failure(.connectivity), when: {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
        })
    }
    
   
    func test_load_deliversErrorOnNon200HttpResponse() {
        let (sut, client) = makeSUT()
        let errorCodes = [199, 201, 300, 400, 500]
        
        errorCodes.enumerated().forEach { index, code in
            expect(sut, toCompleteWithResult: .failure(.invalidData), when: {
                client.complete(withStatusCode: code, at: index)
            })
        }
    }
    
    func test_load_deliversErrorOn200HttpResponseWithInvalidJson() {
        let (sut, client) = makeSUT()
    
        expect(sut, toCompleteWithResult: .failure(.invalidData), when: {
            let invalidJSON = Data(_ : "invalid json".utf8)
            client.complete(withStatusCode: 200, data: invalidJSON)
        })
    }
    
    func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJSONList() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWithResult: .success([]), when: {
            let emptyListJSON = Data(_ : "{\"items\": []}".utf8)
            client.complete(withStatusCode: 200, data: emptyListJSON)
        })
    }
    
    
    //MARK: Helpers
    
    private func makeSUT(url: URL = URL(string: "http://a-url.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        
        return (sut, client)
    }
    
    private func expect(_ sut: RemoteFeedLoader, toCompleteWithResult result: RemoteFeedLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        var capturedResults = [RemoteFeedLoader.Result]()
        sut.load { capturedResults.append($0) }
        
        action()
    
        XCTAssertEqual(capturedResults, [result], file: file, line: line)
    }
    
    private class HTTPClientSpy: HTTPClient {
        var messages = [(url: URL, completion: (HTTPClientResult) -> Void)]()
        var requestedURLs: [URL] {
            return messages.map { $0.url }
        }
        
        func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
            messages.append((url, completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(withStatusCode code: Int, data: Data = Data(), at index: Int = 0) {
            let response = HTTPURLResponse(
                url: requestedURLs[index],
                statusCode: code,
                httpVersion: nil,
                headerFields: nil
            )!
            messages[index].completion(.success(data, response))
            
        }
    }
    
}
