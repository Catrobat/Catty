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

#define kSirenUpdateIntervallImmediately 0
#define kSirenUpdateIntervallDaily 1
#define kSirenUpdateIntervallWeekly 7
#define kSirenAlertTypeForce 1
#define kSirenAlertTypeOption 2
#define kSirenAlertTypeSkip 3
#define kSirenAlertTypeNone 4

#define kLengthOfShortCommitHash 7
#define kLastUsedProgram @"lastUsedProgram"
#define kMinLoopDurationTime (20 * 1000 * 1000) // in nanoseconds!
#define kProgramCodeFileName @"code.xml"
#define kProgramSoundsDirName @"sounds"
#define kProgramImagesDirName @"images"
#define kProgramsFolder @".programs"
#define kResourceFileNameSeparator @"_" // [md5]_[fileName] e.g. D32285BE8042D8D8071FAF0A33054DD0_music.mp3                                      //         or for images: 34A109A82231694B6FE09C216B390570_normalCat
#define kPreviewImageNamePrefix @"small_" // [md5]_small_[fileName] e.g. 34A109A82231694B6FE09C216B390570_small_normalCat
#define kLocalizedMyImageExtension @"png"
#define kPreviewImageWidth 160
#define kPreviewImageHeight 160
#define kMinNumOfObjects 0
#define kDefaultNumOfObjects 0
#define kBackgroundObjects 1
#define kMinNumOfProgramNameCharacters 1
#define kMaxNumOfProgramNameCharacters 250
#define kMinNumOfProgramDescriptionCharacters 1
#define kMaxNumOfProgramDescriptionCharacters 400
#define kMinNumOfObjectNameCharacters 1
#define kMaxNumOfObjectNameCharacters 150
#define kMinNumOfLookNameCharacters 1
#define kMaxNumOfLookNameCharacters 150
#define kMinNumOfSoundNameCharacters 1
#define kMaxNumOfSoundNameCharacters 150
#define kMinNumOfMessageNameCharacters 1
#define kMaxNumOfMessageNameCharacters 20
#define kMinNumOfVariableNameCharacters 1
#define kMaxNumOfVariableNameCharacters 15

#define kNoProgramIDYetPlaceholder @"x"
#define kProgramIDSeparator @"_"

#define kDefaultProgramBundleName @"My first program"
#define kDefaultProgramBundleOtherObjectsNamePrefix @"Mole"

// indexes
#define kNumberOfSectionsInProgramTableViewController 2
#define kBackgroundSectionIndex 0
#define kBackgroundObjectIndex 0
#define kObjectSectionIndex 1
#define kObjectIndex 0

typedef NS_ENUM(NSUInteger, kDTMActionType) {
    kDTMActionAskUserForUniqueName = 0,
    kDTMActionEditProgram,
    kDTMActionEditObject,
    kDTMActionEditLook,
    kDTMActionEditSound,
    kDTMActionEditBrickOrScript,
    kDTMActionReportMessage,
    kDTMActionVariableName
};

typedef NS_ENUM(NSInteger, ResourceType) {
    kNoResources =          0,
    kTextToSpeech =         1 << 0,
    kBluetoothPhiro =       1 << 1,
    kBluetoothArduino =     1 << 2,
    kFaceDetection =        1 << 3,
    kVibration =            1 << 4,
    kLocation =             1 << 5,
    kAccelerometer =        1 << 6,
    kGyro =                 1 << 7,
    kMagnetometer =         1 << 8,
    kLoudness =             1 << 9,
    kLED =                  1 << 10
};

#define kDTPayloadProgramLoadingInfo @"DTPayloadProgramLoadingInfo"
#define kDTPayloadSpriteObject @"DTPayloadSpriteObject"
#define kDTPayloadLook @"DTPayloadLook"
#define kDTPayloadSound @"DTPayloadSound"
#define kDTPayloadCellIndexPath @"DTPayloadCellIndexPath"
#define kDTPayloadAskUserAction @"DTPayloadAskUserAction"
#define kDTPayloadAskUserTarget @"DTPayloadAskUserTarget"
#define kDTPayloadAskUserObject @"DTPayloadAskUserObject"
#define kDTPayloadAskUserPromptTitle @"DTPayloadAskUserPromptTitle"
#define kDTPayloadAskUserPromptMessage @"DTPayloadAskUserPromptMessage"
#define kDTPayloadAskUserPromptValue @"DTPayloadAskUserPromptValue"
#define kDTPayloadAskUserPromptPlaceholder @"DTPayloadAskUserPromptPlaceholder"
#define kDTPayloadAskUserMinInputLength @"DTPayloadAskUserMinInputLength"
#define kDTPayloadAskUserMaxInputLength @"DTPayloadAskUserMaxInputLength"
#define kDTPayloadAskUserInvalidInputAlertMessage @"DTPayloadAskUserInvalidInputAlertMessage"
#define kDTPayloadAskUserExistingNames @"DTPayloadAskUserExistingNames"
#define kDTPayloadTextView @"DTPayloadTextView"
#define kDTPayloadCancel @"DTPayloadCancel"

#define kUserDetailsShowDetailsKey @"showDetails"
#define kUserIsFirstAppLaunch @"isFirstAppLaunch"
#define kUserIsLoggedIn @"userIsLoggedIn"
#define kUserLoginToken @"userLoginToken"
#define kUserShowIntroductionOnLaunch @"showIntroductionOnLaunch"
#define kUserDetailsShowDetailsObjectsKey @"detailsForObjects"
#define kUserDetailsShowDetailsLooksKey @"detailsForLooks"
#define kUserDetailsShowDetailsSoundsKey @"detailsForSounds"
#define kUserDetailsShowDetailsProgramsKey @"detailsForPrograms"
#define kScreenshotThumbnailPrefix @".thumb_"

#define kUserDefaultsBrickSelectionStatisticsMap @"BrickStatisticsMap"
