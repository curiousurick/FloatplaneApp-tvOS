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

class LoginImageTextField: UIView {
    @IBOutlet var textField: UITextField!
    @IBOutlet var iconImage: UIImageView!
    @IBOutlet var placeholderLabel: UILabel!

    private let focusedScale: CGFloat = 1.05
    private let unfocusedScale: CGFloat = 1.0
    private let focusAnimationDuration = 0.1
    private let slightViewCornerRadius: CGFloat = 2

    override func awakeFromNib() {
        super.awakeFromNib()

        iconImage.layer.cornerRadius = slightViewCornerRadius
        iconImage.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        iconImage.layer.masksToBounds = true

        textField.layer.cornerRadius = slightViewCornerRadius
        textField.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        textField.layer.masksToBounds = true

        iconImage.backgroundColor = isFocused ? UIColor.focusedTextImageColor : UIColor.unfocusedTextImageColor
    }

    func focusAnimation(focused: Bool) {
        UIView.animate(withDuration: focusAnimationDuration, animations: { () in
            let scale = focused ? self.focusedScale : self.unfocusedScale
            let transform = CGAffineTransformMakeScale(scale, scale)
            self.transform = transform
            self.iconImage.backgroundColor = focused ? UIColor.focusedTextImageColor : UIColor.unfocusedTextImageColor
        })
    }

    func updatePlaceholderView() {
        let hasText = textField.text != nil && !textField.text!.isEmpty
        placeholderLabel.alpha = hasText ? 0.0 : 1.0
    }
}
