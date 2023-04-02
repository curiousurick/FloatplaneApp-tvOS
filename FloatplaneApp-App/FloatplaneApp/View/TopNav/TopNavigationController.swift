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
import FloatplaneApp_Operations
import FloatplaneApp_Utilities
import FloatplaneApp_Models

class TopNavigationController: UINavigationController {
    // 30 minutes
    private let CreatorRefreshInternal: TimeInterval = 30 * 60
    private let creatorOperation = OperationManager.instance.creatorOperation
    private let creatorListOperation = OperationManager.instance.creatorListOperation
    private let unwindFromLoginSegue = "UnwindFromLogin"
    private let loginViewControllerSegue = "LoginViewController"
    private let logger = Log4S()
    
    private var timer: Timer?
    
    private var fpTabBarController: FPTabBarController? {
        return self.viewControllers[0] as? FPTabBarController
    }
    
    var activeBaseCreator: BaseCreator? {
        didSet {
            self.getActiveCreator()
        }
    }
    private var activeCreator: Creator? {
        didSet {
            if let activeCreator = activeCreator {
                scheduleCreatorUpdate()
                DispatchQueue.main.async {
                    self.fpTabBarController?.creator = activeCreator
                }
            }
            else {
                timer?.invalidate()
                timer = nil
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        AppDelegate.instance.topNavigationController = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func tabBarReady() {
        if UserStore.instance.getUser() != nil {
            getCreators()
        }
        else {
            goToLoginView()
        }
    }
    
    func goToLoginView() {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: self.loginViewControllerSegue, sender: self)
        }
    }
    
    func clearAndGoToLoginView() {
        self.activeBaseCreator = nil
        self.activeCreator = nil
        self.fpTabBarController?.resetView()
        goToLoginView()
    }
    
    @IBAction func unwindToTopNavController(segue: UIStoryboardSegue) {
        if segue.identifier == unwindFromLoginSegue {
            logger.info("Successfully logged in")
            getCreators()
        }
    }
    
    private func getCreators() {
        creatorListOperation.get(request: CreatorListRequest()) { response, error in
            if let response = response, response.creators.count > 0 {
                BaseCreatorStore.instance.setCreators(creators: response.creators)
                self.activeBaseCreator = response.creators[0]
            }
        }
    }
    
    private func scheduleCreatorUpdate() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: CreatorRefreshInternal, repeats: true) { timer in
            self.getActiveCreator()
        }
    }
    
    private func getActiveCreator() {
        guard let urlName = activeBaseCreator?.urlname else {
            logger.error("getActiveCreator called when there is no active creator.")
            return
        }
        let request = CreatorRequest(named: urlName)
        creatorOperation.get(request: request) { response, error in
            if let creator = response {
                self.activeCreator = creator
            }
        }
    }
}
