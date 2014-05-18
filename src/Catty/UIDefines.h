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

#import "LanguageTranslationDefines.h"

// TODO: which characters in program, object, image names do we have to support?
#define kTextFieldAllowedCharacters @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_- 1234567890"

#define kMenuImageNameContinue @"continue"
#define kMenuImageNameNew @"new"
#define kMenuImageNamePrograms @"programs"
#define kMenuImageNameHelp @"help"
#define kMenuImageNameExplore @"explore"
#define kMenuImageNameUpload @"upload"

// brick UI config
// brick categories
typedef NS_ENUM(NSInteger, kBrickCategoryType) {
    kControlBrick = 0,
    kMotionBrick = 1,
    kSoundBrick = 2,
    kLookBrick = 3,
    kVariableBrick = 4
};

// placeholder texts
#define kPlaceHolderTag 99998
#define kLoadingViewTag 99999

#define kIphone5ScreenHeight 568.0f
#define kIphone4ScreenHeight 480.0f
#define kAddScriptCategoryTableViewBottomMargin 15.0f

// brick type identifiers
//typedef NS_ENUM(NSUInteger, kBrickType) {
//
//    // 1 control bricks
//    kProgramStartedBrick = 100,
//    kTappedBrick = 101,
//    kWaitBrick = 102,
//    kReceiveBrick = 103,
//    kBroadcastBrick = 104,
//    kBroadcastWaitBrick = 105,
//    kNoteBrick = 106,
//    kForeverBrick = 107,
//    kIfBrick = 108,
//    kIfElseBrick = 109,
//    kIfEndBrick = 110,
//    kRepeatBrick = 111,
//    kLoopEndBrick = 112,
//
//    // 2 motion bricks
//    kPlaceAtBrick = 200,
//    kSetXBrick = 201,
//    kSetYBrick = 202,
//    kChangeXByNBrick = 203,
//    kChangeYByNBrick = 204,
//    kIfOnEdgeBounceBrick = 205,
//    kMoveNStepsBrick = 206,
//    kTurnLeftBrick = 207,
//    kTurnRightBrick = 208,
//    kPointInDirectionBrick = 209,
//    kPointToBrick = 210,
//    kGlideToBrick = 211,
//    kGoNStepsBackBrick = 212,
//    kComeToFrontBrick = 213,
//
//    // 3 sound bricks
//    kPlaySoundBrick = 300,
//    kStopAllSoundsBrick = 301,
//    kSetVolumeToBrick = 302,
//    kChangeVolumeByNBrick = 303,
//    kSpeakBrick = 304,
//
//    // 4 look bricks
//    kSetLookBrick = 400,
//    kNextLookBrick = 401,
//    kSetSizeToBrick = 402,
//    kChangeSizeByNBrick = 403,
//    kHideBrick = 404,
//    kShowBrick = 405,
//    kSetGhostEffectBrick = 406,
//    kChangeGhostEffectByNBrick = 407,
//    kSetBrightnessBrick = 408,
//    kChangeBrightnessByNBrick = 409,
//    kClearGraphicEffectBrick = 410,
//
//    // 5 variable bricks
//    kSetVariableBrick = 500,
//    kChangeVariableBrick = 501
//
//};

// ----------------- REFACTOR BEGIN -------------------

// brick categories
#define kBrickCategoryNames @[\
    kBrickCellControlCategoryTitle,\
    kBrickCellMotionCategoryTitle,\
    kBrickCellSoundCategoryTitle,\
    kBrickCellLooksCategoryTitle,\
    kBrickCellVariablesCategoryTitle\
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
#define kBrickInlineViewCanvasOffsetX 0.0f
#define kBrickInlineViewCanvasOffsetY 0.0f
#define kBrickBackgroundImageNameSuffix @"_bg"

// brick heights
#define kBrickHeight1h @44
#define kBrickHeight2h @71
#define kBrickHeight3h @94
#define kBrickHeightControl1h @62
#define kBrickHeightControl2h @88

#define kBrickLabelFontSize 16.0f
#define kBrickTextFieldFontSize 15.0f
#define kBrickInputFieldHeight 28.0f
#define kBrickInputFieldMinWidth 60.0f
#define kBrickComboBoxWidth 210.0f
#define kBrickInputFieldTopMargin 4.0f
#define kBrickInputFieldBottomMargin 5.0f
#define kBrickInputFieldLeftMargin 4.0f
#define kBrickInputFieldRightMargin 4.0f
#define kBrickInputFieldMinRowHeight (kBrickInputFieldHeight + 4.0f)
#define kDefaultImageCellBorderWidth 1.0f

// delete button bricks
#define kBrickDeleteButtonSize 22.0f

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
    kIfElseBrick = 9,
    kIfEndBrick = 10,
    kRepeatBrick = 11,
    kLoopEndBrick = 12
};

// Note:
// -----------------------------------------------------------------------------------------------------------
// \n                  ... NewLine
// {INT;range=(X,Y)}   ... UITextField (NSInteger), inf ... infinite
// {FLOAT;range=(X,Y)} ... UITextField (float), inf ... infinite
// {MESSAGE}           ... UIPicker (select message)
// {OBJECT}            ... UIPicker (select object)
// {SOUND}             ... UIPicker (select sound)
// {LOOK}              ... UIPicker (select sound)
// {VARIABLE}          ... UIPicker (select variable)
// {TEXT}              ... UITextField (NSString)

// Examples for possible ranges:
// {FLOAT;range=(inf, 0.0f]} ... All negative float numbers including (!) zero
// {FLOAT;range=(inf, 0.0f)} ... All negative float numbers excluding (!) zero
// {INT;range=(0, 11]}       ... All positive integer numbers 1-11
// {INT;range=[0, 11)}       ... All positive integer numbers 0-10

#define kControlBrickNames @[\
    kBrickCellControlTitleWhenProgramStarted,\
    kBrickCellControlTitleWhenTapped,\
    kBrickCellControlTitleWait,\
    kBrickCellControlTitleWhenIReceive,\
    kBrickCellControlTitleBroadcast,\
    kBrickCellControlTitleBroadcastAndWait,\
    kBrickCellControlTitleNote,\
    kBrickCellControlTitleForever,\
    kBrickCellControlTitleIf,\
    kBrickCellControlTitleElse,\
    kBrickCellControlTitleEndIf,\
    kBrickCellControlTitleRepeat,\
    kBrickCellControlTitleEndOfLoop\
]

#define kControlBrickNameParams @[\
    @[],                            /* program started */\
    @[],                            /* tapped          */\
    @"{FLOAT;range=(0.0f,inf)}",    /* wait            */\
    @"{MESSAGE}",                   /* receive         */\
    @"{MESSAGE}",                   /* broadcast       */\
    @"{MESSAGE}",                   /* broadcast wait  */\
    @"{TEXT}",                      /* note            */\
    @[],                            /* forever         */\
    @"{FLOAT;range=(-inf,inf)}",    /* if              */\
    @[],                            /* else            */\
    @[],                            /* if end          */\
    @"{INT;range=[0,inf)}",         /* repeat          */\
    @[]                             /* loop end        */\
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
    @"brick_orange_1h",    /* else            */\
    @"brick_orange_1h",    /* if end          */\
    @"brick_orange_1h",    /* repeat          */\
    @"brick_orange_1h"     /* loop end        */\
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
    kBrickHeight1h,        /* else            */\
    kBrickHeight1h,        /* if end          */\
    kBrickHeight1h,        /* repeat          */\
    kBrickHeight1h         /* loop end        */\
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
    kBrickCellMotionTitlePlaceAt,\
    kBrickCellMotionTitleSetX,\
    kBrickCellMotionTitleSetY,\
    kBrickCellMotionTitleChangeX,\
    kBrickCellMotionTitleChangeY,\
    kBrickCellMotionTitleIfOnEdgeBounce,\
    kBrickCellMotionTitleMoveNSteps,\
    kBrickCellMotionTitleTurnLeft,\
    kBrickCellMotionTitleTurnRight,\
    kBrickCellMotionTitlePointInDirection,\
    kBrickCellMotionTitlePointTowards,\
    kBrickCellMotionTitleGlideTo,\
    kBrickCellMotionTitleGoNStepsBack,\
    kBrickCellMotionTitleComeToFront\
]

#define kMotionBrickNameParams @[\
    @[@"{FLOAT;range=(-inf,inf)}", @"{FLOAT;range=(-inf,inf)}"], /* place at           */\
    @"{FLOAT;range=(-inf,inf)}",                                 /* set X              */\
    @"{FLOAT;range=(-inf,inf)}",                                 /* set Y              */\
    @"{FLOAT;range=(-inf,inf)}",                                 /* change X by N      */\
    @"{FLOAT;range=(-inf,inf)}",                                 /* change Y by N      */\
    @[],                                                         /* if on edge bounce  */\
    @"{INT;range=[0,inf)}",                                      /* move N steps       */\
    @"{FLOAT;range=(-inf,inf)}",                                 /* turn left          */\
    @"{FLOAT;range=(-inf,inf)}",                                 /* turn right         */\
    @"{FLOAT;range=(-inf,inf)}",                                 /* point in direction */\
    @"{OBJECT}",                                                 /* point to brick     */\
    @[@"{FLOAT;range=(0,inf)}", @"{FLOAT;range=(-inf,inf)}", @"{FLOAT;range=(-inf,inf)}"], /* glide to brick     */\
    @"{INT;range=[0,inf)}",                                      /* go N steps back    */\
    @[]                                                          /* come to front      */\
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
    kChangeVolumeByNBrick = 3,
    kSpeakBrick = 4
};

#define kSoundBrickNames @[\
    kBrickCellSoundTitlePlaySound,\
    kBrickCellSoundTitleStopAllSounds,\
    kBrickCellSoundTitleSetVolumeTo,\
    kBrickCellSoundTitleChangeVolumeByN,\
    kBrickCellSoundTitleSpeak\
]

#define kSoundBrickNameParams @[\
    @"{SOUND}",                     /* play sound         */\
    @[],                            /* stop all sounds    */\
    @"{FLOAT;range=(-inf,inf)}",    /* set volume to      */\
    @"{FLOAT;range=(-inf,inf)}",    /* change volume to   */\
    @"{TEXT}"                       /* speak              */\
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
    kSetLookBrick = 0,
    kNextLookBrick = 1,
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
    kBrickCellLookTitleSetLook,\
    kBrickCellLookTitleNextLook,\
    kBrickCellLookTitleSetSizeTo,\
    kBrickCellLookTitleChangeSizeByN,\
    kBrickCellLookTitleHide,\
    kBrickCellLookTitleShow,\
    kBrickCellLookTitleSetGhostEffect,\
    kBrickCellLookTitleChangeGhostEffectByN,\
    kBrickCellLookTitleSetBrightness,\
    kBrickCellLookTitleChangeBrightnessByN,\
    kBrickCellLookTitleClearGraphicEffect\
]

#define kLookBrickNameParams @[\
    @"{LOOK}",                      /* set background           */\
    @[],                            /* next background          */\
    @"{FLOAT;range=(-inf,inf)}",    /* set size to              */\
    @"{FLOAT;range=(-inf,inf)}",    /* change size by N         */\
    @[],                            /* hide                     */\
    @[],                            /* show                     */\
    @"{FLOAT;range=(-inf,inf)}",    /* set ghost effect         */\
    @"{FLOAT;range=(-inf,inf)}",    /* change ghost effect by N */\
    @"{FLOAT;range=(-inf,inf)}",    /* set brightness           */\
    @"{FLOAT;range=(-inf,inf)}",    /* change brightness by N   */\
    @[]                             /* clear graphic effect     */\
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
    kBrickCellVariableTitleSetVariable,\
    kBrickCellVariableTitleChangeVariable\
]

#define kVariableBrickNameParams @[\
    @[@"{VARIABLE}",@"{FLOAT;range=(-inf,inf)}"],    /* set size to              */\
    @[@"{VARIABLE}",@"{FLOAT;range=(-inf,inf)}"]     /* change size by N         */\
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

// bricks that are note shown in BricksCollectionViewController, because they are dependent on other bricks
#define kUnselectableBricksObject @[\
    @[@(kIfElseBrick), @(kIfEndBrick), @(kLoopEndBrick)], /* control bricks  */\
    @[],                                                  /* motion bricks   */\
    @[],                                                  /* sound bricks    */\
    @[],                                                  /* look bricks     */\
    @[]                                                   /* variable bricks */\
]

#define kUnselectableBricksBackgroundObject @[\
    @[@(kIfElseBrick), @(kIfEndBrick), @(kLoopEndBrick)], /* control bricks  */\
    @[@(kIfOnEdgeBounceBrick), @(kGoNStepsBackBrick), @(kComeToFrontBrick)], /* motion bricks   */\
    @[],                                                  /* sound bricks    */\
    @[],                                                  /* look bricks     */\
    @[]                                                   /* variable bricks */\
]

#define kBrickModifiedTitlesForBackgroundObject @[\
    @{},                                                  /* control bricks  */\
    @{},                                                  /* motion bricks   */\
    @{},                                                  /* sound bricks    */\
    @{@(kSetLookBrick) : kBrickCellLookTitleSetBackground, @(kNextLookBrick) : kBrickCellLookTitleNextBackground }, /* look bricks     */\
    @{}                                                   /* variable bricks */\
]

#define kClassNameBrickNameMap @{\
    /* control bricks */\
    @"StartScript"               : @{@"categoryType" : @(kControlBrick), @"brickType" : @(kProgramStartedBrick)},\
    @"WhenScript"                : @{@"categoryType" : @(kControlBrick), @"brickType" : @(kTappedBrick)},\
    @"WaitBrick"                 : @{@"categoryType" : @(kControlBrick), @"brickType" : @(kWaitBrick)},\
    @"BroadcastScript"           : @{@"categoryType" : @(kControlBrick), @"brickType" : @(kReceiveBrick)},\
    @"BroadcastBrick"            : @{@"categoryType" : @(kControlBrick), @"brickType" : @(kBroadcastBrick)},\
    @"BroadcastWaitBrick"        : @{@"categoryType" : @(kControlBrick), @"brickType" : @(kBroadcastWaitBrick)},\
    @"NoteBrick"                 : @{@"categoryType" : @(kControlBrick), @"brickType" : @(kNoteBrick)},\
    @"ForeverBrick"              : @{@"categoryType" : @(kControlBrick), @"brickType" : @(kForeverBrick)},\
    @"IfLogicBeginBrick"         : @{@"categoryType" : @(kControlBrick), @"brickType" : @(kIfBrick)},\
    @"IfLogicElseBrick"          : @{@"categoryType" : @(kControlBrick), @"brickType" : @(kIfElseBrick)},\
    @"IfLogicEndBrick"           : @{@"categoryType" : @(kControlBrick), @"brickType" : @(kIfEndBrick)},\
    @"RepeatBrick"               : @{@"categoryType" : @(kControlBrick), @"brickType" : @(kRepeatBrick)},\
    @"LoopEndBrick"              : @{@"categoryType" : @(kControlBrick), @"brickType" : @(kLoopEndBrick)},\
    /* motion bricks */\
    @"PlaceAtBrick"              : @{@"categoryType" : @(kMotionBrick),  @"brickType" : @(kPlaceAtBrick)},\
    @"SetXBrick"                 : @{@"categoryType" : @(kMotionBrick),  @"brickType" : @(kSetXBrick)},\
    @"SetYBrick"                 : @{@"categoryType" : @(kMotionBrick),  @"brickType" : @(kSetYBrick)},\
    @"ChangeXByNBrick"           : @{@"categoryType" : @(kMotionBrick),  @"brickType" : @(kChangeXByNBrick)},\
    @"ChangeYByNBrick"           : @{@"categoryType" : @(kMotionBrick),  @"brickType" : @(kChangeYByNBrick)},\
    @"IfOnEdgeBounceBrick"       : @{@"categoryType" : @(kMotionBrick),  @"brickType" : @(kIfOnEdgeBounceBrick)},\
    @"MoveNStepsBrick"           : @{@"categoryType" : @(kMotionBrick),  @"brickType" : @(kMoveNStepsBrick)},\
    @"TurnLeftBrick"             : @{@"categoryType" : @(kMotionBrick),  @"brickType" : @(kTurnLeftBrick)},\
    @"TurnRightBrick"            : @{@"categoryType" : @(kMotionBrick),  @"brickType" : @(kTurnRightBrick)},\
    @"PointInDirectionBrick"     : @{@"categoryType" : @(kMotionBrick),  @"brickType" : @(kPointInDirectionBrick)},\
    @"PointToBrick"              : @{@"categoryType" : @(kMotionBrick),  @"brickType" : @(kPointToBrick)},\
    @"GlideToBrick"              : @{@"categoryType" : @(kMotionBrick),  @"brickType" : @(kGlideToBrick)},\
    @"GoNStepsBackBrick"         : @{@"categoryType" : @(kMotionBrick),  @"brickType" : @(kGoNStepsBackBrick)},\
    @"ComeToFrontBrick"          : @{@"categoryType" : @(kMotionBrick),  @"brickType" : @(kComeToFrontBrick)},\
    /* sound bricks */\
    @"PlaySoundBrick"            : @{@"categoryType" : @(kSoundBrick),   @"brickType" : @(kPlaySoundBrick)},\
    @"StopAllSoundsBrick"        : @{@"categoryType" : @(kSoundBrick),   @"brickType" : @(kStopAllSoundsBrick)},\
    @"SetVolumeToBrick"          : @{@"categoryType" : @(kSoundBrick),   @"brickType" : @(kSetVolumeToBrick)},\
    @"ChangeVolumeByNBrick"      : @{@"categoryType" : @(kSoundBrick),   @"brickType" : @(kChangeVolumeByNBrick)},\
    @"SpeakBrick"                : @{@"categoryType" : @(kSoundBrick),   @"brickType" : @(kSpeakBrick)},\
    /* look bricks */\
    @"SetLookBrick"              : @{@"categoryType" : @(kLookBrick),    @"brickType" : @(kSetLookBrick)},\
    @"NextLookBrick"             : @{@"categoryType" : @(kLookBrick),    @"brickType" : @(kNextLookBrick)},\
    @"SetSizeToBrick"            : @{@"categoryType" : @(kLookBrick),    @"brickType" : @(kSetSizeToBrick)},\
    @"ChangeSizeByNBrick"        : @{@"categoryType" : @(kLookBrick),    @"brickType" : @(kChangeSizeByNBrick)},\
    @"HideBrick"                 : @{@"categoryType" : @(kLookBrick),    @"brickType" : @(kHideBrick)},\
    @"ShowBrick"                 : @{@"categoryType" : @(kLookBrick),    @"brickType" : @(kShowBrick)},\
    @"SetGhostEffectBrick"       : @{@"categoryType" : @(kLookBrick),    @"brickType" : @(kSetGhostEffectBrick)},\
    @"ChangeGhostEffectByNBrick" : @{@"categoryType" : @(kLookBrick),    @"brickType" : @(kChangeGhostEffectByNBrick)},\
    @"SetBrightnessBrick"        : @{@"categoryType" : @(kLookBrick),    @"brickType" : @(kSetBrightnessBrick)},\
    @"ChangeBrightnessByNBrick"  : @{@"categoryType" : @(kLookBrick),    @"brickType" : @(kChangeBrightnessByNBrick)},\
    @"ClearGraphicEffectBrick"   : @{@"categoryType" : @(kLookBrick),    @"brickType" : @(kClearGraphicEffectBrick)},\
    /* look bricks */\
    @"SetVariableBrick"          : @{@"categoryType" : @(kVariableBrick),@"brickType" : @(kSetVariableBrick)},\
    @"ChangeVariableBrick"       : @{@"categoryType" : @(kVariableBrick),@"brickType" : @(kChangeVariableBrick)}\
}

// ----------------- REFACTOR END -------------------

// Notifications
static NSString *const kBrickCellAddedNotification = @"BrickCellAddedNotification";
static NSString *const kSoundAddedNotification = @"SoundAddedNotification";
static NSString *const kBrickDetailViewDismissed = @"kBrickDetailViewDismissed";

// Notification keys
static NSString *const kUserInfoKeyBrickCell = @"UserInfoKeyBrickCell";
static NSString *const kUserInfoSpriteObject = @"UserInfoSpriteObject";
static NSString *const kUserInfoSound = @"UserInfoSound";

// UI Elements
#define NAVIGATION_BAR_HEIGHT 64
#define STATUS_BAR_HEIGHT 10

static NSString *const kSelectionMenuTitle = @"Select Brick Category";
