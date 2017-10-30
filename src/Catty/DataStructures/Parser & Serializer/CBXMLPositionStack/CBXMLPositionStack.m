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

#import "CBXMLPositionStack.h"
#import "CBStack.h"

@interface CBXMLPositionStack ()
@property (nonatomic, strong) CBStack *stackStorageBackend;
@end

@implementation CBXMLPositionStack

#pragma mark - Getters and Setters
- (NSUInteger)numberOfXmlElements
{
    return self.stackStorageBackend.numberOfElements;
}

- (NSMutableArray*)stack
{
    return self.stackStorageBackend.stack;
}

- (CBStack*)stackStorageBackend
{
    if (! _stackStorageBackend) {
        _stackStorageBackend = [CBStack new];
    }
    return _stackStorageBackend;
}

#pragma mark - Operations
- (void)pushXmlElementName:(NSString*)xmlElementName
{
    [self.stackStorageBackend pushElement:xmlElementName];
}

- (NSString*)popXmlElementName
{
    return (NSString*)[self.stackStorageBackend popElement];
}

- (BOOL)isEmpty
{
    return (self.numberOfXmlElements == 0);
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
    CBXMLPositionStack *copiedPositionStack = [[self class] new];
    copiedPositionStack.stackStorageBackend = [self.stackStorageBackend mutableCopy];
    return copiedPositionStack;
}

@end
