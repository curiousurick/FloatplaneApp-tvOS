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

import FloatplaneApp_Utilities
import AlamofireImage
import UIKit

public class ImageCacheConfig {
    
    public static let instance = ImageCacheConfig()
    
    private init() { }
    
    private var setup = false
    public func setup(diskSpaceMB: Int = 150) {
        if !setup {
            return
        }
        let diskCapacity = diskSpaceMB * 1024 * 1024
        let diskCache = URLCache(memoryCapacity: 0, diskCapacity: diskCapacity, diskPath: "image_disk_cache")
        let configuration = URLSessionConfiguration.default
        configuration.urlCache = diskCache
        let downloader = ImageDownloader(configuration: configuration)
        UIImageView.af.sharedImageDownloader = downloader
        setup = true
    }
}
