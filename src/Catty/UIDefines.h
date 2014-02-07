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

#define kBtnCancelTitle NSLocalizedString(@"Cancel", @"Cancel button for views")
#define kBtnOKTitle NSLocalizedString(@"OK", @"OK button for views")
#define kBtnDeleteTitle NSLocalizedString(@"Delete", @"Delete button for views")

#define kDefaultImageCellBorderWidth 1.0f

// brick UI config
// brick categories
typedef NS_ENUM(NSInteger, kBrickCategoryType) {
    kControlBrick = 0,
    kMotionBrick = 1,
    kSoundBrick = 2,
    kLookBrick = 3,
    kVariableBrick = 4
};

// object components
#define kScriptsTitle NSLocalizedString(@"Scripts",nil)
#define kLooksTitle NSLocalizedString(@"Looks",nil)
#define kBackgroundsTitle NSLocalizedString(@"Backgrounds",nil)
#define kSoundsTitle NSLocalizedString(@"Sounds",nil)

// placeholder texts
#define kPlaceHolderTag 99998
#define kLoadingViewTag 99999
#define kEmptyViewPlaceHolder @"Click \"+\" to add %@"

#define kIphone5ScreenHeight 568.0f
#define kIphone4ScreenHeight 480.0f
#define kAddScriptCategoryTableViewBottomMargin 15.0f

// brick categories
#define kBrickCategoryNames @[\
    NSLocalizedString(@"Control",nil),\
    NSLocalizedString(@"Motion",nil),\
    NSLocalizedString(@"Sound",nil),\
    NSLocalizedString(@"Looks",nil),\
    NSLocalizedString(@"Variables",nil)\
]

#define kBrickCategoryColors @[\
    [UIColor orangeColor],\
    [UIColor lightBlueColor],\
    [UIColor violetColor],\
    [UIColor greenColor],\
    [UIColor lightRedColor]\
]

// brick subview const values
#define kBrickInlineViewOffsetX 54.0f
#define kBrickShapeNormalInlineViewOffsetY 3.0f
#define kBrickShapeRoundedSmallInlineViewOffsetY 22.0f
#define kBrickShapeRoundedBigInlineViewOffsetY 22.0f
#define kBrickShapeNormalMarginHeightDeduction 9.0f
#define kBrickShapeRoundedSmallMarginHeightDeduction 28.0f
#define kBrickShapeRoundedBigMarginHeightDeduction 28.0f
#define kBrickPatternImageViewOffsetX 0.0f
#define kBrickPatternImageViewOffsetY 0.0f
#define kBrickPatternBackgroundImageViewOffsetX 54.0f
#define kBrickPatternBackgroundImageViewOffsetY 0.0f
#define kBrickLabelOffsetX 0.0f
#define kBrickLabelOffsetY 0.0f
#define kBrickBackgroundImageNameSuffix @"_bg"

// brick heights
#define kBrickHeight1h @44
#define kBrickHeight2h @71
#define kBrickHeight3h @94
#define kBrickHeightControl1h @62
#define kBrickHeightControl2h @88

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

#define kControlBrickNames @[\
    NSLocalizedString(@"When program started",nil),\
    NSLocalizedString(@"When tapped",nil),\
    NSLocalizedString(@"Wait %d second",nil),\
    NSLocalizedString(@"When I receive\n%@",nil),\
    NSLocalizedString(@"Broadcast\n%@",nil),\
    NSLocalizedString(@"Broadcast and wait\n%@",nil),\
    NSLocalizedString(@"Note %@",nil),\
    NSLocalizedString(@"Forever",nil),\
    NSLocalizedString(@"If %d is true then",nil),\
    NSLocalizedString(@"Repeat %d times",nil)\
]

#define kControlBrickImageNames @[\
    @"brick_control_1h",   /* program started */\
    @"brick_control_1h",   /* tapped          */\
    @"brick_orange_1h",    /* wait            */\
    @"brick_control_2h",   /* receive         */\
    @"brick_orange_2h",    /* broadcast       */\
    @"brick_orange_2h",    /* broadcast wait  */\
    @"brick_orange_2h",    /* note            */\
    @"brick_orange_1h",    /* forever         */\
    @"brick_orange_1h",    /* if              */\
    @"brick_orange_1h"     /* repeat          */\
]

#define kControlBrickHeights @[\
    kBrickHeightControl1h, /* program started */\
    kBrickHeightControl1h, /* tapped          */\
    kBrickHeight1h,        /* wait            */\
    kBrickHeightControl2h, /* receive         */\
    kBrickHeight2h,        /* broadcast       */\
    kBrickHeight2h,        /* broadcast wait  */\
    kBrickHeight2h,        /* note            */\
    kBrickHeight1h,        /* forever         */\
    kBrickHeight1h,        /* if              */\
    kBrickHeight1h         /* repeat          */\
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
    kComeToFrontBrick = 13
};

#define kMotionBrickNames @[\
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

#define kMotionBrickImageNames @[\
    @"brick_blue_2h",      /* place at           */\
    @"brick_blue_1h",      /* set X              */\
    @"brick_blue_1h",      /* set Y              */\
    @"brick_blue_1h",      /* change X by N      */\
    @"brick_blue_1h",      /* change Y by N      */\
    @"brick_blue_1h",      /* if on edge bounce  */\
    @"brick_blue_1h",      /* move N steps       */\
    @"brick_blue_1h",      /* turn left          */\
    @"brick_blue_1h",      /* turn right         */\
    @"brick_blue_1h",      /* point in direction */\
    @"brick_blue_2h",      /* point to brick     */\
    @"brick_blue_3h",      /* glide to brick     */\
    @"brick_blue_1h",      /* go N steps back    */\
    @"brick_blue_1h"       /* come to front      */\
]

#define kMotionBrickHeights @[\
    kBrickHeight2h,        /* place at           */\
    kBrickHeight1h,        /* set X              */\
    kBrickHeight1h,        /* set Y              */\
    kBrickHeight1h,        /* change X by N      */\
    kBrickHeight1h,        /* change Y by N      */\
    kBrickHeight1h,        /* if on edge bounce  */\
    kBrickHeight1h,        /* move N steps       */\
    kBrickHeight1h,        /* turn left          */\
    kBrickHeight1h,        /* turn right         */\
    kBrickHeight1h,        /* point in direction */\
    kBrickHeight2h,        /* point to brick     */\
    kBrickHeight3h,        /* glide to brick     */\
    kBrickHeight1h,        /* go N steps back    */\
    kBrickHeight1h         /* come to front      */\
]

// sound bricks
typedef NS_ENUM(NSInteger, kSoundBrickType) {
    kPlaySoundBrick = 0,
    kStopAllSoundsBrick = 1,
    kSetVolumeToBrick = 2,
    kChangeVolumeByBrick = 3,
    kSpeakBrick = 4
};

#define kSoundBrickNames @[\
    NSLocalizedString(@"Start sound\%@",nil),\
    NSLocalizedString(@"Stop all sounds",nil),\
    NSLocalizedString(@"Set volume to %f\%",nil),\
    NSLocalizedString(@"Change volume by %f",nil),\
    NSLocalizedString(@"Speak %@",nil)\
]

#define kSoundBrickImageNames @[\
    @"brick_violet_2h",    /* play sound         */\
    @"brick_violet_1h",    /* stop all sounds    */\
    @"brick_violet_1h",    /* set volume to      */\
    @"brick_violet_1h",    /* change volume to   */\
    @"brick_violet_2h"     /* speak              */\
]

#define kSoundBrickHeights @[\
    kBrickHeight2h,        /* play sound         */\
    kBrickHeight1h,        /* stop all sounds    */\
    kBrickHeight1h,        /* set volume to      */\
    kBrickHeight1h,        /* change volume to   */\
    kBrickHeight2h         /* speak              */\
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

#define kLookBrickNames @[\
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

#define kLookBrickImageNames @[\
    @"brick_green_2h",     /* set background           */\
    @"brick_green_1h",     /* next background          */\
    @"brick_green_1h",     /* set size to              */\
    @"brick_green_1h",     /* change size by N         */\
    @"brick_green_1h",     /* hide                     */\
    @"brick_green_1h",     /* show                     */\
    @"brick_green_2h",     /* set ghost effect         */\
    @"brick_green_2h",     /* change ghost effect by N */\
    @"brick_green_2h",     /* set brightness           */\
    @"brick_green_2h",     /* change brightness by N   */\
    @"brick_green_1h"      /* clear graphic effect     */\
]

#define kLookBrickHeights @[\
    kBrickHeight2h,        /* set background           */\
    kBrickHeight1h,        /* next background          */\
    kBrickHeight1h,        /* set size to              */\
    kBrickHeight1h,        /* change size by N         */\
    kBrickHeight1h,        /* hide                     */\
    kBrickHeight1h,        /* show                     */\
    kBrickHeight2h,        /* set ghost effect         */\
    kBrickHeight2h,        /* change ghost effect by N */\
    kBrickHeight2h,        /* set brightness           */\
    kBrickHeight2h,        /* change brightness by N   */\
    kBrickHeight1h         /* clear graphic effect     */\
]

// variable bricks
typedef NS_ENUM(NSInteger, kVariableBrickType) {
    kSetVariableBrick = 0,
    kChangeVariableBrick = 1
};

#define kVariableBrickNames @[\
    NSLocalizedString(@"Set variable\n%@\nto %f",nil),\
    NSLocalizedString(@"Change variable\n%@\nby %f",nil)\
]

#define kVariableBrickImageNames @[\
    @"brick_red_3h",       /* set variable    */\
    @"brick_red_3h"        /* change variable */\
]

#define kVariableBrickHeights @[\
    kBrickHeight3h,        /* set variable    */\
    kBrickHeight3h         /* change variable */\
]

typedef NS_ENUM(NSInteger, kBrickShapeType) {
    kBrickShapeNormal = 0,
    kBrickShapeRoundedSmall = 1,
    kBrickShapeRoundedBig = 2
};
