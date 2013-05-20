//
//  UserVariablesContainer.h
//  Catty
//
//  Created by Dominik Ziegler on 5/3/13.
//
//

#import <Foundation/Foundation.h>


@class SpriteObject;
@class Uservariable;

@interface VariablesContainer : NSObject


// Map<Sprite, List<UserVariable>
@property (nonatomic, strong) NSMapTable* objectVariableList;

// List<UserVariable> projectVariables;
@property (nonatomic, strong) NSMutableArray* programVariableList;


-(Uservariable*) getUserVariableNamed:(NSString*) name forSpriteObject:(SpriteObject*) sprite;

-(void) setUserVariable:(Uservariable*)userVariable toValue:(double)value;

@end
