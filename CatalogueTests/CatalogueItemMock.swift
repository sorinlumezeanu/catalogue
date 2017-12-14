//
//  CatalogueItemMock.swift
//  CatalogueTests
//
//  Created by Sorin Lumezeanu on 10/12/2017.
//  Copyright © 2017 Sorin Lumezeanu. All rights reserved.
//

import Foundation
import ObjectMapper

class CatalogueItemMock: CatalogueItem {
    
    convenience init(identifier: String?, text: String?, confidence: Double?) {
        self.init()
        
        self.identifier = identifier
        self.text = text
        self.confidence = confidence
    }
}
