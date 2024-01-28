/**
 *  Copyright (C) 2010-2024 The Catrobat Team
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
    var elements: SynchronizedArray<Any>

    init(name: String) {
        self.name = name
        self.elements = SynchronizedArray()
    }

    init(list: UserList) {
        self.name = list.name
        self.elements = SynchronizedArray()
    }

    var count: Int {
        self.elements.count
    }

    var isEmpty: Bool {
        self.elements.isEmpty
    }

    override var description: String {
        "UserList: Name: \(String(describing: self.name)), Value: \(String(describing: self.elements))"
    }

    override func isEqual(_ object: Any?) -> Bool {
        guard let userList = object as? UserList else {
            return false
        }
        if (name == userList.name) && self.elements.isEqual(userList.elements) {
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
        self.elements.append(element)
    }

    func insert(element: Any, at index: Int) {
        if index == 1 && self.elements.isEmpty {
            self.add(element: element)
        } else if index > 0 && index <= (self.elements.count + 1) {
            self.elements.insert(element, at: index - 1)
        }
    }

    func delete(at index: Int) {
        if index > 0 && index <= self.elements.count {
            self.elements.remove(at: index - 1)
        }
    }

    func replace(at index: Int, with element: Any) {
        if index > 0 && index <= self.elements.count {
            let actualIndex = index - 1
            if elements[actualIndex] != nil {
                elements[actualIndex] = element
            }
        }
    }

    func element(at index: Int) -> Any? {
        if index > 0 && index <= self.elements.count {
            return elements[index - 1]
        }
        return nil
    }

    func contains(where predicate: (Any) throws -> Bool) rethrows -> Bool {
        var result = false
        do {
            result = try self.elements.contains(where: predicate)
        } catch {
            throw error
        }
        return result
    }

    func firstIndex(where predicate: (Any) -> Bool) -> Int? {
        self.elements.firstIndex(where: predicate)
    }

    func stringRepresentation() -> String {
        var value = ""
        if !self.isEmpty {
            var allElementsAreSingleLength = true
            var elements = [String]()

            for index in 1...self.count {
                var newValue = ""

                if let listElement = self.element(at: index) {
                    if let stringElement = listElement as? String {
                        newValue = stringElement
                    } else if let intElement = listElement as? Int {
                        newValue = String(intElement)
                    } else if let doubleElement = listElement as? Double {
                        newValue = String(doubleElement)
                    }
                }

                elements.append(newValue)
                if newValue.count > 1 {
                    allElementsAreSingleLength = false
                }
            }
            if allElementsAreSingleLength {
                value = elements.joined()
            } else {
                value = elements.joined(separator: " ")
            }
        }
        return value
    }
}
