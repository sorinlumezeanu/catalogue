//
//  APIClient.swift
//  Catalogue
//
//  Created by Sorin Lumezeanu on 09/12/2017.
//  Copyright © 2017 Sorin Lumezeanu. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireObjectMapper
import ObjectMapper

public protocol APIServiceProtocol: Service {
    func request<T: Mappable>(endpoint: APIEndpointProtocol,
                              fetchingOptions: CatalogueFetchingOptions?,
                              completion: @escaping (_ response: [T]?, _ error: Error?) -> Void)
}

class APIService: APIServiceProtocol {
    
    private static let baseUrl = "https://marlove.net/e/mock/v1/"
    private static let httpHeaders: HTTPHeaders = ["Authorization": "df49b6cd51b0baf6e98f373e2efd8d23"]

    private static let serverTrustPolicies: [String: ServerTrustPolicy] = [
        "marlove.net": .pinCertificates(
            certificates: ServerTrustPolicy.certificates(),
            validateCertificateChain: true,
            validateHost: true
        )
    ]

    private static let sessionManager = SessionManager(
        configuration: URLSessionConfiguration.default,
        serverTrustPolicyManager: ServerTrustPolicyManager(policies: APIService.serverTrustPolicies)
    )
    
    func request<T: Mappable>(endpoint: APIEndpointProtocol,
                              fetchingOptions: CatalogueFetchingOptions?,
                              completion: @escaping (_ response: [T]?, _ error: Error?) -> Void) {

        APIService.sessionManager.request(endpoint.absoluteUrl(withBaseUrl: APIService.baseUrl),
                                          method: endpoint.method,
                                          parameters: self.requestParameters(from: fetchingOptions),
                                          encoding: endpoint.urlEncoding(),
                                          headers: APIService.httpHeaders).responseArray {
                                            (response: DataResponse<[T]>) in
                                            
                                            self.debugResponse(response)
                                            
                                            let error = response.error ?? response.result.error ?? nil
                                            if let error = error {
                                                completion(nil, error)
                                            } else {
                                                completion(response.result.value, nil)
                                            }
        }
    }
    
    private func requestParameters(from fetchingOptions: CatalogueFetchingOptions?) -> Parameters? {
        guard let fetchingOptions = fetchingOptions else { return nil }
        
        switch fetchingOptions {
        case .newerThan(let identifier):
            return ["since_id": identifier]
        case .olderThan(let identifier):
            return ["max_id": identifier]
        }
    }
    
    private func debugResponse<T: Mappable>(_ response: DataResponse<[T]>) {
        print(response.request?.url?.absoluteString ?? "unknown URL")
        
        if let responseData = response.data {
            print(String(data: responseData, encoding: String.Encoding.utf8) as Any)
        }
    }
}
