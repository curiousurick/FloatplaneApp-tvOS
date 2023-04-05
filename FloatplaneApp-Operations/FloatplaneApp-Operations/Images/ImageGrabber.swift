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
import AlamofireImage

/// Wrapper for ImageDownloader to make it easier to get images from a URL
public class ImageGrabber {
    
    public static let instance = ImageGrabber()
    
    private init() { }
    
    /// Takes the image URL and returns the image data returned by ImageDownloader.
    /// Returns nil if ImageDownloader cannot find the image data.
    /// TODO: Add logging for errors
    public func grab(url: URL, completion: @escaping ((Data?) -> Void)) {
        let _ = try? ImageDownloader.default.download(URLRequest(url: url, method: .get), completion: { response in
            completion(response.data)
        })
    }
    
}
