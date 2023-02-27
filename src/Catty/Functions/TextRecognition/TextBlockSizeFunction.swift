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

class TextBlockSizeFunction: SingleParameterDoubleFunction {

    static let tag = "TEXT_BLOCK_SIZE"
    static let name = kUIFEFunctionTextBlockSize
    static let defaultValue = 0.0
    static let isIdempotent = false
    static let position = 140
    static let requiredResource = ResourceType.textRecognition

    let getVisualDetectionManager: () -> VisualDetectionManagerProtocol?
    let stageWidth: Double?

    init(stageSize: CGSize, visualDetectionManagerGetter: @escaping () -> VisualDetectionManagerProtocol?) {
        self.getVisualDetectionManager = visualDetectionManagerGetter
        self.stageWidth = Double(stageSize.width)
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
              let stageWidth = self.stageWidth,
              let frameSize = self.getVisualDetectionManager()?.visualDetectionFrameSize
        else { return type(of: self).defaultValue }

        let textBlockNumber = Int(textBlockNumberAsDouble)
        if textBlockNumber <= 0 || textBlockNumber > visualDetectionManager.textBlockSizeRatio.count {
            return type(of: self).defaultValue
        }

        let textBlockSize = visualDetectionManager.textBlockSizeRatio[textBlockNumber - 1] * stageWidth / Double(frameSize.width) * 100
        if textBlockSize > 100 {
            return 100
        }
        if textBlockSize < 0 {
            return 0
        }
        return textBlockSize
    }

    func formulaEditorSections() -> [FormulaEditorSection] {
        [.sensors(position: type(of: self).position, subsection: .textRecognition)]
    }
}
