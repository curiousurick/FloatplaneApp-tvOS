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

class TopNavigationController: UINavigationController {
    
    private var timer: Timer?
    
    private var tabBarViewController: FPTabBarController? {
        get {
            return tabBarController as? FPTabBarController
        }
    }
    
    private var activeCreatorUrlName: String? = "linustechtips" {
        didSet {
            timer?.invalidate()
            timer = nil
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scheduleCreatorUpdate()
    }
    
    private func scheduleCreatorUpdate() {
        timer = Timer.scheduledTimer(withTimeInterval: 30 * 60, repeats: true) { timer in
            self.getActiveCreator()
        }
        timer?.fire()
    }
    
    private func getActiveCreator() {
        guard let activeCreatorUrlName = activeCreatorUrlName else {
            return
        }
        let request = CreatorRequest(named: activeCreatorUrlName)
        CreatorOperation().get(request: request) { response, error in
            if let creator = response {
                let userInfo: [String : Any] = [
                    FPNotifications.ActiveCreatorUpdated.creatorKey : creator
                ]
                NotificationCenter.default.post(name: FPNotifications.ActiveCreatorUpdated.name, object: nil, userInfo: userInfo)
            }
        }
    }
}
