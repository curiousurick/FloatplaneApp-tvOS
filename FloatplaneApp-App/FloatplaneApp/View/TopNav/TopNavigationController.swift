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
import FloatplaneApp_DataStores

class TopNavigationController: UINavigationController {
    // 30 minutes
    private let CreatorRefreshInternal: TimeInterval = 30 * 60
    private let getFirstPageOperation = OperationManager.instance.getFirstPageOperation
    private let creatorOperation = OperationManager.instance.creatorOperation
    private let creatorListOperation = OperationManager.instance.creatorListOperation
    private let logger = Log4S()

    private var fpTabBarController: FPTabBarController? {
        return self.viewControllers[0] as? FPTabBarController
    }
    
    // Main data for viewing
    var baseCreators: [BaseCreator]?
    var activeCreator: Creator?
    var firstPage: [FeedItem]?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func clearAndGoToLoginView() {
        self.activeCreator = nil
        self.baseCreators = nil
        self.firstPage = nil
        self.fpTabBarController?.resetView()
        AppDelegate.instance.rootViewController.goToLogin()
    }
    
    func updateChildViewData(baseCreators: [BaseCreator], activeCreator: Creator, firstPage: [FeedItem]) {
        self.firstPage = firstPage
        self.activeCreator = activeCreator
        self.baseCreators = baseCreators
        self.fpTabBarController?.baseCreators = baseCreators
        self.fpTabBarController?.firstPage = firstPage
        self.fpTabBarController?.activeCreator = activeCreator
        self.fpTabBarController?.resetView()
    }
    
    func changeSelectedCreator(baseCreator: BaseCreator) {
        guard let baseCreators = baseCreators,
              baseCreators.contains(where: { $0 == baseCreator }) else {
            logger.error("Switching to creator which is not known")
            return
        }
        if let activeCreator = activeCreator,
           let firstPage = firstPage,
           baseCreator.id == activeCreator.id {
            logger.debug("Asked to change to already active creator.")
            self.updateChildViewData(baseCreators: baseCreators, activeCreator: activeCreator, firstPage: firstPage)
            return
        }
        let urlName = baseCreator.urlname
        let creatorId = baseCreator.id
        Task {
            async let activeCreatorAsync = getActiveCreator(urlName: urlName)
            async let getFirstPageAsync = getFirstPage(creatorId: creatorId)
            guard let activeCreator = await activeCreatorAsync.0,
                  let firstPage = await getFirstPageAsync.0 else {
                // TODO: Give error page
                return
            }
            self.updateChildViewData(baseCreators: baseCreators, activeCreator: activeCreator, firstPage: firstPage)
        }
    }
    
    private func getActiveCreator(urlName: String) async -> (Creator?, Error?) {
        let request = CreatorRequest(named: urlName)
        return await withCheckedContinuation { continutation in
            OperationManager.instance.creatorOperation.get(request: request) { response, error in
                continutation.resume(returning: (response, error))
            }
        }
    }
    
    private func getFirstPage(creatorId: String) async -> ([FeedItem]?, Error?) {
        logger.debug("Fetching next page of content for feed")
        let request = ContentFeedRequest.firstPage(for: creatorId)
        return await withCheckedContinuation { continuation in
            OperationManager.instance.contentFeedOperation.get(request: request) { fetchedFeed, error in
                continuation.resume(returning: (fetchedFeed?.items, error))
            }
        }
    }
}
