/**
 *  Copyright (C) 2010-2016 The Catrobat Team
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
#import "CBStack.h"

@interface CBXMLOpenedNestingBricksStack ()
@property (nonatomic, strong) CBStack *stackStorageBackend;
@end

@implementation CBXMLOpenedNestingBricksStack

- (CBStack*)stackStorageBackend
{
    if (! _stackStorageBackend) {
        _stackStorageBackend = [CBStack new];
    }
    return _stackStorageBackend;
}

- (NSUInteger)numberOfOpenedNestingBricks
{
    return self.stackStorageBackend.numberOfElements;
}

- (void)pushAndOpenNestingBrick:(Brick*)openedNestingBrick
{
    if (! openedNestingBrick) {
        return;
    }
    [self.stackStorageBackend pushElement:openedNestingBrick];
}

- (Brick*)popAndCloseTopMostNestingBrick
{
    if (self.stackStorageBackend.numberOfElements) {
        return (Brick*)[self.stackStorageBackend popElement];
    }
    return nil;
}

- (BOOL)isEmpty
{
    return (self.numberOfOpenedNestingBricks == 0);
}

#pragma mark - NSFastEnumeration
- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState*)state
                                  objects:(__unsafe_unretained id[])buffer
                                    count:(NSUInteger)len
{
    return [self.stackStorageBackend.stack countByEnumeratingWithState:state objects:buffer count:len];
}

- (id)mutableCopy
{
    CBXMLOpenedNestingBricksStack *copiedOpenedNestingBricksStack = [[self class] new];
    copiedOpenedNestingBricksStack.stackStorageBackend = [self.stackStorageBackend mutableCopy];
    return copiedOpenedNestingBricksStack;
}

@end
