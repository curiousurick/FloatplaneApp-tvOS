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
import Alamofire
import FloatplaneApp_Models

public class LoginOperation {
    
    var baseUrl: URL = URL(string: "\(OperationConstants.domainBaseUrl)/api/v2/auth/login")!
    // Used to simulate iOS so we don't need captcha
    private let userAgent = "floatplane/59 CFNetwork/1404.0.5 Darwin/22.3.0"
    private let headers: HTTPHeaders
    
    init() {
        let headerMap = [
            "user-agent" : userAgent
        ]
        headers = HTTPHeaders(headerMap)
    }
    
    public func get(request: LoginRequest, completion: ((LoginResponse?, LoginFailedResponse?) -> Void)? = nil) {
        AF.request(baseUrl, method: .post, parameters: request, headers: headers).response { response in
            // Login successful
            if let data = response.data,
                let loginResponse = try? JSONDecoder().decode(LoginResponse.self, from: data) {
                completion?(loginResponse, nil)
            }
            // Failure response from server.
            else if let data = response.data,
                    let loginFailedResponse = try? JSONDecoder().decode(LoginFailedResponse.self, from: data) {
                completion?(nil, loginFailedResponse)
            }
            // Generic HTTP Failure
            else if let httpError = response.error {
                let failedResponse = LoginFailedResponse(errors: [], message: httpError.localizedDescription)
                completion?(nil, failedResponse)
            }
        }
    }
}
