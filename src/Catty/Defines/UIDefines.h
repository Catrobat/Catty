/**
 *  Copyright (C) 2010-2019 The Catrobat Team
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
#define kIphone5ScreenHeight 568.0f
#define kIphone6PScreenHeight 736.0f
#define kIpadScreenHeight 1028.0f

// ScenePresenterViewController
#define kSlidingStartArea 40
#define kFirstSwipeDuration 0.65f
#define kHideMenuViewDelay 0.45f

// Scene

#define kSceneDefaultFont @"Helvetica"
#define kSceneLabelFontSize 45.0f

// Blocked characters for project names, object names, images names, sounds names and variable/list names
#define kTextFieldBlockedCharacters @""

#define kMenuImageNameContinue @"continue"
#define kMenuImageNameNew @"new"
#define kMenuImageNameProjects @"projects"
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
#define kBrickCellDeleteButtonWidthHeight 55.0f
#define kSelectButtonOffset 30.0f
#define kSelectButtonTranslationOffsetX 60.0f
#define kScriptCollectionViewInset 5.0f

// Notifications
static NSString *const kBrickCellAddedNotification = @"BrickCellAddedNotification";
static NSString *const kSoundAddedNotification = @"SoundAddedNotification";
static NSString *const kRecordAddedNotification = @"RecordAddedNotification";
static NSString *const kBrickDetailViewDismissed = @"BrickDetailViewDismissed";
static NSString *const kProjectDownloadedNotification = @"ProjectDownloadedNotification";
static NSString *const kHideLoadingViewNotification = @"HideLoadingViewNotification";
static NSString *const kShowSavedViewNotification = @"ShowSavedViewNotification";
static NSString *const kReadyToUpload = @"ReadyToUploadProject";
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
    kInvisible                = 99,
    kFavouriteBricks           = 0
};

#define kMinFavouriteBrickSize 5
#define kMaxFavouriteBrickSize 10

#define WRAP_UINT_IN_NSNUMBER(number) ([NSNumber numberWithUnsignedInteger:number])
#define kNSNumberZero WRAP_UINT_IN_NSNUMBER(0)

#define kWhenScriptDefaultAction @"Tapped" // at the moment Catrobat only supports this type of action for WhenScripts

typedef NS_ENUM(NSInteger, kBrickShapeType) {
    kBrickShapeSquareSmall = 0,
    kBrickShapeRoundedSmall,
    kBrickShapeRoundedBig
};

// brick heights
#define kBrickHeight1h 55.9f
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
#define kBrickComboBoxWidth [Util screenWidth] - 65
#define kBrickInputFieldTopMargin 4.0f
#define kBrickInputFieldBottomMargin 5.0f
#define kBrickInputFieldLeftMargin 4.0f
#define kBrickInputFieldRightMargin 4.0f
#define kBrickInputFieldMinRowHeight kBrickInputFieldHeight
#define kDefaultImageCellBorderWidth 0.5f
