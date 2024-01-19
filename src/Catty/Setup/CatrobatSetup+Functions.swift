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

extension CatrobatSetup {

    static func registeredFunctions(stageSize: CGSize, touchManager: TouchManagerProtocol, visualDetectionManager: VisualDetectionManager, bluetoothService: BluetoothService) -> [Function] {
        [SinFunction(),
         CosFunction(),
         TanFunction(),
         LnFunction(),
         LogFunction(),
         PiFunction(),
         SqrtFunction(),
         RandFunction(),
         AbsFunction(),
         RoundFunction(),
         ModFunction(),
         AsinFunction(),
         AcosFunction(),
         AtanFunction(),
         ExpFunction(),
         PowerFunction(),
         FloorFunction(),
         CeilFunction(),
         MaxFunction(),
         MinFunction(),
         TrueFunction(),
         FalseFunction(),
         JoinFunction(),
         JoinThreeStringsFunction(),
         RegularExpressionFunction(),
         LetterFunction(),
         LengthFunction(),
         ElementFunction(),
         NumberOfItemsFunction(),
         ContainsFunction(),
         CollisionFunction(),
         IndexOfItemFunction(),
         MultiFingerXFunction(touchManagerGetter: { touchManager }),
         MultiFingerYFunction(touchManagerGetter: { touchManager }),
         MultiFingerTouchedFunction(touchManagerGetter: { touchManager }),
         TextBlockXFunction(stageSize: stageSize, visualDetectionManagerGetter: { visualDetectionManager }),
         TextBlockYFunction(stageSize: stageSize, visualDetectionManagerGetter: { visualDetectionManager }),
         TextBlockSizeFunction(stageSize: stageSize, visualDetectionManagerGetter: { visualDetectionManager }),
         TextBlockFromCameraFunction(visualDetectionManagerGetter: { visualDetectionManager }),
         TextBlockLanguageFromCameraFunction(visualDetectionManagerGetter: { visualDetectionManager }),
         IDOfDetectedObjectFunction(visualDetectionManagerGetter: { visualDetectionManager }),
         ObjectWithIDVisibleFunction(visualDetectionManagerGetter: { visualDetectionManager }),
         LabelOfObjectWithIDFunction(visualDetectionManagerGetter: { visualDetectionManager }),
         XOfObjectWithIDFunction(stageSize: stageSize, visualDetectionManagerGetter: { visualDetectionManager }),
         YOfObjectWithIDFunction(stageSize: stageSize, visualDetectionManagerGetter: { visualDetectionManager }),
         WidthOfObjectWithIDFunction(stageSize: stageSize, visualDetectionManagerGetter: { visualDetectionManager }),
         HeightOfObjectWithIDFunction(stageSize: stageSize, visualDetectionManagerGetter: { visualDetectionManager }),
         ArduinoAnalogPinFunction(bluetoothServiceGetter: { bluetoothService }),
         ArduinoDigitalPinFunction(bluetoothServiceGetter: { bluetoothService })]
    }
}
