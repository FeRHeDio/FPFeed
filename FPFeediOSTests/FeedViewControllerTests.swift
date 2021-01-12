//
//  FeedViewControllerTests.swift
//  FPFeediOSTests
//
//  Created by Fernando Putallaz on 12/01/2021.
//  Copyright © 2021 eFePe. All rights reserved.
//

import XCTest

final class FeedViewController {
    
    init(loader: FeedViewControllerTests.LoaderSpy) {
        
    }
    
}


final class FeedViewControllerTests: XCTest {
    
    func test_init_doesNotLoadFeed() {
        let loader = LoaderSpy()
        _ = FeedViewController(loader: loader)
        
        XCTAssertEqual(loader.loadCallCount, 0)
    }
    
    // MARK: - Helpers
    
    class LoaderSpy {
        private(set) var loadCallCount: Int = 0
        
    }
    
    
}
