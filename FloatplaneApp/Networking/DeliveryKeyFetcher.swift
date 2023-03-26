//
//  DeliveryKeyFetcher.swift
//  FloatplaneApp
//
//  Created by George Urick on 3/25/23.
//

import Foundation
import Alamofire

class DeliveryKeyFetcher {
    
    /// Test URL for WAN show 3/24/23
    let url = "https://www.floatplane.com//api/v2/cdn/delivery?type=vod&guid=wcKzVJkZMg"
    
    func get(completion: @escaping (DeliveryKey) -> Void) {
        let afURL = URL(string: url)!
        
        AF.request(afURL).responseDecodable(of: DeliveryKey.self) { response in
            completion(response.value!)
        }
    }
    
    
}
