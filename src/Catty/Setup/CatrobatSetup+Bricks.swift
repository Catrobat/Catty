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

@objc class CatrobatSetup: NSObject {

    @objc public static func registeredBricks() -> [BrickProtocol] {
        var bricks: [BrickProtocol] = [
            // control bricks
            BroadcastScript(),
            StartScript(),
            WaitBrick(),
            IfThenLogicBeginBrick(),
            IfThenLogicEndBrick(),
            IfLogicBeginBrick(),
            IfLogicElseBrick(),
            IfLogicEndBrick(),
            WhenScript(),
            BroadcastBrick(),
            BroadcastWaitBrick(),
            ForeverBrick(),
            RepeatBrick(),
            RepeatUntilBrick(),
            WhenTouchDownScript(),
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
            IfOnEdgeBounceBrick(),
            GoNStepsBackBrick(),
            VibrationBrick(),
            // look bricks
            HideBrick(),
            SetLookBrick(),
            ShowBrick(),
            SetSizeToBrick(),
            SetTransparencyBrick(),
            NextLookBrick(),
            PreviousLookBrick(),
            SetBackgroundBrick(),
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
            // sound bricks
            PlaySoundBrick(),
            PlaySoundAndWaitBrick(),
            StopAllSoundsBrick(),
            SpeakBrick(),
            SpeakAndWaitBrick(),
            SetVolumeToBrick(),
            ChangeVolumeByNBrick(),
            // variable bricks
            SetVariableBrick(),
            ChangeVariableBrick(),
            ShowTextBrick(),
            HideTextBrick(),
            AddItemToUserListBrick(),
            InsertItemIntoUserListBrick(),
            ReplaceItemInUserListBrick(),
            DeleteItemOfUserListBrick(),
            ArduinoSendDigitalValueBrick(),
            ArduinoSendPWMValueBrick()
        ]

        if isPhiroEnabled() {
            bricks.append(PhiroMotorStopBrick())
            bricks.append(PhiroMotorMoveForwardBrick())
            bricks.append(PhiroMotorMoveBackwardBrick())
            bricks.append(PhiroPlayToneBrick())
            bricks.append(PhiroRGBLightBrick())
            bricks.append(PhiroIfLogicBeginBrick())
        }

        return bricks
    }

    @objc public static func registeredBrickCategories() -> [BrickCategory] {
        var categories = [
            BrickCategory(type: kBrickCategoryType.controlBrick,
                          name: kLocalizedCategoryControl,
                          color: UIColor.controlBrickOrange,
                          strokeColor: UIColor.controlBrickStroke),

            BrickCategory(type: kBrickCategoryType.motionBrick,
                          name: kLocalizedCategoryMotion,
                          color: UIColor.motionBrickBlue,
                          strokeColor: UIColor.motionBrickStroke),

            BrickCategory(type: kBrickCategoryType.lookBrick,
                          name: kLocalizedCategoryLook,
                          color: UIColor.lookBrickGreen,
                          strokeColor: UIColor.lookBrickStroke),

            BrickCategory(type: kBrickCategoryType.soundBrick,
                          name: kLocalizedCategorySound,
                          color: UIColor.soundBrickViolet,
                          strokeColor: UIColor.soundBrickStroke),

            BrickCategory(type: kBrickCategoryType.variableBrick,
                          name: kLocalizedCategoryVariable,
                          color: UIColor.variableBrickRed,
                          strokeColor: UIColor.variableBrickStroke)
        ]

        if isFavouritesCategoryAvailable() {
            categories.prepend(BrickCategory(type: kBrickCategoryType.favouriteBricks,
                                             name: kLocalizedCategoryFrequentlyUsed,
                                             color: UIColor.controlBrickOrange,
                                             strokeColor: UIColor.controlBrickStroke))
        }
        if isArduinoEnabled() {
            categories.append(BrickCategory(type: kBrickCategoryType.arduinoBrick,
                                            name: kLocalizedCategoryArduino,
                                            color: UIColor.arduinoBrick,
                                            strokeColor: UIColor.arduinoBrickStroke))
        }
        if isPhiroEnabled() {
            categories.append(BrickCategory(type: kBrickCategoryType.phiroBrick,
                                            name: kLocalizedCategoryPhiro,
                                            color: UIColor.phiroBrick,
                                            strokeColor: UIColor.phiroBrickStroke))
        }

        return categories
    }

    private static func isArduinoEnabled() -> Bool {
        return UserDefaults.standard.bool(forKey: kUseArduinoBricks)
    }

    private static func isPhiroEnabled() -> Bool {
        return UserDefaults.standard.bool(forKey: kUsePhiroBricks)
    }

    private static func isFavouritesCategoryAvailable() -> Bool {
        return Util.getBrickInsertionDictionaryFromUserDefaults()?.count ?? 0 >= kMinFavouriteBrickSize
    }
}
