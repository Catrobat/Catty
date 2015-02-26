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

#import "CBXMLOpenedNestingBricksStack.h"

@interface CBXMLOpenedNestingBricksStack ()

@property (nonatomic, strong) NSMutableArray *openedNestingBricks;
@property (nonatomic, readwrite) NSUInteger numberOfOpenedNestingBricks;

@end

@implementation CBXMLOpenedNestingBricksStack

- (NSUInteger)numberOfOpenedNestingBricks
{
    return [self.openedNestingBricks count];
}

- (void)pushAndOpenNestingBrick:(Brick*)openedNestingBricks
{
    if (! openedNestingBricks) {
        return;
    }
    [self.openedNestingBricks addObject:openedNestingBricks];
}

- (Brick*)popAndCloseTopMostNestingBrick
{
    if ([self.openedNestingBricks count]) {
        Brick *brick = self.openedNestingBricks.lastObject;
        [self.openedNestingBricks removeLastObject];
        return brick;
    }
    return nil;
}

- (BOOL)isEmpty
{
    return ([self.openedNestingBricks count] == 0);
}

- (NSMutableArray*)openedNestingBricks
{
    if(!_openedNestingBricks) {
        _openedNestingBricks = [[NSMutableArray alloc] init];
    }
    return _openedNestingBricks;
}

#pragma mark - NSFastEnumeration
- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState*)state
                                  objects:(__unsafe_unretained id[])buffer
                                    count:(NSUInteger)len
{
    return [self.openedNestingBricks countByEnumeratingWithState:state objects:buffer count:len];
}

- (id)mutableCopy
{
    CBXMLOpenedNestingBricksStack *copiedOpenedNestingBricksStack = [[self class] new];
    copiedOpenedNestingBricksStack.openedNestingBricks = [self.openedNestingBricks mutableCopy];
    copiedOpenedNestingBricksStack.numberOfOpenedNestingBricks = self.numberOfOpenedNestingBricks;
    return copiedOpenedNestingBricksStack;
}

@end
