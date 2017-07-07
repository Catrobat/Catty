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
#import "OrderedMapTable.h"

@implementation Scene


- (instancetype)initWithName:(NSString *)name
                  objectList:(NSMutableArray<SpriteObject *> *)objectList
          objectVariableList:(OrderedMapTable *)objectVariableList
               originalWidth:(NSString *)originalWidth
              originalHeight:(NSString *)originalHeight {
    NSParameterAssert(name);
    NSParameterAssert(objectList);
    NSParameterAssert(objectVariableList);
    NSParameterAssert(originalWidth);
    NSParameterAssert(originalHeight);
    
    self = [super init];
    if (self != nil) {
        _name = [name copy];
        _objectList = objectList;
        _objectVariableList = objectVariableList;
        _originalWidth = [originalWidth copy];
        _originalHeight = [originalHeight copy];
    }
    return self;
}

- (SpriteObject *)background {
    return [self.objectList firstObject];
}

- (void)addObject:(SpriteObject *)object {
    NSParameterAssert(object);
    
    [self.objectList addObject:object];
}

- (void)removeObject:(SpriteObject *)object {
    NSParameterAssert(object);
    NSParameterAssert([self.objectList containsObject:object]);
    
    [object removeSounds:object.soundList AndSaveToDisk:NO];
    [object removeLooks:object.lookList AndSaveToDisk:NO];
    object.program = nil;
    [self.objectList removeObject:object];
}

- (void)moveObjectFromIndex:(NSUInteger)originIndex toIndex:(NSUInteger)destinationIndex {
    NSParameterAssert(originIndex < [self.objectList count]);
    NSParameterAssert(destinationIndex < [self.objectList count]);
    
    if (originIndex == destinationIndex) {
        return;
    }
    SpriteObject *object = [self.objectList objectAtIndex:originIndex];
    [self.objectList removeObjectAtIndex:originIndex];
    [self.objectList insertObject:object atIndex:destinationIndex];
}

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (![[other class] isEqual:[self class]])
        return NO;
    
    return [self isEqualToScene:other];
}

- (BOOL)isEqualToScene:(Scene *)scene {
    return [self.name isEqualToString:scene.name]
        && [self isObjectListEqualTo:scene.objectList]
        && [self.objectVariableList isEqualToOrderedMapTable:scene.objectVariableList]
        && [self.originalWidth isEqualToString:scene.originalWidth]
        && [self.originalHeight isEqualToString:scene.originalHeight];
}

- (BOOL)isObjectListEqualTo:(NSMutableArray<SpriteObject *> *)objectList {
    if ([self.objectList count] != [objectList count])
        return NO;
    
    for (SpriteObject *object in self.objectList) {
        if (![objectList containsObject:object])
            return NO;
    }
    for (SpriteObject *object in objectList) {
        if (![self.objectList containsObject:object])
            return NO;
    }
    
    return YES;
}

@end
