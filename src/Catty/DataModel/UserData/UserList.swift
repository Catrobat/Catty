/**
 *  Copyright (C) 2010-2020 The Catrobat Team
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

@objcMembers class UserList: NSObject, UserListProtocol {

    var name: String
    var value: SynchronizedArray<Any>

    init(name: String) {
        self.name = name
        self.value = SynchronizedArray()
    }

    init(list: UserList) {
        self.name = list.name
        self.value = SynchronizedArray()
    }

    override var description: String {
        "UserList: Name: \(String(describing: self.name)), Value: \(String(describing: self.value))"
    }

    override func isEqual(_ object: Any?) -> Bool {
        guard let userList = object as? UserList else {
            return false
        }
        if (name == userList.name) && self.value.isEqual(userList.value) {
            return true
        }
        return false
    }

    func mutableCopy(with context: CBMutableCopyContext) -> Any {
        let updatedReference = context.updatedReference(forReference: self)

        if updatedReference != nil {
            return updatedReference as Any
        }

        return self
    }

    func add(element: Any) {
        self.value.append(element)
    }

    func insert(element: Any, at index: Int) {
        if index == 1 && self.value.isEmpty {
            self.add(element: element)
        } else if index > 0 && index <= (self.value.count + 1) {
            self.value.insert(element, at: index - 1)
        }
    }

    func delete(at index: Int) {
        if index > 0 && index <= self.value.count {
            self.value.remove(at: index - 1)
        }
    }

    func replace(at index: Int, with element: Any) {
        if index > 0 && index <= self.value.count {
            let actualIndex = index - 1
            if value[actualIndex] != nil {
                value[actualIndex] = element
            }
        }
    }

}
