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

class ObjectCache {
    static let shared = ObjectCache()

    private var cache: [String: ObjectLook] = [:]

    private init() {}

    func getLook(for objectId: String) -> ObjectLook? {
        if let cachedLook = cache[objectId] {
                    return cachedLook
                } else {
                    let look = ObjectLook()
                    cache[objectId] = look
                    return look
                }
    }

    func cacheLook(_ look: ObjectLook, for objectId: String) {
        cache[objectId] = look
    }
}

struct ObjectLook {
    var rotation: Double = 90.0
    var lastLook: UIImage?
    var size: Double = 1.0
}
