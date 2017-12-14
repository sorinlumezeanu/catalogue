//
//  CatalogueServiceTests.swift
//  CatalogueTests
//
//  Created by Sorin Lumezeanu on 11/12/2017.
//  Copyright © 2017 Sorin Lumezeanu. All rights reserved.
//

import XCTest
@testable import Catalogue

import ObjectMapper

class CatalogueServiceTests: XCTestCase {
    
    // system under test
    var catalogueService: CatalogueService!
    
    override func setUp() {
        super.setUp()
        
        ServiceProvider.register { APIServiceMock() as APIServiceProtocol }
        ServiceProvider.register { CacheServiceMock.shared as CacheServiceProtocol }
        
        self.catalogueService = CatalogueService()
    }
    
    override func tearDown() {
        super.tearDown()
        
        ServiceProvider.clearResolvers()
        self.catalogueService = nil
    }
    
    func testFetchCatalogueItems_oldItems_useCache() {
        let fetchingOptions = CatalogueFetchingOptions.olderThan(itemIdentifier: "test")
        let itemsAreReceived = expectation(description: "received 7 items")
        
        // go!
        self.catalogueService.fetchCatalogueItems(fetchingOptions: fetchingOptions, useCache: true) { (items, error) in
            XCTAssertTrue(error == nil, "Expected 7 items but received error: \(error!).")
            XCTAssertTrue(items != nil, "Expected 7 items but received a 'nil' array of items.")
            XCTAssertTrue(items!.count == 7, "Expected 7 items but received \(items!.count) items.")
            itemsAreReceived.fulfill()
        }
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testFetchCatalogueItems_oldItems_dontUseCache() {
        let fetchingOptions = CatalogueFetchingOptions.olderThan(itemIdentifier: "test")
        let itemsAreReceived = expectation(description: "received 2 items")
        
        // go!
        self.catalogueService.fetchCatalogueItems(fetchingOptions: fetchingOptions, useCache: false) { (items, error) in
            XCTAssertTrue(error == nil, "Expected 2 items but received error: \(error!).")
            XCTAssertTrue(items != nil, "Expected 2 items but received a 'nil' array of items.")
            XCTAssertTrue(items!.count == 2, "Expected 2 items but received \(items!.count) items.")
            itemsAreReceived.fulfill()
        }
        
        waitForExpectations(timeout: 10, handler: nil)
    }
}

extension CatalogueServiceTests {
    
    // keep the service mock classes nested inside the test class (other test classes may/will define their own mocks)
    class APIServiceMock: APIServiceProtocol {
        
        func request<T: Mappable>(endpoint: APIEndpointProtocol,
                                  fetchingOptions: CatalogueFetchingOptions?,
                                  completion: @escaping (_ response: [T]?, _ error: Error?) -> Void) {
            
            var mockItems: [CatalogueItemMock] = []
            for itemIndex in 0 ..< 2 {
                mockItems.append(CatalogueItemMock(identifier: "idem: \(itemIndex)", text: "text: \(itemIndex)", confidence: 0.9))
            }
            completion(mockItems as? [T], nil)
        }
    }
    
}

extension CatalogueServiceTests {
    
    // keep the service mock classes nested inside the test class (other test classes may/will define their own mocks)
    class CacheServiceMock: CacheServiceProtocol {
        
        fileprivate static let shared = CacheServiceMock()
        
        func save<T>(object: T, forKey key: String) where T : NSCoding {
        }
        
        func loadObject<T>(forKey key: String, completion: @escaping (T?, Error?) -> Void) where T : NSCoding {
            if T.self == CatalogueKeys.self {
                let catalogueKeys = CatalogueKeysMock()
                completion(catalogueKeys as? T, nil)
            }
        }
        
        func loadObjects<T>(forKeys keys: [String], completion: @escaping ([T]?, Error?) -> Void) where T : NSCoding {
            if T.self == CatalogueItem.self {
                var mockItems: [CatalogueItemMock] = []
                for itemIndex in 0 ..< 7 {      // serve bcak 7 'cached' items
                    mockItems.append(CatalogueItemMock(identifier: "idem: \(itemIndex)", text: "text: \(itemIndex)", confidence: 0.9))
                }
                completion(mockItems as? [T], nil)
            }
        }
    }
    
    class CatalogueKeysMock: CatalogueKeys {
        
        override func keys(forItemsOlderThan itemIdentifier: String, limit: Int) -> [String] {
            return ["test"]
        }
    }
}

