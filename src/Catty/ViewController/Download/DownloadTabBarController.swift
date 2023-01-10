/**
 *  Copyright (C) 2010-2022 The Catrobat Team
 *  (http://developer.catrobat.org/credits)
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU Affero General Public License as
 *  published by the Free Software Foundation, either version 3 of the
 *  License, or (at your option) any later version.
 *
 *  An additional term exception under section 7 of the GNU Affero
 *  General Public License, version 3, is available at
 *  (http://developer.catrobat.org/license_additional_term)
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 *  GNU Affero General Public License for more details.
 *
 *  You should have received a copy of the GNU Affero General Public License
 *  along with this program.  If not, see http://www.gnu.org/licenses/.
 */

import Foundation
import UIKit

class DownloadTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = kLocalizedCatrobatCommunity
        if #available(iOS 15.0, *) {
            let tabBarAppearance = UITabBarAppearance()
            tabBarAppearance.backgroundColor = UIColor.tabBar

            tabBarAppearance.stackedLayoutAppearance.normal.iconColor = UIColor.tabTint
            tabBarAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [
                NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10.0),
                NSAttributedString.Key.foregroundColor: UIColor.tabTint
            ]
        tabBarAppearance.stackedLayoutAppearance.selected.iconColor = UIColor.whiteGray
        tabBarAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10.0),
            NSAttributedString.Key.foregroundColor: UIColor.whiteGray
        ]
        tabBar.standardAppearance = tabBarAppearance
        tabBar.scrollEdgeAppearance = tabBarAppearance
        }
        tabBar.barTintColor = UIColor.tabBar
        tabBar.barStyle = .default
        tabBar.tintColor = UIColor.whiteGray
        tabBar.unselectedItemTintColor = UIColor.tabTint
        view.backgroundColor = UIColor.background

        UITabBarItem.appearance().setTitleTextAttributes(
            [
                .font: UIFont.boldSystemFont(ofSize: 10.0),
                .foregroundColor: UIColor.whiteGray
            ],
            for: .selected)
        UITabBarItem.appearance().setTitleTextAttributes(
            [
                .font: UIFont.boldSystemFont(ofSize: 10.0),
                .foregroundColor: UIColor.tabTint
            ],
            for: .normal)
    }
}
