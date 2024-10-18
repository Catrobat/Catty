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

@objc class CatrobatSetup: NSObject {

    @objc public static func registeredBricks() -> [BrickProtocol] {
        var bricks: [BrickProtocol] = [
            // event bricks
            StartScript(),
            WhenScript(),
            WhenTouchDownScript(),
            BroadcastScript(),
            BroadcastBrick(),
            BroadcastWaitBrick(),
            WhenConditionScript(),
            WhenBackgroundChangesScript(),
            // control bricks
            WaitBrick(),
            NoteBrick(),
            ForeverBrick(),
            IfLogicBeginBrick(),
            IfLogicElseBrick(),
            IfLogicEndBrick(),
            IfThenLogicBeginBrick(),
            IfThenLogicEndBrick(),
            WaitUntilBrick(),
            RepeatBrick(),
            RepeatUntilBrick(),
            LoopEndBrick(),
            // motion bricks
            PlaceAtBrick(),
            SetXBrick(),
            SetYBrick(),
            ChangeXByNBrick(),
            ChangeYByNBrick(),
            GoToBrick(),
            IfOnEdgeBounceBrick(),
            MoveNStepsBrick(),
            TurnLeftBrick(),
            TurnRightBrick(),
            PointInDirectionBrick(),
            PointToBrick(),
            SetRotationStyleBrick(),
            GlideToBrick(),
            GoNStepsBackBrick(),
            ComeToFrontBrick(),
            VibrationBrick(),
            // look bricks
            SetLookBrick(),
            SetLookByIndexBrick(),
            NextLookBrick(),
            PreviousLookBrick(),
            SetSizeToBrick(),
            ChangeSizeByNBrick(),
            HideBrick(),
            ShowBrick(),
            AskBrick(),
            SayBubbleBrick(),
            SayForBubbleBrick(),
            ThinkBubbleBrick(),
            ThinkForBubbleBrick(),
            SetTransparencyBrick(),
            ChangeTransparencyByNBrick(),
            SetBrightnessBrick(),
            ChangeBrightnessByNBrick(),
            SetColorBrick(),
            ChangeColorByNBrick(),
            ClearGraphicEffectBrick(),
            SetBackgroundBrick(),
            SetBackgroundByIndexBrick(),
            SetBackgroundAndWaitBrick(),
            CameraBrick(),
            ChooseCameraBrick(),
            FlashBrick(),
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
            SetVolumeToBrick(),
            ChangeVolumeByNBrick(),
            SpeakBrick(),
            SpeakAndWaitBrick(),
            SetInstrumentBrick(),
            SetTempoToBrick(),
            // variable bricks
            SetVariableBrick(),
            ChangeVariableBrick(),
            ShowTextBrick(),
            HideTextBrick(),
            AddItemToUserListBrick(),
            DeleteItemOfUserListBrick(),
            InsertItemIntoUserListBrick(),
            ReplaceItemInUserListBrick(),
            // arduino bricks
            ArduinoSendDigitalValueBrick(),
            ArduinoSendPWMValueBrick(),
            // embroidery brick
            StitchBrick(),
            StitchThreadColorBrick(),
            StartRunningStitchBrick(),
            StartZigzagStitchBrick(),
            StartTripleStitchBrick(),
            SewUpBrick(),
            StopCurrentStitchBrick(),
            // plot brick
            StartPlotBrick(),
            StopPlotBrick(),
            SavePlotSVGBrick()
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
            BrickCategory(type: kBrickCategoryType.plotBrick,
                          name: kLocalizedCategoryPlot,
                          color: UIColor.plotBrick,
                          strokeColor: UIColor.plotBrickStroke,
                          enabled: isPlotEnabled()),

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

            BrickCategory(type: kBrickCategoryType.soundBrick,
                          name: kLocalizedCategorySound,
                          color: UIColor.soundBrickViolet,
                          strokeColor: UIColor.soundBrickStroke,
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
        if isRecentlyUsedAvailable() {
            categories.prepend(BrickCategory(type: kBrickCategoryType.recentlyUsedBricks,
                                             name: kLocalizedCategoryRecentlyUsed,
                                             color: UIColor.recentlyUsedBricks,
                                             strokeColor: UIColor.recentlyUsedBricksStroke,
                                             enabled: isRecentlyUsedAvailable()))
        }

        return categories
    }

    private static func isArduinoEnabled() -> Bool {
        UserDefaults.standard.bool(forKey: kUseArduinoBricks)
    }

    private static func isPhiroEnabled() -> Bool {
        UserDefaults.standard.bool(forKey: kUsePhiroBricks)
    }

    private static func isRecentlyUsedAvailable() -> Bool {
        RecentlyUsedBricksManager.getRecentlyUsedBricks().count >= UIDefines.recentlyUsedBricksMinSize
    }

    private static func isEmbroideryEnabled() -> Bool {
         UserDefaults.standard.bool(forKey: kUseEmbroideryBricks)
    }

    private static func isWebRequestBrickEnabled() -> Bool {
         UserDefaults.standard.bool(forKey: kUseWebRequestBrick)
    }

    private static func isPlotEnabled() -> Bool {
         UserDefaults.standard.bool(forKey: kUsePlotBricks)
    }
}
