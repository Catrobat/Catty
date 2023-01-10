/**
 *  Copyright (C) 2010-2022 The Catrobat Team
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
#import "FlashHelper.h"

// Scripts
#import "StartScript.h"
#import "WhenScript.h"
#import "WhenTouchDownScript.h"
#import "BroadcastScript.h"

// Bricks
#import "Brick.h"
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
#import "PlaySoundAndWaitBrick.h"
#import "StopAllSoundsBrick.h"
#import "SpeakBrick.h"
#import "SpeakAndWaitBrick.h"
#import "ChangeVolumeByNBrick.h"
#import "SetVolumeToBrick.h"
#import "SetVariableBrick.h"
#import "ChangeVariableBrick.h"
#import "VibrationBrick.h"
#import "GlideToBrick.h"
#import "GoToBrick.h"
#import "MoveNStepsBrick.h"
#import "IfOnEdgeBounceBrick.h"
#import "ShowBrick.h"
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
#import "PhiroIfLogicBeginBrick.h"
#import "ArduinoSendDigitalValueBrick.h"
#import "ArduinoSendPWMValueBrick.h"
#import "SetTransparencyBrick.h"
#import "SetColorBrick.h"
#import "ChangeColorByNBrick.h"
#import "ClearGraphicEffectBrick.h"
#import "ChangeTransparencyByNBrick.h"
#import "ShowTextBrick.h"
#import "HideTextBrick.h"
#import "FlashBrick.h"
#import "AddItemToUserListBrick.h"
#import "DeleteItemOfUserListBrick.h"
#import "InsertItemIntoUserListBrick.h"
#import "ReplaceItemInUserListBrick.h"
#import "WaitUntilBrick.h"
#import "RepeatBrick.h"
#import "RepeatUntilBrick.h"
#import "CameraBrick.h"
#import "ChooseCameraBrick.h"
#import "SayBubbleBrick.h"
#import "SayForBubbleBrick.h"
#import "ThinkBubbleBrick.h"
#import "ThinkForBubbleBrick.h"
#import "AddItemToUserListBrick+CBXMLHandler.h"
#import "PlaceAtBrick+CBXMLHandler.h"

// BrickCells
#import "RepeatBrickCell.h"
#import "SayForBubbleBrickCell.h"
#import "ThinkForBubbleBrickCell.h"
#import "GlideToBrickCell.h"
#import "GoToBrickCell.h"
#import "VibrationBrickCell.h"
#import "MoveNStepsBrickCell.h"
#import "GoNStepsBackBrickCell.h"
#import "IfLogicBeginBrickCell.h"
#import "ChangeVariableBrickCell.h"
#import "ReplaceItemInUserListBrickCell.h"

#import "BrickCellVariableData.h"
#import "BrickCellListData.h"
#import "BrickCellLookData.h"
#import "BrickCellFormulaData.h"

// Formulas
#import "Formula.h"
#import "FormulaElement.h"
#import "Formula+CBXMLHandler.h"

// User
#import <CommonCrypto/CommonCrypto.h>

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
#import "BrickManager.h"
#import "LanguageTranslationDefines.h"
#import "RuntimeImageCache.h"
#import "CBMutableCopyContext.h"
#import "CameraPreviewHandler.h"
#import "UndoManager.h"
#import "TimerLabel.h"
#import "UIUtil.h"


//------------------------------------------------------------------------------------------------------------
// ViewController classes
//------------------------------------------------------------------------------------------------------------

#import "BaseTableViewController.h"
#import "LooksTableViewController.h"
#import "FormulaEditorViewController.h"
#import "MyProjectsViewController.h"
#import "SceneTableViewController.h"
#import "CatrobatTableViewController.h"
#import "ScriptCollectionViewController.h"
#import "LoginViewController.h"
#import "ProjectDetailStoreViewController.h"
#import "ViewControllerDefines.h"
#import "DarkBlueGradientImageDetailCell.h"
#import "PlaceHolderView.h"

//------------------------------------------------------------------------------------------------------------

// Defines
//------------------------------------------------------------------------------------------------------------

#import "ProjectDefines.h"
#import "KeychainUserDefaultsDefines.h"
#import "CatrobatLanguageDefines.h"
#import "ButtonTags.h"

#import "BrickFormulaProtocol.h"

//-----------------------------------------------------------------------------------------------------------
// Headers to sort
//-----------------------------------------------------------------------------------------------------------
#import "CatrobatProject.h"
#import "TableUtil.h"
#import "CellTagDefines.h"
#import "SegueDefines.h"
#import "DarkBlueGradientFeaturedCell.h"
#import "DarkBlueGradientImageCell.h"
#import "CBXMLParser.h"
#import "Parser.h"
#import "GDataXMLNode.h"
#import "CBXMLSerializer.h"
#import "GDataXMLNode+CustomExtensions.h"
#import "GDataXMLElement+CustomExtensions.h"
#import "GDataXMLNode+CustomExtensions.h"
#import "CBXMLSerializerContext.h"
#import "CBXMLParserContext.h"
#import "CBXMLParserHelper.h"
#import "SetVariableBrick+CBXMLHandler.h"
#import "ChangeVariableBrick+CBXMLHandler.h"
#import "MoveNStepsBrick+CBXMLHandler.h"
#import "PointToBrick+CBXMLHandler.h"
#import "Project+CBXMLHandler.h"
#import "Header+CBXMLHandler.h"
#import "SpriteObject+CBXMLHandler.h"
#import "OrderedMapTable.h"
#import "UIDefines.h"
#import "SpriteObject.h"
#import "CBXMLOpenedNestingBricksStack.h"
#import "BDKNotifyHUD.h"
#import "BrickShapeFactory.h"
#import "iOSCombobox.h"
#import "CBXMLValidator.h"
#import "CBXMLSerializerHelper.h"
#import "CBXMLPositionStack.h"
#import "EVCircularProgressView.h"
#import "BrickLookProtocol.h"
