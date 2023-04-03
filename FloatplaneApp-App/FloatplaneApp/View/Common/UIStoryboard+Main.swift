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

fileprivate let LivePlayerViewStoryboardID = "LivePlayerViewController"
fileprivate let LiveStreamOfflineViewStoryboardID = "LiveStreamOfflineViewController"
fileprivate let BrowseViewControllerStoryboardID = "BrowseViewController"
fileprivate let SearchViewControllerStoryboardID = "SearchViewController"
fileprivate let SettingsViewControllerStoryboardID = "SettingsViewController"
fileprivate let VodPlayerViewControllerStoryboardID = "VODPlayerViewController"
fileprivate let TopNavigationControllerStoryboardID = "TopNavigationController"
fileprivate let RootViewControllerStoryboardID = "RootViewController"

extension UIStoryboard {
    private static let mainID = "Main"
    
    static var main: UIStoryboard = .init(name: UIStoryboard.mainID, bundle: nil)
    
    func getRootViewController() -> RootViewController {
        return self.instantiateViewController(withIdentifier: RootViewControllerStoryboardID) as! RootViewController
    }
    
    func getTopNavigationController() -> TopNavigationController {
        return self.instantiateViewController(withIdentifier: TopNavigationControllerStoryboardID) as! TopNavigationController
    }
    
    func getBrowseViewController() -> BrowseViewController {
        return self.instantiateViewController(withIdentifier: BrowseViewControllerStoryboardID) as! BrowseViewController
    }
    
    /// Private because cosumers should grab the UISearchContainerViewController
    private func getSearchViewController() -> SearchViewController {
        return self.instantiateViewController(withIdentifier: SearchViewControllerStoryboardID) as! SearchViewController
    }
    
    func getSearchContainerViewController() -> SearchContainerViewController {
        let searchViewController = getSearchViewController()
        let searchController = UISearchController(searchResultsController: searchViewController)
        let searchContainerController = SearchContainerViewController(searchController: searchController)
        searchController.searchResultsUpdater = searchViewController
        return searchContainerController
    }
    
    func getSettingsViewController() -> SettingsViewController {
        return self.instantiateViewController(withIdentifier: SettingsViewControllerStoryboardID) as! SettingsViewController
    }
    
    func getLivePlayerViewController() -> LivePlayerViewController {
        return self.instantiateViewController(withIdentifier: LivePlayerViewStoryboardID) as! LivePlayerViewController
    }
    
    func getLiveStreamOfflineViewController() -> LiveStreamOfflineViewController {
        return self.instantiateViewController(withIdentifier: LiveStreamOfflineViewStoryboardID) as! LiveStreamOfflineViewController
    }
    
    func getVodPlayerViewController() -> VODPlayerViewController {
        return self.instantiateViewController(withIdentifier: VodPlayerViewControllerStoryboardID) as! VODPlayerViewController
    }
    
}
