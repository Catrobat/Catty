/**
 *  Copyright (C) 2010-2017 The Catrobat Team
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

#import "Script.h"
#import "Brick.h"
#import "BrickManager.h"
#import "CBMutableCopyContext.h"
#import "NSString+CatrobatNSStringExtensions.h"
#import "BroadcastScript.h"
#import "WhenScript.h"

@interface Script()
@property (nonatomic, readwrite) kBrickCategoryType brickCategoryType;
@property (nonatomic, readwrite) kBrickType brickType;
@end

@implementation Script

- (id)init
{
    if (self = [super init]) {
        NSString *subclassName = NSStringFromClass([self class]);
        BrickManager *brickManager = [BrickManager sharedBrickManager];
        self.brickType = [brickManager brickTypeForClassName:subclassName];
        self.brickCategoryType = [brickManager brickCategoryTypeForBrickType:self.brickType];
    }
    return self;
}

#pragma mark - Getters and Setters
- (BOOL)isSelectableForObject
{
    return YES;
}

- (BOOL)isAnimateable
{
    return NO;
}

- (void)addBrick:(Brick*)brick atIndex:(NSUInteger)index
{
    CBAssert([self.brickList indexOfObject:brick] == NSNotFound);
    brick.script = self;
    [brick.script.brickList insertObject:brick atIndex:index];
}

#pragma mark - Custom getter and setter
- (NSString*)brickTitle
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in the subclass %@",
                                           NSStringFromSelector(_cmd), NSStringFromClass([self class])]
                                 userInfo:nil];
}

- (NSMutableArray*)brickList
{
    if (! _brickList) {
        _brickList = [NSMutableArray array];
    }
    return _brickList;
}

- (void)dealloc
{
    NSDebug(@"Dealloc %@", [self class]);
}

#pragma mark - Copy
- (id)mutableCopyWithContext:(CBMutableCopyContext*)context
{
    if (! context) NSError(@"%@ must not be nil!", [CBMutableCopyContext class]);
    
    Script *copiedScript = [[self class] new];
    copiedScript.brickCategoryType = self.brickCategoryType;
    copiedScript.brickType = self.brickType;
    if ([self isKindOfClass:[WhenScript class]]) {
        CBAssert([copiedScript isKindOfClass:[WhenScript class]]);
        WhenScript *whenScript = (WhenScript*)self;
        ((WhenScript*)copiedScript).action = [NSString stringWithString:whenScript.action];
    }
    
    [context updateReference:self WithReference:copiedScript];
    
    // deep copy
    copiedScript.brickList = [NSMutableArray arrayWithCapacity:[self.brickList count]];
    for (id brick in self.brickList) {
        if ([brick isKindOfClass:[Brick class]]) {
            Brick *copiedBrick = [brick mutableCopyWithContext:context]; // there are some bricks that refer to other sound, look, sprite objects...
            copiedBrick.script = copiedScript;
            [copiedScript.brickList addObject:copiedBrick];
        }
    }
    if ([self isKindOfClass:[BroadcastScript class]]) {
        ((BroadcastScript*)copiedScript).receivedMessage = ((BroadcastScript*)self).receivedMessage;
    }
    return copiedScript;
}

#pragma mark - Description
- (NSString*)description
{
    NSMutableString *ret = [[NSMutableString alloc] initWithString:NSStringFromClass([self class])];
    const int clipLength = 8;
    NSString *shortObjectName = self.object.name;
    if (self.object.name.length > clipLength) {
        shortObjectName = [NSString stringWithFormat:@"%@...", [shortObjectName substringToIndex:clipLength]];
    }
    [ret appendFormat:@",object:\"%@\",#bricks:%lu", shortObjectName, (unsigned long)self.brickList.count];
    return ret;
}

#pragma mark - isEqualToScript
- (BOOL)isEqualToScript:(Script *)script
{
    if (self.brickCategoryType != script.brickCategoryType) {
        return NO;
    }
    if (self.brickType != script.brickType) {
        return NO;
    }
    if (! [Util isEqual:self.brickTitle toObject:script.brickTitle]) {
        return NO;
    }
    if ([self isKindOfClass:[WhenScript class]]) {
        if (! [script isKindOfClass:[WhenScript class]]) {
            return NO;
        }
        if (! [Util isEqual:((WhenScript*)self).action toObject:((WhenScript*)script).action]) {
            return NO;
        }
    }
    if (! [Util isEqual:self.object.name toObject:script.object.name]) {
        return NO;
    }
    if ([self.brickList count] != [script.brickList count]) {
        return NO;
    }
    
    NSUInteger index;
    for (index = 0; index < [self.brickList count]; ++index) {
        Brick *firstBrick = [self.brickList objectAtIndex:index];
        Brick *secondBrick = [script.brickList objectAtIndex:index];
        
        if (! [firstBrick isEqualToBrick:secondBrick]) {
            return NO;
        }
    }
    return YES;
}

- (void)removeFromObject
{
    NSUInteger index = 0;
    for (Script *script in self.object.scriptList) {
        if (script == self) {
            [self.brickList makeObjectsPerformSelector:@selector(removeFromScript)];
            [self.object.scriptList removeObjectAtIndex:index];
            self.object = nil;
            break;
        }
        ++index;
    }
}

- (void)removeReferences
{
    // DO NOT CHANGE ORDER HERE!
    [self.brickList makeObjectsPerformSelector:@selector(removeReferences)];
    self.object = nil;
}

- (void)setDefaultValuesForObject:(SpriteObject*)spriteObject
{
    // Override this method in Script implementation
}

- (NSInteger)getRequiredResources
{
    NSInteger resources = kNoResources;
    
    for (Brick *brick in self.brickList) {
        resources |= [brick getRequiredResources];
    }
    return resources;
}

@end
