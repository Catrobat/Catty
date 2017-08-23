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
#import "NSArray+CustomExtension.h"
#import "UserVariable.h"
#import "LanguageTranslationDefines.h"
#import "Util.h"

@implementation Scene


- (instancetype)initWithName:(NSString *)name
                  objectList:(NSArray<SpriteObject *> *)objectList
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
        
        _objectList = [objectList mutableCopy];
        [_objectList cb_foreachUsingBlock:^(SpriteObject *item) {
            item.scene = self;
        }];
        
        _objectVariableList = [objectVariableList mutableCopy];
        _originalWidth = [originalWidth copy];
        _originalHeight = [originalHeight copy];
    }
    return self;
}

+ (instancetype)defaultSceneWithName:(NSString *)name {
    NSParameterAssert(name);
    
    SpriteObject *backgroundObject = [[SpriteObject alloc] init];
    backgroundObject.name = kLocalizedBackground;
    
    return [[[self class] alloc] initWithName:name
                                   objectList:@[backgroundObject]
                           objectVariableList:[OrderedMapTable weakToStrongObjectsMapTable]
                                originalWidth:[NSString stringWithFormat:@"%f", [Util screenWidth] ?: 768]
                               originalHeight:[NSString stringWithFormat:@"%f", [Util screenHeight] ?: 1184]];
}

- (SpriteObject *)backgroundObject {
    return [self.objectList firstObject];
}

- (NSArray<UserVariable *> *)allAccessibleVarialbes {
    NSMutableArray<UserVariable *> *variables = [NSMutableArray array];
    for (SpriteObject *object in self.objectList) {
        [variables addObjectsFromArray:object.variables];
    }
    
    NSArray<UserVariable *> *programVariableList = self.program.programVariableList;
    if (programVariableList != nil) {
        [variables addObjectsFromArray:programVariableList];
    }
    
    return variables;
}

- (NSArray<NSString *> *)allObjectNames {
    return [self.objectList cb_mapUsingBlock:^id(SpriteObject *item) {
        return item.name;
    }];
}

- (void)addObject:(SpriteObject *)object {
    NSParameterAssert(object);
    NSAssert(![[self allObjectNames] containsObject:object.name], @"Object with such name already exists");
    
    object.scene = self;
    [self.objectList addObject:object];
}

- (void)addVariable:(UserVariable *)variable forObject:(SpriteObject *)object {
    NSParameterAssert(variable);
    NSParameterAssert(object);
    NSParameterAssert([self.objectList containsObject:object]);
    
    NSAssert(![[object allAccessibleVariableNames] containsObject:variable.name], @"Object with such name already exists");
    
    NSMutableArray<UserVariable *> *objectVariables = [self.objectVariableList objectForKey:object];
    if (objectVariables == nil) {
        objectVariables = [NSMutableArray array];
        [self.objectVariableList setObject:objectVariables forKey:object];
    }
    
    [objectVariables addObject:variable];
}

- (void)removeVariable:(UserVariable *)variable forObject:(SpriteObject *)object {
    NSParameterAssert(variable);
    NSParameterAssert(object);
    NSParameterAssert([self.objectList containsObject:object]);
    
    NSMutableArray<UserVariable *> *objectVariables = [self.objectVariableList objectForKey:object];
    NSAssert([objectVariables containsObject:variable], @"Object doesn't have such variable");
    
    [objectVariables removeObject:variable];
}

- (void)removeObject:(SpriteObject *)object {
    NSParameterAssert(object);
    NSParameterAssert([self.objectList containsObject:object]);
    
    [object removeSounds:object.soundList];
    [object removeLooks:object.lookList];
    object.scene = nil;
    
    [self.objectList removeObject:object];
    [self.objectVariableList removeObjectForKey:object];
}

- (void)removeObjects:(NSArray<SpriteObject *> *)objects {
    NSParameterAssert(objects);
    
    for (SpriteObject *object in objects) {
        [self removeObject:object];
    }
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

- (NSInteger)numberOfNormalObjects {
    return self.objectList.count > 1 ? self.objectList.count - 1 : 0;
}

- (NSInteger)getRequiredResources {
    NSInteger resources = kNoResources;
    
    for (SpriteObject *object in self.objectList) {
        resources |= [object getRequiredResources];
    }
    return resources;
}

- (void)removeReferences {
    [self.objectList makeObjectsPerformSelector:@selector(removeReferences)];
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
