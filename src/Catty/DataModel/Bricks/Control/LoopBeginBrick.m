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

#import "LoopBeginBrick.h"
#import "Util.h"

@implementation LoopBeginBrick

- (BOOL)isLoopBrick
{
    return YES;
}

- (NSArray*)conditions
{
    return @[];
}

- (BOOL)checkCondition
{
    NSError(@"Abstract class. Override checkCondition in Subclass: %@", [self class]);
    return NO;
}

- (void)resetCondition
{
    NSError(@"Abstract class. Override resetCondition in Subclass: %@", [self class]);
}

#pragma mark - Compare
- (BOOL)isEqualToBrick:(Brick*)brick
{
    if(![Util isEqual:self.loopEndBrick.brickTitle toObject:((LoopBeginBrick*)brick).loopEndBrick.brickTitle ])
        return NO;
    return YES;
}

#pragma mark - Resources
- (NSInteger)getRequiredResources
{
    return kNoResources;
}

@end
