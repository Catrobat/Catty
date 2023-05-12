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

class LeftEarXSensor: DeviceDoubleSensor {

    static let tag = "LEFT_EAR_X"
    static let name = kUIFESensorLeftEarX
    static let defaultRawValue = 0.0
    static let position = 390
    static let requiredResource = ResourceType.faceDetection

    let getVisualDetectionManager: () -> VisualDetectionManagerProtocol?
    let stageWidth: Double?

    init(stageSize: CGSize, visualDetectionManagerGetter: @escaping () -> VisualDetectionManagerProtocol?) {
        self.getVisualDetectionManager = visualDetectionManagerGetter
        self.stageWidth = Double(stageSize.width)
    }

    func tag() -> String {
        type(of: self).tag
    }

    func rawValue(landscapeMode: Bool) -> Double {
        guard let positionX = self.getVisualDetectionManager()?.faceLandmarkPositionRatioDictionary[self.tag()] else { return type(of: self).defaultRawValue }
        return positionX
    }

    func convertToStandardized(rawValue: Double) -> Double {
        if rawValue == type(of: self).defaultRawValue {
            return rawValue
        }
        guard let stageWidth = self.stageWidth else {
            return type(of: self).defaultRawValue }
        return stageWidth * rawValue - stageWidth / 2.0
    }

    func formulaEditorSections(for spriteObject: SpriteObject) -> [FormulaEditorSection] {
        [.sensors(position: type(of: self).position, subsection: .pose)]
    }
}
