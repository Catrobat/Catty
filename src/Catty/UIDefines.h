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

// which characters in program, object, image names do we have to support?
#define kTextFieldAllowedCharacters @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyzäöü_#?!()=+-.:&%$€ 1234567890"

#define IsIPad() UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad
#define IsIPhone() UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone
#define IsIPhone5() ((UIScreen.mainScreen.bounds.size.height - 568) ? NO : YES)

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

// delete button bricks
#define kBrickCellDeleteButtonWidthHeight 22.0f
#define kSelectButtonnOffset 30.0f
#define kSelectButtonTranslationOffsetX 60.0f

#define kScriptCollectionViewTopInsets 10.0f
#define kScriptCollectionViewBottomInsets 5.0f

// Notifications
static NSString *const kBrickCellAddedNotification = @"BrickCellAddedNotification";
static NSString *const kSoundAddedNotification = @"SoundAddedNotification";
static NSString *const kBrickDetailViewDismissed = @"kBrickDetailViewDismissed";

// Notification keys
static NSString *const kUserInfoKeyBrickCell = @"UserInfoKeyBrickCell";
static NSString *const kUserInfoSpriteObject = @"UserInfoSpriteObject";
static NSString *const kUserInfoSound = @"UserInfoSound";

// menu titles
static NSString *const kSelectionMenuTitle = @"Select Brick Category";

// UI Elements
#define kNavigationbarHeight 64.0f
#define kToolbarHeight 44.0f
#define kHandleImageHeight 15.0f
#define kHandleImageWidth 40.0f
#define kOffsetTopBrickSelectionView 70.0f

// ---------------------- BRICK CONFIG ---------------------------------------
// brick categories
typedef NS_ENUM(NSUInteger, kBrickCategoryType) {
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
    [UIColor controlBrickOrangeColor],\
    [UIColor motionBrickBlueColor],\
    [UIColor soundBrickVioletColor],\
    [UIColor lookBrickGreenColor],\
    [UIColor varibaleBrickRedColor]\
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
    kBrickShapeSquareSmall = 0,
    kBrickShapeSquareMedium,
    kBrickShapeSquareBig,
    kBrickShapeRoundedSmall,
    kBrickShapeRoundedBig
};


#define kBrickHeightMap @{\
\
/* control bricks */\
@"StartScript"               : @(kBrickHeightControl1h),\
@"WhenScript"                : @(kBrickHeightControl1h),\
@"WaitBrick"                 : @(kBrickHeight1h),\
@"BroadcastScript"           : @(kBrickHeightControl2h),\
@"BroadcastBrick"            : @(kBrickHeight2h),\
@"BroadcastWaitBrick"        : @(kBrickHeight2h),\
@"NoteBrick"                 : @(kBrickHeight2h),\
@"ForeverBrick"              : @(kBrickHeight1h),\
@"IfLogicBeginBrick"         : @(kBrickHeight1h),\
@"IfLogicElseBrick"          : @(kBrickHeight1h),\
@"IfLogicEndBrick"           : @(kBrickHeight1h),\
@"RepeatBrick"               : @(kBrickHeight1h),\
@"LoopEndBrick"              : @(kBrickHeight1h),\
\
/* motion bricks */\
@"PlaceAtBrick"              : @(kBrickHeight2h),\
@"SetXBrick"                 : @(kBrickHeight1h),\
@"SetYBrick"                 : @(kBrickHeight1h),\
@"ChangeXByNBrick"           : @(kBrickHeight1h),\
@"ChangeYByNBrick"           : @(kBrickHeight1h),\
@"IfOnEdgeBounceBrick"       : @(kBrickHeight1h),\
@"MoveNStepsBrick"           : @(kBrickHeight1h),\
@"TurnLeftBrick"             : @(kBrickHeight1h),\
@"TurnRightBrick"            : @(kBrickHeight1h),\
@"PointInDirectionBrick"     : @(kBrickHeight1h),\
@"PointToBrick"              : @(kBrickHeight2h),\
@"GlideToBrick"              : @(kBrickHeight3h),\
@"GoNStepsBackBrick"         : @(kBrickHeight1h),\
@"ComeToFrontBrick"          : @(kBrickHeight1h),\
\
/* sound bricks */\
@"PlaySoundBrick"            : @(kBrickHeight2h),\
@"StopAllSoundsBrick"        : @(kBrickHeight1h),\
@"SetVolumeToBrick"          : @(kBrickHeight1h),\
@"ChangeVolumeByNBrick"      : @(kBrickHeight1h),\
@"SpeakBrick"                : @(kBrickHeight2h),\
\
/* look bricks */\
@"SetLookBrick"              : @(kBrickHeight2h),\
@"NextLookBrick"             : @(kBrickHeight1h),\
@"SetSizeToBrick"            : @(kBrickHeight1h),\
@"ChangeSizeByNBrick"        : @(kBrickHeight1h),\
@"HideBrick"                 : @(kBrickHeight1h),\
@"ShowBrick"                 : @(kBrickHeight1h),\
@"SetGhostEffectBrick"       : @(kBrickHeight2h),\
@"ChangeGhostEffectByNBrick" : @(kBrickHeight2h),\
@"SetBrightnessBrick"        : @(kBrickHeight2h),\
@"ChangeBrightnessByNBrick"  : @(kBrickHeight2h),\
@"ClearGraphicEffectBrick"   : @(kBrickHeight1h),\
\
/* variable bricks */\
@"SetVariableBrick"          : @(kBrickHeight3h),\
@"ChangeVariableBrick"       : @(kBrickHeight3h)\
}

// brick heights
#define kBrickHeight1h 44.0f
#define kBrickHeight2h 71.0f
#define kBrickHeight3h 94.0f
#define kBrickHeightControl1h 62.0f
#define kBrickHeightControl2h 88.0f

#define kBrickOverlapHeight 4.0f

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
