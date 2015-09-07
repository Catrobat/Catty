/**
 *  Copyright (C) 2010-2015 The Catrobat Team
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

// Scripts
#import "StartScript.h"
#import "WhenScript.h"
#import "BroadcastScript.h"

// Bricks
#import "Brick.h"
#import "BrickConditionalBranchProtocol.h"
#import "IfLogicBeginBrick.h"
#import "IfLogicElseBrick.h"
#import "IfLogicEndBrick.h"
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
#import "ChangeVolumeByNBrick.h"
#import "SetVolumeToBrick.h"
#import "SetVariableBrick.h"
#import "ChangeVariableBrick.h"
#import "LedOnBrick.h"
#import "LedOffBrick.h"
#import "VibrationBrick.h"

// Formulas
#import "Formula.h"
#import "FormulaElement.h"

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
#import "AudioManager.h"
#import "ProgramDefines.h"
#import "FlashHelper.h"
#import "LanguageTranslationDefines.h"
