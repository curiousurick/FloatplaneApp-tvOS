//  Copyright © 2023 George Urick
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation

/// Has the info about a user's given creator subscription
public struct Subscription: Hashable, Codable, Equatable {
    /// Info about the subscription plan like how much it costs and at what interval.
    public struct Plan: Hashable, Codable, Equatable {
        public let allowGrandfatheredAccess: Bool
        public let currency: String
        public let description: String
        public let discordRoles: [String]
        public let discordServers: [String]
        public let featured: Bool
        public let id: String
        public let interval: Interval
        public let logo: Icon?
        public let price: String
        public let priceYearly: String
        public let title: String

        public init(
            allowGrandfatheredAccess: Bool, currency: String, description: String,
            discordRoles: [String], discordServers: [String], featured: Bool, id: String,
            interval: Interval, logo: Icon?, price: String, priceYearly: String, title: String
        ) {
            self.allowGrandfatheredAccess = allowGrandfatheredAccess
            self.currency = currency
            self.description = description
            self.discordRoles = discordRoles
            self.discordServers = discordServers
            self.featured = featured
            self.id = id
            self.interval = interval
            self.logo = logo
            self.price = price
            self.priceYearly = priceYearly
            self.title = title
        }
    }

    /// Known options for plan intervals.
    public enum Interval: String, Hashable, Codable, Equatable {
        case month
        case year
    }

    public let creator: String
    public let endDate: Date
    public let interval: Interval
    public let paymentCancelled: Bool
    public let paymentID: Int
    public let plan: Plan
    public let startDate: Date

    public init(
        creator: String, endDate: Date, interval: Interval, paymentCancelled: Bool,
        paymentID: Int, plan: Plan, startDate: Date
    ) {
        self.creator = creator
        self.endDate = endDate
        self.interval = interval
        self.paymentCancelled = paymentCancelled
        self.paymentID = paymentID
        self.plan = plan
        self.startDate = startDate
    }
}

/// Response from the SubscriptionOperation containing the list of subscriptions for the user.
public struct SubscriptionResponse: Codable, Equatable {
    public let subscriptions: [Subscription]

    public init(subscriptions: [Subscription]) {
        self.subscriptions = subscriptions
    }
}
