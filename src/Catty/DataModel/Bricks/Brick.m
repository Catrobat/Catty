/**
 *  Copyright (C) 2010-2015 The Catrobat Team
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
#import "Brick.h"
#import "Script.h"
#import "BrickManager.h"
#import "NSString+CatrobatNSStringExtensions.h"
#import "IfLogicElseBrick.h"
#import "IfLogicBeginBrick.h"
#import "IfLogicEndBrick.h"
#import "LoopEndBrick.h"
#import "LoopBeginBrick.h"
#import "RepeatBrick.h"
#import "BroadcastScript.h"
#import "WaitBrick.h"
#import "BroadcastBrick.h"
#import "Formula.h"
#import "Util.h"
#import "CBMutableCopyContext.h"
#import "BroadcastWaitBrick.h"
#import "NoteBrick.h"
#include <mach/mach_time.h>
#import "BrickCell.h"

@interface Brick()

@property (nonatomic, assign) kBrickCategoryType brickCategoryType;
@property (nonatomic, assign) kBrickType brickType;

@end

@implementation Brick


#pragma mark - NSObject

- (id)init
{
    self = [super init];
    if (self) {
        NSString *subclassName = NSStringFromClass([self class]);
        BrickManager *brickManager = [BrickManager sharedBrickManager];
        self.brickType = [brickManager brickTypeForClassName:subclassName];
        self.brickCategoryType = [brickManager brickCategoryTypeForBrickType:self.brickType];
    }
    return self;
}

- (BOOL)isSelectableForObject
{
    return YES;
}

- (BOOL)isAnimateable
{
    return NO;
}

- (BOOL)isFormulaBrick
{
    return ([self conformsToProtocol:@protocol(BrickFormulaProtocol)]);
}

- (BOOL)isIfLogicBrick
{
    return NO;
}

- (BOOL)isLoopBrick
{
    return NO;
}

- (NSString*)description
{
    return @"Brick (NO SPECIFIC DESCRIPTION GIVEN! OVERRIDE THE DESCRIPTION METHOD!";
}

- (SKAction*)action
{
    NSError(@"%@ (NO SPECIFIC Action GIVEN! OVERRIDE THE action METHOD!", self.class);
    return nil;
}


- (void)performFromScript:(Script*)script
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (dispatch_block_t)actionBlock
{
    return ^{
        NSError(@"%@ (NO SPECIFIC Action GIVEN! OVERRIDE THE actionBlock METHOD!", self.class);
    };
}

- (BOOL)isEqualToBrick:(Brick*)brick
{
    if(self.brickCategoryType != brick.brickCategoryType)
        return NO;
    if(self.brickType != brick.brickType)
        return NO;

    NSArray *firstPropertyList = [[Util propertiesOfInstance:self] allValues];
    NSArray *secondPropertyList = [[Util propertiesOfInstance:brick] allValues];
    
    if([firstPropertyList count] != [secondPropertyList count])
        return NO;
    
    NSUInteger index;
    for(index = 0; index < [firstPropertyList count]; index++) {
        NSObject *firstObject = [firstPropertyList objectAtIndex:index];
        NSObject *secondObject = [secondPropertyList objectAtIndex:index];
        
        // prevent recursion (e.g. Script->Brick->Script->Brick...)
        if([firstObject isKindOfClass:[Script class]] && [secondObject isKindOfClass:[Script class]])
            continue;
    
        if(![Util isEqual:firstObject toObject:secondObject])
            return NO;
    }
    
    return YES;
}

- (void)setDefaultValuesForObject:(SpriteObject*)spriteObject
{
    // Override this method in Brick implementation
}

#pragma mark - Copy
// This function must be overriden by Bricks with references to other Bricks (e.g. ForeverBrick)
- (id)mutableCopyWithContext:(CBMutableCopyContext*)context
{
    return [self mutableCopyWithContext:context AndErrorReporting:YES];
}


- (id)mutableCopyWithContext:(CBMutableCopyContext*)context AndErrorReporting:(BOOL)reportError
{
    if (! context) NSError(@"%@ must not be nil!", [CBMutableCopyContext class]);
    Brick *brick = [[self class] new];
    brick.brickCategoryType = self.brickCategoryType;
    brick.brickType = self.brickType;
    [context updateReference:self WithReference:brick];

    NSDictionary *properties = [Util propertiesOfInstance:self];
    for (NSString *propertyKey in properties) {
        id propertyValue = [properties objectForKey:propertyKey];
        Class propertyClazz = [propertyValue class];        
        if ([propertyValue conformsToProtocol:@protocol(CBMutableCopying)]) {
            id updatedReference = [context updatedReferenceForReference:propertyValue];
            if (updatedReference) {
                [brick setValue:updatedReference forKey:propertyKey];
            } else {
                id propertyValueClone = [propertyValue mutableCopyWithContext:context];
                [brick setValue:propertyValueClone forKey:propertyKey];
            }
        } else if ([propertyValue conformsToProtocol:@protocol(NSMutableCopying)]) {
            // standard datatypes like NSString are already conforming to the NSMutableCopying protocol
            id propertyValueClone = [propertyValue mutableCopyWithZone:nil];
            [brick setValue:propertyValueClone forKey:propertyKey];
        } else if (propertyClazz == [@(YES) class]) {
            // 64-bit bool -> typedef bool BOOL
            [brick setValue:propertyValue forKey:propertyKey];
        } else if (propertyClazz == [@(1) class]) {
            // 32-bit bool -> typedef signed char BOOL
            [brick setValue:propertyValue forKey:propertyKey];
        } else if (reportError) {
            NSError(@"Property %@ of class %@ in Brick of class %@ does not conform to CBMutableCopying protocol. Implement mutableCopyWithContext method in %@", propertyKey, [propertyValue class], [self class], [self class]);
        }
    }
    return brick;
}

- (void)removeFromScript
{
    NSUInteger index = 0;
    for (Brick *brick in self.script.brickList) {
        if (brick == self) {
            [self.script.brickList removeObjectAtIndex:index];
            break;
        }
        ++index;
    }
}

- (void)removeReferences
{
    self.script = nil;
}


#pragma mark Animation
- (void)animateWithIndexPath:(NSIndexPath*)path Script:(Script*)script andCollectionView:(UICollectionView*)collectionView
{
    if ([self isKindOfClass:[LoopBeginBrick class]] || [self isKindOfClass:[LoopEndBrick class]]) {
        [self loopBrickForAnimationIndexPath:path Script:script andCollectionView:collectionView];
    } else if ([self isKindOfClass:[IfLogicBeginBrick class]] || [self isKindOfClass:[IfLogicElseBrick class]] || [self isKindOfClass:[IfLogicEndBrick class]]) {
        [self ifBrickForAnimationIndexPath:path Script:script andCollectionView:collectionView];
    }
}
- (void)loopBrickForAnimationIndexPath:(NSIndexPath*)indexPath Script:(Script*)script andCollectionView:(UICollectionView*)collectionView
{
    if ([self isKindOfClass:[LoopBeginBrick class]]) {
        LoopBeginBrick *begin = (LoopBeginBrick*)self;
        NSInteger count = 0;
        for (Brick *check in script.brickList) {
            if ([check isEqual:begin.loopEndBrick]) {
                break;
            }
            ++count;
        }
        begin.animate = YES;
        begin.loopEndBrick.animate = YES;
        [self animateLoop:count IndexPath:indexPath andCollectionView:collectionView];
    } else if ([self isKindOfClass:[LoopEndBrick class]]) {
        LoopEndBrick *endBrick = (LoopEndBrick *)self;
        NSInteger count = 0;
        for (Brick *check in script.brickList) {
            if ([check isEqual:endBrick.loopBeginBrick]) {
                break;
            }
            ++count;
        }
        endBrick.animate = YES;
        endBrick.loopBeginBrick.animate = YES;
        [self animateLoop:count IndexPath:indexPath andCollectionView:collectionView];
    }
}

- (void)ifBrickForAnimationIndexPath:(NSIndexPath*)indexPath Script:(Script*)script andCollectionView:(UICollectionView*)collectionView
{
    if ([self isKindOfClass:[IfLogicBeginBrick class]]) {
        IfLogicBeginBrick *begin = (IfLogicBeginBrick*)self;
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
        [self animateIf:elsecount and:endcount IndexPath:indexPath andCollectionView:collectionView];
    } else if ([self isKindOfClass:[IfLogicElseBrick class]]) {
        IfLogicElseBrick *elseBrick = (IfLogicElseBrick*)self;
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
        [self animateIf:begincount and:endcount IndexPath:indexPath andCollectionView:collectionView];
    } else if ([self isKindOfClass:[IfLogicEndBrick class]]) {
        IfLogicEndBrick *endBrick = (IfLogicEndBrick*)self;
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
        [self animateIf:elsecount and:begincount IndexPath:indexPath andCollectionView:collectionView];
    }
}

-(void)animateLoop:(NSInteger)count IndexPath:(NSIndexPath*)indexPath andCollectionView:(UICollectionView*)collectionView
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        BrickCell *cell = (BrickCell*)[collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:count+1 inSection:indexPath.section]];
        [cell animate:YES];
    });
}

-(void)animateIf:(NSInteger)count1 and:(NSInteger)count2 IndexPath:(NSIndexPath*)indexPath andCollectionView:(UICollectionView*)collectionView
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        BrickCell *elsecell = (BrickCell*)[collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:count1+1 inSection:indexPath.section]];
        BrickCell *begincell = (BrickCell*)[collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:count2+1 inSection:indexPath.section]];
        [elsecell animate:YES];
        [begincell animate:YES];
    });
}

#pragma mark ScriptCollectionViewController Copy

- (void)scriptCollectionCopyBrick:(UICollectionView*)collectionView andIndexPath:(NSIndexPath*)indexPath
{
    if ([self isLoopBrick]) {
        // loop brick
        LoopBeginBrick *loopBeginBrick = nil;
        LoopEndBrick *loopEndBrick = nil;
        if ([self isKindOfClass:[LoopBeginBrick class]]) {
            loopBeginBrick = ((LoopBeginBrick*)self);
            loopEndBrick = loopBeginBrick.loopEndBrick;
        } else {
            CBAssert([self isKindOfClass:[LoopEndBrick class]]);
            loopEndBrick = ((LoopEndBrick*)self);
            loopBeginBrick = loopEndBrick.loopBeginBrick;
        }
        CBAssert((loopBeginBrick != nil) || (loopEndBrick != nil));
        NSUInteger loopBeginIndex = [self.script.brickList indexOfObject:loopBeginBrick];
        NSUInteger loopEndIndex = (loopBeginIndex + 1);
        LoopBeginBrick *copiedLoopBeginBrick = [loopBeginBrick mutableCopyWithContext:[CBMutableCopyContext new]];
        LoopEndBrick *copiedLoopEndBrick = [loopEndBrick mutableCopyWithContext:[CBMutableCopyContext new]];
        copiedLoopBeginBrick.loopEndBrick = copiedLoopEndBrick;
        copiedLoopEndBrick.loopBeginBrick = copiedLoopBeginBrick;
        [self.script addBrick:copiedLoopBeginBrick atIndex:loopBeginIndex];
        [self.script addBrick:copiedLoopEndBrick atIndex:loopEndIndex];
        NSIndexPath *loopBeginIndexPath = [NSIndexPath indexPathForItem:(loopBeginIndex + 1) inSection:indexPath.section];
        NSIndexPath *loopEndIndexPath = [NSIndexPath indexPathForItem:(loopBeginIndex + 2) inSection:indexPath.section];
        [collectionView insertItemsAtIndexPaths:@[loopBeginIndexPath, loopEndIndexPath]];
        
    } else if ([self isIfLogicBrick]) {
        // if brick
        IfLogicBeginBrick *ifLogicBeginBrick = nil;
        IfLogicElseBrick *ifLogicElseBrick = nil;
        IfLogicEndBrick *ifLogicEndBrick = nil;
        if ([self isKindOfClass:[IfLogicBeginBrick class]]) {
            ifLogicBeginBrick = ((IfLogicBeginBrick*)self);
            ifLogicElseBrick = ifLogicBeginBrick.ifElseBrick;
            ifLogicEndBrick = ifLogicBeginBrick.ifEndBrick;
        } else if ([self isKindOfClass:[IfLogicElseBrick class]]) {
            ifLogicElseBrick = ((IfLogicElseBrick*)self);
            ifLogicBeginBrick = ifLogicElseBrick.ifBeginBrick;
            ifLogicEndBrick = ifLogicElseBrick.ifEndBrick;
        } else {
            CBAssert([self isKindOfClass:[IfLogicEndBrick class]]);
            ifLogicEndBrick = ((IfLogicEndBrick*)self);
            ifLogicBeginBrick = ifLogicEndBrick.ifBeginBrick;
            ifLogicElseBrick = ifLogicEndBrick.ifElseBrick;
        }
        CBAssert((ifLogicBeginBrick != nil) && (ifLogicElseBrick != nil) && (ifLogicEndBrick != nil));
        NSUInteger ifLogicBeginIndex = [self.script.brickList indexOfObject:ifLogicBeginBrick];
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
        [self.script addBrick:copiedIfLogicBeginBrick atIndex:ifLogicBeginIndex];
        [self.script addBrick:copiedIfLogicElseBrick atIndex:ifLogicElseIndex];
        [self.script addBrick:copiedIfLogicEndBrick atIndex:ifLogicEndIndex];
        NSIndexPath *ifLogicBeginIndexPath = [NSIndexPath indexPathForItem:(ifLogicBeginIndex + 1) inSection:indexPath.section];
        NSIndexPath *ifLogicElseIndexPath = [NSIndexPath indexPathForItem:(ifLogicBeginIndex + 2) inSection:indexPath.section];
        NSIndexPath *ifLogicEndIndexPath = [NSIndexPath indexPathForItem:(ifLogicBeginIndex + 3) inSection:indexPath.section];
        [collectionView insertItemsAtIndexPaths:@[ifLogicBeginIndexPath, ifLogicElseIndexPath, ifLogicEndIndexPath]];
        
    } else {
        // normal brick
        NSUInteger copiedBrickIndex = ([self.script.brickList indexOfObject:self] + 1);
        Brick *copiedBrick = [self mutableCopyWithContext:[CBMutableCopyContext new]];
        [self.script addBrick:copiedBrick atIndex:copiedBrickIndex];
        NSIndexPath *newIndexPath = [NSIndexPath indexPathForItem:(indexPath.row + 1) inSection:indexPath.section];
        [collectionView insertItemsAtIndexPaths:@[newIndexPath]];
    }
}

@end
