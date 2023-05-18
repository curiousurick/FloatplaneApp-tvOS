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
import Kenmore_Models
import Kenmore_Utilities
import Kenmore_DataStores
import Kenmore_Operations

class LaunchScreenViewController: UIViewController {
    private let logger = Log4S()

    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var floatPlaneLabel: UILabel!

    private let getFirstPageOperation = OperationManagerImpl.instance.getFirstPageOperation

    override func viewDidLoad() {
        super.viewDidLoad()
        setupAndDisplayFirstView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

    private func setupAndDisplayFirstView() {
        Task {
            if UserStoreImpl.instance.getUser() == nil {
                AppDelegate.instance.rootViewController.goToLogin()
            }
            else {
                AppDelegate.instance.rootViewController.getFirstPageAndLoadMainView()
            }
        }
    }
}
