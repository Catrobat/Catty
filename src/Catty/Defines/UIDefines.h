/**
 *  Copyright (C) 2010-2016 The Catrobat Team
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

// Screen Sizes in Points
#define kIphone4ScreenHeight 480.0f
#define kIphone4ScreenWidth 320.0f
#define kIphone5ScreenHeight 568.0f
#define kIphone5ScreenWidth 320.0f
#define kIphone6ScreenHeight 667.0f
#define kIphone6ScreenWidth 375.0f
#define kIphone6PScreenHeight 736.0f
#define kIphone6PScreenWidth 414.0f
#define kIpadScreenHeight 1028.0f
#define kIpadScreenWidth 768.0f
#define kIpadRetinaScreenHeight 2048.0f
#define kIpadRetinaScreenWidth 1536.0f

// CatrobatTableViewController
#define kIconDownsizeFactorIphone4 0.85f

// ScenePresenterViewController
#define kWidthSlideMenu 150
#define kBounceEffect 5
#define kPlaceOfButtons 17
#define kSlidingStartArea 40
#define kContinueButtonSize 85
#define kContinueOffset 15
#define kMenuButtonSize 44
#define kMenuIPhone4GapSize 30
#define kMenuIPhone5GapSize 35
#define kMenuIPhone4ContinueGapSize 40
#define kMenuIPhone5ContinueGapSize 45
#define kMenuLabelWidth 50
#define kMenuLabelHeight 20
#define kPlaceofLabels (kPlaceOfButtons-29)
#define kPlaceofContinueLabel (kPlaceOfButtons)
#define kDontResumeSounds 4
#define kfirstSwipeDuration 0.8f

// XXX: which characters in program, object, image names do we have to support?
#define kTextFieldAllowedCharacters @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyzäöü#?!()[]{}^*|<>£¥=+-.,:;\"'&@%$€ 1234567890"

#define kMenuImageNameContinue @"continue"
#define kMenuImageNameNew @"new"
#define kMenuImageNamePrograms @"programs"
#define kMenuImageNameHelp @"help"
#define kMenuImageNameExplore @"explore"
#define kMenuImageNameUpload @"upload"

// view tags
#define kPlaceHolderTag        99994
#define kLoadingViewTag        99995
#define kSavedViewTag          99996
#define kRegistrationViewTag   99997
#define kLoginViewTag          99998
#define kUploadViewTag         99999

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
static NSString *const kRecordAddedNotification = @"RecordAddedNotification";
static NSString *const kBrickDetailViewDismissed = @"BrickDetailViewDismissed";
static NSString *const kProgramDownloadedNotification = @"ProgramDownloadedNotification";
static NSString *const kHideLoadingViewNotification = @"HideLoadingViewNotification";
static NSString *const kShowSavedViewNotification = @"ShowSavedViewNotification";
static NSString *const kReadyToUpload = @"ReadyToUploadProgram";
static NSString *const kLoggedInNotification = @"LoggedInNotification";

// Notification keys
static NSString *const kUserInfoKeyBrickCell = @"UserInfoKeyBrickCell";
static NSString *const kUserInfoSpriteObject = @"UserInfoSpriteObject";
static NSString *const kUserInfoSound = @"UserInfoSound";

// UI Elements
#define kNavigationbarHeight 64.0f
#define kToolbarHeight 44.0f
#define kHandleImageHeight 15.0f
#define kHandleImageWidth 40.0f
#define kOffsetTopBrickSelectionView 70.0f

//BDKNotifyHUD
#define kBDKNotifyHUDDestinationOpacity 0.3f
#define kBDKNotifyHUDCenterOffsetY (-20.0f)
#define kBDKNotifyHUDPresentationDuration 0.5f
#define kBDKNotifyHUDPresentationSpeed 0.1f
#define kBDKNotifyHUDPaddingTop 30.0f
static NSString *const kBDKNotifyHUDCheckmarkImageName = @"checkmark.png";

#define kFormulaEditorShowResultDuration 4.0f
#define kFormulaEditorTopOffset 64.0f

// ---------------------- BRICK CONFIG ---------------------------------------
// brick categories
typedef NS_ENUM(NSUInteger, kBrickCategoryType) {
    kControlBrick              = 1,
    kMotionBrick               = 2,
    kLookBrick                 = 3,
    kSoundBrick                = 4,
    kVariableBrick             = 5,
    kArduinoBrick              = 6,
    kPhiroBrick                = 7,
    kFavouriteBricks           = 0
};

typedef NS_ENUM(NSUInteger, PageIndexCategoryType) {
    kPageIndexFrequentlyUsed,
    kPageIndexControlBrick,
    kPageIndexMotionBrick,
    kPageIndexLookBrick,
    kPageIndexSoundBrick,
    kPageIndexVariableBrick,
    kPageIndexArduinoBrick,
    kPageIndexPhiroBrick
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
    kVibrationBrick            = 114,
    
    // 2xx look bricks
    kSetLookBrick              = 200,
    kNextLookBrick             = 201,
    kSetSizeToBrick            = 202,
    kChangeSizeByNBrick        = 203,
    kHideBrick                 = 204,
    kShowBrick                 = 205,
    kSetTransparencyBrick      = 206,
    kChangeTransparencyByNBrick= 207,
    kSetBrightnessBrick        = 208,
    kChangeBrightnessByNBrick  = 209,
    kSetColorToBrick           = 210,
    kChangeColorByNBrick       = 211,
    kClearGraphicEffectBrick   = 212,
    kLedOnBrick                = 213,
    kLedOffBrick               = 214,

    
    // 3xx sound bricks
    kPlaySoundBrick            = 300,
    kStopAllSoundsBrick        = 301,
    kSetVolumeToBrick          = 302,
    kChangeVolumeByNBrick      = 303,
    kSpeakBrick                = 304,



    // 4xx variable bricks
    kSetVariableBrick          = 400,
    kChangeVariableBrick       = 401,
    kShowTextBrick             = 402,
    kHideTextBrick             = 403,
    
    // 5xx arduino bricks
    kArduinoSendDigitalValueBrick  = 500,
    kArduinoSendPWMValueBrick = 501,
    
    // 6xx phiro bricks
    kPhiroMotorStopBrick       = 600,
    kPhiroMotorMoveForwardBrick = 601,
    kPhiroMotorMoveBackwardBrick = 602,
    kPhiroPlayToneBrick          = 603,
    kPhiroRGBLightBrick          = 604,
    kPhiroIfLogicBeginBrick         = 605


};

#define kMinFavouriteBrickSize 5
#define kMaxFavouriteBrickSize 10

#define WRAP_BRICK_TYPE_IN_NSSTRING(brick) (WRAP_UINT_IN_NSNUMBER(brick).stringValue)
#define WRAP_UINT_IN_NSNUMBER(number) ([NSNumber numberWithUnsignedInteger:number])
#define kNSNumberZero WRAP_UINT_IN_NSNUMBER(0)

#define kDefaultFavouriteBricksStatisticArray @[\
WRAP_BRICK_TYPE_IN_NSSTRING(kTappedBrick),\
WRAP_BRICK_TYPE_IN_NSSTRING(kForeverBrick),\
WRAP_BRICK_TYPE_IN_NSSTRING(kIfBrick),\
WRAP_BRICK_TYPE_IN_NSSTRING(kPlaceAtBrick),\
WRAP_BRICK_TYPE_IN_NSSTRING(kPlaySoundBrick),\
WRAP_BRICK_TYPE_IN_NSSTRING(kSpeakBrick),\
WRAP_BRICK_TYPE_IN_NSSTRING(kSetLookBrick),\
WRAP_BRICK_TYPE_IN_NSSTRING(kSetVariableBrick),\
WRAP_BRICK_TYPE_IN_NSSTRING(kChangeVariableBrick)\
]

// brick categories
#define kBrickCategoryNames @[\
    kLocalizedControl,\
    kLocalizedMotion,\
    kLocalizedLooks,\
    kLocalizedSound,\
    kLocalizedVariables,\
    kLocalizedPhiro\
]

#define kBrickCategoryColors @[\
    [UIColor controlBrickOrangeColor],\
    [UIColor motionBrickBlueColor],\
    [UIColor lookBrickGreenColor],\
    [UIColor soundBrickVioletColor],\
    [UIColor varibaleBrickRedColor],\
    [UIColor ArduinoBrickColor],\
    [UIColor PhiroBrickColor]\
]

#define kBrickCategoryStrokeColors @[\
    [UIColor controlBrickStrokeColor],\
    [UIColor motionBrickStrokeColor],\
    [UIColor lookBrickStrokeColor],\
    [UIColor soundBrickStrokeColor],\
    [UIColor variableBrickStrokeColor],\
    [UIColor ArduinoBrickStrokeColor],\
    [UIColor PhiroBrickStrokeColor]\
]

#define kWhenScriptDefaultAction @"Tapped" // at the moment Catrobat only supports this type of action for WhenScripts

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
    @"VibrationBrick"            : @(kVibrationBrick),\
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
    @"SetTransparencyBrick"      : @(kSetTransparencyBrick),\
    @"ChangeTransparencyByNBrick": @(kChangeTransparencyByNBrick),\
    @"SetBrightnessBrick"        : @(kSetBrightnessBrick),\
    @"ChangeBrightnessByNBrick"  : @(kChangeBrightnessByNBrick),\
    @"SetColorToBrick"           : @(kSetColorToBrick),\
    @"ChangeColorByNBrick"       : @(kChangeColorByNBrick),\
    @"ClearGraphicEffectBrick"   : @(kClearGraphicEffectBrick),\
    @"LedOnBrick"                : @(kLedOnBrick),\
    @"LedOffBrick"               : @(kLedOffBrick),\
\
    /* variable bricks */\
    @"SetVariableBrick"          : @(kSetVariableBrick),\
    @"ChangeVariableBrick"       : @(kChangeVariableBrick),\
    @"ShowTextBrick"             : @(kShowTextBrick),\
    @"HideTextBrick"             : @(kHideTextBrick),\
\
    /* arduino bricks */\
    @"ArduinoSendDigitalValueBrick" : @(kArduinoSendDigitalValueBrick),\
    @"ArduinoSendPWMValueBrick"     : @(kArduinoSendPWMValueBrick),\
\
    /* phiro bricks */\
    @"PhiroMotorStopBrick"          : @(kPhiroMotorStopBrick),\
    @"PhiroMotorMoveForwardBrick"   : @(kPhiroMotorMoveForwardBrick),\
    @"PhiroMotorMoveBackwardBrick"  : @(kPhiroMotorMoveBackwardBrick),\
    @"PhiroPlayToneBrick"           : @(kPhiroPlayToneBrick),\
    @"PhiroRGBLightBrick"          : @(kPhiroRGBLightBrick),\
    @"PhiroIfLogicBeginBrick"         : @(kPhiroIfLogicBeginBrick)\
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
@"VibrationBrick"            : @(kBrickHeight1h),\
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
@"SetTransparencyBrick"      : @(kBrickHeight2h),\
@"ChangeTransparencyByNBrick": @(kBrickHeight2h),\
@"SetBrightnessBrick"        : @(kBrickHeight2h),\
@"ChangeBrightnessByNBrick"  : @(kBrickHeight2h),\
@"ClearGraphicEffectBrick"   : @(kBrickHeight1h),\
@"LedOnBrick"                : @(kBrickHeight1h),\
@"LedOffBrick"               : @(kBrickHeight1h),\
@"SetColorToBrick"           : @(kBrickHeight1h),\
@"ChangeColorByNBrick"       : @(kBrickHeight1h),\
\
/* variable bricks */\
@"SetVariableBrick"          : @(kBrickHeight3h),\
@"ChangeVariableBrick"       : @(kBrickHeight3h),\
@"ShowTextBrick"             : @(kBrickHeight3h),\
@"HideTextBrick"             : @(kBrickHeight2h),\
\
/* arduino bricks */\
@"ArduinoSendDigitalValueBrick" : @(kBrickHeight2h),\
@"ArduinoSendPWMValueBrick"     : @(kBrickHeight2h),\
\
/* phiro bricks */\
@"PhiroMotorStopBrick"          : @(kBrickHeight2h),\
@"PhiroMotorMoveForwardBrick"   : @(kBrickHeight3h),\
@"PhiroMotorMoveBackwardBrick"  : @(kBrickHeight3h),\
@"PhiroPlayToneBrick"           : @(kBrickHeight3h),\
@"PhiroRGBLightBrick"          : @(kBrickHeight3h),\
@"PhiroIfLogicBeginBrick"          : @(kBrickHeight1h)\
}

// brick heights
#define kBrickHeight1h 48.9f
#define kBrickHeight2h 75.9f
#define kBrickHeight3h 98.9f
#define kBrickHeightControl1h 72.4f
#define kBrickHeightControl2h 99.4f

#define kBrickOverlapHeight -4.4f

// brick subview const values
#define kBrickInlineViewOffsetX 54.0f
#define kBrickShapeNormalInlineViewOffsetY 4.0f
#define kBrickShapeRoundedSmallInlineViewOffsetY 20.7f
#define kBrickShapeRoundedBigInlineViewOffsetY 37.0f
#define kBrickShapeNormalMarginHeightDeduction 14.0f
#define kBrickShapeRoundedSmallMarginHeightDeduction 27.0f
#define kBrickShapeRoundedBigMarginHeightDeduction 47.0f
#define kBrickPatternImageViewOffsetX 0.0f
#define kBrickPatternImageViewOffsetY 0.0f
#define kBrickPatternBackgroundImageViewOffsetX 54.0f
#define kBrickPatternBackgroundImageViewOffsetY 0.0f
#define kBrickLabelOffsetX 0.0f
#define kBrickLabelOffsetY 5.0f
#define kBrickInlineViewCanvasOffsetX 0.0f
#define kBrickInlineViewCanvasOffsetY 0.0f
#define kBrickBackgroundImageNameSuffix @"_bg"

#define kBrickLabelFontSize 15.0f
#define kBrickTextFieldFontSize 15.0f
#define kBrickInputFieldHeight 28.0f
#define kBrickInputFieldMinWidth 40.0f
#define kBrickInputFieldMaxWidth [Util screenWidth]/2.0f
#define kBrickComboBoxWidth [Util screenWidth]/2.0f
#define kBrickInputFieldTopMargin 4.0f
#define kBrickInputFieldBottomMargin 5.0f
#define kBrickInputFieldLeftMargin 4.0f
#define kBrickInputFieldRightMargin 4.0f
#define kBrickInputFieldMinRowHeight (kBrickInputFieldHeight + 4.0f)
#define kDefaultImageCellBorderWidth 0.5f
