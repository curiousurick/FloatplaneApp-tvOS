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
import FloatplaneApp_Models
import FloatplaneApp_Utilities
import FloatplaneApp_DataStores
import FloatplaneApp_Operations

class TopNavigationController: UINavigationController {
    private let creatorOperation = OperationManagerImpl.instance.creatorOperation
    private let contentFeedOperation = OperationManagerImpl.instance.contentFeedOperation
    /// Main data for viewing
    private let dataSource = DataSource.instance
    private let logger = Log4S()

    private var fpTabBarController: FPTabBarController? {
        viewControllers[0] as? FPTabBarController
    }

    func clearAndGoToLoginView() {
        dataSource.clearData()
        fpTabBarController?.resetView()
        AppDelegate.instance.rootViewController.goToLogin()
    }

    func updateChildViewData() {
        fpTabBarController?.resetView()
    }

    func changeSelectedCreator(baseCreator: BaseCreator) {
        guard let baseCreators = dataSource.baseCreators,
              baseCreators.contains(where: { $0 == baseCreator }) else {
            logger.error("Switching to creator which is not known")
            return
        }
        if let activeCreator = dataSource.activeCreator,
           baseCreator.id == activeCreator.id {
            logger.debug("Asked to change to already active creator.")
            updateChildViewData()
            return
        }
        let urlName = baseCreator.urlname
        let creatorId = baseCreator.id
        Task {
            let activeCreatorRequest = CreatorRequest(named: urlName)
            async let activeCreatorAsync = creatorOperation.get(request: activeCreatorRequest)
            let firstPageRequest = ContentFeedRequest.firstPage(for: creatorId)
            async let getFirstPageAsync = contentFeedOperation.get(request: firstPageRequest)
            guard let activeCreator = await activeCreatorAsync.response,
                  let firstPage = await getFirstPageAsync.response else {
                // TODO: Give error page
                return
            }
            self.dataSource.activeCreator = activeCreator
            self.dataSource.feed = firstPage.items
            self.updateChildViewData()
        }
    }
}
