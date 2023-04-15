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

import Alamofire
import Foundation
import FloatplaneApp_Models
import FloatplaneApp_Utilities
import FloatplaneApp_DataStores

/// Attemps a Logout.
protocol LogoutOperationStrategy: InternalOperationStrategy<LogoutRequest, LogoutResponse> {}

class LogoutOperationStrategyImpl: LogoutOperationStrategy {
    private let logger = Log4S()
    private let baseUrl: URL = .init(string: "\(OperationConstants.domainBaseUrl)/api/v2/auth/logout")!

    private let session: Session
    private let headers: HTTPHeaders

    var dataRequest: DataRequest?

    convenience init(session: Session) {
        let headerMap = ["user-agent": OperationConstants.iOSUserAgent]
        self.init(
            session: session,
            headers: HTTPHeaders(headerMap)
        )
    }

    /// Available for testing purposes.
    init(
        session: Session,
        headers: HTTPHeaders
    ) {
        self.headers = headers
        self.session = session
    }

    /// Performs a logout and then clears all caches upon success.
    /// TODO: Investigate if we should clear the cache even if the call fails.
    func get(request _: LogoutRequest) async -> OperationResponse<LogoutResponse> {
        let dataRequest = session.request(baseUrl, method: .post, headers: headers)
        self.dataRequest = dataRequest
        return await withCheckedContinuation { continuation in
            dataRequest.response { response in
                if response.response?.statusCode == 200 {
                    self.logger.info("Successfully logged out")
                    continuation.resume(returning: OperationResponse(response: LogoutResponse(), error: nil))
                }
                else {
                    continuation.resume(returning: OperationResponse(response: nil, error: response.error))
                }
            }
        }
    }
}
