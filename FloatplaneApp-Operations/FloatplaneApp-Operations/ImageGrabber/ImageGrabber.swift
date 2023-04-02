//
//  ImageGrabber.swift
//  FloatplaneApp-Operations
//
//  Created by George Urick on 4/1/23.
//

import Foundation
import AlamofireImage

public class ImageGrabber {
    
    public static let instance = ImageGrabber()
    
    private init() { }
    
    public func grab(url: URL, completion: @escaping ((Data?) -> Void)) {
        let _ = try? ImageDownloader.default.download(URLRequest(url: url, method: .get), completion: { response in
            completion(response.data)
            
        })
    }
    
}
