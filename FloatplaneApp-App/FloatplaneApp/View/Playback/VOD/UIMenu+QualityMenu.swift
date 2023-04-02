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
import FloatplaneApp_Models

extension UIMenu {
    
    convenience init(children: [UIMenuElement]) {
        self.init(title: "", children: children)
    }
    
    static func getQualityMenu(
        selectedQualityLevel: QualityLevel,
        videoMetadata: VideoMetadata,
        optionSelected: @escaping ((QualityLevel) -> Void)
    ) -> UIMenu {
        let optionActions = videoMetadata.levels.enumerated().map { (index, level) in
            let isSelected = selectedQualityLevel == level
            let state: UIAction.State = isSelected ? .on : .off
            return UIAction(
                title: level.label,
                state: state,
                handler: { action in
                    optionSelected(level)
                }
            )
        }
        let image = selectedQualityLevel.label.image()!
        return UIMenu(
            title: "Video Quality",
            image: image,
            options: [.singleSelection],
            children: optionActions
        )
    }
    
}
