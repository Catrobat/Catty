//
//  UserVariablesContainer.m
//  Catty
//
//  Created by Dominik Ziegler on 5/3/13.
//
//

#import "VariablesContainer.h"
#import "UserVariable.h"

@implementation VariablesContainer


-(void)dealloc
{
    [self.objectVariableList removeAllObjects];
    self.programVariableList = nil;
    self.objectVariableList = nil;
}


-(Uservariable*) getUserVariableNamed:(NSString*) name forSpriteObject:(SpriteObject*) sprite
{
    NSDebug(@"Variable: %@", name);
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
    for(Uservariable* var in userVariables) {
        if([var.name isEqualToString:name]) {
            variable = var;
            break;
        }
    }
    
    return variable;
    
}



@end

