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
import Foundation
import Kenmore_Models
import Kenmore_Utilities
import Kenmore_Operations

class FPTabBarController: UITabBarController, UITabBarControllerDelegate {
    private let logger = Log4S()
    private let updateLiveTabQueue = OperationQueue()
    private let creatorOperation = OperationManagerImpl.instance.creatorOperation
    private let creatorDataSourceManager = DataSource.instance

    private var livePlayerViewController: LivePlayerViewController!
    private var liveStreamOfflineViewController: LiveStreamOfflineViewController!
    private var browseViewController: BrowseViewController!
    private var searchViewController: SearchContainerViewController!
    private var settingsViewConroller: SettingsViewController!

    var lastFocusedIndex: Int?
    var viewToFocus: UIFocusEnvironment? = nil {
        didSet {
            if viewToFocus != nil {
                self.setNeedsFocusUpdate()
                self.updateFocusIfNeeded()
            }
        }
    }

    override var preferredFocusEnvironments: [UIFocusEnvironment] {
        if let viewToFocus = viewToFocus {
            self.viewToFocus = nil
            return [viewToFocus]
        }
        else {
            return super.preferredFocusEnvironments
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self

        let storyboard = UIStoryboard.main

        // Setup Live Tab
        livePlayerViewController = storyboard.getLivePlayerViewController()
        liveStreamOfflineViewController = storyboard.getLiveStreamOfflineViewController()
        let liveTab = UITabBarItem(title: TabConstants.liveName, image: nil, tag: TabConstants.liveId)
        liveStreamOfflineViewController.tabBarItem = liveTab
        livePlayerViewController.tabBarItem = liveTab

        // Setup Browse ViewController
        browseViewController = storyboard.getBrowseViewController()
        let browseTab = UITabBarItem(title: TabConstants.browseName, image: nil, tag: TabConstants.browseId)
        browseViewController.tabBarItem = browseTab

        // Setup Search ViewController
        searchViewController = storyboard.getSearchContainerViewController()

        let searchTab = UITabBarItem(title: TabConstants.searchName, image: nil, tag: TabConstants.searchId)
        searchViewController.tabBarItem = searchTab

        // Setup Settings ViewController
        settingsViewConroller = storyboard.getSettingsViewController()

        let settingsTab = UITabBarItem(title: TabConstants.settingsName, image: nil, tag: TabConstants.settingsId)
        settingsViewConroller.tabBarItem = settingsTab

        viewControllers = [
            livePlayerViewController,
            browseViewController,
            searchViewController,
            settingsViewConroller,
        ]
        resetView()
    }

    func resetView() {
        guard isViewLoaded else {
            logger.info("Data was collected before view had a chance to load.")
            return
        }
        selectedViewController = viewControllers?[1]
        DispatchQueue.main.async {
            self.viewToFocus = self.tabBar
        }
    }

    func updateLiveTab(online: Bool, deliverKey: DeliveryKey? = nil) {
        DispatchQueue.main.async {
            guard let viewControllers = self.viewControllers else {
                return
            }
            var selectedViewController: UIViewController!
            if online {
                self.livePlayerViewController.deliveryKey = deliverKey
                selectedViewController = self.livePlayerViewController
            }
            else {
                selectedViewController = self.liveStreamOfflineViewController
            }
            var allVCs = viewControllers
            allVCs[0] = selectedViewController
            self.setViewControllers(allVCs, animated: false)
            self.selectedIndex = 1
            self.selectedIndex = 0
            self.toggleHidden(selectedViewController: selectedViewController)
        }
    }

    func toggleHidden(selectedViewController: UIViewController) {
        if selectedViewController == livePlayerViewController {
            tabBar.isHidden = true
        }
        else {
            tabBar.isHidden = false
        }
    }

    func tabBarController(_: UITabBarController, didSelect viewController: UIViewController) {
        // If switching to search view, focus its search bar
        if viewController == viewControllers?[TabConstants.searchIndex],
           lastFocusedIndex != TabConstants.searchIndex {
            viewToFocus = searchViewController.view
        }

        lastFocusedIndex = viewControllers?.firstIndex(of: viewController)
    }

    func updateCreatorInfo() {
        guard let activeCreator = creatorDataSourceManager.activeCreator else {
            return
        }
        Task {
            let request = CreatorRequest(named: activeCreator.urlname)
            let opResponse = await creatorOperation.get(request: request, invalidateCache: true)
            if let response = opResponse.response {
                self.creatorDataSourceManager.activeCreator = response
            }
        }
    }
}
