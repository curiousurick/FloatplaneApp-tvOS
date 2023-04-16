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
import FloatplaneApp_Models

enum TestingError: Error, Equatable {
    case reallyBad
    case notSoBad
    case strangelyGood
    case whyCallMeAnError
}

enum TestModelSupplier {
    static let about = "about"
    static let categoryString = "category"
    static let height: UInt64 = 720
    static let width: UInt64 = 1280
    static let path = URL(string: "https://fp.c/foo")!
    static let subImage = Icon(childImages: [], height: height, path: path, width: width)
    static let icon = Icon(childImages: [subImage], height: height, path: path, width: width)
    static let defaultChannel = "defaultChannel"
    static let description = "description"
    static let discoverable = true
    static let id = "id"
    static let incomeDisplay = true
    static let channelString = "channel"
    static let title = "title"
    static let ownerString = "owner"
    static let streamPath = "https://fp.c/streamthis.m3u8"
    static let offline = LiveStream.Offline(description: description, thumbnail: icon, title: title)
    static let liveStream = LiveStream(
        channel: channelString, description: description, id: id, offline: offline,
        owner: ownerString, streamPath: streamPath, thumbnail: icon, title: title
    )
    static let subscriberCountDisplay = "42000"
    static let urlname = "linustechtips"

    static let creatorRequest = CreatorRequest(named: urlname)
    static let creator = Creator(
        about: about, category: categoryString, cover: icon, defaultChannel: defaultChannel,
        description: description, discoverable: discoverable, icon: icon, id: id,
        incomeDisplay: incomeDisplay, liveStream: liveStream, owner: ownerString,
        subscriberCountDisplay: subscriberCountDisplay, title: title, urlname: urlname
    )

    static let fetchAfter = 20
    static let limit: UInt64 = 20
    static let creatorId = "creatorId"
    static let contentFeedRequest = ContentFeedRequest(fetchAfter: fetchAfter, limit: limit, creatorId: creatorId)
    static let attachmentOrder = "0"
    static let audioAttachment = "audioAttachment.mp3"
    static let cardString = "card"
    static let coverString = "cover"
    static let creatorString = "creator"
    static let order: UInt64 = 1
    static let channel = Channel(
        about: about, card: cardString, cover: coverString, creator: creatorId,
        icon: icon, id: id, order: order, title: title, urlname: urlname
    )
    static let comments: UInt64 = 1000
    static let category = Category(id: id, title: title)
    static let allowGrandfatheredAccess = false
    static let currency = "USD"
    static let discordRole = "discordRole"
    static let discordServer = "discordServer"
    static let featured = true
    static let interval = Subscription.Interval.month
    static let price = "5.00"
    static let priceYearly = "50.00"
    static let subscriptionPlan = Subscription.Plan(
        allowGrandfatheredAccess: allowGrandfatheredAccess, currency: currency, description: description,
        discordRoles: [discordRole], discordServers: [discordServer], featured: featured, id: id,
        interval: interval, logo: icon, price: price, priceYearly: priceYearly, title: title
    )
    static let username = "username"
    static let owner = Owner(id: id, username: username)
    static let contentCreator = ContentCreator(
        about: about, card: icon, category: category, channels: [channelString], cover: icon,
        defaultChannel: defaultChannel, description: description, discoverable: discoverable, icon: icon,
        id: id, incomeDisplay: incomeDisplay, liveStream: liveStream, owner: owner,
        subscriberCountDisplay: subscriberCountDisplay, subscriptionPlans: [subscriptionPlan], title: title,
        urlname: urlname
    )
    static let dislikes: UInt64 = 1
    static let galleryAttachment = "galleryattachment.jpg"
    static let guid = "guid"
    static let likes: UInt64 = 40
    static let audioCount: UInt64 = 1
    static let audioDuration: UInt64 = 1
    static let galleryCount: UInt64 = 0
    static let hasAudio = true
    static let hasGallery = false
    static let hasPicture = true
    static let hasVideo = true
    static let isFeatured = true
    static let pictureCount: UInt64 = 1
    static let videoCount: UInt64 = 1
    static let videoDuration: UInt64 = 120

    static let metadata = Metadata(
        audioCount: audioCount, audioDuration: audioDuration, galleryCount: galleryCount,
        hasAudio: hasAudio, hasGallery: hasGallery, hasPicture: hasPicture, hasVideo: hasVideo,
        isFeatured: isFeatured, pictureCount: pictureCount, videoCount: videoCount,
        videoDuration: videoDuration
    )
    static let pictureAttachment = "pic.jpg"
    static let releaseDate = Date(timeIntervalSince1970: 20000)
    static let score: UInt64 = 40
    static let tag = "tech"
    static let text = "this is text"
    static let videoType = VideoType.blogPost
    static let videoAttachment = "video.mp4"
    static let wasReleasedSilently = true
    static let feedItem = FeedItem(
        attachmentOrder: [attachmentOrder], audioAttachments: [audioAttachment], channel: channel, comments: comments,
        creator: contentCreator, dislikes: dislikes, galleryAttachments: [galleryAttachment], guid: guid, id: id,
        likes: likes, metadata: metadata, pictureAttachments: [pictureAttachment], releaseDate: releaseDate,
        score: score, tags: [tag], text: text, thumbnail: icon, title: title, type: videoType,
        videoAttachments: [videoAttachment], wasReleasedSilently: wasReleasedSilently
    )
    static let creatorFeed = CreatorFeed(items: [feedItem])

    static let creatorListRequest = CreatorListRequest()
    static let baseCreator = BaseCreator(
        about: about, category: categoryString, cover: icon, defaultChannel: defaultChannel,
        description: description, discoverable: discoverable, icon: icon, id: id, incomeDisplay: incomeDisplay,
        liveStream: liveStream, owner: ownerString, subscriberCountDisplay: subscriberCountDisplay,
        title: title, urlname: urlname
    )
    static let contentEmail = true
    static let contentFirebase = false
    static let createdAt = Date()
    static let creatorMessageEmail = true
    static let updatedAt = Date()
    static let userString = "user"
    static let userNotificationSettings = UserNotificationSetting(
        contentEmail: contentEmail, contentFirebase: contentFirebase, createdAt: createdAt,
        creator: creatorString, creatorMessageEmail: creatorMessageEmail, id: id,
        updatedAt: updatedAt, user: userString
    )
    static let creatorResponseObject = CreatorListResponse.CreatorResponseObject(
        creator: baseCreator,
        userNotificationSetting: userNotificationSettings
    )
    static let creatorListResponse = CreatorListResponse(responseObjects: [creatorResponseObject])

    static let contentVideoRequest = ContentVideoRequest(id: id)
    static let postType = PostType.vod
    static let duration: UInt64 = 39583
    static let isProcessing = true
    static let primaryBlogPost = "primaryBlogPost"
    static let isAccessible = true
    static let userInteraction = "userInteraction"
    static let qualityLevel = QualityLevel(name: "1080p", width: 1920, height: 1080, label: "1080p", order: 4)
    static let contentVideoResponse = ContentVideoResponse(
        id: id, guid: guid, title: title, type: postType, description: description,
        releaseDate: releaseDate, duration: duration, creator: creatorString, likes: likes,
        dislikes: dislikes, score: score, isProcessing: isProcessing, primaryBlogPost: primaryBlogPost,
        thumbnail: icon, isAccessible: isAccessible, blogPosts: [primaryBlogPost], timelineSprite: icon,
        userInteraction: [userInteraction], levels: [qualityLevel]
    )

    static let liveDeliveryKeyRequest = LiveDeliveryKeyRequest(creator: creatorString)
    static let vodDeliveryKeyRequest = VodDeliveryKeyRequest(guid: guid)
    static let cdn = "cdn"
    static let strategy = "strategy"
    static let codecs = "codecs"
    static let label = "label"
    static let mimeType = "mimeType"
    static let deliveryKeyQualityLevelName = DeliveryKeyQualityLevel.ql1080p
    static let decodedQualityLevel = DecodedQualityLevel(
        codecs: codecs, height: height, label: label, mimeType: mimeType,
        name: deliveryKeyQualityLevelName, order: order, width: width
    )
    static let fileName = "fileName"
    static let accessToken = "accessToken"
    static let qualityLevelResourceData = QualityLevelResourceData(
        decodedQualityLevel: decodedQualityLevel, fileName: fileName, accessToken: accessToken
    )
    static let qualityLevelMap = [DeliveryKeyQualityLevel.ql1080p: qualityLevelResourceData]
    static let resourceData = ResourceData(qualityLevels: qualityLevelMap, options: [deliveryKeyQualityLevelName])
    static let uri = "uri"
    static let resource = DeliveryKey.Resource(data: resourceData, uri: uri)
    static let deliveryKey = DeliveryKey(cdn: cdn, resource: resource, strategy: strategy)

    static let realCdn = "https://cdn-vod-drm2.floatplane.com"
    static let realUri = "/Videos/MRYfq5bLkt/{qualityLevelParams.2}/chunk.m3u8?token={qualityLevelParams.4}"
    static let realResource = DeliveryKey.Resource(data: resourceData, uri: realUri)
    static let realDeliveryKey = DeliveryKey(cdn: realCdn, resource: realResource, strategy: strategy)

    static let videoMetadataRequest = VideoMetadataRequest(feedItem: feedItem, id: id)
    static let videoMetadata = VideoMetadata(
        feedItem: feedItem,
        contentVideoResponse: contentVideoResponse,
        deliveryKey: deliveryKey
    )

    static let subscriptionRequest = SubscriptionRequest()
    static let endDate = Date(timeIntervalSince1970: 500_100)
    static let startDate = Date(timeIntervalSince1970: 500_000)
    static let paymentCancelled = true
    static let paymentID = 1
    static let subscription = Subscription(
        creator: creatorString, endDate: endDate, interval: interval, paymentCancelled: paymentCancelled,
        paymentID: paymentID, plan: subscriptionPlan, startDate: startDate
    )
    static let subscriptionResponse = SubscriptionResponse(subscriptions: [subscription])
    static let sortOrder = SortOrder.ascending
    static let searchQuery = "intel"
    static let searchRequest = SearchRequest(
        creatorId: creatorId,
        sort: sortOrder,
        searchQuery: searchQuery,
        fetchAfter: fetchAfter,
        limit: Int(limit)
    )
    static let searchResponse = SearchResponse(items: [feedItem])

    static let password = "mySuperS3cretPassword"
    static let loginRequest = LoginRequest(username: username, password: password)
    static let user = User(id: userString, username: username, profileImage: icon)
    static let needs2FA = true
    static let loginResponse = LoginResponse(user: user, needs2FA: needs2FA)
    static let errorMessage = "Wrong password!!!!"
    static let errorName = "ERROR_NAME.WRONG_PASSWORD"
    static let errorId = "403"
    static let loginError = LoginFailedResponse.LoginError(id: errorId, message: errorMessage, name: errorName)
    static let loginFailedResponse = LoginFailedResponse(errors: [loginError], message: errorMessage)

    static let logoutRequest = LogoutRequest()
    static let logoutResponse = LogoutResponse()
}
