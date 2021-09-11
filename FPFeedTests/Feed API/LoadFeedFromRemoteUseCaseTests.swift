//
//  RemoteFeedLoaderTests.swift
//  FPFeedTests
//
//  Created by Fernando Putallaz on 01/10/2020.
//  Copyright © 2020 eFePe. All rights reserved.
//

import XCTest
import FPFeed

class LoadFeedFromRemoteUseCaseTests: XCTestCase {
  
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
    
    expect(sut, toCompleteWith: failure(.connectivity), when: {
      let clientError = NSError(domain: "Test", code: 0)
      client.complete(with: clientError)
    })
  }
  
  
  func test_load_deliversErrorOnNon200HttpResponse() {
    let (sut, client) = makeSUT()
    let errorCodes = [199, 201, 300, 400, 500]
    
    errorCodes.enumerated().forEach { index, code in
      expect(sut, toCompleteWith: failure(.invalidData), when: {
        let json = makeItemsJSON([])
        client.complete(withStatusCode: code, data: json, at: index)
      })
    }
  }
  
  func test_load_deliversErrorOn200HttpResponseWithInvalidJson() {
    let (sut, client) = makeSUT()
    
    expect(sut, toCompleteWith: failure(.invalidData), when: {
      let invalidJSON = Data(_ : "invalid json".utf8)
      client.complete(withStatusCode: 200, data: invalidJSON)
    })
  }
  
  func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJSONList() {
    let (sut, client) = makeSUT()
    
    expect(sut, toCompleteWith: .success([]), when: {
      let emptyListJSON = makeItemsJSON([])
      client.complete(withStatusCode: 200, data: emptyListJSON)
    })
  }
  
  func test_load_deliversItemsOnHTTPResponseWithJSONItems() {
    let (sut, client) = makeSUT()
    let item1 = makeItem(
      id: UUID(),
      imageURL: URL(string: "http://www.someurl.com")!)
    
    let item2 = makeItem(
      id: UUID(),
      description: "some description",
      location: "Some location",
      imageURL: URL(string: "www.someurl.com")!)
    
    let items = [item1.model, item2.model]
    
    expect(sut, toCompleteWith: .success(items), when: {
      let json = makeItemsJSON([item1.json, item2.json])
      client.complete(withStatusCode: 200, data: json)
    })
  }
  
  func test_loadDoesNotDeliverResultAfterSUTInstanceHaveBeenDeallocated() {
    let url = URL(string: "some-url.com")!
    let client = HTTPClientSpy()
    var sut: RemoteFeedLoader? = RemoteFeedLoader(url: url, client: client)
    
    var capturedResults = [RemoteFeedLoader.Result]()
    sut?.load { capturedResults.append($0) }
    
    sut = nil
    client.complete(withStatusCode: 200, data: makeItemsJSON([]))
    
    XCTAssertTrue(capturedResults.isEmpty)
  }
  
  //MARK: Helpers
  
  private func makeSUT(url: URL = URL(string: "http://a-url.com")!, file: StaticString = #file, line: UInt = #line) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
    
    let client = HTTPClientSpy()
    let sut = RemoteFeedLoader(url: url, client: client)
    
    trackForMemoryLeak(client, file: file, line: line)
    trackForMemoryLeak(sut, file: file, line: line)
    
    return (sut, client)
  }
  
  private func failure(_ error: RemoteFeedLoader.Error) -> RemoteFeedLoader.Result {
    return .failure(error)
  }
  
  private func makeItem(id: UUID, description: String? = nil, location: String? = nil, imageURL: URL) -> (model: FeedImage, json: [String: Any]) {
    let item = FeedImage(id: id, description: description, location: location, url: imageURL)
    
    let json = [
      "id": id.uuidString,
      "description": description,
      "location": location,
      "image": imageURL.absoluteString
    ].reduce(into: [String: Any]()) { (accu, element) in
      if let value = element.value { accu[element.key] = value }
    }
    
    return (item, json)
  }
  
  func makeItemsJSON(_ items: [[String: Any]]) -> Data {
    let json = ["items": items]
    
    return try! JSONSerialization.data(withJSONObject: json)
  }
  
  private func expect(_ sut: RemoteFeedLoader, toCompleteWith expectedResult: RemoteFeedLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
    let exp = expectation(description: "Wait for load completion")
    
    sut.load { receivedResult in
      switch (receivedResult, expectedResult) {
      case let (.success(receivedItems), .success(expectedItems)):
        XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
        
      case let (.failure(receivedError as RemoteFeedLoader.Error), .failure(expectedError as RemoteFeedLoader.Error)):
        XCTAssertEqual(receivedError, expectedError, file: file, line: line)
        
      default:
        XCTFail("Expected result \(expectedResult) got \(receivedResult) instead", file: file, line: line)
      }
      
      exp.fulfill()
    }
    
    action()
    wait(for: [exp], timeout: 1.0)
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
    
    func complete(withStatusCode code: Int, data: Data, at index: Int = 0) {
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
