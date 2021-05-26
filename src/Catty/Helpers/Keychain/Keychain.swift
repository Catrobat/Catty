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

@objc class Keychain: NSObject {

    private static func getQuery(forKey key: String) -> [CFString: Any] {
        [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: key,
            kSecAttrAccount: key,
            kSecAttrAccessible: kSecAttrAccessibleAfterFirstUnlock
        ]
    }

    @objc @discardableResult static func saveValue(_ value: Any, forKey key: String) -> Bool {
        Keychain.deleteValue(forKey: key)

        var query = Keychain.getQuery(forKey: key)
        guard let archivedData = try? NSKeyedArchiver.archivedData(withRootObject: value, requiringSecureCoding: true) else {
            return false
        }
        query[kSecValueData] = archivedData

        return SecItemAdd(query as NSDictionary, nil) == errSecSuccess
    }

    @objc @discardableResult static func deleteValue(forKey key: String) -> Bool {
        let query = Keychain.getQuery(forKey: key)
        return SecItemDelete(query as NSDictionary) == errSecSuccess
    }

    @objc static func loadValue(forKey key: String) -> Any? {
        let query = Keychain.getQuery(forKey: key)

        var value: AnyObject?
        if SecItemCopyMatching(query as NSDictionary, &value) == errSecSuccess {
            if let value = value as? Data {
                return try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(value)
            }
        }

        return nil
    }

}
