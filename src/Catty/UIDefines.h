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

// placeholder texts
#define kPlaceHolderTag 99998
#define kLoadingViewTag 99999

#define kIphone5ScreenHeight 568.0f
#define kIphone4ScreenHeight 480.0f
#define kAddScriptCategoryTableViewBottomMargin 15.0f

// ---------------------- BRICK CONFIG ---------------------------------------
// brick categories
typedef NS_ENUM(NSInteger, kBrickCategoryType) {
    kControlBrick              = 0,
    kMotionBrick               = 1,
    kSoundBrick                = 2,
    kLookBrick                 = 3,
    kVariableBrick             = 4
};

// brick type identifiers
typedef NS_ENUM(NSUInteger, kBrickType) {
    // invalid brick type
    kInvalidBrick              = NSUIntegerMax,

    // 0xx control bricks
    kProgramStartedBrick       =   0,
    kTappedBrick               =   1,
    kWaitBrick                 =   2,
    kReceiveBrick              =   3,
    kBroadcastBrick            =   4,
    kBroadcastWaitBrick        =   5,
    kNoteBrick                 =   6,
    kForeverBrick              =   7,
    kIfBrick                   =   8,
    kIfElseBrick               =   9,
    kIfEndBrick                =  10,
    kRepeatBrick               =  11,
    kLoopEndBrick              =  12,

    // 1xx motion bricks
    kPlaceAtBrick              = 100,
    kSetXBrick                 = 101,
    kSetYBrick                 = 102,
    kChangeXByNBrick           = 103,
    kChangeYByNBrick           = 104,
    kIfOnEdgeBounceBrick       = 105,
    kMoveNStepsBrick           = 106,
    kTurnLeftBrick             = 107,
    kTurnRightBrick            = 108,
    kPointInDirectionBrick     = 109,
    kPointToBrick              = 110,
    kGlideToBrick              = 111,
    kGoNStepsBackBrick         = 112,
    kComeToFrontBrick          = 113,

    // 2xx sound bricks
    kPlaySoundBrick            = 200,
    kStopAllSoundsBrick        = 201,
    kSetVolumeToBrick          = 202,
    kChangeVolumeByNBrick      = 203,
    kSpeakBrick                = 204,

    // 3xx look bricks
    kSetLookBrick              = 300,
    kNextLookBrick             = 301,
    kSetSizeToBrick            = 302,
    kChangeSizeByNBrick        = 303,
    kHideBrick                 = 304,
    kShowBrick                 = 305,
    kSetGhostEffectBrick       = 306,
    kChangeGhostEffectByNBrick = 307,
    kSetBrightnessBrick        = 308,
    kChangeBrightnessByNBrick  = 309,
    kClearGraphicEffectBrick   = 310,

    // 4xx variable bricks
    kSetVariableBrick          = 400,
    kChangeVariableBrick       = 401

};

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

// map brick classes to corresponding brick type identifiers
#define kClassNameBrickTypeMap @{\
\
    /* control bricks */\
    @"StartScript"               : @(kProgramStartedBrick),\
    @"WhenScript"                : @(kTappedBrick),\
    @"WaitBrick"                 : @(kWaitBrick),\
    @"BroadcastScript"           : @(kReceiveBrick),\
    @"BroadcastBrick"            : @(kBroadcastBrick),\
    @"BroadcastWaitBrick"        : @(kBroadcastWaitBrick),\
    @"NoteBrick"                 : @(kNoteBrick),\
    @"ForeverBrick"              : @(kForeverBrick),\
    @"IfLogicBeginBrick"         : @(kIfBrick),\
    @"IfLogicElseBrick"          : @(kIfElseBrick),\
    @"IfLogicEndBrick"           : @(kIfEndBrick),\
    @"RepeatBrick"               : @(kRepeatBrick),\
    @"LoopEndBrick"              : @(kLoopEndBrick),\
\
    /* motion bricks */\
    @"PlaceAtBrick"              : @(kPlaceAtBrick),\
    @"SetXBrick"                 : @(kSetXBrick),\
    @"SetYBrick"                 : @(kSetYBrick),\
    @"ChangeXByNBrick"           : @(kChangeXByNBrick),\
    @"ChangeYByNBrick"           : @(kChangeYByNBrick),\
    @"IfOnEdgeBounceBrick"       : @(kIfOnEdgeBounceBrick),\
    @"MoveNStepsBrick"           : @(kMoveNStepsBrick),\
    @"TurnLeftBrick"             : @(kTurnLeftBrick),\
    @"TurnRightBrick"            : @(kTurnRightBrick),\
    @"PointInDirectionBrick"     : @(kPointInDirectionBrick),\
    @"PointToBrick"              : @(kPointToBrick),\
    @"GlideToBrick"              : @(kGlideToBrick),\
    @"GoNStepsBackBrick"         : @(kGoNStepsBackBrick),\
    @"ComeToFrontBrick"          : @(kComeToFrontBrick),\
\
    /* sound bricks */\
    @"PlaySoundBrick"            : @(kPlaySoundBrick),\
    @"StopAllSoundsBrick"        : @(kStopAllSoundsBrick),\
    @"SetVolumeToBrick"          : @(kSetVolumeToBrick),\
    @"ChangeVolumeByNBrick"      : @(kChangeVolumeByNBrick),\
    @"SpeakBrick"                : @(kSpeakBrick),\
\
    /* look bricks */\
    @"SetLookBrick"              : @(kSetLookBrick),\
    @"NextLookBrick"             : @(kNextLookBrick),\
    @"SetSizeToBrick"            : @(kSetSizeToBrick),\
    @"ChangeSizeByNBrick"        : @(kChangeSizeByNBrick),\
    @"HideBrick"                 : @(kHideBrick),\
    @"ShowBrick"                 : @(kShowBrick),\
    @"SetGhostEffectBrick"       : @(kSetGhostEffectBrick),\
    @"ChangeGhostEffectByNBrick" : @(kChangeGhostEffectByNBrick),\
    @"SetBrightnessBrick"        : @(kSetBrightnessBrick),\
    @"ChangeBrightnessByNBrick"  : @(kChangeBrightnessByNBrick),\
    @"ClearGraphicEffectBrick"   : @(kClearGraphicEffectBrick),\
\
    /* variable bricks */\
    @"SetVariableBrick"          : @(kSetVariableBrick),\
    @"ChangeVariableBrick"       : @(kChangeVariableBrick)\
}

typedef NS_ENUM(NSInteger, kBrickShapeType) {
    kBrickShapeNormal = 0,
    kBrickShapeRoundedSmall = 1,
    kBrickShapeRoundedBig = 2
};

// brick heights
#define kBrickHeight1h 44.0f
#define kBrickHeight2h 71.0f
#define kBrickHeight3h 94.0f
#define kBrickHeightControl1h 62.0f
#define kBrickHeightControl2h 88.0f

// ----------------- REFACTOR BEGIN -------------------

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

// motion bricks
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

// sound bricks
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

// look bricks
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

// variable bricks
#define kVariableBrickNameParams @[\
    @[@"{VARIABLE}",@"{FLOAT;range=(-inf,inf)}"],    /* set size to              */\
    @[@"{VARIABLE}",@"{FLOAT;range=(-inf,inf)}"]     /* change size by N         */\
]

#define kVariableBrickImageNames @[\
    @"brick_red_3h",       /* set variable    */\
    @"brick_red_3h"        /* change variable */\
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

// ----------------- REFACTOR END -------------------

// Notifications
static NSString *const kBrickCellAddedNotification = @"BrickCellAddedNotification";
static NSString *const kSoundAddedNotification = @"SoundAddedNotification";
static NSString *const kBrickDetailViewDismissed = @"kBrickDetailViewDismissed";

// Notification keys
static NSString *const kUserInfoKeyBrickCell = @"UserInfoKeyBrickCell";
static NSString *const kUserInfoSpriteObject = @"UserInfoSpriteObject";
static NSString *const kUserInfoSound = @"UserInfoSound";
