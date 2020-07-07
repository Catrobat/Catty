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

class FaceSizeSensor: DeviceSensor {

    static let tag = "FACE_SIZE"
    static let name = kUIFESensorFaceSize
    static let defaultRawValue = 0.0
    static let position = 250
    static let requiredResource = ResourceType.faceDetection

    let getFaceDetectionManager: () -> FaceDetectionManagerProtocol?
    let sceneWidth: Double?

    init(sceneSize: CGSize, faceDetectionManagerGetter: @escaping () -> FaceDetectionManagerProtocol?) {
        self.getFaceDetectionManager = faceDetectionManagerGetter
        self.sceneWidth = Double(sceneSize.width)
    }

    func tag() -> String {
        type(of: self).tag
    }

    func rawValue(landscapeMode: Bool) -> Double {
        guard let faceSize = self.getFaceDetectionManager()?.faceSizeRatio else { return type(of: self).defaultRawValue }
        return Double(faceSize)
    }

    func convertToStandardized(rawValue: Double) -> Double {
        guard let frameSize = self.getFaceDetectionManager()?.faceDetectionFrameSize,
            let sceneWidth = self.sceneWidth
            else { return type(of: self).defaultRawValue }

        let faceSize = rawValue * sceneWidth / Double(frameSize.width) * 100
        if faceSize > 100 {
            return 100
        }
        if faceSize < 0 {
            return 0
        }
        return faceSize
    }

    func formulaEditorSections(for spriteObject: SpriteObject) -> [FormulaEditorSection] {
        [.device(position: type(of: self).position)]
    }
}
