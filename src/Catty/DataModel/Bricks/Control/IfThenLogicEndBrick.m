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

#import "IfThenLogicEndBrick.h"
#import "IfThenLogicBeginBrick.h"
#import "Util.h"
#import "CBMutableCopyContext.h"

@implementation IfThenLogicEndBrick

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

- (BOOL)isIfLogicBrick
{
    return YES;
}

- (void)performFromScript:(Script*)script
{
    
}

#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"If Then Logic End Brick"];
}

#pragma mark - Compare
- (BOOL)isEqualToBrick:(Brick*)brick
{
    if ([brick class] != [self class]) {
        return NO;
    }
    
    IfThenLogicEndBrick *logicBrick = (IfThenLogicEndBrick*)brick;
    if ([logicBrick.ifBeginBrick class] != [self.ifBeginBrick class]) {
        return NO;
    }
    return YES;
}

#pragma mark - Copy
- (id)mutableCopyWithContext:(CBMutableCopyContext*)context
{
    IfThenLogicEndBrick *endBrick = [self mutableCopyWithContext:context AndErrorReporting:NO];
    IfThenLogicBeginBrick *beginBrick = [context updatedReferenceForReference:self.ifBeginBrick];
    
    if(beginBrick) {
        endBrick.ifBeginBrick = beginBrick;
        beginBrick.ifEndBrick = endBrick;
    } else {
        NSError(@"IfThenLogicBeginBrick must not be nil for Brick with class %@!", [self class]);
    }
    
    return endBrick;
}

#pragma mark - Resources
- (NSInteger)getRequiredResources
{
    return kNoResources;
}

@end
