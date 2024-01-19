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

class IDOfDetectedObjectFunction: SingleParameterDoubleFunction {

    static let tag = "ID_OF_DETECTED_OBJECT"
    static let name = kUIFEFunctionIDOfDetectedObject
    static let defaultValue = -1.0
    static let isIdempotent = false
    static let position = 100
    static let requiredResource = ResourceType.objectRecognition

    let getVisualDetectionManager: () -> VisualDetectionManagerProtocol?

    init(visualDetectionManagerGetter: @escaping () -> VisualDetectionManagerProtocol?) {
        self.getVisualDetectionManager = visualDetectionManagerGetter
    }

    func tag() -> String {
        type(of: self).tag
    }

    func firstParameter() -> FunctionParameter {
        .number(defaultValue: 1)
    }

    func value(parameter: AnyObject?) -> Double {
        guard let indexAsDouble = parameter as? Double,
              let visualDetectionManager = self.getVisualDetectionManager()
        else { return type(of: self).defaultValue }

        let index = Int(indexAsDouble)
        if index <= 0 || index > visualDetectionManager.objectRecognitions.count {
            return type(of: self).defaultValue
        }

        return Double(index - 1)
    }

    func formulaEditorSections() -> [FormulaEditorSection] {
        [.sensors(position: type(of: self).position, subsection: .objectDetection)]
    }
}
