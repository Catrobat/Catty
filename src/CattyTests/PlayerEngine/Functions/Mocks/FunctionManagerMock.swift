/**
 *  Copyright (C) 2010-2018 The Catrobat Team
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

@testable import Pocket_Code

// this class is subject to change when FunctionManager is no Singleton anymore
final class FunctionManagerMock: FunctionManagerProtocol {
    
    static var defaultValueForUndefinedFunction: Double = 0
    let functionList: [Function]
    
    init(functions: [Function]) {
        self.functionList = functions
    }

    func functions() -> [Function] {
        return self.functionList
    }
    
    func function(tag: String) -> Function? {
        return nil
    }
    
    func value(tag: String, firstParameter: AnyObject?, secondParameter: AnyObject?) -> AnyObject {
        return FunctionManagerMock.defaultValueForUndefinedFunction as AnyObject
    }
    
    func exists(tag: String) -> Bool {
        return false
    }
    
    static func requiredResource(tag: String) -> ResourceType {
        return ResourceType.noResources
    }
    
    static func name(tag: String) -> String? {
        return ""
    }
    
    func isIdempotent(tag: String) -> Bool {
        guard let function = self.function(tag: tag) else { return false }
        return type(of: function).isIdempotent
    }
    
    func formulaEditorItems() -> [FormulaEditorItem] {
        var items = [FormulaEditorItem]()
        
        for function in functionList {
            items.append(FormulaEditorItem(function: function))
        }
        
        return items
    }
}
