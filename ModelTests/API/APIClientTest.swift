//
//  APIClientTest.swift
//  ModelTests
//
//  Created by kawaharadai on 2018/10/13.
//  Copyright © 2018年 kawaharadai. All rights reserved.
//

import XCTest
@testable import Model

final class APIClientTest: XCTestCase {
    
    func test_request_API通信を行いレスポンスを受けるテスト() {
        let expectation = self.expectation(description: "API通信を行いレスポンスを受けるテスト")
        APIClient.request(option: .sampleAPI()) { result in
            expectation.fulfill()
            // レスポンスの結果は考慮しない
            XCTAssertNotNil(result)
        }
        self.waitForExpectations(timeout: 10, handler: nil)
    }

}
