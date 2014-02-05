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

// indexes
#define kBackgroundIndex 0
#define kObjectIndex (kBackgroundIndex + kBackgroundObjects)

// object components
#define kScriptsTitle NSLocalizedString(@"Scripts",nil)
#define kLooksTitle NSLocalizedString(@"Looks",nil)
#define kBackgroundsTitle NSLocalizedString(@"Backgrounds",nil)
#define kSoundsTitle NSLocalizedString(@"Sounds",nil)

// script categories
typedef NS_ENUM(NSInteger, kBrickCategoryType) {
    kControlBrick = 0,
    kMotionBrick = 1,
    kSoundBrick = 2,
    kLookBrick = 3,
    kVariableBrick = 4
};

#define kBrickTypeNames @[\
NSLocalizedString(@"Control",nil),\
NSLocalizedString(@"Motion",nil),\
NSLocalizedString(@"Sound",nil),\
NSLocalizedString(@"Looks",nil),\
NSLocalizedString(@"Variables",nil)\
]

#define kBrickTypeColors @[\
[UIColor orangeColor],\
[UIColor lightBlueColor],\
[UIColor violetColor],\
[UIColor greenColor],\
[UIColor lightRedColor]\
]

// script category bricks

// control bricks
typedef NS_ENUM(NSInteger, kControlBrickType) {
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
};

#define kControlBrickTypeNames @[\
NSLocalizedString(@"When program started",nil),\
NSLocalizedString(@"When tapped",nil),\
NSLocalizedString(@"Wait %d second",nil),\
NSLocalizedString(@"\nWhen I receive\n%@",nil),\
NSLocalizedString(@"Broadcast\n%@",nil),\
NSLocalizedString(@"Broadcast and wait\n%@",nil),\
NSLocalizedString(@"Note %@",nil),\
NSLocalizedString(@"Forever",nil),\
NSLocalizedString(@"If %d is true then",nil),\
NSLocalizedString(@"Repeat %d times",nil)\
]

// motion bricks
typedef NS_ENUM(NSInteger, kMotionBrickType) {
    kPlaceAtBrick = 0,
    kSetXBrick = 1,
    kSetYBrick = 2,
    kChangeXByNBrick = 3,
    kChangeYByNBrick = 4,
    kIfOnEdgeBounceBrick = 5,
    kMoveNStepsBrick = 6,
    kTurnLeftBrick = 7,
    kTurnRightBrick = 8,
    kPointInDirectionBrick = 9,
    kPointToBrick = 10,
    kGlideToBrick = 11,
    kGoNStepsBackBrick = 12,
    kComeToFrontBrick= 13
};

#define kMotionBrickTypeNames @[\
NSLocalizedString(@"Place at\nX: %d Y: %d",nil),\
NSLocalizedString(@"Set X to %d",nil),\
NSLocalizedString(@"Set Y to %d",nil),\
NSLocalizedString(@"Change X by %d",nil),\
NSLocalizedString(@"Change Y by %d",nil),\
NSLocalizedString(@"If on edge, bounce",nil),\
NSLocalizedString(@"Move %f steps",nil),\
NSLocalizedString(@"Turn left %f°",nil),\
NSLocalizedString(@"Turn right %f°",nil),\
NSLocalizedString(@"Point in direction %f°",nil),\
NSLocalizedString(@"Point towards\n%@",nil),\
NSLocalizedString(@"Glide %f second\nto X: %d Y: %d",nil),\
NSLocalizedString(@"Go back %d layer",nil),\
NSLocalizedString(@"Go to front",nil)\
]

// sound bricks
typedef NS_ENUM(NSInteger, kSoundBrickType) {
    kPlaySoundBrick = 0,
    kStopAllSoundsBrick = 1,
    kSetVolumeToBrick = 2,
    kChangeVolumeByBrick = 3,
    kSpeakBrick = 4
};

#define kSoundBrickTypeNames @[\
NSLocalizedString(@"Start sound\%@",nil),\
NSLocalizedString(@"Stop all sounds",nil),\
NSLocalizedString(@"Set volume to %f\%",nil),\
NSLocalizedString(@"Change volume by %f",nil),\
NSLocalizedString(@"Speak %@",nil)\
]

// look bricks
typedef NS_ENUM(NSInteger, kLookBrickType) {
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
};

#define kLookBrickTypeNames @[\
NSLocalizedString(@"Set background\n%@",nil),\
NSLocalizedString(@"Next background",nil),\
NSLocalizedString(@"Set size to %f\%",nil),\
NSLocalizedString(@"Change size by %f\%",nil),\
NSLocalizedString(@"Hide",nil),\
NSLocalizedString(@"Show",nil),\
NSLocalizedString(@"Set transparency\nto %f\%",nil),\
NSLocalizedString(@"Change transparency\nby %f\%",nil),\
NSLocalizedString(@"Set brightness to %f\%",nil),\
NSLocalizedString(@"Change brightness\nby %f\%",nil),\
NSLocalizedString(@"Clear graphic effects",nil)\
]

// variable bricks
typedef NS_ENUM(NSInteger, kVariableBrickType) {
    kSetVariableBrick = 0,
    kChangeVariableBrick = 1
};

#define kVariableBrickTypeNames @[\
NSLocalizedString(@"Set variable\n%@\nto %f",nil),\
NSLocalizedString(@"Change variable\n%@\nby %f",nil)\
]
