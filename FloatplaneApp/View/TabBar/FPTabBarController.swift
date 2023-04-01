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
import UIKit

class FPTabBarController: UITabBarController {
    private let logger = Log4S()
    private let updateLiveTabQueue = OperationQueue()
    private let creatorOperation = OperationManager.instance.creatorOperation
    
    private struct Tab {
        static let liveName = "Live"
        static let liveId = 0
        static let browseName = "Browse"
        static let browseId = 1
        static let searchName = "Search"
        static let searchId = 2
        static let settingsName = "Settings"
        static let settingsId = 3
    }
    
    private var livePlayerViewController: LivePlayerViewController!
    private var liveStreamOfflineViewController: LiveStreamOfflineViewController!
    private var browseViewController: BrowseViewController!
    private var searchViewController: SearchViewController!
    
    var creator: Creator! {
        didSet {
            livePlayerViewController.creator = creator
            liveStreamOfflineViewController.creator = creator
            browseViewController.creator = creator
            searchViewController.creator = creator
            livePlayerViewController.creator = creator
            liveStreamOfflineViewController.creator = creator
            viewToFocus = tabBar
        }
    }
    
    var viewToFocus: UIFocusEnvironment? = nil {
        didSet {
            if viewToFocus != nil {
                self.setNeedsFocusUpdate();
                self.updateFocusIfNeeded();
            }
        }
    }

    override var preferredFocusEnvironments: [UIFocusEnvironment] {
        if let viewToFocus = viewToFocus {
            self.viewToFocus = nil
            return [viewToFocus]
        } else {
            return super.preferredFocusEnvironments;
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let storyboard = UIStoryboard.main
        
        // Setup Live Tab
        livePlayerViewController = storyboard.getLivePlayerViewController()
        liveStreamOfflineViewController = storyboard.getLiveStreamOfflineViewController()
        let liveTab = UITabBarItem(title: Tab.liveName, image: nil, tag: Tab.liveId)
        liveStreamOfflineViewController.tabBarItem = liveTab
        livePlayerViewController.tabBarItem = liveTab
        
        
        // Setup Browse ViewController
        self.browseViewController = storyboard.getBrowseViewController()
        let browseTab = UITabBarItem(title: Tab.browseName, image: nil, tag: Tab.browseId)
        browseViewController.tabBarItem = browseTab

        // Setup Search ViewController
        let searchNavController = SearchViewController.createEmbeddedInNavigationController()
        let searchContainer = searchNavController.viewControllers[0] as? UISearchContainerViewController
        self.searchViewController = searchContainer?.searchController.searchResultsController as? SearchViewController
        
        let searchTab = UITabBarItem(title: Tab.searchName, image: nil, tag: Tab.searchId)
        searchNavController.tabBarItem = searchTab
        
        // Setup Settings ViewController
        let settingsController = storyboard.getSettingsViewController()
        
        let settingsTab = UITabBarItem(title: Tab.settingsName, image: nil, tag: Tab.settingsId)
        settingsController.tabBarItem = settingsTab

        self.viewControllers = [
            livePlayerViewController,
            browseViewController,
            searchNavController,
            settingsController
        ]
        self.selectedViewController = self.viewControllers?[1]
        
        let navigationController = self.navigationController as! TopNavigationController
        navigationController.tabBarReady()
    }
    
    func resetView() {
        DispatchQueue.main.async {
            self.selectedViewController = self.viewControllers?[1]
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func updateLiveTab(online: Bool, deliverKey: LiveDeliveryKey? = nil) {
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
        }
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if item == tabBar.items?.first {
            updateCreatorInfo()
        }
    }
    
    func updateCreatorInfo() {
        let request = CreatorRequest(named: creator.urlname)
        creatorOperation.get(request: request, invalidateCache: true) { response, error in
            if let response = response {
                self.creator = response
            }
        }
    }
    
}
