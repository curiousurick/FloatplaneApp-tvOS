//
//  CookieManager.swift
//  FloatplaneApp
//
//  Created by George Urick on 3/25/23.
//

import Foundation
import Alamofire

class CookieManager {
    
    func setup() {
        let cfuvidCookieProps = [
            HTTPCookiePropertyKey.domain: OperationConstants.domain,
            HTTPCookiePropertyKey.path: OperationConstants.basePath,
            HTTPCookiePropertyKey.name: UserConfiguration.cfuvidCookieKey,
            HTTPCookiePropertyKey.value: UserConfiguration.cfuvidCookie
        ]
        let sailsSidCookieProps = [
            HTTPCookiePropertyKey.domain: OperationConstants.domain,
            HTTPCookiePropertyKey.path: OperationConstants.basePath,
            HTTPCookiePropertyKey.name: UserConfiguration.sailsSidCookieKey,
            HTTPCookiePropertyKey.value: UserConfiguration.sailsSidCookie
        ]
        
        if let cfuvidCookie = HTTPCookie(properties: cfuvidCookieProps),
        let sailsCookie = HTTPCookie(properties: sailsSidCookieProps) {
            AF.session.configuration.httpCookieStorage?.setCookie(cfuvidCookie)
            AF.session.configuration.httpCookieStorage?.setCookie(sailsCookie)
        }
    }
    
}
