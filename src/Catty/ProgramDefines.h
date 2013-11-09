/**
 *  Copyright (C) 2010-2013 The Catrobat Team
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
#import "OrderedDictionary.h"

#define kLastProgram @"lastProgram"
#define kDefaultProject @"My first Project"
#define kProgramCodeFileName @"code.xml"
#define kProgramSoundsDirName @"sounds"
#define kProgramImagesDirName @"images"
#define kProgramsFolder @"levels"
#define kResourceFileNameSeparator @"_" // [UUID]_[fileName] e.g. D32285BE8042D8D8071FAF0A33054DD0_music.mp3                                      //         or for images: 34A109A82231694B6FE09C216B390570_normalCat
#define kPreviewImageNamePrefix @"small_" // [UUID]_small_[fileName] e.g. 34A109A82231694B6FE09C216B390570_small_normalCat
#define kPreviewImageWidth 160
#define kPreviewImageHeight 160
#define kMinNumOfObjects 1
#define kBackgroundObjects 1

// object components
#define kScriptsTitle NSLocalizedString(@"Scripts",nil)
#define kLooksTitle NSLocalizedString(@"Looks",nil)
#define kBackgroundsTitle NSLocalizedString(@"Backgrounds",nil)
#define kSoundsTitle NSLocalizedString(@"Sounds",nil)

#define kScriptCategoryControlTitle NSLocalizedString(@"Control",nil)
#define kScriptCategoryMotionTitle NSLocalizedString(@"Motion",nil)
#define kScriptCategorySoundTitle NSLocalizedString(@"Sound",nil)
#define kScriptCategoryLooksTitle NSLocalizedString(@"Looks",nil)
#define kScriptCategoryVariablesTitle NSLocalizedString(@"Variables",nil)

// script categories
typedef enum {
  kControlBrick = 0,
  kMotionBrick = 1,
  kSoundBrick = 2,
  kLookBrick = 3,
  kVariableBrick = 4
} kBrickType;

#define kBrickTypeNames @{[@(kControlBrick) stringValue] : kScriptCategoryControlTitle, [@(kMotionBrick) stringValue] : kScriptCategoryMotionTitle, [@(kSoundBrick) stringValue] : kScriptCategorySoundTitle, [@(kLookBrick) stringValue] : kScriptCategoryLooksTitle, [@(kVariableBrick) stringValue] : kScriptCategoryVariablesTitle}

#define kScriptCategoryControlColor [UIColor orangeColor]
#define kScriptCategoryMotionColor [UIColor lightBlueColor]
#define kScriptCategorySoundColor [UIColor violetColor]
#define kScriptCategoryLooksColor [UIColor greenColor]
#define kScriptCategoryVariablesColor [UIColor lightRedColor]

#define kBrickTypeColors @{[@(kControlBrick) stringValue] : kScriptCategoryControlColor, [@(kMotionBrick) stringValue] : kScriptCategoryMotionColor, [@(kSoundBrick) stringValue] : kScriptCategorySoundColor, [@(kLookBrick) stringValue] : kScriptCategoryLooksColor, [@(kVariableBrick) stringValue] : kScriptCategoryVariablesColor}

// script category bricks
// control bricks
#define kProgramStartedBrickName NSLocalizedString(@"When program started",nil)
#define kTappedBrickName NSLocalizedString(@"When tapped",nil)
#define kWaitBrickName NSLocalizedString(@"Wait %d second",nil)
#define kReceiveBrickName NSLocalizedString(@"When I receive",nil)
#define kBroadcastBrickName NSLocalizedString(@"Broadcast",nil)
#define kBroadcastWaitBrickName NSLocalizedString(@"Broadcast and wait",nil)
#define kNoteBrickName NSLocalizedString(@"Note",nil)
#define kForeverBrickName NSLocalizedString(@"Forever",nil)
#define kIfBrickName NSLocalizedString(@"If %d is true then",nil)
#define kRepeatBrickName NSLocalizedString(@"Repeat %d times",nil)

// identifiers
typedef enum {
  kProgramStartedBrick = 0,
  kTappedBrick = 1,
  kWaitBrick = 2,
  kReceiveBrick = 3,
  kBroadcastBrick = 4,
  kBroadcastWaitBrick = 5,
  kNoteBrick = 6,
  kForeverBrick = 7,
  kIfBrick = 8,
  kRepeatBrick = 9
} kControlBrickType;

#define kControlBrickTypeNames @{[@(kProgramStartedBrick) stringValue] : kProgramStartedBrickName, [@(kTappedBrick) stringValue] : kTappedBrickName, [@(kWaitBrick) stringValue] : kWaitBrickName, [@(kReceiveBrick) stringValue] : kReceiveBrickName, [@(kBroadcastBrick) stringValue] : kBroadcastBrickName, [@(kBroadcastWaitBrick) stringValue] : kBroadcastWaitBrickName, [@(kNoteBrick) stringValue] : kNoteBrickName, [@(kForeverBrick) stringValue] : kForeverBrickName, [@(kIfBrick) stringValue] : kIfBrickName, [@(kRepeatBrick) stringValue] : kRepeatBrickName}

// motion bricks
#define kPlaceAtBrickName NSLocalizedString(@"Place at",nil)
#define kSetXBrickName NSLocalizedString(@"Set X to",nil)
#define kSetYBrickName NSLocalizedString(@"Set Y to",nil)
#define kChangeXByNBrickName NSLocalizedString(@"Change X by",nil)
#define kChangeYByNBrickName NSLocalizedString(@"Change Y by",nil)
#define kMoveNStepsBrickName NSLocalizedString(@"Move %f steps",nil)
#define kTurnLeftBrickName NSLocalizedString(@"Turn left %f°",nil)
#define kTurnRightBrickName NSLocalizedString(@"Turn right %f°",nil)
#define kPointInDirectionBrickName NSLocalizedString(@"Point in direction %f°",nil)
#define kPointToBrickName NSLocalizedString(@"Point towards",nil)
#define kGlideToBrickName NSLocalizedString(@"Glide %f second to X: %d Y: %d",nil)

// identifiers
typedef enum {
  kPlaceAtBrick = 0,
  kSetXBrick = 1,
  kSetYBrick = 2,
  kChangeXByNBrick = 3,
  kChangeYByNBrick = 4,
  kMoveNStepsBrick = 5,
  kTurnLeftBrick = 6,
  kTurnRightBrick = 7,
  kPointInDirectionBrick = 8,
  kPointToBrick = 9,
  kGlideToBrick = 10
} kMotionBrickType;

#define kMotionBrickTypeNames @{[@(kPlaceAtBrick) stringValue] : kPlaceAtBrickName, [@(kSetXBrick) stringValue] : kSetXBrickName, [@(kSetYBrick) stringValue] : kSetYBrickName, [@(kChangeXByNBrick) stringValue] : kChangeXByNBrickName, [@(kChangeYByNBrick) stringValue] : kChangeYByNBrickName, [@(kMoveNStepsBrick) stringValue] : kMoveNStepsBrickName, [@(kTurnLeftBrick) stringValue] : kTurnLeftBrickName, [@(kTurnRightBrick) stringValue] : kTurnRightBrickName, [@(kPointInDirectionBrick) stringValue] : kPointInDirectionBrickName, [@(kPointToBrick) stringValue] : kPointToBrickName, [@(kGlideToBrick) stringValue] : kGlideToBrickName}

#define kPlaySoundBrickName NSLocalizedString(@"Start sound",nil)
#define kStopAllSoundsBrickName NSLocalizedString(@"Stop all sounds",nil)
#define kSetVolumeToBrickName NSLocalizedString(@"Set volume to %f\%",nil)
#define kChangeVolumeByBrickName NSLocalizedString(@"Change volume by %f",nil)
#define kSpeakBrickName NSLocalizedString(@"Speak",nil)

// identifiers
typedef enum {
  kPlaySoundBrick = 0,
  kStopAllSoundsBrick = 1,
  kSetVolumeToBrick = 2,
  kChangeVolumeByBrick = 3,
  kSpeakBrick = 4
} kSoundBrickType;

#define kSoundBrickTypeNames @{[@(kPlaySoundBrick) stringValue] : kPlaySoundBrickName, [@(kStopAllSoundsBrick) stringValue] : kStopAllSoundsBrickName, [@(kSetVolumeToBrick) stringValue] : kSetVolumeToBrickName, [@(kChangeVolumeByBrick) stringValue] : kChangeVolumeByBrickName, [@(kSpeakBrick) stringValue] : kSpeakBrickName}

#define kSetBackgroundBrickName NSLocalizedString(@"Set background",nil)
#define kNextBackgroundBrickName NSLocalizedString(@"Next background",nil)
#define kSetSizeToBrickName NSLocalizedString(@"Set size to %f\%",nil)
#define kChangeSizeByNBrickName NSLocalizedString(@"Change size by %f\%",nil)
#define kHideBrickName NSLocalizedString(@"Hide",nil)
#define kShowBrickName NSLocalizedString(@"Show",nil)
#define kSetGhostEffectBrickName NSLocalizedString(@"Set transparency to %f\%",nil)
#define kChangeGhostEffectByNBrickName NSLocalizedString(@"Change transparency by %f\%",nil)
#define kSetBrightnessBrickName NSLocalizedString(@"Set brightness to %f\%",nil)
#define kChangeBrightnessByNBrickName NSLocalizedString(@"Change brightness by %f\%",nil)
#define kClearGraphicEffectBrickName NSLocalizedString(@"Clear graphic effects",nil)

// identifiers
typedef enum {
  kSetBackgroundBrick = 0,
  kNextBackgroundBrick = 1,
  kSetSizeToBrick = 2,
  kChangeSizeByNBrick = 3,
  kHideBrick = 4,
  kShowBrick = 5,
  kSetGhostEffectBrick = 6,
  kChangeGhostEffectByNBrick = 7,
  kSetBrightnessBrick = 8,
  kChangeBrightnessByNBrick = 9,
  kClearGraphicEffectBrick = 10
} kLookBrickType;

#define kLookBrickTypeNames @{[@(kSetBackgroundBrick) stringValue] : kSetBackgroundBrickName, [@(kNextBackgroundBrick) stringValue] : kNextBackgroundBrickName, [@(kSetSizeToBrick) stringValue] : kSetSizeToBrickName, [@(kChangeSizeByNBrick) stringValue] : kChangeSizeByNBrickName, [@(kHideBrick) stringValue] : kHideBrickName, [@(kShowBrick) stringValue] : kShowBrickName, [@(kSetGhostEffectBrick) stringValue] : kSetGhostEffectBrickName, [@(kChangeGhostEffectByNBrick) stringValue] : kChangeGhostEffectByNBrickName, [@(kSetBrightnessBrick) stringValue] : kSetBrightnessBrickName, [@(kChangeBrightnessByNBrick) stringValue] : kChangeBrightnessByNBrickName, [@(kClearGraphicEffectBrick) stringValue] : kClearGraphicEffectBrickName}

#define kSetVariableBrickName NSLocalizedString(@"Set variable %@ to %f",nil)
#define kChangeVariableBrickName NSLocalizedString(@"Change variable %@ by %f",nil)

typedef enum {
  kSetVariableBrick = 0,
  kChangeVariableBrick = 1
} kVariableBrickType;

#define kVariableBrickTypeNames [OrderedDictionary dictionaryWithObjects:@[kSetVariableBrickName, kChangeVariableBrickName] forKeys:@[[@(kPlaySoundBrick) stringValue], [@(kStopAllSoundsBrick) stringValue]]];

// indexes
#define kBackgroundIndex 0
#define kObjectIndex (kBackgroundIndex + kBackgroundObjects)
