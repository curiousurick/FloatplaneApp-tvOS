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

class LoginImageTextView: UIView {
    
    @IBOutlet var textField: UITextField!
    @IBOutlet var iconImage: UIImageView!
    
    let focusedColor = UIColor(red: 0x4E / 255, green: 0xAC / 255, blue: 0xE6 / 255, alpha: 1.0)
    let unfocusedColor = UIColor(red: 0x60 / 255, green: 0x95 / 255, blue: 0xAE / 255, alpha: 1.0)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        iconImage.layer.cornerRadius = 2
        iconImage.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        iconImage.layer.masksToBounds = true
        
        textField.layer.cornerRadius = 2
        textField.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        textField.layer.masksToBounds = true
        
        self.iconImage.backgroundColor = isFocused ? focusedColor : unfocusedColor
    }
    
    func focusAnimation(focused: Bool) {
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            let scale = focused ? 1.05 : 1.0
            let transform = CGAffineTransformMakeScale(scale, scale)
            self.transform = transform
            self.iconImage.backgroundColor = focused ? self.focusedColor : self.unfocusedColor
        })
    }
    
}
