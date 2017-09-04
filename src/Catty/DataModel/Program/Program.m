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

#import "Program.h"
#import "Util.h"
#import "AppDelegate.h"
#import "Brick.h"
#import "CatrobatLanguageDefines.h"
#import "CBXMLParser.h"
#import "CBXMLSerializer.h"
#import "CBMutableCopyContext.h"
#import "Scene.h"
#import "OrderedMapTable.h"
#import "Pocket_Code-Swift.h"
#import "NSArray+CustomExtension.h"


@implementation Program

- (instancetype)initWithHeader:(Header *)header scenes:(NSArray<Scene *> *)scenes programVariableList:(NSArray<UserVariable *> *)programVariableList {
    NSParameterAssert(header);
    NSParameterAssert(scenes.count);
    NSParameterAssert(programVariableList);
    
    self = [super init];
    if (self) {
        _header = header;
        
        _scenes = [scenes mutableCopy];
        [_scenes cb_foreachUsingBlock:^(Scene *item) {
            item.program = self;
        }];
        
        _programVariableList = [programVariableList mutableCopy];
    }
    return self;
}

+ (instancetype)defaultProgramWithName:(NSString *)programName {
    NSParameterAssert(programName);
    
    Scene *scene = [Scene defaultSceneWithName:@"Scene 1"];
    
    Header *header = [Header defaultHeader];
    header.programName = [programName copy];
    header.screenWidth = @(scene.originalWidth.floatValue);
    header.screenHeight = @(scene.originalHeight.floatValue);
    
    return [[[self class] alloc] initWithHeader:header scenes:@[scene] programVariableList:@[]];
}

- (NSArray<UserVariable *> *)allVariables {
    NSMutableArray<UserVariable *> *variables = [self.programVariableList mutableCopy];
    
    for (Scene *scene in self.scenes) {
        for (SpriteObject *spriteObject in scene.objectList) {
            [variables addObjectsFromArray:spriteObject.variables];
        }
    }
    
    return [variables copy];
}

- (NSArray<NSString *> *)allVariableNames {
    return [[self allVariables] cb_mapUsingBlock:^id(UserVariable *item) {
        return item.name;
    }];
}

- (NSArray<NSString *> *)allSceneNames {
    return [[self scenes] cb_mapUsingBlock:^id(Scene *item) {
        return item.name;
    }];
}

- (NSString *)programName {
    return self.header.programName;
}

- (NSString *)programID {
    return self.header.programID;
}

- (NSString *)programDescription {
    return self.header.programDescription;
}

- (void)setProgramDescription:(NSString *)programDescription {
    self.header.programDescription = programDescription;
}

- (void)moveSceneAtIndex:(NSInteger)sourceIndex toIndex:(NSInteger)destinationIndex {
    NSParameterAssert(sourceIndex >= 0 && [self.scenes count] > sourceIndex);
    NSParameterAssert(destinationIndex >= 0 && [self.scenes count] > destinationIndex);
    
    if (sourceIndex == destinationIndex) {
        return;
    }
    Scene *scene = [self.scenes objectAtIndex:sourceIndex];
    [self.scenes removeObjectAtIndex:sourceIndex];
    [self.scenes insertObject:scene atIndex:destinationIndex];
}

- (void)addProgramVariable:(UserVariable *)variable {
    NSParameterAssert(variable);
    NSAssert(![[self allVariableNames] containsObject:variable.name], @"Variable with such name already exists");
    
    [self.programVariableList addObject:variable];
}

- (void)removeProgramVariable:(UserVariable *)variable {
    NSParameterAssert(variable);
    NSAssert([[self programVariableList] containsObject:variable], @"No such program variable");
    
    [self.programVariableList removeObject:variable];
}

- (NSInteger)getRequiredResources {
    NSInteger resources = kNoResources;
    
    for (Scene *scene in self.scenes) {
        resources |= [scene getRequiredResources];
    }
    return resources;
}

- (void)removeReferences {
    [self.scenes makeObjectsPerformSelector:@selector(removeReferences)];
}

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (![[other class] isEqual:[self class]])
        return NO;
    
    return [self isEqualToProgram:other];
}

- (BOOL)isEqualToProgram:(Program *)program {
    return [program.header isEqualToHeader:self.header]
    && [program.scenes isEqualToArray:self.scenes]
    && [program.programVariableList isEqualToArray:self.programVariableList];
}

- (NSString*)description {
    NSMutableString *ret = [[NSMutableString alloc] init];
    [ret appendFormat:@"Header:\n %@\n", [self.header description]];
    [ret appendFormat:@"Scenes: %@\n", self.scenes];
    [ret appendFormat:@"Program Variable List: %@\n", self.programVariableList];
    return [ret copy];
}

@end
