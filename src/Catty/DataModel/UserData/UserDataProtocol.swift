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

@objc protocol UserDataProtocol: CBMutableCopying {
    var name: String { get set }
}

protocol UserVariableProtocol: UserDataProtocol {
    var value: Any? { get set }
}

protocol UserListProtocol: UserDataProtocol {
    var count: Int { get }
    var isEmpty: Bool { get }

    func add(element: Any)
    func insert(element: Any, at index: Int)
    func delete(at index: Int)
    func replace(at index: Int, with element: Any)
    func element(at index: Int) -> Any?
    func contains(where predicate: (Any) throws -> Bool) rethrows -> Bool
}
