//
//  DeliveryKeyFetcher.swift
//  FloatplaneApp
//
//  Created by George Urick on 3/25/23.
//

import Foundation
import Alamofire

class DeliveryKeyOperation: APIOperation {
    
    typealias ResponseValue = DeliveryKey
    typealias RequestParams = DeliveryKeyRequest
    
    
    /// Test URL for WAN show 3/24/23
    let baseUrl: URL = URL(string: "https://\(OperationConstants.domain)/api/v2/cdn/delivery")!
    
    func get(params: DeliveryKeyRequest, completion: ((DeliveryKey?, Error?) -> Void)? = nil) {
        let params = [
            // Only known value right now
            "type": params.type.rawValue,
            "guid": params.guid
        ]
        AF.request(baseUrl, parameters: params).responseDecodable(of: DeliveryKey.self) { response in
            completion?(response.value!, nil)
        }
    }
    
    
}
