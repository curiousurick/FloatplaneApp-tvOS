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
import FloatplaneApp_Models
import FloatplaneApp_Utilities

class RootViewController: UIViewController {
    private let logger = Log4S()
    private let getFirstPageOperation = OperationManager.instance.getFirstPageOperation
    
    var topNavigationController: TopNavigationController?
    
    override func encodeRestorableState(with coder: NSCoder) {
        super.encodeRestorableState(with: coder)
        
        self.children.forEach { child in
            if let restorationIdentifier = child.restorationIdentifier {
                coder.encode(child, forKey: restorationIdentifier)
            }
        }
    }
    
    override func decodeRestorableState(with coder: NSCoder) {
        super.decodeRestorableState(with: coder)
        
        if let mainViewController = topNavigationController {
            self.addChild(mainViewController)
        }
    }
    
    override func viewDidLayoutSubviews() {
        let registerViewController = self.children.first(where: { $0 is LaunchScreenViewController })
        let mainViewController = self.children.first(where: { $0 is TopNavigationController })
        
        switch (registerViewController, mainViewController) {
        case (let registerViewController?, let mainViewController?):
            self.switch(source: registerViewController, destination: mainViewController)
        default:
            break
        }
        
        super.viewDidLayoutSubviews()
    }

    private func `switch`(source: UIViewController, destination: UIViewController) {
        
        source.willMove(toParent: nil)
        
        destination.view.frame = self.view.bounds
        self.view.addSubview(destination.view)
        
        source.view.removeFromSuperview()
        source.removeFromParent()
        
        destination.didMove(toParent: self)
    }

    private func transition(from: UIViewController, to: UIViewController) {
        from.willMove(toParent: nil)
        self.addChild(to)
        
        self.transition(from: from, to: to, duration: self.transitionCoordinator?.transitionDuration ?? 0.4, options: [], animations: {
            
        }) { (finished) in
            from.removeFromParent()
            to.didMove(toParent: self)
        }
    }
    
    func goToLogin() {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: SegueIdentifier.LaunchScreenViewController.showLoginScreen, sender: nil)
        }
    }

    @IBAction func unwindToRootViewController(_ segue: UIStoryboardSegue) {
        self.getFirstPageAndLoadMainView()
    }
    
    func getFirstPageAndLoadMainView() {
        Task {
            let getFirstPageResponse = await getFirstPageOperation.get()
            if let result = getFirstPageResponse.0 {
                // Don't replace navigation controller if you have it.
                let navController = self.topNavigationController ?? UIStoryboard.main.getTopNavigationController()
                self.topNavigationController = navController
                self.switchToMainView(
                    baseCreators: result.baseCreators,
                    activeCreator: result.activeCreator,
                    firstPage: result.firstPage
                )
            }
            else {
                self.logger.error("Error getting first page. Returning to login. Error \(String(describing: getFirstPageResponse.1))")
                return goToLogin()
            }
        }
    }
    
    func switchToMainView(
        baseCreators: [BaseCreator],
        activeCreator: Creator,
        firstPage: [FeedItem]
    ) {
        if let registerViewController = self.children.first(where: { $0 is LaunchScreenViewController }),
           let topNavigationController = topNavigationController {
            topNavigationController.firstPage = firstPage
            topNavigationController.activeCreator = activeCreator
            topNavigationController.baseCreators = baseCreators
            topNavigationController.updateChildViewData(
                baseCreators: baseCreators,
                activeCreator: activeCreator,
                firstPage: firstPage
            )
            self.transition(from: registerViewController, to: topNavigationController)
        }
    }
    
}
