//
//  DelegateMockBase.swift
//  CatalogueTests
//
//  Created by Sorin Lumezeanu on 10/12/2017.
//  Copyright © 2017 Sorin Lumezeanu. All rights reserved.
//

import Foundation
import XCTest

class DelegateMockBase {    
    var testExpectation: XCTestExpectation?
    
    init(withTestExpectation testExpectation: XCTestExpectation?) {
        self.testExpectation = testExpectation
    }
}
