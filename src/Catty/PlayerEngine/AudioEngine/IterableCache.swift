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

public class IterableCache<ObjectType: AnyObject>: NSObject, NSCacheDelegate {

    var cache = NSCache<NSString, ObjectType>()
    var keySet = Set<String>()
    let cacheQueue = DispatchQueue(label: "cacheQueue")

    override init() {
        super.init()
        cache.delegate = self
    }

    func setObject(_ obj: ObjectType, forKey: String) {
        _ = cacheQueue.sync {
            cache.setObject(obj, forKey: forKey as NSString)
            keySet.insert(forKey)
        }
    }

    func object(forKey: String) -> ObjectType? {
        var object: ObjectType?
        _ = cacheQueue.sync {
            object = cache.object(forKey: forKey as NSString)
        }
        return object
    }

    func getKeySet() -> Set<String> {
        return self.keySet
    }

    private func removeFromKeySet(key: String) {
        keySet.remove(key)
    }

    func removeAllObjects() {
        cache.removeAllObjects()
        keySet.removeAll()
    }

    public func cache(_ cache: NSCache<AnyObject, AnyObject>, willEvictObject obj: Any) {
        if let player = obj as? AudioPlayer {
            removeFromKeySet(key: player.getFileName())
            player.remove()
        }
    }
}
