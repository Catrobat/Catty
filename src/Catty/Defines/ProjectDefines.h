/**
 *  Copyright (C) 2010-2022 The Catrobat Team
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

#define kLengthOfShortCommitHash 7
#define kLastUsedProject @"lastUsedProject"
#define kMinLoopDurationTime (20 * 1000 * 1000) // in nanoseconds!
#define kProjectCodeFileName @"code.xml"
#define kProjectSoundsDirName @"sounds"
#define kProjectImagesDirName @"images"
#define kProjectsFolder @".projects"
#define kResourceFileNameSeparator @"_" // [md5]_[fileName] e.g. D32285BE8042D8D8071FAF0A33054DD0_music.mp3                                      //         or for images: 34A109A82231694B6FE09C216B390570_normalCat
#define kLocalizedMyImageExtension @"png"
#define kPreviewThumbnailWidth 160
#define kPreviewThumbnailHeight 160
#define kMinNumOfObjects 0
#define kDefaultNumOfObjects 0
#define kBackgroundObjects 1

#define kMinNumOfProjectNameCharacters 1
#if DEBUG
#define kMaxNumOfProjectNameCharacters 25
#else
#define kMaxNumOfProjectNameCharacters 250
#endif

#define kMinNumOfObjectNameCharacters 1
#if DEBUG
#define kMaxNumOfObjectNameCharacters 25
#else
#define kMaxNumOfObjectNameCharacters 250
#endif

#define kMinNumOfLookNameCharacters 1 
#if DEBUG
#define kMaxNumOfLookNameCharacters 25
#else
#define kMaxNumOfLookNameCharacters 250
#endif

#define kMinNumOfSoundNameCharacters 1
#if DEBUG
#define kMaxNumOfSoundNameCharacters 25
#else
#define kMaxNumOfSoundNameCharacters 250
#endif

#define kMinNumOfMessageNameCharacters 1
#if DEBUG
#define kMaxNumOfMessageNameCharacters 25
#else
#define kMaxNumOfMessageNameCharacters 250
#endif

#define kMinNumOfVariableNameCharacters 1
#if DEBUG
#define kMaxNumOfVariableNameCharacters 25
#else
#define kMaxNumOfVariableNameCharacters 250
#endif

#define kNoProjectIDYetPlaceholder @"x"
#define kProjectIDSeparator @"_"

#define kDefaultProjectBundleName @"My first project"
#define kDefaultProjectBundleOtherObjectsNamePrefix @"Mole"

// indexes
#define kNumberOfSectionsInSceneTableViewController 2
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
    kEmbroidery =           1 << 14,
    kInternet =             1 << 15,
    kBodyPoseDetection =    1 << 16,
    kHandPoseDetection =    1 << 17,
    kTextRecognition =      1 << 18,
    kObjectRecognition =    1 << 19,
    kAccelerometerAndDeviceMotion = kAccelerometer | kDeviceMotion, // TODO Pass ResourceType parameters as array (e.g. in "Sensor"),
    kVisualDetection = kFaceDetection | kBodyPoseDetection | kHandPoseDetection | kTextRecognition | kObjectRecognition
};

#define kScreenshotFilename @"screenshot.png"
#define kScreenshotManualFilename @"manual_screenshot.png"
#define kScreenshotAutoFilename @"automatic_screenshot.png"

#define kUserDefaultsBrickSelectionStatisticsMap @"BrickSelectionStatisticsMap"

#define kTrustedDomainFilename @"TrustedDomains"
