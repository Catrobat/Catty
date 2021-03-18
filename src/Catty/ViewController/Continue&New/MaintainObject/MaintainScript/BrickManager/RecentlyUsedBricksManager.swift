/**
 *  Copyright (C) 2010-2021 The Catrobat Team
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

@objc
class RecentlyUsedBricksManager: NSObject {

    @objc
    class func getRecentlyUsedBricks() -> [String] {
        let userDefaults = UserDefaults.standard
        if let recentlyUsed = userDefaults.array(forKey: "recentlyUsedBricks") as? [String] {
            return recentlyUsed
        } else {
            let recentlyUsed = [String]()
            setRecentlyUsedBricks(to: recentlyUsed)
            return recentlyUsed
            }
        }

    @objc
    class func updateRecentlyUsedBricks(for brickOrScript: String) {
        var recentlyUsed = getRecentlyUsedBricks()
        recentlyUsed.removeAll(where: { $0 == brickOrScript })
        if recentlyUsed.count >= kMaxRecentlyUsedSize {
            recentlyUsed.removeLast()
        }
        recentlyUsed.prepend(brickOrScript)
        setRecentlyUsedBricks(to: recentlyUsed)
    }

    class func setRecentlyUsedBricks(to recentlyUsed: [String]) {
        UserDefaults.standard.set(recentlyUsed, forKey: "recentlyUsedBricks")
    }

    class func resetRecentlyUsedBricks() {
        setRecentlyUsedBricks(to: [String]())
    }
}
