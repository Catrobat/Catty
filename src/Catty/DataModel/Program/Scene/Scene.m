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

#import "Scene.h"
#import "SpriteObject.h"

@implementation Scene

- (instancetype)initWithName:(NSString *)name objects:(NSMutableArray<SpriteObject *> *)objects {
    NSParameterAssert(name);
    NSParameterAssert(objects);
    
    self = [super init];
    if (self != nil) {
        _name = [name copy];
        _allObjects = objects;
    }
    return self;
}

- (SpriteObject *)background {
    return [self.allObjects firstObject];
}

- (void)addObject:(SpriteObject *)object {
    NSParameterAssert(object);
    
    [_allObjects addObject:object];
}

- (void)removeObject:(SpriteObject *)object {
    NSParameterAssert(object);
    NSParameterAssert([self.allObjects containsObject:object]);
    
    [object removeSounds:object.soundList AndSaveToDisk:NO];
    [object removeLooks:object.lookList AndSaveToDisk:NO];
    object.program = nil;
    [self.allObjects removeObject:object];
}

- (void)moveObjectFromIndex:(NSUInteger)originIndex toIndex:(NSUInteger)destinationIndex {
    NSParameterAssert(originIndex < [self.allObjects count]);
    NSParameterAssert(destinationIndex < [self.allObjects count]);
    
    if (originIndex == destinationIndex) {
        return;
    }
    SpriteObject *object = [self.allObjects objectAtIndex:originIndex];
    [self.allObjects removeObjectAtIndex:originIndex];
    [self.allObjects insertObject:object atIndex:destinationIndex];
}

@end
