/**
 *  Copyright (C) 2010-2023 The Catrobat Team
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

class TextBlockYFunction: SingleParameterDoubleFunction {

    static let tag = "TEXT_BLOCK_Y"
    static let name = kUIFEFunctionTextBlockY
    static let defaultValue = 0.0
    static let isIdempotent = false
    static let position = 130
    static let requiredResource = ResourceType.textRecognition

    let getVisualDetectionManager: () -> VisualDetectionManagerProtocol?
    let stageHeight: Double?

    init(stageSize: CGSize, visualDetectionManagerGetter: @escaping () -> VisualDetectionManagerProtocol?) {
        self.getVisualDetectionManager = visualDetectionManagerGetter
        self.stageHeight = Double(stageSize.height)
    }

    func tag() -> String {
        type(of: self).tag
    }

    func firstParameter() -> FunctionParameter {
        .number(defaultValue: 1)
    }

    func value(parameter: AnyObject?) -> Double {
        guard let textBlockNumberAsDouble = parameter as? Double,
              let visualDetectionManager = self.getVisualDetectionManager(),
              let stageHeight = self.stageHeight
        else { return type(of: self).defaultValue }

        let textBlockNumber = Int(textBlockNumberAsDouble)
        if textBlockNumber <= 0 || textBlockNumber > visualDetectionManager.textBlockPosition.count {
            return type(of: self).defaultValue
        }

        let textBlockPositionY = visualDetectionManager.textBlockPosition[textBlockNumber - 1].y
        return stageHeight * textBlockPositionY - stageHeight / 2.0
    }

    func formulaEditorSections() -> [FormulaEditorSection] {
        [.sensors(position: type(of: self).position, subsection: .textRecognition)]
    }
}
