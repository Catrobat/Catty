/**
 *  Copyright (C) 2010-2020 The Catrobat Team
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
#define kLastUsedProject @"lastUsedProject"
#define kMinLoopDurationTime (20 * 1000 * 1000) // in nanoseconds!
#define kProjectCodeFileName @"code.xml"
#define kProjectSoundsDirName @"sounds"
#define kProjectImagesDirName @"images"
#define kProjectsFolder @".projects"
#define kResourceFileNameSeparator @"_" // [md5]_[fileName] e.g. D32285BE8042D8D8071FAF0A33054DD0_music.mp3                                      //         or for images: 34A109A82231694B6FE09C216B390570_normalCat
#define kPreviewImageNamePrefix @"small_" // [md5]_small_[fileName] e.g. 34A109A82231694B6FE09C216B390570_small_normalCat
#define kLocalizedMyImageExtension @"png"
#define kPreviewThumbnailWidth 160
#define kPreviewThumbnailHeight 160
#define kMinNumOfObjects 0
#define kDefaultNumOfObjects 0
#define kBackgroundObjects 1
#define kMinNumOfProjectNameCharacters 1
#define kMaxNumOfProjectNameCharacters 250
#define kMinNumOfObjectNameCharacters 1
#define kMaxNumOfObjectNameCharacters 250
#define kMinNumOfLookNameCharacters 1
#define kMaxNumOfLookNameCharacters 250
#define kMinNumOfSoundNameCharacters 1
#define kMaxNumOfSoundNameCharacters 250
#define kMinNumOfMessageNameCharacters 1
#define kMaxNumOfMessageNameCharacters 250
#define kMinNumOfVariableNameCharacters 1
#define kMaxNumOfVariableNameCharacters 250

#define kNoProjectIDYetPlaceholder @"x"
#define kProjectIDSeparator @"_"

#define kDefaultProjectBundleName @"My first project"
#define kDefaultProjectBundleOtherObjectsNamePrefix @"Mole"

// indexes
#define kNumberOfSectionsInProjectTableViewController 2
#define kBackgroundSectionIndex 0
#define kBackgroundObjectIndex 0
#define kObjectSectionIndex 1
#define kObjectIndex 0

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
    kLED =                  1 << 10,
    kCompass =              1 << 11,
    kDeviceMotion =         1 << 12,
    kTouchHandler =         1 << 13,
    kAccelerometerAndDeviceMotion = kAccelerometer | kDeviceMotion // TODO Pass ResourceType parameters as array (e.g. in "Sensor")
};

#define kUserDetailsShowDetailsKey @"showDetails"
#define kUserIsLoggedIn @"userIsLoggedIn"
#define kUserLoginToken @"userLoginToken"
#define kUserIntroductionHasBeenShown @"introductionHasBeenShown"
#define kUserShowIntroductionOnEveryLaunch @"showIntroductionOnEveryLaunch"
#define kUserDetailsShowDetailsObjectsKey @"detailsForObjects"
#define kUserDetailsShowDetailsLooksKey @"detailsForLooks"
#define kUserDetailsShowDetailsSoundsKey @"detailsForSounds"
#define kUserDetailsShowDetailsProjectsKey @"detailsForProjects"
#define kScreenshotThumbnailPrefix @".thumb_"
#define kScreenshotFilename @"screenshot.png"
#define kScreenshotManualFilename @"manual_screenshot.png"
#define kScreenshotAutoFilename @"automatic_screenshot.png"

#define kUserDefaultsBrickSelectionStatisticsMap @"BrickSelectionStatisticsMap"

#define kBubbleBrickNodeName @"textBubble"

