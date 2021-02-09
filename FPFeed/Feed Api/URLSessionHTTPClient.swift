//
//  URLSessionHTTPClient.swift
//  FPFeed
//
//  Created by Fernando Putallaz on 09/02/2021.
//  Copyright © 2021 eFePe. All rights reserved.
//

import Foundation

public class URLSessionHTTPClient: HTTPClient {
  private let session: URLSession
  
  public init(session: URLSession = .shared) {
    self.session = session
  }
  
  private struct UnexpectedValueRepresentation: Error {}
  
  public func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
    session.dataTask(with: url) { data, response, error in
      if let error = error {
        completion(.failure(error))
      } else if let data = data, let response = response as? HTTPURLResponse {
        completion(.success(data, response))
      } else {
        completion(.failure(UnexpectedValueRepresentation()))
      }
    }.resume()
  }
}
