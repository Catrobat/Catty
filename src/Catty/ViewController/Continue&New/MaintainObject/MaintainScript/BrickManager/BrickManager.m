/**
 *  Copyright (C) 2010-2018 The Catrobat Team
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
#import "BrickProtocol.h"
#import "BrickFormulaProtocol.h"
#import "WhenScript.h"
#import "LoopEndBrick.h"
#import "LoopBeginBrick.h"
#import "IfLogicBeginBrick.h"
#import "IfThenLogicEndBrick.h"
#import "IfThenLogicBeginBrick.h"
#import "IfLogicElseBrick.h"
#import "IfLogicEndBrick.h"
#import "CBMutableCopyContext.h"
#import "ForeverBrick.h"

@implementation BrickManager {
    NSDictionary *_brickHeightDictionary;
}

#pragma mark - construction methods
+ (instancetype)sharedBrickManager
{
    static BrickManager *_sharedCattyBrickManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ _sharedCattyBrickManager = [BrickManager new]; });
    return _sharedCattyBrickManager;
}

- (id)init
{
    self = [super init];
    if (self) {
        _brickHeightDictionary = kBrickHeightMap;
    }
    return self;
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
    // get inverse map of kClassNameBrickTypeMap
    // and save this map statically for performance reasons
    static NSDictionary *brickTypeClassNameMap = nil;
    if (brickTypeClassNameMap == nil) {
        NSDictionary *classNameBrickTypeMap = [self classNameBrickTypeMap];
        NSMutableDictionary *brickTypeClassNameMutableMap = [NSMutableDictionary
                                                             dictionaryWithCapacity:[classNameBrickTypeMap count]];
        for (NSString *className in classNameBrickTypeMap) {
            [brickTypeClassNameMutableMap setObject:className
                                             forKey:classNameBrickTypeMap[className]];
        }
        brickTypeClassNameMap = [brickTypeClassNameMutableMap copy]; // make NSDictionary out of NSMutableDictionary
    }
    return brickTypeClassNameMap;
}

- (kBrickType)brickTypeForClassName:(NSString*)className
{
    // find right brick type by given class name (use regular map)
    NSDictionary *classNameBrickTypeMap = [self classNameBrickTypeMap];
    NSNumber *brickTypeAsNumber = classNameBrickTypeMap[className];
    if (! brickTypeAsNumber) {
        return kInvalidBrick;
    }
    return (kBrickType)[brickTypeAsNumber unsignedIntegerValue];
}

- (NSString*)classNameForBrickType:(kBrickType)brickType
{
    // find right class name by given brick type (use inverse map)
    NSDictionary *brickTypeClassNameMap = [self brickTypeClassNameMap];
    return brickTypeClassNameMap[@(brickType)];
}

- (kBrickCategoryType)brickCategoryTypeForBrickType:(kBrickType)brickType
{
    return (kBrickCategoryType)(((NSUInteger)brickType) / 100)+1;
}

- (NSArray*)brickClassNamesOrderedByBrickType
{
    // save array statically for performance reasons
    static NSArray *orderedBrickClassNames = nil;
    if (orderedBrickClassNames == nil) {
        // get all brick types in NSMutableArray and sort them
        NSDictionary *brickTypeClassNameMap = [self brickTypeClassNameMap];
        NSArray *allBrickTypes = [brickTypeClassNameMap allKeys];
        NSArray *orderedBrickTypes = [allBrickTypes sortedArrayUsingSelector:@selector(compare:)];
        // collect class names
        NSMutableArray *orderedBrickClassNamesMutable = [NSMutableArray arrayWithCapacity:orderedBrickTypes.count];
        for (NSNumber *brickType in orderedBrickTypes) {
            [orderedBrickClassNamesMutable addObject:brickTypeClassNameMap[brickType]];
        }
        orderedBrickClassNames = orderedBrickClassNamesMutable;
    }
    return orderedBrickClassNames;
}

- (NSArray*)selectableBricks
{
    // save array statically for performance reasons
    static NSArray *selectableBricks = nil;
    if (selectableBricks == nil) {
        NSArray *orderedBrickClassNames = [self brickClassNamesOrderedByBrickType];
        NSMutableArray *selectableBricksMutableArray = [NSMutableArray arrayWithCapacity:[orderedBrickClassNames count]];
        for (NSString *className in orderedBrickClassNames) {
            // only add selectable brick/script objects to the array
            id brickOrScript = [[NSClassFromString(className) alloc] init];
            if ([brickOrScript conformsToProtocol:@protocol(BrickProtocol)]) {
                id<BrickProtocol> brick = brickOrScript;
                if (brick.isSelectableForObject) {
                    [selectableBricksMutableArray addObject:brick];
                }
            }
        }
        selectableBricks = selectableBricksMutableArray;
    }
    return selectableBricks;
}

- (NSArray*)selectableScriptBricks
{
    static NSArray *scripts = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray *allBricks = [self brickClassNamesOrderedByBrickType];
        NSMutableArray *mutableScriptBricks = [[NSMutableArray alloc] initWithCapacity:allBricks.count];
        [allBricks enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            CBAssert([obj isKindOfClass:[NSString class]]);
            Class class = NSClassFromString(obj);
            id brickOrScript = [class new];
            if ([brickOrScript isKindOfClass:[Script class]] && [brickOrScript conformsToProtocol:@protocol(ScriptProtocol)]) {
                if ([brickOrScript isKindOfClass:[WhenScript class]]) {
                    ((WhenScript*)brickOrScript).action = kWhenScriptDefaultAction;
                }
                id<ScriptProtocol> scriptBrick = brickOrScript;
                [mutableScriptBricks addObject:scriptBrick];
            }
        }];
        scripts = mutableScriptBricks;
    });
    return scripts;
}

- (NSArray*)selectableBricksForCategoryType:(kBrickCategoryType)categoryType
{
    NSArray *selectableBricks = [self selectableBricks];
    NSMutableArray *selectableBricksForCategoryMutable = [NSMutableArray arrayWithCapacity:[selectableBricks count]];
    if (categoryType == kControlBrick) {
        [selectableBricksForCategoryMutable addObjectsFromArray:[[BrickManager sharedBrickManager] selectableScriptBricks]];
    }
    if (categoryType == kFavouriteBricks) {
        NSArray *selectableBricksOrScripts = [selectableBricks arrayByAddingObjectsFromArray:[[BrickManager sharedBrickManager] selectableScriptBricks]];
        NSArray *favouriteBricks = [Util getSubsetOfTheMostFavoriteChosenBricks:kMaxFavouriteBrickSize];
        for(NSString* oneFavouriteBrickTitle in favouriteBricks) {
            for(id<BrickProtocol> scriptOrBrick in selectableBricksOrScripts) {
                NSString *wrappedBrickType = [NSNumber numberWithUnsignedInteger:(NSUInteger)[scriptOrBrick brickType]].stringValue;
                if([wrappedBrickType isEqualToString:oneFavouriteBrickTitle]) {
                    [selectableBricksForCategoryMutable addObject:scriptOrBrick];
                }
            }
        }
        return (NSArray*)selectableBricksForCategoryMutable;
    }
    for (id<BrickProtocol> brick in selectableBricks) {
        if (brick.brickCategoryType == categoryType) {
            [selectableBricksForCategoryMutable addObject:brick];
        }
    }

    return (NSArray*)selectableBricksForCategoryMutable;
}

- (kBrickType)brickTypeForCategoryType:(kBrickCategoryType)categoryType andBrickIndex:(NSUInteger)index
{
    return (kBrickType)((categoryType-1) * 100 + index);
}

- (NSUInteger)brickIndexForBrickType:(kBrickType)brickType
{
    return (brickType % 100);
}

- (CGSize)sizeForBrick:(NSString*)brickName
{
    CGSize size = CGSizeZero;
    NSNumber *height = [_brickHeightDictionary objectForKey:brickName];
    size = CGSizeMake(UIScreen.mainScreen.bounds.size.width, [height floatValue]);
    return size;
}

- (BOOL)isScript:(kBrickType)type
{
    if (type == kProgramStartedBrick || type == kTappedBrick || type == kReceiveBrick) {
        return YES;
    }
    return NO;
}

- (NSInteger)checkEndLoopBrickTypeForDrawing:(BrickCell*)cell
{
    LoopEndBrick *brick = (LoopEndBrick*)cell.scriptOrBrick;
    if ([brick.loopBeginBrick isKindOfClass:[ForeverBrick class]]) {
        NSInteger count;
        BOOL before = YES;
        BOOL after = NO;
        for (count = 0; count < brick.script.brickList.count; count++) {
            Brick* equalBrick = brick.script.brickList[count];
            if (equalBrick == brick) {
                if (count-1 >= 0) {
                    //CheckBrick before
                    before = [self checkBrickbeforeBrick:brick andIndex:count-1];
                }
                if (count+1 < brick.script.brickList.count) {
                    //CheckBrick after
                    after = [self checkBrickafterBrick:brick andIndex:count+1];
                }
            }
        }
        if (after && before) {
            return 0;
        } else if (!after && !before){
            return 2;
        } else if (!after && before){
            return 1;
        } else if (after && !before){
            return 3;
        }
      
    }
    return 0;
}

- (BOOL)checkBrickafterBrick:(Brick*)brick andIndex:(NSInteger)index
{
    Brick* afterBrick = brick.script.brickList[index];
    if ([afterBrick isKindOfClass:[LoopEndBrick class]]) {
        LoopEndBrick *afterLoopEndBrick = (LoopEndBrick*)afterBrick;
        if (![afterLoopEndBrick.loopBeginBrick isKindOfClass:[ForeverBrick class]]) {
            return YES;
        }
        return NO;
    }
    return YES;
}

- (BOOL)checkBrickbeforeBrick:(Brick*)brick andIndex:(NSInteger)index
{
    Brick* beforeBrick = brick.script.brickList[index];
    if ([beforeBrick isKindOfClass:[LoopEndBrick class]]) {
        LoopEndBrick *beforeLoopEndBrick = (LoopEndBrick*)beforeBrick;
        if (![beforeLoopEndBrick.loopBeginBrick isKindOfClass:[ForeverBrick class]]) {
            return YES;
        }
        return NO;
    }
    return YES;
}

#pragma mark Animation
- (NSArray*)animateWithIndexPath:(NSIndexPath*)path Script:(Script*)script andBrick:(Brick *)brick
{
    if ([brick isKindOfClass:[LoopBeginBrick class]] || [brick isKindOfClass:[LoopEndBrick class]]) {
        return [self loopBrickForAnimationIndexPath:path Script:script andBrick:brick];
    } else if ([brick isKindOfClass:[IfLogicBeginBrick class]] || [brick isKindOfClass:[IfThenLogicBeginBrick class]] || [brick isKindOfClass:[IfLogicElseBrick class]] || [brick isKindOfClass:[IfLogicEndBrick class]]  || [brick isKindOfClass:[IfThenLogicEndBrick class]]) {
        return [self ifBrickForAnimationIndexPath:path Script:script andBrick:brick];
    } else {
        return nil;
    }
}
- (NSArray*)loopBrickForAnimationIndexPath:(NSIndexPath*)indexPath Script:(Script*)script andBrick:(Brick *)brick
{
    if ([brick isKindOfClass:[LoopBeginBrick class]]) {
        LoopBeginBrick *begin = (LoopBeginBrick*)brick;
        NSInteger count = 0;
        for (Brick *check in script.brickList) {
            if ([check isEqual:begin.loopEndBrick]) {
                break;
            }
            ++count;
        }
        begin.animate = YES;
        begin.loopEndBrick.animate = YES;
        return @[[NSNumber numberWithInteger:count+1]];
    } else if ([brick isKindOfClass:[LoopEndBrick class]]) {
        LoopEndBrick *endBrick = (LoopEndBrick *)brick;
        NSInteger count = 0;
        for (Brick *check in script.brickList) {
            if ([check isEqual:endBrick.loopBeginBrick]) {
                break;
            }
            ++count;
        }
        endBrick.animate = YES;
        endBrick.loopBeginBrick.animate = YES;
        return @[[NSNumber numberWithInteger:count+1]];
    }
    return nil;
}

- (NSArray*)ifBrickForAnimationIndexPath:(NSIndexPath*)indexPath Script:(Script*)script andBrick:(Brick *)brick
{
    if ([brick isKindOfClass:[IfThenLogicBeginBrick class]]) {
        IfThenLogicBeginBrick *begin = (IfThenLogicBeginBrick*)brick;
        NSInteger endcount = 0;
        for (Brick *checkBrick in script.brickList) {
            if ([checkBrick isEqual:begin.ifEndBrick]) {
                break;
            } else {
                ++endcount;
            }
            
        }
        begin.animate = YES;
        begin.ifEndBrick.animate = YES;
        return @[[NSNumber numberWithInteger:1],[NSNumber numberWithInteger:endcount+1]];
    }
    if ([brick isKindOfClass:[IfLogicBeginBrick class]]) {
        IfLogicBeginBrick *begin = (IfLogicBeginBrick*)brick;
        NSInteger elsecount = 0;
        NSInteger endcount = 0;
        BOOL found = NO;
        for (Brick *checkBrick in script.brickList) {
            if (! found) {
                if ([checkBrick isEqual:begin.ifElseBrick]) {
                    found = YES;
                } else {
                    ++elsecount;
                }
            }
            if ([checkBrick isEqual:begin.ifEndBrick]) {
                break;
            } else {
                ++endcount;
            }
            
        }
        begin.animate = YES;
        begin.ifElseBrick.animate = YES;
        begin.ifEndBrick.animate = YES;
        return @[[NSNumber numberWithInteger:elsecount+1],[NSNumber numberWithInteger:endcount+1]];
    } else if ([brick isKindOfClass:[IfLogicElseBrick class]]) {
        IfLogicElseBrick *elseBrick = (IfLogicElseBrick*)brick;
        NSInteger begincount = 0;
        NSInteger endcount = 0;
        BOOL found = NO;
        for (Brick *checkBrick in script.brickList) {
            if (! found) {
                if ([checkBrick isEqual:elseBrick.ifBeginBrick]) {
                    found = YES;
                } else {
                    ++begincount;
                }
            }
            if ([checkBrick isEqual:elseBrick.ifEndBrick]) {
                break;
            } else {
                ++endcount;
            }
        }
        elseBrick.animate = YES;
        elseBrick.ifBeginBrick.animate = YES;
        elseBrick.ifEndBrick.animate = YES;
        return @[[NSNumber numberWithInteger:begincount+1],[NSNumber numberWithInteger:endcount+1]];
    } else if ([brick isKindOfClass:[IfLogicEndBrick class]] || [brick isKindOfClass:[IfThenLogicEndBrick class]]) {
        IfLogicEndBrick *endBrick = (IfLogicEndBrick*)brick;
        NSInteger elsecount = 0;
        NSInteger begincount = 0;
        BOOL found = NO;
        for (Brick *checkBrick in script.brickList) {
            if (! found) {
                if ([checkBrick isEqual:endBrick.ifBeginBrick]) {
                    found = YES;
                } else {
                    ++begincount;
                }
            }
            if ([checkBrick isEqual:endBrick.ifElseBrick]) {
                break;
            } else {
                ++elsecount;
            }
            
        }
        endBrick.animate = YES;
        endBrick.ifElseBrick.animate = YES;
        endBrick.ifBeginBrick.animate = YES;
        return @[[NSNumber numberWithInteger:elsecount+1],[NSNumber numberWithInteger:begincount+1]];
    }
    return nil;
}

#pragma mark ScriptCollectionViewController Copy

- (NSArray*)scriptCollectionCopyBrickWithIndexPath:(NSIndexPath*)indexPath andBrick:(Brick*)brick
{
    if ([brick isLoopBrick]) {
        // loop brick
        LoopBeginBrick *loopBeginBrick = nil;
        LoopEndBrick *loopEndBrick = nil;
        if ([brick isKindOfClass:[LoopBeginBrick class]]) {
            loopBeginBrick = ((LoopBeginBrick*)brick);
            loopEndBrick = loopBeginBrick.loopEndBrick;
        } else {
            CBAssert([brick isKindOfClass:[LoopEndBrick class]]);
            loopEndBrick = ((LoopEndBrick*)brick);
            loopBeginBrick = loopEndBrick.loopBeginBrick;
        }
        CBAssert((loopBeginBrick != nil) || (loopEndBrick != nil));
        NSUInteger loopBeginIndex = [brick.script.brickList indexOfObject:loopBeginBrick];
        NSUInteger loopEndIndex = (loopBeginIndex + 1);
        LoopBeginBrick *copiedLoopBeginBrick = [loopBeginBrick mutableCopyWithContext:[CBMutableCopyContext new]];
        LoopEndBrick *copiedLoopEndBrick = [loopEndBrick mutableCopyWithContext:[CBMutableCopyContext new]];
        copiedLoopBeginBrick.loopEndBrick = copiedLoopEndBrick;
        copiedLoopEndBrick.loopBeginBrick = copiedLoopBeginBrick;
        [brick.script addBrick:copiedLoopBeginBrick atIndex:loopBeginIndex];
        [brick.script addBrick:copiedLoopEndBrick atIndex:loopEndIndex];
        NSIndexPath *loopBeginIndexPath = [NSIndexPath indexPathForItem:(loopBeginIndex + 1) inSection:indexPath.section];
        NSIndexPath *loopEndIndexPath = [NSIndexPath indexPathForItem:(loopBeginIndex + 2) inSection:indexPath.section];
        return @[loopBeginIndexPath, loopEndIndexPath];
        
    } else if ([brick isIfLogicBrick]) {
        // if brick
        IfThenLogicBeginBrick *ifThenLogicBeginBrick = nil;
        IfThenLogicEndBrick *ifThenLogicEndBrick = nil;
        IfLogicBeginBrick *ifLogicBeginBrick = nil;
        IfLogicElseBrick *ifLogicElseBrick = nil;
        IfLogicEndBrick *ifLogicEndBrick = nil;
        if ([brick isKindOfClass:[IfThenLogicBeginBrick class]]) {
            ifThenLogicBeginBrick = ((IfThenLogicBeginBrick*)brick);
            ifThenLogicEndBrick = ifThenLogicBeginBrick.ifEndBrick;
        } else if ([brick isKindOfClass:[IfLogicBeginBrick class]]) {
            ifLogicBeginBrick = ((IfLogicBeginBrick*)brick);
            ifLogicElseBrick = ifLogicBeginBrick.ifElseBrick;
            ifLogicEndBrick = ifLogicBeginBrick.ifEndBrick;
        } else if ([brick isKindOfClass:[IfLogicElseBrick class]]) {
            ifLogicElseBrick = ((IfLogicElseBrick*)brick);
            ifLogicBeginBrick = ifLogicElseBrick.ifBeginBrick;
            ifLogicEndBrick = ifLogicElseBrick.ifEndBrick;
        } else if ([brick isKindOfClass:[IfThenLogicEndBrick class]]) {
            ifThenLogicEndBrick = ((IfThenLogicEndBrick*)brick);
            ifThenLogicBeginBrick = ifThenLogicEndBrick.ifBeginBrick;
        } else {
            CBAssert([brick isKindOfClass:[IfLogicEndBrick class]]);
            ifLogicEndBrick = ((IfLogicEndBrick*)brick);
            ifLogicBeginBrick = ifLogicEndBrick.ifBeginBrick;
            ifLogicElseBrick = ifLogicEndBrick.ifElseBrick;
        }
        if(ifLogicBeginBrick != nil) {
            CBAssert((ifLogicBeginBrick != nil) && (ifLogicElseBrick != nil) && (ifLogicEndBrick != nil));
            NSUInteger ifLogicBeginIndex = [brick.script.brickList indexOfObject:ifLogicBeginBrick];
            NSUInteger ifLogicElseIndex = (ifLogicBeginIndex + 1);
            NSUInteger ifLogicEndIndex = (ifLogicElseIndex + 1);
            IfLogicBeginBrick *copiedIfLogicBeginBrick = [ifLogicBeginBrick mutableCopyWithContext:[CBMutableCopyContext new]];
            IfLogicElseBrick *copiedIfLogicElseBrick = [ifLogicElseBrick mutableCopyWithContext:[CBMutableCopyContext new]];
            IfLogicEndBrick *copiedIfLogicEndBrick = [ifLogicEndBrick mutableCopyWithContext:[CBMutableCopyContext new]];
            copiedIfLogicBeginBrick.ifElseBrick = copiedIfLogicElseBrick;
            copiedIfLogicBeginBrick.ifEndBrick = copiedIfLogicEndBrick;
            copiedIfLogicElseBrick.ifBeginBrick = copiedIfLogicBeginBrick;
            copiedIfLogicElseBrick.ifEndBrick = copiedIfLogicEndBrick;
            copiedIfLogicEndBrick.ifBeginBrick = copiedIfLogicBeginBrick;
            copiedIfLogicEndBrick.ifElseBrick = copiedIfLogicElseBrick;
            [brick.script addBrick:copiedIfLogicBeginBrick atIndex:ifLogicBeginIndex];
            [brick.script addBrick:copiedIfLogicElseBrick atIndex:ifLogicElseIndex];
            [brick.script addBrick:copiedIfLogicEndBrick atIndex:ifLogicEndIndex];
            NSIndexPath *ifLogicBeginIndexPath = [NSIndexPath indexPathForItem:(ifLogicBeginIndex + 1) inSection:indexPath.section];
            NSIndexPath *ifLogicElseIndexPath = [NSIndexPath indexPathForItem:(ifLogicBeginIndex + 2) inSection:indexPath.section];
            NSIndexPath *ifLogicEndIndexPath = [NSIndexPath indexPathForItem:(ifLogicBeginIndex + 3) inSection:indexPath.section];
            return @[ifLogicBeginIndexPath, ifLogicElseIndexPath, ifLogicEndIndexPath];
        } else if(ifThenLogicBeginBrick != nil){
            CBAssert((ifThenLogicBeginBrick != nil) && (ifLogicElseBrick == nil) && (ifThenLogicEndBrick != nil));
            NSUInteger ifLogicBeginIndex = [brick.script.brickList indexOfObject:ifThenLogicBeginBrick];
            NSUInteger ifLogicEndIndex = (ifLogicBeginIndex + 1);
            IfThenLogicBeginBrick *copiedIfLogicBeginBrick = [ifThenLogicBeginBrick mutableCopyWithContext:[CBMutableCopyContext new]];
            IfThenLogicEndBrick *copiedIfLogicEndBrick = [ifThenLogicEndBrick mutableCopyWithContext:[CBMutableCopyContext new]];
            copiedIfLogicBeginBrick.ifEndBrick = copiedIfLogicEndBrick;
            copiedIfLogicEndBrick.ifBeginBrick = copiedIfLogicBeginBrick;
            [brick.script addBrick:copiedIfLogicEndBrick atIndex:ifLogicEndIndex];
            NSIndexPath *ifLogicBeginIndexPath = [NSIndexPath indexPathForItem:(ifLogicBeginIndex + 1) inSection:indexPath.section];
            NSIndexPath *ifLogicEndIndexPath = [NSIndexPath indexPathForItem:(ifLogicBeginIndex + 2) inSection:indexPath.section];
            return @[ifLogicBeginIndexPath, ifLogicEndIndexPath];
        } else {
            return @[];
        }
    } else {
        // normal brick
        NSUInteger copiedBrickIndex = ([brick.script.brickList indexOfObject:brick] + 1);
        Brick *copiedBrick = [brick mutableCopyWithContext:[CBMutableCopyContext new]];
        [brick.script addBrick:copiedBrick atIndex:copiedBrickIndex];
        NSIndexPath *newIndexPath = [NSIndexPath indexPathForItem:(indexPath.row + 1) inSection:indexPath.section];
        return @[newIndexPath];
    }
}


#pragma mark RemovingBrick from CollectionView

- (NSArray*)getIndexPathsForRemovingBricks:(NSIndexPath*)indexPath andBrick:(Brick*)brick
{
    if ([brick isLoopBrick]) {
        // loop brick
        LoopBeginBrick *loopBeginBrick = nil;
        LoopEndBrick *loopEndBrick = nil;
        if ([brick isKindOfClass:[LoopBeginBrick class]]) {
            loopBeginBrick = ((LoopBeginBrick*)brick);
            NSUInteger loopBeginIndex = [brick.script.brickList indexOfObject:loopBeginBrick];
            NSIndexPath *loopBeginIndexPath = [NSIndexPath indexPathForItem:(loopBeginIndex + 1) inSection:indexPath.section];
            
            loopEndBrick = loopBeginBrick.loopEndBrick;
            NSUInteger loopEndIndex = [brick.script.brickList indexOfObject:loopEndBrick];
            NSIndexPath *loopEndIndexPath = [NSIndexPath indexPathForItem:(loopEndIndex + 1) inSection:indexPath.section];
            
            [loopBeginBrick removeFromScript];
            [loopEndBrick removeFromScript];
            return @[loopBeginIndexPath,loopEndIndexPath];
        } else {
            CBAssert([brick isKindOfClass:[LoopEndBrick class]]);
            loopEndBrick = ((LoopEndBrick*)brick);
            NSUInteger loopEndIndex = [brick.script.brickList indexOfObject:loopEndBrick];
            NSIndexPath *loopEndIndexPath = [NSIndexPath indexPathForItem:(loopEndIndex + 1) inSection:indexPath.section];
            
            loopBeginBrick = loopEndBrick.loopBeginBrick;
            NSUInteger loopBeginIndex = [brick.script.brickList indexOfObject:loopBeginBrick];
            NSIndexPath *loopBeginIndexPath = [NSIndexPath indexPathForItem:(loopBeginIndex + 1) inSection:indexPath.section];
            
            [loopBeginBrick removeFromScript];
            [loopEndBrick removeFromScript];
            return @[loopBeginIndexPath,loopEndIndexPath];
        }
        
    } else if ([brick isIfLogicBrick]) {
        // if brick
        IfThenLogicBeginBrick *ifThenLogicBeginBrick = nil;
        IfThenLogicEndBrick *ifThenLogicEndBrick = nil;
        IfLogicBeginBrick *ifLogicBeginBrick = nil;
        IfLogicElseBrick *ifLogicElseBrick = nil;
        IfLogicEndBrick *ifLogicEndBrick = nil;
        if ([brick isKindOfClass:[IfLogicBeginBrick class]]) {
            ifLogicBeginBrick = ((IfLogicBeginBrick*)brick);
            NSUInteger ifLogicBeginIndex = [brick.script.brickList indexOfObject:ifLogicBeginBrick];
            NSIndexPath *ifLogicBeginIndexPath = [NSIndexPath indexPathForItem:(ifLogicBeginIndex + 1) inSection:indexPath.section];
            
            ifLogicElseBrick = ifLogicBeginBrick.ifElseBrick;
            NSUInteger ifLogicElseIndex = [brick.script.brickList indexOfObject:ifLogicElseBrick];
            NSIndexPath *ifLogicElseIndexPath = [NSIndexPath indexPathForItem:(ifLogicElseIndex + 1) inSection:indexPath.section];
            
            ifLogicEndBrick = ifLogicBeginBrick.ifEndBrick;
            NSUInteger ifLogicEndIndex = [brick.script.brickList indexOfObject:ifLogicEndBrick];
            NSIndexPath *ifLogicEndIndexPath = [NSIndexPath indexPathForItem:(ifLogicEndIndex + 1) inSection:indexPath.section];
            
            [ifLogicBeginBrick removeFromScript];
            [ifLogicElseBrick removeFromScript];
            [ifLogicEndBrick removeFromScript];
            
            return @[ifLogicBeginIndexPath,ifLogicElseIndexPath,ifLogicEndIndexPath];
            
        } else if ([brick isKindOfClass:[IfThenLogicBeginBrick class]]) {
            ifThenLogicBeginBrick = ((IfThenLogicBeginBrick*)brick);
            NSUInteger ifLogicBeginIndex = [brick.script.brickList indexOfObject:ifThenLogicBeginBrick];
            NSIndexPath *ifLogicBeginIndexPath = [NSIndexPath indexPathForItem:(ifLogicBeginIndex + 1) inSection:indexPath.section];
            
            ifThenLogicEndBrick = ifThenLogicBeginBrick.ifEndBrick;
            NSUInteger ifLogicEndIndex = [brick.script.brickList indexOfObject:ifThenLogicEndBrick];
            NSIndexPath *ifLogicEndIndexPath = [NSIndexPath indexPathForItem:(ifLogicEndIndex + 1) inSection:indexPath.section];
            
            [ifThenLogicBeginBrick removeFromScript];
            [ifThenLogicEndBrick removeFromScript];
            
            return @[ifLogicBeginIndexPath,ifLogicEndIndexPath];
            
        } else if ([brick isKindOfClass:[IfLogicElseBrick class]]) {
            ifLogicElseBrick = ((IfLogicElseBrick*)brick);
            NSUInteger ifLogicElseIndex = [brick.script.brickList indexOfObject:ifLogicElseBrick];
            NSIndexPath *ifLogicElseIndexPath = [NSIndexPath indexPathForItem:(ifLogicElseIndex + 1) inSection:indexPath.section];
            
            ifLogicBeginBrick = ifLogicElseBrick.ifBeginBrick;
            NSUInteger ifLogicBeginIndex = [brick.script.brickList indexOfObject:ifLogicBeginBrick];
            NSIndexPath *ifLogicBeginIndexPath = [NSIndexPath indexPathForItem:(ifLogicBeginIndex + 1) inSection:indexPath.section];
            
            ifLogicEndBrick = ifLogicElseBrick.ifEndBrick;
            NSUInteger ifLogicEndIndex = [brick.script.brickList indexOfObject:ifLogicEndBrick];
            NSIndexPath *ifLogicEndIndexPath = [NSIndexPath indexPathForItem:(ifLogicEndIndex + 1) inSection:indexPath.section];
            
            [ifLogicElseBrick removeFromScript];
            [ifLogicBeginBrick removeFromScript];
            [ifLogicEndBrick removeFromScript];
            return @[ifLogicBeginIndexPath,ifLogicElseIndexPath,ifLogicEndIndexPath];
            
        } else if ([brick isKindOfClass:[IfThenLogicEndBrick class]]) {
            ifThenLogicEndBrick = ((IfThenLogicEndBrick*)brick);
            NSUInteger ifLogicEndIndex = [brick.script.brickList indexOfObject:ifThenLogicEndBrick];
            NSIndexPath *ifLogicEndIndexPath = [NSIndexPath indexPathForItem:(ifLogicEndIndex + 1) inSection:indexPath.section];
            
            ifThenLogicBeginBrick = ifThenLogicEndBrick.ifBeginBrick;
            NSUInteger ifLogicBeginIndex = [brick.script.brickList indexOfObject:ifLogicBeginBrick];
            NSIndexPath *ifLogicBeginIndexPath = [NSIndexPath indexPathForItem:(ifLogicBeginIndex + 1) inSection:indexPath.section];
            
            [ifThenLogicBeginBrick removeFromScript];
            [ifThenLogicEndBrick removeFromScript];
            return @[ifLogicBeginIndexPath,ifLogicEndIndexPath];
        } else {
            CBAssert([brick isKindOfClass:[IfLogicEndBrick class]]);
            ifLogicEndBrick = ((IfLogicEndBrick*)brick);
            NSUInteger ifLogicEndIndex = [brick.script.brickList indexOfObject:ifLogicEndBrick];
            NSIndexPath *ifLogicEndIndexPath = [NSIndexPath indexPathForItem:(ifLogicEndIndex + 1) inSection:indexPath.section];
            
            ifLogicBeginBrick = ifLogicEndBrick.ifBeginBrick;
            NSUInteger ifLogicBeginIndex = [brick.script.brickList indexOfObject:ifLogicBeginBrick];
            NSIndexPath *ifLogicBeginIndexPath = [NSIndexPath indexPathForItem:(ifLogicBeginIndex + 1) inSection:indexPath.section];
            
            ifLogicElseBrick = ifLogicEndBrick.ifElseBrick;
            NSUInteger ifLogicElseIndex = [brick.script.brickList indexOfObject:ifLogicElseBrick];
            NSIndexPath *ifLogicElseIndexPath = [NSIndexPath indexPathForItem:(ifLogicElseIndex + 1) inSection:indexPath.section];
            
            [ifLogicBeginBrick removeFromScript];
            [ifLogicEndBrick removeFromScript];
            [ifLogicElseBrick removeFromScript];
            return @[ifLogicBeginIndexPath,ifLogicElseIndexPath,ifLogicEndIndexPath];
            
        }
        
    } else {
        [brick removeFromScript];
        return @[indexPath];
    }
    
}

@end
