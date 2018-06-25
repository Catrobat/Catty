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

//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//

//------------------------------------------------------------------------------------------------------------
// Data model classes
//------------------------------------------------------------------------------------------------------------

// Sensors
#import "FaceDetection.h"
#import "FlashHelper.h"

// Scripts
#import "StartScript.h"
#import "WhenScript.h"
#import "BroadcastScript.h"

// Bricks
#import "Brick.h"
#import "BrickConditionalBranchProtocol.h"
#import "IfLogicBeginBrick.h"
#import "IfThenLogicBeginBrick.h"
#import "IfLogicElseBrick.h"
#import "IfLogicEndBrick.h"
#import "IfThenLogicEndBrick.h"
#import "LoopBeginBrick.h"
#import "LoopEndBrick.h"
#import "NoteBrick.h"
#import "BroadcastBrick.h"
#import "BroadcastWaitBrick.h"
#import "HideBrick.h"
#import "WaitBrick.h"
#import "PlaySoundBrick.h"
#import "StopAllSoundsBrick.h"
#import "SpeakBrick.h"
#import "SpeakAndWaitBrick.h"
#import "ChangeVolumeByNBrick.h"
#import "SetVolumeToBrick.h"
#import "SetVariableBrick.h"
#import "ChangeVariableBrick.h"
#import "VibrationBrick.h"
#import "GlideToBrick.h"
#import "MoveNStepsBrick.h"
#import "IfOnEdgeBounceBrick.h"
#import "ShowBrick.h"
#import "SetLookBrick.h"
#import "SetBackgroundBrick.h"
#import "SetSizeToBrick.h"
#import "PointInDirectionBrick.h"
#import "PlaceAtBrick.h"
#import "GoNStepsBackBrick.h"
#import "ComeToFrontBrick.h"
#import "ChangeSizeByNBrick.h"
#import "ChangeXByNBrick.h"
#import "ChangeYByNBrick.h"
#import "PointToBrick.h"
#import "SetXBrick.h"
#import "SetYBrick.h"
#import "TurnLeftBrick.h"
#import "TurnRightBrick.h"
#import "PhiroBrick.h"
#import "BluetoothBrick.h"
#import "PhiroRGBLightBrick.h"
#import "PhiroMotorStopBrick.h"
#import "PhiroPlayToneBrick.h"
#import "PhiroMotorMoveForwardBrick.h"
#import "PhiroMotorMoveBackwardBrick.h"
#import "ArduinoSendDigitalValueBrick.h"
#import "ArduinoSendPWMValueBrick.h"
#import "SetTransparencyBrick.h"
#import "SetBrightnessBrick.h"
#import "SetColorBrick.h"
#import "ChangeColorByNBrick.h"
#import "NextLookBrick.h"
#import "PreviousLookBrick.h"
#import "ClearGraphicEffectBrick.h"
#import "ChangeTransparencyByNBrick.h"
#import "ChangeBrightnessByNBrick.h"
#import "ShowTextBrick.h"
#import "HideTextBrick.h"
#import "FlashBrick.h"
#import "AddItemToUserListBrick.h"
#import "DeleteItemOfUserListBrick.h"
#import "InsertItemIntoUserListBrick.h"
#import "ReplaceItemInUserListBrick.h"
#import "RepeatBrick.h"
#import "RepeatUntilBrick.h"
#import "CameraBrick.h"
#import "ChooseCameraBrick.h"
#import "SayBubbleBrick.h"
#import "SayForBubbleBrick.h"
#import "ThinkBubbleBrick.h"
#import "ThinkForBubbleBrick.h"

// Formulas
#import "Formula.h"
#import "FormulaElement.h"
#import "Functions.h"

// UserVariable
#import "UserVariable.h"

// Assets
#import "Look.h"
#import "Sound.h"

//------------------------------------------------------------------------------------------------------------
// Extension classes
//------------------------------------------------------------------------------------------------------------

#import "UIImage+CatrobatUIImageExtensions.h"

//------------------------------------------------------------------------------------------------------------
// Util classes
//------------------------------------------------------------------------------------------------------------

#import "Util.h"
#import "CBFileManager.h"
#import "AudioManager.h"
#import "FlashHelper.h"
#import "LanguageTranslationDefines.h"
#import "LoadingView.h"
#import "RuntimeImageCache.h"
#import "CBMutableCopyContext.h"
#import "CameraPreviewHandler.h"
#import "BubbleBrickHelper.h"

//------------------------------------------------------------------------------------------------------------
// ViewController classes
//------------------------------------------------------------------------------------------------------------

#import "BaseTableViewController.h"
#import "LooksTableViewController.h"
#import "FormulaEditorViewController.h"


//------------------------------------------------------------------------------------------------------------
// View
//------------------------------------------------------------------------------------------------------------
#import "FormulaEditorSensorButton.h"

//------------------------------------------------------------------------------------------------------------
// Defines
//------------------------------------------------------------------------------------------------------------
#import "NetworkDefines.h"
#import "ProgramDefines.h"
#import "KeychainUserDefaultsDefines.h"

#import "BrickFormulaProtocol.h"


