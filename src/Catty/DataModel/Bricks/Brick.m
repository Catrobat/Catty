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
#import "RepeatBrick.h"
#import "BroadcastBrick.h"
#import "Formula.h"
#import "Util.h"
#import "CBMutableCopyContext.h"
#import "BroadcastWaitBrick.h"
#import "NoteBrick.h"
#include <mach/mach_time.h>

@interface Brick()

@property (nonatomic, readwrite) kBrickCategoryType brickCategoryType;
@property (nonatomic, readwrite) kBrickType brickType;

@end

@implementation Brick

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
    NSArray *firstPropertyList = [[Util propertiesOfInstance:self] allValues];
    NSArray *secondPropertyList = [[Util propertiesOfInstance:brick] allValues];
    
    if([firstPropertyList count] != [secondPropertyList count])
        return NO;
    
    NSUInteger index;
    for(index = 0; index < [firstPropertyList count]; index++) {
        NSObject *firstObject = [firstPropertyList objectAtIndex:index];
        NSObject *secondObject = [secondPropertyList objectAtIndex:index];
        
        if(![Util isEqual:firstObject toObject:secondObject])
            return NO;
    }
    
    return YES;
}

#pragma mark - Copy
// This function must be overriden by Bricks with references to other Bricks (e.g. ForeverBrick)
- (id)mutableCopyWithContext:(CBMutableCopyContext*)context
{
    return [self mutableCopyWithContext:context AndErrorReporting:true];
}


- (id)mutableCopyWithContext:(CBMutableCopyContext*)context AndErrorReporting:(BOOL)reportError
{
    if(!context) NSError(@"%@ must not be nil!", [CBMutableCopyContext class]);
    
    Brick *brick = [[self class] new];
    [context updateReference:self WithReference:brick];
    
    NSDictionary *properties = [Util propertiesOfInstance:self];
    
    for (NSString *propertyKey in properties) {
        id propertyValue = [properties objectForKey:propertyKey];
        
        if([propertyValue conformsToProtocol:@protocol(CBMutableCopying)]) {
            id updatedReference = [context updatedReferenceForReference:propertyValue];
            if(updatedReference) {
                [brick setValue:updatedReference forKey:propertyKey];
            } else {
                id propertyValueClone = [propertyValue mutableCopyWithContext:context];
                [brick setValue:propertyValueClone forKey:propertyKey];
            }
        } else if([propertyValue conformsToProtocol:@protocol(NSMutableCopying)]) {
            // standard datatypes like NSString are already conforming to the NSMutableCopying protocol
            id propertyValueClone = [propertyValue mutableCopyWithZone:nil];
            [brick setValue:propertyValueClone forKey:propertyKey];
        } else if(reportError) {
            NSError(@"Property %@ of class %@ in Brick of class %@ does not conform to CBMutableCopying protocol. Implement mutableCopyWithContext method in %@", propertyKey, [propertyValue class], [self class], [self class]);
        }
    }
    
    return brick;
}

#pragma mark - Brick actions
- (NSUInteger)runAction
{
    NSDate *startTime = [NSDate date];
    NSUInteger brickIndex = 0;
    for (Brick *brick in self.script.brickList) {
        if (self == brick) {
            break;
        }
        ++brickIndex;
    }
    assert(brickIndex < [self.script.brickList count]);
    SKAction *action = nil;
    if ([self isKindOfClass:[LoopBeginBrick class]]) {
        LoopBeginBrick *loopBeginBrick = (LoopBeginBrick*)self;
        loopBeginBrick.loopStartTime = mach_absolute_time();
        BOOL condition = [loopBeginBrick checkCondition];
        if (! condition) {
            LoopEndBrick *loopEndBrick = loopBeginBrick.loopEndBrick;
            brickIndex = (1 + [self.script.brickList indexOfObject:loopEndBrick]);
        }
        [self.script runSequenceAndWait:YES];
    } else if ([self isKindOfClass:[LoopEndBrick class]]) {
        uint64_t loopEndTime = mach_absolute_time();
        LoopBeginBrick *loopBeginBrick = ((LoopEndBrick*)self).loopBeginBrick;
        brickIndex = [self.script.brickList indexOfObject:loopBeginBrick];
        if (brickIndex == NSNotFound) {
            abort();
        }
        
        [self.script runSequenceAndWait:YES];
        
        // information for converting from MTU to nanoseconds
        mach_timebase_info_data_t info;
        if (! mach_timebase_info(&info)) {
            // time elapsed in Mach time units
            const uint64_t loopDurationMTU = loopEndTime - loopBeginBrick.loopStartTime;
            // elapsed time in nanoseconds
            const double loopDuration = (double)loopDurationMTU * (double)info.numer / (double)info.denom;
            // FIXME: check if UI actions executed + outsource constant!!
            if (loopDuration < kMinLoopDurationTime) {
                [NSThread sleepForTimeInterval:((kMinLoopDurationTime - loopDuration)/1000000000)];
            }
        }
        loopBeginBrick.loopStartTime = mach_absolute_time();
    } else if ([self isKindOfClass:[BroadcastWaitBrick class]]) {
        NSDebug(@"broadcast wait");
        //        dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [(BroadcastWaitBrick*)self performBroadcastWait];
        });
    } else if ([self isKindOfClass:[BroadcastBrick class]]) {
//        action = [self action];
//        [self.script.actionSequenceList addObject:action];
        [self.script runSequenceAndWait:YES];
        dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self.script.object.program broadcast:((BroadcastBrick*)self).broadcastMessage senderScript:self.script];
        });
    } else if ([self isKindOfClass:[IfLogicBeginBrick class]]) {
        BOOL condition = [((IfLogicBeginBrick*)self) checkCondition];
        if (! condition) {
            brickIndex = (1 + [self.script.brickList indexOfObject:((IfLogicBeginBrick*)self).ifElseBrick]);
        }
        if (brickIndex == NSIntegerMin) {
            NSError(@"The XML-Structure is wrong, please fix the project");
        }
                [self.script runSequenceAndWait:YES];
    } else if ([self isKindOfClass:[IfLogicElseBrick class]]) {
        brickIndex = (1 + [self.script.brickList indexOfObject:((IfLogicElseBrick*)self).ifEndBrick]);
        if (brickIndex == NSIntegerMin) {
            NSError(@"The XML-Structure is wrong, please fix the project");
        }
                [self.script runSequenceAndWait:YES];
    } else if ([self isKindOfClass:[IfLogicEndBrick class]]) {
        IfLogicBeginBrick *ifBeginBrick = ((IfLogicEndBrick*)self).ifBeginBrick;
        if ([self.script.brickList indexOfObject:ifBeginBrick] == NSNotFound) {
            abort();
        }
        
        [self.script runSequenceAndWait:YES];
    } else if ([self isKindOfClass:[NoteBrick class]]) {
        // nothing to do!
    } else {
        action = [self action];
        [self.script.actionSequenceList addObject:action];
    }
    
    return brickIndex;
}

- (void)removeReferences
{
    self.script = nil;
}

@end
