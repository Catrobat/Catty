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

#import "BrickManager.h"

@implementation BrickManager

#pragma mark - construction methods
static BrickManager *sharedBrickManager = nil;

+ (BrickManager*)sharedBrickManager
{
    // singletone instance
    @synchronized(self) {
        if (sharedBrickManager == nil) {
            sharedBrickManager = [[BrickManager alloc] init];
        }
    }
    return sharedBrickManager;
}

#pragma mark - helpers
- (NSDictionary*)classNameBrickTypeMap
{
    // save map of kClassNameBrickTypeMap statically
    // for performance reasons
    static NSDictionary *classNameBrickTypeMap = nil;
    if (classNameBrickTypeMap == nil) {
        classNameBrickTypeMap = kClassNameBrickTypeMap;
    }
    return classNameBrickTypeMap;
}

- (NSDictionary*)brickTypeClassNameMap
{
    static NSDictionary *brickTypeClassNameMap = nil;
    // get inverse map of kClassNameBrickTypeMap
    // and save this map statically for performance reasons
    if (brickTypeClassNameMap == nil) {
        NSDictionary *classNameBrickTypeMap = [self classNameBrickTypeMap];
        NSMutableDictionary *brickTypeClassNameMutableMap = nil;
        brickTypeClassNameMap = [NSMutableDictionary
                                 dictionaryWithCapacity:[classNameBrickTypeMap count]];
        for (NSNumber *brickType in classNameBrickTypeMap) {
            [brickTypeClassNameMutableMap setObject:classNameBrickTypeMap[brickType]
                                             forKey:brickType];
        }
        brickTypeClassNameMap = [brickTypeClassNameMutableMap copy];
    }
    return brickTypeClassNameMap;
}

- (kBrickType)brickTypeForClassName:(NSString*)className
{
    NSDictionary *classNameBrickTypeMap = [self classNameBrickTypeMap];
    NSNumber *brickTypeAsNumber = classNameBrickTypeMap[className];
    if (! brickTypeAsNumber) {
        return kInvalidBrick;
    }
    return (kBrickType)[brickTypeAsNumber unsignedIntegerValue];
}

- (kBrickCategoryType)brickCategoryTypeForBrickType:(kBrickType)brickType
{
    return (kBrickCategoryType)(((NSUInteger)brickType) / 100);
}

- (NSString*)classNameForBrickType:(kBrickType)brickType
{
    NSDictionary *brickTypeClassNameMap = [self brickTypeClassNameMap];
    return brickTypeClassNameMap[@(brickType)];
}

- (NSUInteger)numberOfAvailableBricksForCategoryType:(kBrickCategoryType)categoryType
{
    switch (categoryType) {
        case kControlBrick:
            return [kControlBrickHeights count];
        case kMotionBrick:
            return [kMotionBrickHeights count];
        case kSoundBrick:
            return [kSoundBrickHeights count];
        case kLookBrick:
            return [kLookBrickHeights count];
        case kVariableBrick:
            return [kVariableBrickHeights count];
        default:
            break;
    }
    return 0;
}

- (BOOL)isScriptBrickForBrickType:(kBrickType)brickType
{
    kBrickCategoryType categoryType = (kBrickCategoryType)(((NSUInteger)brickType) / 100);
    if (categoryType == kControlBrick) {
        switch (brickType) {
            case kProgramStartedBrick:
            case kTappedBrick:
            case kReceiveBrick:
                return YES;
            default:
                break;
        }
    }
    return NO;
}

- (kBrickType)brickTypeForCategoryType:(kBrickCategoryType)categoryType andBrickIndex:(NSUInteger)index
{
    return (kBrickType)(categoryType * 100 + index);
}

- (NSUInteger)brickIndexForBrickType:(kBrickType)brickType
{
    return (brickType % 100);
}

@end
