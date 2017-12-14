//
//  CatalogueStore.swift
//  Catalogue
//
//  Created by Sorin Lumezeanu on 09/12/2017.
//  Copyright © 2017 Sorin Lumezeanu. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireObjectMapper

public protocol CatalogueServiceProtocol: Service {
    
    func fetchCatalogueItems(fetchingOptions: CatalogueFetchingOptions?,
                             useCache: Bool,
                             completion: @escaping (_ items: [CatalogueItem]?, _ error: Error?) -> Void)
    
    func fetchImage(forCatalogueItem catalogueItem: CatalogueItem, completion: @escaping (_ image: UIImage?) -> Void)
}

class CatalogueService: CatalogueServiceProtocol {

    private struct Constants {
        static let catalogueKeysCacheKey = "catalogueKeys"
        static let catalogueItemImageBytesKeySuffix = "_photo"
        static let defaultPageSize = 10
    }
    
    func fetchCatalogueItems(fetchingOptions: CatalogueFetchingOptions?,
                             useCache: Bool,
                             completion: @escaping (_ items: [CatalogueItem]?, _ error: Error?) -> Void) {        

        if useCache {
            self.fetchCatalogueItemsFromCache(fetchingOptions: fetchingOptions) { (cachedItems) in
                if let cachedItems = cachedItems, cachedItems.isEmpty == false {
                    completion(cachedItems, nil)
                } else {
                    self.fetchCatalogueItemsFromNetwork(fetchingOptions: fetchingOptions, completion: completion)
                }
            }
        } else {
            self.fetchCatalogueItemsFromNetwork(fetchingOptions: fetchingOptions, completion: completion)
        }
    }
    
    func fetchImage(forCatalogueItem catalogueItem: CatalogueItem, completion: @escaping (_ image: UIImage?) -> Void) {
        guard let itemIdentifier = catalogueItem.identifier else {
            completion(nil)
            return
        }
        
        let imageKey = itemIdentifier + Constants.catalogueItemImageBytesKeySuffix
        let cacheService: CacheServiceProtocol = ServiceProvider.resolve()
        cacheService.loadObject(forKey: imageKey) { (base64EncodedImage: NSString?, _) -> Void in
            catalogueItem.base64EncodedImage = base64EncodedImage as String?
            completion(catalogueItem.image())
        }
    }
    
    private func fetchCatalogueItemsFromNetwork(fetchingOptions: CatalogueFetchingOptions?,
                                                completion: @escaping (_ items: [CatalogueItem]?, _ error: Error?) -> Void) {
        
        let apiService: APIServiceProtocol = ServiceProvider.resolve()
        let endpoint = APIEndpoint(path: "items", method: .get)
        
        apiService.request(endpoint: endpoint, fetchingOptions: fetchingOptions) { (catalogueItems: [CatalogueItem]?, error: Error?) in
            if let catalogueItems = catalogueItems, catalogueItems.isEmpty == false {
                self.persist(catalogueItems: catalogueItems, fetchingOptions: fetchingOptions)
            }
            completion(catalogueItems, error)
        }
    }
    
    private func fetchCatalogueItemsFromCache(fetchingOptions: CatalogueFetchingOptions?,
                                              completion: @escaping (_ items: [CatalogueItem]?) -> Void) {
        
        let cacheService: CacheServiceProtocol = ServiceProvider.resolve()
        cacheService.loadObject(forKey: Constants.catalogueKeysCacheKey) { (cachedCatalogueKeys: CatalogueKeys?, _) -> Void in
            let catalogueKeys = cachedCatalogueKeys ?? CatalogueKeys()
            
            var itemKeysToLoad: [String] = []
            if let fetchingOptions = fetchingOptions {
                switch fetchingOptions {
                case .newerThan(let itemIdentifier):
                    itemKeysToLoad = catalogueKeys.keys(forItemsNewerThan: itemIdentifier, limit: Constants.defaultPageSize)
                case .olderThan(let itemIdentifier):
                    itemKeysToLoad = catalogueKeys.keys(forItemsOlderThan: itemIdentifier, limit: Constants.defaultPageSize)
                }
            } else {
                itemKeysToLoad = catalogueKeys.firstKeys(limit: Constants.defaultPageSize)
            }
            
            if itemKeysToLoad.isEmpty == false {
                cacheService.loadObjects(forKeys: itemKeysToLoad) { (catalogueItems: [CatalogueItem]?, _) -> Void in
                    completion(catalogueItems)
                }
            } else {
                completion(nil)
            }
        }
    }
    
    private func persist(catalogueItems: [CatalogueItem], fetchingOptions: CatalogueFetchingOptions?) {
        let persistedItemIdentifiers = self.persist(catalogueItems: catalogueItems.filter { $0.identifier != nil })
        
        let cacheService: CacheServiceProtocol = ServiceProvider.resolve()
        cacheService.loadObject(forKey: Constants.catalogueKeysCacheKey) { (cachedCatalogueKeys: CatalogueKeys?, _) -> Void in
            let catalogueKeys = cachedCatalogueKeys ?? CatalogueKeys()
            
            if let fetchingOptions = fetchingOptions {
                switch fetchingOptions {
                case .newerThan(_):
                    catalogueKeys.add(keys: persistedItemIdentifiers.reversed(), atPosition: .first)
                case .olderThan(_):
                    catalogueKeys.add(keys: persistedItemIdentifiers, atPosition: .last)
                }
            } else {
                catalogueKeys.add(keys: persistedItemIdentifiers, atPosition: .last)
            }
            
            self.persist(catalogueKeys: catalogueKeys)
        }
    }
    
    private func persist(catalogueItems: [CatalogueItem]) -> [String] {
        var persistedItemIdentifiers: [String] = []
        
        catalogueItems.forEach {
            if let itemIdentifier = $0.identifier {
                persistedItemIdentifiers.append(itemIdentifier)
                
                let cacheService: CacheServiceProtocol = ServiceProvider.resolve()
                
                // persist the catalogue item (all fields but the item's image-bytes)
                cacheService.save(object: $0, forKey: itemIdentifier)
                
                // persist the item's image-bytes
                if let base64EncodedImage = $0.base64EncodedImage as NSString? {
                    cacheService.save(object: base64EncodedImage, forKey: itemIdentifier + Constants.catalogueItemImageBytesKeySuffix)
                }
            }
        }
        
        return persistedItemIdentifiers
    }
    
    private func persist(catalogueKeys: CatalogueKeys) {
        let cacheService: CacheServiceProtocol = ServiceProvider.resolve()
        cacheService.save(object: catalogueKeys, forKey: Constants.catalogueKeysCacheKey)
    }
}
