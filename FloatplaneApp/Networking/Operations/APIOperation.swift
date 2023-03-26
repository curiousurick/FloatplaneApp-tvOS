//
//  APIOperation.swift
//  FloatplaneApp
//
//  Created by George Urick on 3/25/23.
//

import Foundation

protocol APIOperation: AnyObject {
    
    associatedtype RequestParams
    associatedtype ResponseValue
    
    var baseUrl: URL { get }
    
    func get(params: RequestParams, completion: ((ResponseValue?, Error?) -> Void)?)
    
}
