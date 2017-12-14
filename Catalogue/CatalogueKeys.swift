//
//  Catalogue.swift
//  Catalogue
//
//  Created by Sorin Lumezeanu on 10/12/2017.
//  Copyright © 2017 Sorin Lumezeanu. All rights reserved.
//

import Foundation

class CatalogueKeys: NSObject, NSCoding {
    
    private struct Constants {
        static let itemIdentifiersArchivingKey = "keys"
    }
    
    enum Position {
        case first
        case last
    }
    
    private var keys: [String] = []
    
    func firstKeys(limit: Int) -> [String] {
        return Array(self.keys.prefix(limit))
    }

    func keys(forItemsOlderThan itemIdentifier: String, limit: Int) -> [String] {
        guard let olderThanIndex = self.keys.index(of: itemIdentifier) else { return [] }
        
        return Array(Array(self.keys[olderThanIndex...].dropFirst()).prefix(limit))
    }

    func keys(forItemsNewerThan itemIdentifier: String, limit: Int) -> [String] {
        guard let newerThanIndex = self.keys.index(of: itemIdentifier) else { return [] }
        
        return Array(Array(self.keys[..<newerThanIndex]).suffix(limit))
    }
    
    func add(keys: [String], atPosition position: Position) {
        switch position {
        case .first:
            self.keys.insert(contentsOf: keys, at: 0)
        case .last:
            self.keys.append(contentsOf: keys)
        }
    }
    
    // required for subclassing in the Testing target
    override public init() {
        super.init()
    }
    
    required init(coder aDecoder: NSCoder) {
        self.keys = (aDecoder.decodeObject(forKey: Constants.itemIdentifiersArchivingKey) as? [String]) ?? []
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.keys, forKey: Constants.itemIdentifiersArchivingKey)
    }
}
