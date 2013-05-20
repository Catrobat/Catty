//
//  UserVariablesContainer.m
//  Catty
//
//  Created by Dominik Ziegler on 5/3/13.
//
//

#import "VariablesContainer.h"
#import "UserVariable.h"
#import <pthread.h>

@implementation VariablesContainer

static pthread_mutex_t variablesLock;

-(id)init
{
    self = [super init];
    if(self) {
        pthread_mutex_init(&variablesLock,NULL);
    }
    return self;
}

-(void)dealloc
{
    [self.objectVariableList removeAllObjects];
    [self.programVariableList removeAllObjects];
    self.programVariableList = nil;
    self.objectVariableList = nil;
    pthread_mutex_destroy(&variablesLock);
}


-(Uservariable*) getUserVariableNamed:(NSString*) name forSpriteObject:(SpriteObject*) sprite
{
    NSArray* objectUserVariables = [self.objectVariableList objectForKey:sprite];
    
    Uservariable* variable = [self findUserVariableNamed:name inArray:objectUserVariables];
    
    if(!variable) {
        variable = [self findUserVariableNamed:name inArray:self.programVariableList];
    }
    return variable;
    
}


-(Uservariable*) findUserVariableNamed:(NSString*)name inArray:(NSArray*)userVariables
{
    Uservariable* variable = nil;
    pthread_mutex_lock(&variablesLock);
    for(int i=0; i<[userVariables count]; i++) {
        Uservariable* var = [userVariables objectAtIndex:i];
        if([var.name isEqualToString:name]) {
            variable = var;
            break;
        }
    }
    pthread_mutex_unlock(&variablesLock);
    
    return variable;
}

-(void) setUserVariable:(Uservariable*)userVariable toValue:(double)value
{
    pthread_mutex_lock(&variablesLock);
    userVariable.value = [NSNumber numberWithDouble:value];
    pthread_mutex_unlock(&variablesLock);
}




@end

