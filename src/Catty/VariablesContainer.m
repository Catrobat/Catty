/**
 *  Copyright (C) 2010-2013 The Catrobat Team
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
#import <pthread.h>

@implementation VariablesContainer

static pthread_mutex_t variablesLock;

-(id)init
{
    self = [super init];
    if (self) {
        pthread_mutex_init(&variablesLock,NULL);
    }
    return self;
}

-(void)dealloc
{
    NSDebug(@"Dealloc Variables");
    [self.objectVariableList removeAllObjects];
    [self.programVariableList removeAllObjects];
    self.programVariableList = nil;
    self.objectVariableList = nil;
    pthread_mutex_destroy(&variablesLock);
}


-(UserVariable*) getUserVariableNamed:(NSString*) name forSpriteObject:(SpriteObject*) sprite
{
    NSArray* objectUserVariables = [self.objectVariableList objectForKey:sprite];
    
    UserVariable* variable = [self findUserVariableNamed:name inArray:objectUserVariables];
    
    if(!variable) {
        variable = [self findUserVariableNamed:name inArray:self.programVariableList];
    }
    return variable;
    
}


-(UserVariable*) findUserVariableNamed:(NSString*)name inArray:(NSArray*)userVariables
{
    UserVariable* variable = nil;
    pthread_mutex_lock(&variablesLock);
    for(int i=0; i<[userVariables count]; i++) {
        UserVariable* var = [userVariables objectAtIndex:i];
        if([var.name isEqualToString:name]) {
            variable = var;
            break;
        }
    }
    pthread_mutex_unlock(&variablesLock);
    
    return variable;
}

-(void) setUserVariable:(UserVariable*)userVariable toValue:(double)value
{
    pthread_mutex_lock(&variablesLock);
    userVariable.value = [NSNumber numberWithDouble:value];
    pthread_mutex_unlock(&variablesLock);
}

-(void) changeVariable:(UserVariable*)userVariable byValue:(double)value
{
    pthread_mutex_lock(&variablesLock);
    userVariable.value = [NSNumber numberWithFloat:([userVariable.value doubleValue] + value)];
    pthread_mutex_unlock(&variablesLock);
}


@end

