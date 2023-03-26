import Foundation

struct CreatorFeed: Codable {
    struct Metadata: Codable {
        let audioCount: UInt64
        let audioDuration: UInt64
        let galleryCount: UInt64
        let hasAudio: Bool
        let hasGallery: Bool
        let hasPicture: Bool
        let hasVideo: Bool
        let isFeatured: Bool
        let pictureCount: UInt64
        let videoCount: UInt64
        let videoDuration: UInt64
    }

    struct Channel: Codable {
        let about: String
        let card: String?
        let cover: String?
        let creator: String
        let icon: Icon
        let id: String
        let order: UInt64
        let title: String
        let urlname: String
    }
    
    struct Icon: Codable {
        let childImages: [Image]
        let height: UInt64
        let path: URL
        let width: UInt64
    }

    struct Image: Codable {
        let height: UInt64
        let path: URL
        let width: UInt64
    }
    
    struct Category: Codable {
        let id: String
        let title: String
    }
    
    struct LiveStream: Codable {
        struct Offline: Codable {
            let description: String
            let thumbnail: Icon
            let title: String
        }
        let channel: String
        let description: String
        let id: String
        let offline: Offline
        let owner: String
        let streamPath: String
        let thumbnail: Icon
        let title: String
    }
    
    struct Owner: Codable {
        let id: String
        let username: String
    }
    
    struct SubscriptionPlan: Codable {
        let allowGrandfatheredAccess: Bool
        let currency: String
        let description: String
        let discordRoles: [String]
        let discordServers: [String]
        let featured: Bool
        let id: String
        let interval: String
        let logo: String?
        let price: String
        let priceYearly: String
        let title: String
    }
    
    struct Creator: Codable {
        let about: String
        let card: Icon
        let category: Category
        let channels: [String]
        let cover: Icon
        let defaultChannel: String
        let description: String
        let discoverable: Bool
        let icon: Icon
        let id: String
        let incomeDisplay: Bool
        let liveStream: LiveStream
        let owner: Owner
        let subscriberCountDisplay: String
        let subscriptionPlans: [SubscriptionPlan]
        let title: String
        let urlname: String
    }
    
    struct FeedItem: Codable {
        let attachmentOrder: [String]
        let audioAttachments: [String]
        let channel: Channel
        let comments: UInt64
        let creator: Creator
        let dislikes: UInt64
        let galleryAttachments: [String]
        let guid: String
        let id: String
        let isAccessible: Bool = true
        let likes: UInt64
        let metadata: Metadata
        let pictureAttachments: [String]
        let releaseDate: Date
        let score: UInt64
        let tags: [String]
        let text: String
        let thumbnail: Icon
        let title: String
        let type: String
        let videoAttachments: [String]
        let wasReleasedSilently: Bool
    }
    
    let items: [FeedItem]
    
    func combine(with items: [FeedItem]) -> CreatorFeed {
        var combined = self.items
        combined += items
        return CreatorFeed(items: combined)
        
    }
    
}
