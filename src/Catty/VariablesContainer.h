//
//  UserVariablesContainer.h
//  Catty
//
//  Created by Dominik Ziegler on 5/3/13.
//
//

#import <Foundation/Foundation.h>

@interface Variables : NSObject

// List<UserVariable> projectVariables;
@property (nonatomic, strong) NSMutableArray* programVariableList;
// Map<Sprite, List<UserVariable>
@property (nonatomic, strong) NSMutableDictionary* objectVariableList;

@end
