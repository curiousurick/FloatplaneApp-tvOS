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
import ParallaxView
import Kenmore_Models
import Kenmore_Utilities
import Kenmore_Operations

class CreatorListViewCell: ParallaxCollectionViewCell {
    private let logger = Log4S()

    static let identifier = "CreatorListViewCell"

    @IBOutlet var creatorIconView: UIImageView!

    func updateImage(creator: BaseCreator?) {
        guard let creator = creator else {
            creatorIconView.image = nil
            return
        }
        let icon = creator.icon.path
        ImageGrabber.instance.grab(url: icon) { response in
            guard let data = response,
                  let image = UIImage(data: data) else {
                self.logger.error("Error getting image for CreatorList Icon")
                return
            }
            DispatchQueue.main.async {
                let radius = self.creatorIconView.frame.width / 2
                self.creatorIconView.layer.cornerRadius = radius
                self.creatorIconView.layer.masksToBounds = true
                self.creatorIconView.image = image
            }
        }
    }
}
