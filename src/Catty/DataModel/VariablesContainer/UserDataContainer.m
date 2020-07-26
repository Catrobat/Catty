/**
 *  Copyright (C) 2010-2020 The Catrobat Team
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

#import "UserDataContainer.h"
#import "Pocket_Code-Swift.h"
#import "OrderedMapTable.h"
#include "SpriteObject.h"
#import <pthread.h>

@interface UserDataContainer()
@property (nonatomic, strong) NSMutableArray<UserVariable*> *variables;
@property (nonatomic, strong) NSMutableArray<UserList*> *lists;
@end

@implementation UserDataContainer

static pthread_mutex_t variablesLock;
@synthesize variables = _variables;
@synthesize lists = _lists;

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
    NSDebug(@"Dealloc Variables and Lists");
    [_lists removeAllObjects];
    [_variables removeAllObjects];
    self.variables = nil;
    self.lists = nil;
    pthread_mutex_destroy(&variablesLock);
}

#pragma mark custom getters and setters

- (NSArray<UserVariable*> *)variables
{
    // lazy instantiation
    if (! _variables)
        _variables = [NSMutableArray array];
    return _variables;
}

- (NSArray<UserList*> *)lists
{
    // lazy instantiation
    if (! _lists)
        _lists = [NSMutableArray array];
    return _lists;
}

- (void)removeAllVariables
{
    pthread_mutex_lock(&variablesLock);
    if (_variables) {
        [_variables removeAllObjects];
    }
    pthread_mutex_unlock(&variablesLock);
}

- (void)removeAllLists
{
    pthread_mutex_lock(&variablesLock);
    if (_lists) {
        [_lists removeAllObjects];
    }
    pthread_mutex_unlock(&variablesLock);
}

- (UserVariable*)getUserVariableWithName:(NSString*)name
{
    UserVariable *variable = nil;
    pthread_mutex_lock(&variablesLock);
    for (int i = 0; i < [self.variables count]; ++i) {
        UserVariable *var = [self.variables objectAtIndex:i];
        if ([var.name isEqualToString:name]) {
            variable = var;
            break;
        }
    }
    pthread_mutex_unlock(&variablesLock);
    return variable;
}

- (UserList*)getUserListWithName:(NSString*)name
{
    UserList *list = nil;
    pthread_mutex_lock(&variablesLock);
    for (int i = 0; i < [self.lists count]; ++i) {
        UserList *lis = [self.lists objectAtIndex:i];
        if ([lis.name isEqualToString:name]) {
            list = lis;
            break;
        }
    }
    pthread_mutex_unlock(&variablesLock);
    return list;
}

- (BOOL)removeUserVariableWithName:(NSString*)name
{
    UserVariable *variable = [self getUserVariableWithName:name];
    if (variable) {
        pthread_mutex_lock(&variablesLock);
        for (int i = 0; i < [self.variables count]; ++i) {
            UserVariable *var = [self.variables objectAtIndex:i];
            if ([var.name isEqualToString:name]) {
                [_variables removeObjectAtIndex:i];
                break;
            }
        }
        pthread_mutex_unlock(&variablesLock);
        return YES;
    }
    return NO;
}

- (BOOL)removeUserListWithName:(NSString*)name
{
    UserList *list = [self getUserListWithName:name];
    if (list) {
        pthread_mutex_lock(&variablesLock);
        for (int i = 0; i < [self.lists count]; ++i) {
            UserList *list = [self.lists objectAtIndex:i];
            if ([list.name isEqualToString:name]) {
                [_lists removeObjectAtIndex:i];
                break;
            }
        }
        pthread_mutex_unlock(&variablesLock);
        return YES;
    }
    return NO;
}

- (BOOL)containsVariable: (UserVariable*)userVariable
{
    for (UserVariable *userVariableToCompare in self.variables) {
        if ([userVariableToCompare.name isEqualToString:userVariable.name]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)containsList: (UserList*)userList
{
    for (UserVariable *userListToCompare in self.lists) {
        if ([userListToCompare.name isEqualToString:userList.name]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)addVariable:(UserVariable*)userVariable
{
    if (!_variables) {
        _variables = [NSMutableArray new];
    } else {
        for (UserVariable *userVariableToCompare in self.variables) {
            if ([userVariableToCompare.name isEqualToString:userVariable.name]) {
                return NO;
            }
        }
    }
    
    [_variables addObject:userVariable];
    return YES;
}

- (BOOL)addList:(UserList*)userList
{
    if (!_lists) {
        _lists = [NSMutableArray new];
    } else {
        for (UserVariable *userListToCompare in self.lists) {
            if ([userListToCompare.name isEqualToString:userList.name]) {
                return NO;
            }
        }
    }
    
    [_lists addObject: userList];
    return YES;
}

- (BOOL)isEqualToUserDataContainer:(UserDataContainer*)userDataContainer
{
    NSMutableArray *progVarsAndLists = [[NSMutableArray alloc] initWithCapacity: 2];
    [progVarsAndLists insertObject:[NSMutableArray arrayWithObjects:self.variables,userDataContainer.variables, nil] atIndex:0];
    [progVarsAndLists insertObject:[NSMutableArray arrayWithObjects:self.lists,userDataContainer.lists, nil] atIndex:1];
    
    for (NSMutableArray *varsOrLists in progVarsAndLists) {
        NSMutableArray *thisVarsOrLists = [varsOrLists objectAtIndex:0];
        NSMutableArray *otherVarsOrLists = [varsOrLists objectAtIndex:1];
        
        if ([thisVarsOrLists count] != [otherVarsOrLists count])
            return NO;
        
        for (id<UserDataProtocol> firstVariable in thisVarsOrLists) {
            id<UserDataProtocol> secondVariable = nil;
            // look for variable with same name (order in variable list can differ)
            for (id<UserDataProtocol> variable in otherVarsOrLists) {
                if ([firstVariable.name isEqualToString:variable.name]) {
                    secondVariable = variable;
                    break;
                }
            }
            if ((secondVariable == nil) || (! [firstVariable isEqual:secondVariable]))
                return NO;
        }
    }
    return YES;
}

- (id)mutableCopy
{
    UserDataContainer *copiedUserDataContainer = [UserDataContainer new];
    copiedUserDataContainer.variables = [self.variables mutableCopy];
    copiedUserDataContainer.lists = [self.lists mutableCopy];

    return copiedUserDataContainer;
}

@end
