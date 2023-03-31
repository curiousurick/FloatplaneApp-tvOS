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
    private let LivePlayerViewStoryboardID = "LivePlayerViewController"
    private let LiveStreamOfflineViewStoryboardID = "LiveStreamOfflineViewController"
    private let BrowseViewControllerStoryboardID = "BrowseViewController"
    private let SettingsViewControllerStoryboardID = "SettingsViewController"
    private let creatorOperation = OperationManager.instance.creatorOperation
    
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
            self.updateLiveTab()
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
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        // Setup Live Tab
        livePlayerViewController = storyboard
            .instantiateViewController(withIdentifier: LivePlayerViewStoryboardID) as? LivePlayerViewController
        liveStreamOfflineViewController = storyboard
            .instantiateViewController(withIdentifier: LiveStreamOfflineViewStoryboardID) as? LiveStreamOfflineViewController
        let liveTab = UITabBarItem(title: "Live", image: nil, tag: 0)
        liveStreamOfflineViewController.tabBarItem = liveTab
        livePlayerViewController.tabBarItem = liveTab
        
        
        // Setup Browse ViewController
        self.browseViewController = storyboard.instantiateViewController(withIdentifier: BrowseViewControllerStoryboardID) as? BrowseViewController
        let browseTab = UITabBarItem(title: "Browse", image: nil, tag: 1)
        browseViewController.tabBarItem = browseTab

        // Setup Search ViewController
        let searchControllers = SearchViewController.createEmbeddedInNavigationController()
        self.searchViewController = searchControllers.1
        let searchViewNavController = searchControllers.0
        
        let searchTab = UITabBarItem(title: "Search", image: nil, tag: 2)
        searchViewNavController.tabBarItem = searchTab
        
        // Setup Settings ViewController
        let settingsController = storyboard.instantiateViewController(withIdentifier: SettingsViewControllerStoryboardID) as! SettingsViewController
        
        let settingsTab = UITabBarItem(title: "Settings", image: nil, tag: 3)
        settingsController.tabBarItem = settingsTab

        self.viewControllers = [
            liveStreamOfflineViewController,
            browseViewController,
            searchViewNavController,
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
    
    private func updateLiveTab() {
        DispatchQueue.main.async {
            guard var viewControllers = self.viewControllers,
                  let creator = self.creator else {
                return
            }
            if creator.liveStream.offline != nil {
                viewControllers[0] = self.liveStreamOfflineViewController
            }
            else {
                viewControllers[0] = self.livePlayerViewController
            }
        }
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if item == tabBar.items?[0] {
            updateCreatorInfo()
        }
    }
    
    func updateCreatorInfo() {
        let request = CreatorRequest(named: "linustechtips")
        creatorOperation.get(request: request, invalidateCache: true) { response, error in
            if let response = response {
                self.creator = response
            }
        }
    }
    
}
