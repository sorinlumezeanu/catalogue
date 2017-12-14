//
//  CacheService.swift
//  Catalogue
//
//  Created by Sorin Lumezeanu on 10/12/2017.
//  Copyright © 2017 Sorin Lumezeanu. All rights reserved.
//

import Foundation
import Carlos

public protocol CacheServiceProtocol: Service {
        
    func save<T: NSCoding>(object: T, forKey key: String)
    func loadObject<T: NSCoding>(forKey key: String, completion: @escaping (T?, Error?) -> Void)
    func loadObjects<T: NSCoding>(forKeys keys: [String], completion: @escaping (_ objects: [T]?, _ error: Error?) -> Void)
}

class CacheService: CacheServiceProtocol {
        
    private let cache = MemoryCacheLevel<String, NSData>().compose(DiskCacheLevel())
    
    func save<T: NSCoding>(object: T, forKey key: String) {
        let objectData = NSKeyedArchiver.archivedData(withRootObject: object)
        let _ = self.cache.set(objectData as NSData, forKey: key)
    }
    
    func loadObject<T: NSCoding>(forKey key: String, completion: @escaping (T?, Error?) -> Void) {
        self.cache.get(key)
            .onSuccess { (archivedObject) in
                let cachedObject = NSKeyedUnarchiver.unarchiveObject(with: archivedObject as Data) as? T
                completion(cachedObject, nil)
            }.onFailure { (error) in
                completion(nil, error)
        }
    }
    
    func loadObjects<T: NSCoding>(forKeys keys: [String], completion: @escaping (_ objects: [T]?, _ error: Error?) -> Void) {
        self.cache.batchGetSome(keys)
            .onSuccess { (archivedObjects) in
                var cachedObjects: [T] = []
                archivedObjects.forEach {
                    if let cachedObject = NSKeyedUnarchiver.unarchiveObject(with: $0 as Data) as? T {
                        cachedObjects.append(cachedObject)
                    }
                }
                completion(cachedObjects, nil)
            }.onFailure { (error) in
                completion(nil, error)
        }
    }
}

