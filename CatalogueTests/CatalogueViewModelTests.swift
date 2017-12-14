//
//  CatalogueViewModelTests.swift
//  CatalogueTests
//
//  Created by Sorin Lumezeanu on 09/12/2017.
//  Copyright © 2017 Sorin Lumezeanu. All rights reserved.
//

import XCTest
@testable import Catalogue

import ObjectMapper

class CatalogueViewModelTests: XCTestCase {
    
    // system under test
    var catalogueViewModel: CatalogueViewModel!
    
    override func setUp() {
        super.setUp()
        
        ServiceProvider.register { CatalogueServiceMock() as CatalogueServiceProtocol }
    }
    
    override func tearDown() {
        super.tearDown()
        
        ServiceProvider.clearResolvers()
        self.catalogueViewModel = nil
    }
    
    func testStartLoadingItems() {
        class CatalogueViewModelDelegateMock: DelegateMockBase, CatalogueViewModelDelegate {
            func didReceiveCatalogueItems(_ items: [CatalogueItem]) {
                if items.count == 5 {
                    self.testExpectation?.fulfill()
                } else {
                    XCTFail("Expected 5 items but received \(items.count) items.")
                }
            }
            func didReceiveError(_ error: Error) {
                XCTFail("Did not expect 'didReceiveError:_' to be called.")
            }
        }
        
        let itemsAreReceived = expectation(description: "received 5 items")
        let mockDelegate = CatalogueViewModelDelegateMock(withTestExpectation: itemsAreReceived)
        self.catalogueViewModel = CatalogueViewModel(withDelegate: mockDelegate)
        
        self.catalogueViewModel.startLoadingItems()
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testRefreshItems() {
        
        class CatalogueViewModelDelegateMock: DelegateMockBase, CatalogueViewModelDelegate {
            func didReceiveCatalogueItems(_ items: [CatalogueItem]) {
                if items.count == 2 {
                    self.testExpectation?.fulfill()
                } else {
                    XCTFail("Expected 2 items but received \(items.count) items.")
                }
            }
            func didReceiveError(_ error: Error) {
                XCTFail("Did not expect 'didReceiveError:_' to be called.")
            }
        }
        
        let itemsAreReceived = expectation(description: "received 2 items")
        let mockDelegate = CatalogueViewModelDelegateMock(withTestExpectation: itemsAreReceived)
        self.catalogueViewModel = CatalogueViewModel(withDelegate: mockDelegate)
        
        let firstCatalogueItemMock = CatalogueItemMock(identifier: "123456", text: "123456", confidence: 0.5)
        self.catalogueViewModel.catalogueItems = [firstCatalogueItemMock]
        
        self.catalogueViewModel.refreshItems()
        
        waitForExpectations(timeout: 10, handler: nil)
    }
}

extension CatalogueViewModelTests {
    
    // keep the service mock classes nested inside the test class (other test classes may/will define their own mocks)
    class CatalogueServiceMock: CatalogueServiceProtocol {
        
        func fetchCatalogueItems(fetchingOptions: CatalogueFetchingOptions?,
                                 useCache: Bool,
                                 completion: @escaping (_ items: [CatalogueItem]?, _ error: Error?) -> Void) {

            var mockItems: [CatalogueItemMock] = []

            if useCache {
                if let _ = fetchingOptions {
                    // don't server back anything
                } else {
                    for itemIndex in 0 ..< 5 {      // serve back some 'initial' 5 items
                        mockItems.append(CatalogueItemMock(identifier: "idem: \(itemIndex)", text: "text: \(itemIndex)", confidence: 0.9))
                    }
                }
            } else {
                for itemIndex in 0 ..< 2 {      // serve back 2 'fresh-new' items
                    mockItems.append(CatalogueItemMock(identifier: "idem: \(itemIndex)", text: "text: \(itemIndex)", confidence: 0.9))
                }
            }
            
            completion(mockItems, nil)
        }
        
        func fetchImage(forCatalogueItem catalogueItem: CatalogueItem, completion: @escaping (_ image: UIImage?) -> Void) {
            completion(nil)
        }
        
    }
}

