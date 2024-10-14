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
import Alamofire
import Kenmore_Models
import Kenmore_Utilities
import Kenmore_Operations
import Kenmore_DataStores

class RootViewController: UIViewController {
    private let logger = Log4S()
    private let getFirstPageOperation = OperationManagerImpl.instance.getFirstPageOperation
    private let dataSource = DataSource.instance

    var topNavigationController: TopNavigationController?

    override func encodeRestorableState(with coder: NSCoder) {
        super.encodeRestorableState(with: coder)

        children.forEach { child in
            if let restorationIdentifier = child.restorationIdentifier {
                coder.encode(child, forKey: restorationIdentifier)
            }
        }
    }

    override func decodeRestorableState(with coder: NSCoder) {
        super.decodeRestorableState(with: coder)

        if let mainViewController = topNavigationController {
            addChild(mainViewController)
        }
    }

    override func viewDidLayoutSubviews() {
        let registerViewController = children.first(where: { $0 is LaunchScreenViewController })
        let mainViewController = children.first(where: { $0 is TopNavigationController })

        switch (registerViewController, mainViewController) {
        case let (registerViewController?, mainViewController?):
            self.switch(source: registerViewController, destination: mainViewController)
        default:
            break
        }

        super.viewDidLayoutSubviews()
    }

    private func `switch`(source: UIViewController, destination: UIViewController) {
        source.willMove(toParent: nil)

        destination.view.frame = view.bounds
        view.addSubview(destination.view)

        source.view.removeFromSuperview()
        source.removeFromParent()

        destination.didMove(toParent: self)
    }

    private func transition(from: UIViewController, to: UIViewController) {
        from.willMove(toParent: nil)
        addChild(to)
        to.view.alpha = 0.0
        from.view.alpha = 1.0
        transition(
            from: from,
            to: to,
            duration: 0.4,
            options: [.allowAnimatedContent, .allowUserInteraction],
            animations: {
                to.view.alpha = 1.0
                from.view.alpha = 0.0
            }
        ) { _ in
            from.removeFromParent()
            to.didMove(toParent: self)
        }
    }

    func goToLogin() {
        let loginScreen = UIStoryboard.main.instantiateViewController(withIdentifier: "LoginViewController")
        DispatchQueue.main.async {
            self.transition(from: self.children.first!, to: loginScreen)
        }
    }

    @IBAction func unwindToRootViewController(_: UIStoryboardSegue) {
        getFirstPageAndLoadMainView()
    }

    class FloatplaneDecoder: JSONDecoder, @unchecked Sendable {
        override init() {
            super.init()
            configureDataDecoding()
        }

        /// Configures date format in the way that floatplane APIs return them.
        private func configureDataDecoding() {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            dateDecodingStrategy = .formatted(dateFormatter)
        }
    }

    func getFirstPageAndLoadMainView() {
        Task {
            let request = GetFirstPageRequest(activeCreatorId: AppSettings.instance.firstCreatorId)
            let getFirstPageResponse = await getFirstPageOperation.get(request: request)
            if let result = getFirstPageResponse.response {
                // Don't replace navigation controller if you have it.
                dataSource.feed = result.firstPage
                dataSource.baseCreators = result.baseCreators
                dataSource.activeCreator = result.activeCreator
                let navController = self.topNavigationController ?? UIStoryboard.main.getTopNavigationController()
                self.topNavigationController = navController
                self.switchToMainView()
            }
            else {
                let errorString = String(describing: getFirstPageResponse.error)
                self.logger.error("Error getting first page. Returning to login. Error \(errorString)")
                return goToLogin()
            }
        }
    }

    func switchToMainView() {
        if let launchViewController = children.first(where: { $0 is LaunchScreenViewController }),
           let topNavigationController = topNavigationController {
            transition(from: launchViewController, to: topNavigationController)
        }
        else if let loginViewController = children.first(where: { $0 is LoginViewController }),
                let topNavigationController = topNavigationController {
            transition(from: loginViewController, to: topNavigationController)
        }
    }
}
