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

import XCTest
import FloatplaneApp_Models
@testable import FloatplaneApp_Utilities

class StreamURLFactoryTest: XCTestCase {
    private var subject: StreamURLFactoryImpl!

    override func setUp() {
        super.setUp()

        subject = StreamURLFactoryImpl()
    }

    func testCreateWithDeliveryKey() {
        // Arrange
        let deliveryKey = TestModelSupplier.deliveryKey
        let cdn = deliveryKey.cdn
        let uri = deliveryKey.resource.uri

        // Act
        let result = subject.create(deliveryKey: deliveryKey)

        // Assert
        let expectedUrl = URL(string: "\(cdn)\(uri)")!
        XCTAssertEqual(result, expectedUrl)
    }

    func testCreateWithDeliveryKeyAndQualityLevel() {
        // Arrange
        let deliveryKey = TestModelSupplier.realDeliveryKey
        let cdn = deliveryKey.cdn
        let uri = deliveryKey.resource.uri
        let qualityLevel = QualityLevel.Standard.ql1080p
        let dkQualityLevel = DeliveryKeyQualityLevel.vodCases.first { $0.readable == qualityLevel.label }
        let resourceData = deliveryKey.resource.data.getResource(qualitylevelName: dkQualityLevel)!
        let fileName = resourceData.fileName
        let accessToken = resourceData.accessToken
        let fileNameKey = QualityLevelParams.Constants.FileNameKey
        let accessTokenKey = QualityLevelParams.Constants.AccessTokenKey
        let path = uri
            .replacing(fileNameKey, with: fileName)
            .replacing(accessTokenKey, with: accessToken)

        // Act
        let result = subject.create(deliveryKey: deliveryKey, qualityLevel: qualityLevel)

        // Assert
        let expectedUrl = URL(string: "\(cdn)\(path)")!
        XCTAssertEqual(result, expectedUrl)
    }

    func testCreateWithDeliveryKeyAndQualityLevel_chosenLevelNotFound() {
        let deliveryKey = TestModelSupplier.realDeliveryKey
        let cdn = deliveryKey.cdn
        let uri = deliveryKey.resource.uri
        let qualityLevel = QualityLevel.Standard.qlLive
        let dkQualityLevel = DeliveryKeyQualityLevel.vodCases.last
        let resourceData = deliveryKey.resource.data.getResource(qualitylevelName: dkQualityLevel)!
        let fileName = resourceData.fileName
        let accessToken = resourceData.accessToken
        let fileNameKey = QualityLevelParams.Constants.FileNameKey
        let accessTokenKey = QualityLevelParams.Constants.AccessTokenKey
        let path = uri
            .replacing(fileNameKey, with: fileName)
            .replacing(accessTokenKey, with: accessToken)

        // Act
        let result = subject.create(deliveryKey: deliveryKey, qualityLevel: qualityLevel)

        // Assert
        let expectedUrl = URL(string: "\(cdn)\(path)")!
        XCTAssertEqual(result, expectedUrl)
    }
}
