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

class FacePositionXSensor: DeviceSensor {

    static let tag = "FACE_X_POSITION"
    static let name = kUIFESensorFaceX
    static let defaultRawValue = 0.0
    static let position = 210
    static let requiredResource = ResourceType.faceDetection

    let getFaceDetectionManager: () -> FaceDetectionManagerProtocol?
    let sceneWidth: Double?

    init(faceDetectionManagerGetter: @escaping () -> FaceDetectionManagerProtocol?) {
        self.getFaceDetectionManager = faceDetectionManagerGetter
        self.sceneWidth = Double(Util.screenWidth(true))
    }

    func tag() -> String {
        return type(of: self).tag
    }

    func rawValue() -> Double {
        guard let positionX = self.getFaceDetectionManager()?.facePositionRatioFromLeft else { return type(of: self).defaultRawValue }
        return positionX
    }

    func convertToStandardized(rawValue: Double) -> Double {
        if rawValue == type(of: self).defaultRawValue {
            return rawValue
        }
        guard let sceneWidth = self.sceneWidth else { return type(of: self).defaultRawValue }
        return sceneWidth * rawValue - sceneWidth / 2.0
    }

    func formulaEditorSection(for spriteObject: SpriteObject) -> FormulaEditorSection {
        return .device(position: type(of: self).position)
    }

}
