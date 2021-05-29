/**
 *  Copyright (C) 2010-2021 The Catrobat Team
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

@objc class CatrobatSetup: NSObject {

    @objc public static func registeredBricks() -> [BrickProtocol] {
        var bricks: [BrickProtocol] = [
            // event bricks
            BroadcastScript(),
            StartScript(),
            WhenScript(),
            WhenConditionScript(),
            WhenTouchDownScript(),
            BroadcastBrick(),
            BroadcastWaitBrick(),
            WhenBackgroundChangesScript(),
            // control bricks
            WaitBrick(),
            IfThenLogicBeginBrick(),
            IfThenLogicEndBrick(),
            IfLogicBeginBrick(),
            IfLogicElseBrick(),
            IfLogicEndBrick(),
            ForeverBrick(),
            RepeatBrick(),
            RepeatUntilBrick(),
            NoteBrick(),
            WaitUntilBrick(),
            LoopEndBrick(),
            // motion bricks
            PlaceAtBrick(),
            GlideToBrick(),
            ChangeXByNBrick(),
            ChangeYByNBrick(),
            SetXBrick(),
            SetYBrick(),
            ComeToFrontBrick(),
            MoveNStepsBrick(),
            PointInDirectionBrick(),
            TurnLeftBrick(),
            TurnRightBrick(),
            PointToBrick(),
            GoToBrick(),
            IfOnEdgeBounceBrick(),
            GoNStepsBackBrick(),
            VibrationBrick(),
            SetRotationStyleBrick(),
            // look bricks
            HideBrick(),
            ShowBrick(),
            SetLookBrick(),
            SetLookByIndexBrick(),
            SetSizeToBrick(),
            SetTransparencyBrick(),
            NextLookBrick(),
            PreviousLookBrick(),
            SetBackgroundBrick(),
            SetBackgroundAndWaitBrick(),
            SetBrightnessBrick(),
            ChangeSizeByNBrick(),
            ChangeTransparencyByNBrick(),
            SayForBubbleBrick(),
            ChangeBrightnessByNBrick(),
            ChangeColorByNBrick(),
            SetColorBrick(),
            FlashBrick(),
            SayBubbleBrick(),
            ClearGraphicEffectBrick(),
            CameraBrick(),
            ChooseCameraBrick(),
            ThinkForBubbleBrick(),
            ThinkBubbleBrick(),
            AskBrick(),
            // pen bricks
            PenDownBrick(),
            PenUpBrick(),
            SetPenSizeBrick(),
            SetPenColorBrick(),
            StampBrick(),
            PenClearBrick(),
            // sound bricks
            PlaySoundBrick(),
            PlaySoundAndWaitBrick(),
            StopAllSoundsBrick(),
            SpeakBrick(),
            SpeakAndWaitBrick(),
            SetVolumeToBrick(),
            ChangeVolumeByNBrick(),
            SetInstrumentBrick(),
            SetTempoToBrick(),
            // variable bricks
            SetVariableBrick(),
            ChangeVariableBrick(),
            ShowTextBrick(),
            HideTextBrick(),
            AddItemToUserListBrick(),
            InsertItemIntoUserListBrick(),
            ReplaceItemInUserListBrick(),
            DeleteItemOfUserListBrick(),
            // arduino bricks
            ArduinoSendDigitalValueBrick(),
            ArduinoSendPWMValueBrick(),
            // embroidery brick
            StitchBrick()
        ]

        if isPhiroEnabled() {
            bricks.append(PhiroMotorStopBrick())
            bricks.append(PhiroMotorMoveForwardBrick())
            bricks.append(PhiroMotorMoveBackwardBrick())
            bricks.append(PhiroPlayToneBrick())
            bricks.append(PhiroRGBLightBrick())
            bricks.append(PhiroIfLogicBeginBrick())
        }

        if isWebRequestBrickEnabled() {
            bricks.append(WebRequestBrick())
        }

        return bricks
    }

    @objc public static func registeredBrickCategories() -> [BrickCategory] {
        var categories = [
            BrickCategory(type: kBrickCategoryType.embroideryBrick,
                          name: kLocalizedCategoryEmbroidery,
                          color: UIColor.embroideryBrickPink,
                          strokeColor: UIColor.embroideryBrickStroke,
                          enabled: isEmbroideryEnabled()),

            BrickCategory(type: kBrickCategoryType.arduinoBrick,
                          name: kLocalizedCategoryArduino,
                          color: UIColor.arduinoBrick,
                          strokeColor: UIColor.arduinoBrickStroke,
                          enabled: isArduinoEnabled()),

            BrickCategory(type: kBrickCategoryType.eventBrick,
                          name: kLocalizedCategoryEvent,
                          color: UIColor.eventBrick,
                          strokeColor: UIColor.eventBrickStroke,
                          enabled: true),

            BrickCategory(type: kBrickCategoryType.controlBrick,
                          name: kLocalizedCategoryControl,
                          color: UIColor.controlBrickOrange,
                          strokeColor: UIColor.controlBrickStroke,
                          enabled: true),

            BrickCategory(type: kBrickCategoryType.motionBrick,
                          name: kLocalizedCategoryMotion,
                          color: UIColor.motionBrickBlue,
                          strokeColor: UIColor.motionBrickStroke,
                          enabled: true),

            BrickCategory(type: kBrickCategoryType.lookBrick,
                          name: kLocalizedCategoryLook,
                          color: UIColor.lookBrickGreen,
                          strokeColor: UIColor.lookBrickStroke,
                          enabled: true),

            BrickCategory(type: kBrickCategoryType.penBrick,
                          name: kLocalizedCategoryPen,
                          color: UIColor.penBrickGreen,
                          strokeColor: UIColor.penBrickStroke,
                          enabled: true),

            BrickCategory(type: kBrickCategoryType.soundBrick,
                          name: kLocalizedCategorySound,
                          color: UIColor.soundBrickViolet,
                          strokeColor: UIColor.soundBrickStroke,
                          enabled: true),

            BrickCategory(type: kBrickCategoryType.dataBrick,
                          name: kLocalizedCategoryData,
                          color: UIColor.variableBrickRed,
                          strokeColor: UIColor.variableBrickStroke,
                          enabled: true)
        ]

        if isPhiroEnabled() {
            categories.prepend(BrickCategory(type: kBrickCategoryType.phiroBrick,
                                             name: kLocalizedCategoryPhiro,
                                             color: UIColor.phiroBrick,
                                             strokeColor: UIColor.phiroBrickStroke,
                                             enabled: isPhiroEnabled()))
        }
        if isFavouritesCategoryAvailable() {
            categories.prepend(BrickCategory(type: kBrickCategoryType.favouriteBricks,
                                             name: kLocalizedCategoryFrequentlyUsed,
                                             color: UIColor.frequentlyUsedBricks,
                                             strokeColor: UIColor.frequentlyUsedBricksStroke,
                                             enabled: isFavouritesCategoryAvailable()))
        }

        return categories
    }

    private static func isArduinoEnabled() -> Bool {
        UserDefaults.standard.bool(forKey: kUseArduinoBricks)
    }

    private static func isPhiroEnabled() -> Bool {
        UserDefaults.standard.bool(forKey: kUsePhiroBricks)
    }

    private static func isFavouritesCategoryAvailable() -> Bool {
        Util.getBrickInsertionDictionaryFromUserDefaults()?.count ?? 0 >= kMinFavouriteBrickSize
    }

    private static func isEmbroideryEnabled() -> Bool {
         UserDefaults.standard.bool(forKey: kUseEmbroideryBricks)
    }

    private static func isWebRequestBrickEnabled() -> Bool {
         UserDefaults.standard.bool(forKey: kUseWebRequestBrick)
    }
}
