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

#import "IfLogicElseBrick.h"
#import "IfLogicBeginBrick.h"
#import "IfLogicEndBrick.h"
#import "Util.h"

@implementation IfLogicElseBrick

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
    NSDebug(@"Performing: %@", self.description);
}

- (Brick*)cloneWithScript:(Script *)script
{
    IfLogicElseBrick *clone = [[IfLogicElseBrick alloc] init];
    clone.script = script;
    
    for (Brick *brick in script.brickList.reverseObjectEnumerator) {
        if ([brick isKindOfClass: [IfLogicBeginBrick class]]) {
            IfLogicBeginBrick *beginBrick = (IfLogicBeginBrick*) brick;
            if (beginBrick.ifElseBrick == nil) {
                beginBrick.ifElseBrick = clone;
                clone.ifBeginBrick = beginBrick;
                break;
            }
        }
    }
    
    return clone;
}

#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"If Logic Else Brick"];
}

#pragma mark - Compare
- (BOOL)isEqualToBrick:(Brick*)brick
{
    if ([brick class] != [self class]) {
        return NO;
    }
         
    IfLogicElseBrick *logicBrick = (IfLogicElseBrick*)brick;
    if ([logicBrick.ifBeginBrick class] != [self.ifBeginBrick class]) {
        return NO;
    }
    if ([logicBrick.ifEndBrick class] != [self.ifEndBrick class]) {
        return NO;
    }
    return YES;
}

#pragma mark - Resources
- (NSInteger)getRequiredResources
{
    return kNoResources;
}

@end
