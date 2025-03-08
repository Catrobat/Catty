/**
 *  Copyright (C) 2010-2024 The Catrobat Team
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

// ---------------------- BRICK CONFIG ---------------------------------------
// brick categories
typedef NS_ENUM(NSUInteger, kBrickCategoryType) {
    kEventBrick                = 1,
    kControlBrick              = 2,
    kMotionBrick               = 3,
    kLookBrick                 = 4,
    kSoundBrick                = 5,
    kDataBrick                 = 6,
    kArduinoBrick              = 7,
    kPhiroBrick                = 8,
    kPenBrick                  = 9,
    kEmbroideryBrick           = 10,
    kPlotBrick                 = 11,
    kInvisible                 = 99,
    kRecentlyUsedBricks        = 0
};

typedef NS_ENUM(NSInteger, kBrickShapeType) {
    kBrickShapeSquareSmall = 0,
    kBrickShapeRoundedSmall,
    kBrickShapeRoundedBig
};
