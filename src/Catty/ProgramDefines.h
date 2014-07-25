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
#define kProgramCodeFileName @"code.xml"
#define kProgramSoundsDirName @"sounds"
#define kProgramImagesDirName @"images"
#define kProgramsFolder @".programs"
#define kResourceFileNameSeparator @"_" // [md5]_[fileName] e.g. D32285BE8042D8D8071FAF0A33054DD0_music.mp3                                      //         or for images: 34A109A82231694B6FE09C216B390570_normalCat
#define kPreviewImageNamePrefix @"small_" // [md5]_small_[fileName] e.g. 34A109A82231694B6FE09C216B390570_small_normalCat
#define kDefaultImportedImageNameExtension @"png"
#define kPreviewImageWidth 160
#define kPreviewImageHeight 160
#define kMinNumOfObjects 0
#define kDefaultNumOfObjects 1
#define kBackgroundObjects 1
#define kMinNumOfProgramNameCharacters 1
#define kMaxNumOfProgramNameCharacters 20
#define kMinNumOfProgramDescriptionCharacters 1
#define kMaxNumOfProgramDescriptionCharacters 400
#define kMinNumOfObjectNameCharacters 1
#define kMaxNumOfObjectNameCharacters 20
#define kMinNumOfLookNameCharacters 1
#define kMaxNumOfLookNameCharacters 20
#define kMinNumOfSoundNameCharacters 1
#define kMaxNumOfSoundNameCharacters 20

#define kDefaultProgramName @"My First Program"

// indexes
#define kNumberOfSectionsInProgramTableViewController 2
#define kBackgroundSectionIndex 0
#define kBackgroundObjectIndex 0
#define kObjectSectionIndex 1
#define kObjectIndex 0

typedef NS_ENUM(NSUInteger, kDTMActionType) {
    kDTMActionAskUserForUniqueName = 0,
    kDTMActionEditProgram = 1,
    kDTMActionEditObject = 2,
    kDTMActionEditLook = 3,
    kDTMActionEditSound = 4
};

#define kDTPayloadProgramLoadingInfo @"DTPayloadProgramLoadingInfo"
#define kDTPayloadSpriteObject @"DTPayloadSpriteObject"
#define kDTPayloadLook @"DTPayloadLook"
#define kDTPayloadSound @"DTPayloadSound"
#define kDTPayloadAskUserAction @"DTPayloadAskUserAction"
#define kDTPayloadAskUserTarget @"DTPayloadAskUserTarget"
#define kDTPayloadAskUserObject @"DTPayloadAskUserObject"
#define kDTPayloadAskUserPromptTitle @"DTPayloadAskUserPromptTitle"
#define kDTPayloadAskUserPromptMessage @"DTPayloadAskUserPromptMessage"
#define kDTPayloadAskUserPromptValue @"DTPayloadAskUserPromptValue"
#define kDTPayloadAskUserPromptPlaceholder @"DTPayloadAskUserPromptPlaceholder"
#define kDTPayloadAskUserMinInputLength @"DTPayloadAskUserMinInputLength"
#define kDTPayloadAskUserInvalidInputAlertMessage @"DTPayloadAskUserInvalidInputAlertMessage"
#define kDTPayloadAskUserExistingNames @"DTPayloadAskUserExistingNames"
