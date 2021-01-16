/**
 *  Copyright (C) 2010-2021 The Catrobat Team
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

#import "LoopEndBrick.h"
#import "LoopBeginBrick.h"
#import "Util.h"
#import "CBMutableCopyContext.h"

@implementation LoopEndBrick

- (kBrickCategoryType)category
{
    return kControlBrick;
}

- (BOOL)isSelectableForObject
{
    return NO;
}

- (BOOL)isAnimateable
{
    return YES;
}

- (BOOL)isLoopBrick
{
    return YES;
}

- (void)performFromScript:(Script*)script
{
    NSDebug(@"Performing: %@", self.description);
}

#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"EndLoop"];
}

#pragma mark - Compare
- (BOOL)isEqualToBrick:(Brick*)brick
{
    if ([brick class] != [self class]) {
        return NO;
    }
    
    LoopEndBrick *loopBrick = (LoopEndBrick*)brick;
    if ([loopBrick.loopBeginBrick class] != [self.loopBeginBrick class]) {
        return NO;
    }
    return YES;
}

#pragma mark - Copy
- (id)mutableCopyWithContext:(CBMutableCopyContext*)context
{
    LoopEndBrick *brick = [self mutableCopyWithContext:context AndErrorReporting:NO];
    LoopBeginBrick<CBConditionProtocol> *beginBrick = [context updatedReferenceForReference:self.loopBeginBrick];
    
    if(beginBrick) {
        brick.loopBeginBrick = beginBrick;
        beginBrick.loopEndBrick = brick;
    } else {
        NSError(@"LoopBeginBrick must not be nil for Brick with class %@!", [self class]);
    }
    return brick;
}

#pragma mark - Resources
- (NSInteger)getRequiredResources
{
    return kNoResources;
}

@end
