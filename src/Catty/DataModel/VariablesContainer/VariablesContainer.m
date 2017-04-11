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

#import "VariablesContainer.h"
#import "UserVariable.h"
#import "OrderedMapTable.h"
#include "SpriteObject.h"
#import <pthread.h>

@implementation VariablesContainer

static pthread_mutex_t variablesLock;

- (id)init
{
    self = [super init];
    if (self) {
        pthread_mutex_init(&variablesLock,NULL);
    }
    return self;
}

- (void)dealloc
{
    NSDebug(@"Dealloc Variables");
    [self.objectVariableList removeAllObjects];
    [self.programVariableList removeAllObjects];
    self.programVariableList = nil;
    self.objectVariableList = nil;
    pthread_mutex_destroy(&variablesLock);
}

#pragma mark custom getters and setters

- (OrderedMapTable*)objectVariableList
{
    // lazy instantiation
    if (! _objectVariableList)
        _objectVariableList = [OrderedMapTable weakToStrongObjectsMapTable];
    return _objectVariableList;
}

- (OrderedMapTable*)objectListOfLists
{
    // lazy instantiation
    if (! _objectListOfLists)
        _objectListOfLists = [OrderedMapTable weakToStrongObjectsMapTable];
    return _objectListOfLists;
}

- (NSMutableArray*)programVariableList
{
    // lazy instantiation
    if (! _programVariableList)
        _programVariableList = [NSMutableArray array];
    return _programVariableList;
}

- (NSMutableArray*)programListOfLists
{
    // lazy instantiation
    if (! _programListOfLists)
        _programListOfLists = [NSMutableArray array];
    return _programListOfLists;
}


- (UserVariable*)getUserVariableNamed:(NSString*)name forSpriteObject:(SpriteObject*)sprite isList:(BOOL)isList
{
    NSArray *objectUserVariables = [self.objectVariableList objectForKey:sprite];
    UserVariable *variable = [self findUserVariableNamed:name inArray:objectUserVariables];

    if (! variable) {
        variable = [self findUserVariableNamed:name inArray:self.programVariableList];
    }
    return variable;
}

- (BOOL)removeUserVariableNamed:(NSString*)name forSpriteObject:(SpriteObject*)sprite
{
    NSMutableArray *objectUserVariables = [self.objectVariableList objectForKey:sprite];
    UserVariable *variable = [self findUserVariableNamed:name inArray:objectUserVariables];
    if (variable) {
        [self removeObjectUserVariableNamed:name inArray:objectUserVariables forSpriteObject:sprite];
        return YES;
    } else {
        variable = [self findUserVariableNamed:name inArray:self.programVariableList];
        if (variable) {
                [self removeProgramUserVariableNamed:name];
            return YES;
        }
    }
    return NO;
}

- (UserVariable*)findUserVariableNamed:(NSString*)name inArray:(NSArray*)userVariables
{
    UserVariable *variable = nil;
    pthread_mutex_lock(&variablesLock);
    for (int i = 0; i < [userVariables count]; ++i) {
        UserVariable *var = [userVariables objectAtIndex:i];
        if ([var.name isEqualToString:name]) {
            variable = var;
            break;
        }
    }
    pthread_mutex_unlock(&variablesLock);
    return variable;
}

- (void)removeObjectUserVariableNamed:(NSString*)name inArray:(NSMutableArray*)userVariables forSpriteObject:(SpriteObject*)sprite
{
    pthread_mutex_lock(&variablesLock);
    for (int i = 0; i < [userVariables count]; ++i) {
        UserVariable *var = [userVariables objectAtIndex:i];
        if ([var.name isEqualToString:name]) {
            [userVariables removeObjectAtIndex:i];
            [self.objectVariableList setObject:userVariables forKey:sprite];
            break;
        }
    }
    pthread_mutex_unlock(&variablesLock);
}

- (void)removeProgramUserVariableNamed:(NSString*)name
{
    pthread_mutex_lock(&variablesLock);
    for (int i = 0; i < [self.programVariableList count]; ++i) {
        UserVariable *var = [self.programVariableList objectAtIndex:i];
        if ([var.name isEqualToString:name]) {
            [self.programVariableList removeObjectAtIndex:i];
            break;
        }
    }
    pthread_mutex_unlock(&variablesLock);
}

- (void)setUserVariable:(UserVariable*)userVariable toValue:(id)value
{
    pthread_mutex_lock(&variablesLock);
    if([value isKindOfClass:[NSString class]]){
        NSString *stringValue = (NSString*)value;
        userVariable.value = stringValue;
    } else if([value isKindOfClass:[NSNumber class]]){
        NSNumber *numberValue = (NSNumber*)value;
        userVariable.value = numberValue;
    } else {
        userVariable.value = [NSNumber numberWithInt:0];
    }
    pthread_mutex_unlock(&variablesLock);
}

- (void)changeVariable:(UserVariable*)userVariable byValue:(double)value
{
    pthread_mutex_lock(&variablesLock);
    if ([userVariable.value isKindOfClass:[NSNumber class]]){
        userVariable.value = [NSNumber numberWithFloat:(CGFloat)(([userVariable.value doubleValue] + value))];
    }
    pthread_mutex_unlock(&variablesLock);
}

- (NSArray*)allVariablesForObject:(SpriteObject*)spriteObject
{
    NSMutableArray *vars = [NSMutableArray arrayWithArray:self.programVariableList];
    [vars addObjectsFromArray:[self objectVariablesForObject:spriteObject]];
    return vars;
}

- (NSMutableArray*)allVariables
{
    NSMutableArray *vars = [NSMutableArray arrayWithArray:self.programVariableList];
    for(NSUInteger index = 0; index < [self.objectVariableList count]; index++) {
        NSMutableArray *variableList = [self.objectVariableList objectAtIndex:index];
        if([variableList count] > 0)
            [vars addObjectsFromArray:variableList];
    }
    return vars;
}

- (NSMutableArray*)allLists
{
    NSMutableArray *vars = [NSMutableArray arrayWithArray:self.programListOfLists];
    for(NSUInteger index = 0; index < [self.objectListOfLists count]; index++) {
        NSMutableArray *listOfLists = [self.objectListOfLists objectAtIndex:index];
        if([listOfLists count] > 0)
            [vars addObjectsFromArray:listOfLists];
    }
    return vars;
}

- (NSMutableArray*)allVariablesAndLists
{
    NSMutableArray *vars = [self allVariables ];
    NSMutableArray *lists = [self allLists ];
    if([vars count] > 0){
        [vars addObjectsFromArray:lists];
    }
    
    return vars;
}

- (NSArray*)objectVariablesForObject:(SpriteObject*)spriteObject
{
    NSMutableArray *vars = [NSMutableArray new];
    if([self.objectVariableList objectForKey:spriteObject]) {
        for(UserVariable *var in [self.objectVariableList objectForKey:spriteObject]) {
            [vars addObject:var];
        }
    }
    return vars;
}

- (SpriteObject*)spriteObjectForObjectVariable:(UserVariable*)userVariable
{
    if (!userVariable.isList)
    {
        for (NSUInteger index = 0; index < [self.objectVariableList count]; ++index) {
            SpriteObject *spriteObject = [self.objectVariableList keyAtIndex:index];
            NSMutableArray *userVariableList = [self.objectVariableList objectAtIndex:index];
            for (UserVariable *userVariableToCompare in userVariableList) {
                if (userVariableToCompare == userVariable) {
                    return spriteObject;
                }
            }
        }
    }
    if (userVariable.isList)
    {
        for (NSUInteger index = 0; index < [self.objectListOfLists count]; ++index) {
            SpriteObject *spriteObject = [self.objectListOfLists keyAtIndex:index];
            NSMutableArray *userListOfLists = [self.objectListOfLists objectAtIndex:index];
            for (UserVariable *userListToCompare in userListOfLists) {
                if (userListToCompare == userVariable) {
                    return spriteObject;
                }
            }
        }
    }
    return nil;
}

- (BOOL)isVariableOfSpriteObject:(SpriteObject*)spriteObject userVariable:(UserVariable*)userVariable
{
    for (NSUInteger index = 0; index < [self.objectVariableList count]; ++index) {
        SpriteObject *spriteObjectToCompare = [self.objectVariableList keyAtIndex:index];
        if (spriteObjectToCompare != spriteObject) {
            continue;
        }

        NSMutableArray *userVariableList = [self.objectVariableList objectAtIndex:index];
        for (UserVariable *userVariableToCompare in userVariableList) {
            if ([userVariableToCompare.name isEqualToString:userVariable.name]) {
                return YES;
            }
        }
    }
    return NO;
}

- (BOOL)isProgramVariable:(UserVariable*)userVariable
{
    for (UserVariable *userVariableToCompare in self.programVariableList) {
        if ([userVariableToCompare.name isEqualToString:userVariable.name]) {
            return YES;
        }
    }
    for (UserVariable *userListToCompare in self.programListOfLists) {
        if ([userListToCompare.name isEqualToString:userVariable.name]) {
            return YES;
        }
    }
    return NO;
}

- (void)removeObjectVariablesForSpriteObject:(SpriteObject*)object
{
    [self.objectVariableList removeObjectForKey:object];
}

- (BOOL)isEqualToVariablesContainer:(VariablesContainer*)variablesContainer
{
    //----------------------------------------------------------------------------------------------------
    // objectVariableList
    //----------------------------------------------------------------------------------------------------
    if ([self.objectVariableList count] != [variablesContainer.objectVariableList count])
        return NO;
    
    NSUInteger index;
    for(index = 0; index < [self.objectVariableList count]; ++index) {
        //----------------------------------------------------------------------------------------------------
        // 1) compare keys (sprite object of both object variables)
        //----------------------------------------------------------------------------------------------------
        SpriteObject *firstObject = [self.objectVariableList keyAtIndex:index];
        SpriteObject *secondObject = nil;
        NSUInteger idx;
        // look for object with same name (order in variable list can differ)
        for (idx = 0; idx < [variablesContainer.objectVariableList count]; ++idx) {
            SpriteObject *spriteObject = [variablesContainer.objectVariableList keyAtIndex:idx];
            if ([spriteObject.name isEqualToString:firstObject.name]) {
                secondObject = spriteObject;
                break;
            }
        }
        if (secondObject == nil || (! [firstObject isEqualToSpriteObject:secondObject]))
            return NO;

        //----------------------------------------------------------------------------------------------------
        // 2) compare values (all user variables of both object variables)
        //----------------------------------------------------------------------------------------------------
        NSMutableArray *firstUserVariableList = [self.objectVariableList objectAtIndex:index];
        NSMutableArray *secondUserVariableList = [variablesContainer.objectVariableList objectAtIndex:idx];

        if ([firstUserVariableList count] != [secondUserVariableList count])
            return NO;

        for (UserVariable *firstVariable in firstUserVariableList) {
            UserVariable *secondVariable = nil;
            // look for variable with same name (order in variable list can differ)
            for (UserVariable *variable in secondUserVariableList) {
                if ([firstVariable.name isEqualToString:variable.name]) {
                    secondVariable = variable;
                    break;
                }
            }

            if ((secondVariable == nil) || (! [firstVariable isEqualToUserVariable:secondVariable]))
                return NO;
        }
    }

    //----------------------------------------------------------------------------------------------------
    // programVariableList
    //----------------------------------------------------------------------------------------------------
    if ([self.programVariableList count] != [variablesContainer.programVariableList count])
        return NO;

    for (UserVariable *firstVariable in self.programVariableList) {
        UserVariable *secondVariable = nil;
        // look for variable with same name (order in variable list can differ)
        for (UserVariable *variable in variablesContainer.programVariableList) {
            if ([firstVariable.name isEqualToString:variable.name]) {
                secondVariable = variable;
                break;
            }
        }
        if ((secondVariable == nil) || (! [firstVariable isEqualToUserVariable:secondVariable]))
            return NO;
    }
    return YES;
}

- (id)mutableCopy
{
    VariablesContainer *copiedVariablesContainer = [VariablesContainer new];
    copiedVariablesContainer.objectVariableList = [self.objectVariableList mutableCopy];
    copiedVariablesContainer.programVariableList = [self.programVariableList mutableCopy];
    return copiedVariablesContainer;
}

@end
