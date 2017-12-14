//
//  APIEndpoint.swift
//  Catalogue
//
//  Created by Sorin Lumezeanu on 10/12/2017.
//  Copyright © 2017 Sorin Lumezeanu. All rights reserved.
//

import Foundation

import Alamofire

public protocol APIEndpointProtocol {
    var path: String { get }
    var method: HTTPMethod { get }
    
    func urlEncoding() -> URLEncoding
    func absoluteUrl(withBaseUrl baseUrl: String) -> URL
}

struct APIEndpoint: APIEndpointProtocol {
    let path: String
    let method: HTTPMethod
    
    func urlEncoding() -> URLEncoding {
        switch self.method {
        case .get, .head, .delete:
            return URLEncoding(destination: .queryString)
        default:
            return URLEncoding(destination: .httpBody)
        }
    }
    
    func absoluteUrl(withBaseUrl baseUrl: String) -> URL {
        let urlAbsolutePath = baseUrl + self.path
        guard let url = URL(string: urlAbsolutePath) else {
            fatalError("Invalid URL: \(urlAbsolutePath)")       // better fail disgracefully rather than silently ignore a malformed URL
        }
        
        return url
    }
}
