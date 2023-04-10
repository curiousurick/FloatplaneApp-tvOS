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
import XCTest
@testable import FloatplaneApp_Utilities

final class StringHTMLTest: XCTestCase {
    
    let htmlDescription = "<p>Linus has made some big mistakes. Buying a potato farm and making the best farming content on YouTube will definitely not be like those other things that didn\'t pan out though</p><p><br /></p><p>Get your Uncle Linus hoodie, Uncle Linus Potato Moonshine bottle and Potato \"NFTs\" at www.lttstore.com it\'s a website</p>"
    let strippedDescription = "Linus has made some big mistakes. Buying a potato farm and making the best farming content on YouTube will definitely not be like those other things that didn\'t pan out though\n \nGet your Uncle Linus hoodie, Uncle Linus Potato Moonshine bottle and Potato \"NFTs\" at www.lttstore.com it\'s a website\n"
    
    func testHtmlString() {
        // Act
        let result = htmlDescription.html2String
        
        // Assert
        XCTAssertEqual(result, strippedDescription)
    }
    
    func testAttributedString() {
        // Act
        let result = htmlDescription.html2AttributedString
        
        // Assert
        XCTAssertEqual(result.string, strippedDescription)
    }
    
    func testDataAttributedString_invalidOptions() {
        // Arrange
        let data = Data(htmlDescription.utf8)
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .characterEncoding: "bloop",
            NSAttributedString.DocumentReadingOptionKey.documentType : Data()
        ]
        
        // Act
        let result = data.getAttributedString(options: options)
        
        // Assert
        XCTAssertEqual(result.string, "")
    }
}
