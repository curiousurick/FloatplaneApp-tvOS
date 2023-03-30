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
    
    private var livePlayerViewController: LivePlayerViewController!
    private var liveStreamOfflineViewController: LiveStreamOfflineViewController!
    
    private var creator: NamedCreator!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        var viewControllers: [UIViewController] = []
        
        // Setup Live Tab
        livePlayerViewController = storyboard
            .instantiateViewController(withIdentifier: LivePlayerViewStoryboardID) as? LivePlayerViewController
        liveStreamOfflineViewController = storyboard
            .instantiateViewController(withIdentifier: LiveStreamOfflineViewStoryboardID) as? LiveStreamOfflineViewController
        viewControllers.append(liveStreamOfflineViewController)
        let liveTab = UITabBarItem(title: "Live", image: nil, tag: 0)
        liveStreamOfflineViewController.tabBarItem = liveTab
        livePlayerViewController.tabBarItem = liveTab
        
        // Setup Browse ViewController
        let browseController = storyboard.instantiateViewController(withIdentifier: BrowseViewControllerStoryboardID) as! BrowseViewController
        viewControllers.append(browseController)
        let browseTab = UITabBarItem(title: "Browse", image: nil, tag: 1)
        browseController.tabBarItem = browseTab
        
        // Setup Search ViewController
        let searchController = SearchViewController.createEmbeddedInNavigationController()
        viewControllers.append(searchController)
        let searchTab = UITabBarItem(title: "Search", image: nil, tag: 2)
        searchController.tabBarItem = searchTab
        
        // Setup Settings ViewController
        let settingsController = storyboard.instantiateViewController(withIdentifier: SettingsViewControllerStoryboardID) as! SettingsViewController
        viewControllers.append(settingsController)
        let settingsTab = UITabBarItem(title: "Settings", image: nil, tag: 3)
        settingsController.tabBarItem = settingsTab
        
        self.viewControllers = viewControllers
        
        NotificationCenter.default.addObserver(
            forName: FPNotifications.ActiveCreatorUpdated.name,
            object: nil,
            queue: updateLiveTabQueue
        ) { notification in
            self.updateLiveTab(userInfo: notification.userInfo)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        selectedViewController = viewControllers?[1]
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @objc func updateLiveTab(userInfo: [AnyHashable : Any]?) {
        guard let userInfo = userInfo,
              var viewControllers = viewControllers else {
            return
        }
        guard let creator = userInfo[FPNotifications.ActiveCreatorUpdated.creatorKey] as? NamedCreator else {
            logger.warn("ActiveCreatorUpdated notification received without creator")
            return
        }
        self.creator = creator
        DispatchQueue.main.async {
            if let offline = creator.liveStream.offline {
                self.liveStreamOfflineViewController.offline = offline
                viewControllers[0] = self.liveStreamOfflineViewController
            }
            else {
                self.livePlayerViewController.video = creator.liveStream
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
        CreatorOperation().get(request: request, invalidateCache: true) { response, error in
            if let creator = response {
                let userInfo: [String : Any] = [
                    FPNotifications.ActiveCreatorUpdated.creatorKey : creator
                ]
                NotificationCenter.default.post(name: FPNotifications.ActiveCreatorUpdated.name, object: nil, userInfo: userInfo)
            }
        }
    }
    
}
