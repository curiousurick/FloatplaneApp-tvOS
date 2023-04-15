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

import UIKit
import AlamofireImage
import FloatplaneApp_Utilities

/// Creates the standard configuration for the image cache.
/// Sets up the limit of the cache based on the number of MB should be usd. 150 MB is the default.
/// The URLCache is universal so all image calls should result in caching.
/// But it also sets this on the AlamofireImage ImageDownloader because that's how all the images are retrieved.
public class ImageCacheConfig {
    public static let instance = ImageCacheConfig()
    private let imageDiskCachePath = "image_disk_cache"

    private init() {}

    /// Don't allow this to be called for than once.
    private var setup = false

    /// Sets up the image cache configuration to set the disk path and capacity of the image cache.
    public func setup(diskSpaceMB: Int = 150) {
        if setup {
            return
        }
        let diskCapacity = diskSpaceMB * 1024 * 1024
        let diskCache = URLCache(memoryCapacity: diskCapacity, diskCapacity: diskCapacity, diskPath: imageDiskCachePath)
        let configuration = URLSessionConfiguration.default
        configuration.urlCache = diskCache
        let downloader = ImageDownloader(configuration: configuration)
        UIImageView.af.sharedImageDownloader = downloader
        setup = true
    }
}
