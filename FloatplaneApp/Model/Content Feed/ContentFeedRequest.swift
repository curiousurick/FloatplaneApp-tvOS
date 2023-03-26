//
//  ContentFeedRequest.swift
//  FloatplaneApp
//
//  Created by George Urick on 3/25/23.
//

import Foundation

struct ContentFeedRequest {
    let fetchAfter: Int
    let limit: UInt64
    let creatorId: String
}
