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

@objc(UserVariable)
@objcMembers class UserVariable: NSObject, CBMutableCopying {

    var name: String
    var value: Any?
    var textLabel: SKLabelNode?
    var isList: Bool

    override private init() {
        self.name = String()
        self.isList = false
    }

    init(name: String) {
        self.name = name
        self.isList = false
    }

    init(variable: UserVariable) {
        self.name = variable.name
        self.isList = variable.isList
    }

    init(name: String, isList: Bool) {
        self.name = name
        self.isList = isList
    }

    override var description: String {
        "UserVariable: Name: \(String(describing: self.name)), Value: \(String(describing: self.value))"
    }

    override func isEqual(_ object: Any?) -> Bool {
        guard let userVariable = object as? UserVariable else {
            return false
        }
        if (name == userVariable.name) && Util.isEqual(value, to: userVariable.value) && (isList == userVariable.isList) {
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

}
