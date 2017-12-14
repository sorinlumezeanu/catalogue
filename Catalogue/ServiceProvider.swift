//
//  ServiceFactoryProvider.swift
//  Catalogue
//
//  Created by Sorin Lumezeanu on 10/12/2017.
//  Copyright © 2017 Sorin Lumezeanu. All rights reserved.
//

import Foundation

public protocol Service {
    // marker protocol
}

public final class ServiceProvider {
    
    struct ResolverKey: Hashable, Equatable {
        var protocolType: Any.Type
        
        var hashValue: Int {
            return "\(protocolType)".hashValue
        }
        
        static func ==(lhs: ResolverKey, rhs: ResolverKey) -> Bool {
            return lhs.protocolType == rhs.protocolType
        }
    }
    
    private static var resolvers = [ResolverKey : () -> Any]()
    
    public static func register<T>(resolver: @escaping () -> T) {
        ServiceProvider.resolvers[ResolverKey(protocolType: T.self)] = resolver
    }
    
    public static func resolve<T>() -> T {
        let key = ResolverKey(protocolType: T.self)
        guard let resolver = self.resolvers[key] else {
            fatalError("Unregistered service type: \(T.self)")
        }
        return resolver() as! T
    }
    
    private static let sharedCache = CacheService()
    
    static func addDefaultResolvers() {
        ServiceProvider.clearResolvers()
        
        ServiceProvider.register { CatalogueService() as CatalogueServiceProtocol }
        ServiceProvider.register { APIService() as APIServiceProtocol }
        ServiceProvider.register { ServiceProvider.sharedCache as CacheServiceProtocol }
    }
    
    public static func clearResolvers() {
        ServiceProvider.resolvers.removeAll()
    }
}


