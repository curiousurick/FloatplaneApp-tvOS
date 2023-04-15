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

private let LivePlayerViewStoryboardID = "LivePlayerViewController"
private let LiveStreamOfflineViewStoryboardID = "LiveStreamOfflineViewController"
private let BrowseViewControllerStoryboardID = "BrowseViewController"
private let SearchViewControllerStoryboardID = "SearchViewController"
private let SettingsViewControllerStoryboardID = "SettingsViewController"
private let VodPlayerViewControllerStoryboardID = "VODPlayerViewController"
private let TopNavigationControllerStoryboardID = "TopNavigationController"
private let RootViewControllerStoryboardID = "RootViewController"

extension UIStoryboard {
    private static let mainID = "Main"

    static var main: UIStoryboard = .init(name: UIStoryboard.mainID, bundle: nil)

    func getRootViewController() -> RootViewController {
        instantiateViewController(withIdentifier: RootViewControllerStoryboardID) as! RootViewController
    }

    func getTopNavigationController() -> TopNavigationController {
        instantiateViewController(withIdentifier: TopNavigationControllerStoryboardID) as! TopNavigationController
    }

    func getBrowseViewController() -> BrowseViewController {
        instantiateViewController(withIdentifier: BrowseViewControllerStoryboardID) as! BrowseViewController
    }

    /// Private because cosumers should grab the UISearchContainerViewController
    private func getSearchViewController() -> SearchViewController {
        instantiateViewController(withIdentifier: SearchViewControllerStoryboardID) as! SearchViewController
    }

    func getSearchContainerViewController() -> SearchContainerViewController {
        let searchViewController = getSearchViewController()
        let searchController = UISearchController(searchResultsController: searchViewController)
        let searchContainerController = SearchContainerViewController(searchController: searchController)
        searchController.searchResultsUpdater = searchViewController
        return searchContainerController
    }

    func getSettingsViewController() -> SettingsViewController {
        instantiateViewController(withIdentifier: SettingsViewControllerStoryboardID) as! SettingsViewController
    }

    func getLivePlayerViewController() -> LivePlayerViewController {
        instantiateViewController(withIdentifier: LivePlayerViewStoryboardID) as! LivePlayerViewController
    }

    func getLiveStreamOfflineViewController() -> LiveStreamOfflineViewController {
        instantiateViewController(withIdentifier: LiveStreamOfflineViewStoryboardID) as! LiveStreamOfflineViewController
    }

    func getVodPlayerViewController() -> VODPlayerViewController {
        instantiateViewController(withIdentifier: VodPlayerViewControllerStoryboardID) as! VODPlayerViewController
    }
}
