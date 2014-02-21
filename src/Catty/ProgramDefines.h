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
#define kDefaultProject @"My first Project"
#define kProgramCodeFileName @"code.xml"
#define kProgramSoundsDirName @"sounds"
#define kProgramImagesDirName @"images"
#define kProgramsFolder @"levels"
#define kResourceFileNameSeparator @"_" // [UUID]_[fileName] e.g. D32285BE8042D8D8071FAF0A33054DD0_music.mp3                                      //         or for images: 34A109A82231694B6FE09C216B390570_normalCat
#define kPreviewImageNamePrefix @"small_" // [UUID]_small_[fileName] e.g. 34A109A82231694B6FE09C216B390570_small_normalCat
#define kPreviewImageWidth 160
#define kPreviewImageHeight 160
#define kMinNumOfObjects 1
#define kBackgroundObjects 1

#define kDefaultProgramName NSLocalizedString(@"New Program",@"Default name for new programs")
#define kBackgroundTitle NSLocalizedString(@"Background",@"Title for Background-Section-Header in program view")
#define kObjectTitleSingular NSLocalizedString(@"Object",@"Title for Object-Section-Header in program view (singular)")
#define kObjectTitlePlural NSLocalizedString(@"Objects",@"Title for Object-Section-Header in program view (plural)")
#define kBackgroundObjectName NSLocalizedString(@"Background",@"Title for Background-Object in program view")
#define kDefaultObjectName NSLocalizedString(@"My Object",@"Title for first (default) object in program view")
#define kProgramNamePlaceholder NSLocalizedString(@"Enter your program name here...",@"Placeholder for rename-program-name input field")

// indexes
#define kNumberOfSectionsInProgramTableViewController 2
#define kBackgroundSectionIndex 0
#define kBackgroundObjectIndex 0
#define kObjectSectionIndex 1
#define kObjectIndex 0
