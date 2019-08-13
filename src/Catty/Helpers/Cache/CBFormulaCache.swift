/**
 *  Copyright (C) 2010-2019 The Catrobat Team
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

@objc class CBFormulaCache: NSObject {

    private var cachedResults = [FormulaElement: AnyObject]()
    private let cacheQueue = DispatchQueue(label: "cache")

    @objc func cacheObject(object: AnyObject, forKey key: FormulaElement) {
        cacheQueue.sync {
            cachedResults[key] = object
        }
    }

    @objc func retrieveObject(forKey key: FormulaElement) -> AnyObject? {
        var result: AnyObject?

        _ = cacheQueue.sync {
            result = cachedResults[key]
        }

        return result
    }

    @objc func removeObject(fromCache element: FormulaElement) {
        _ = cacheQueue.sync {
            cachedResults.removeValue(forKey: element)
        }
    }

    @objc func clearCache() {
        cacheQueue.sync {
            cachedResults.removeAll()
        }
    }

    @objc func count() -> Int {
        var result = Int()

        cacheQueue.sync {
            result = cachedResults.count
        }

        return result
    }
}
