//
//  Level.h
//  Catty
//
//  Created by Mattias Rauter on 17.04.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Header.h"

@class VariablesContainer;

// skip properties with this name (i.e. spriteList needs a custom initialization)
#define kXMLSkip @"spriteList"

@interface Program : NSObject

// PROPERTIES
// new xml (version 0.6 of language version)
// ---------------------------------------------------
@property (nonatomic, strong) Header *header;

// sprites
@property (nonatomic, strong) NSMutableArray *objectList;

// variables
@property (nonatomic, strong) VariablesContainer *variables;

// METHODS
// ---------------------------------------------------
- (NSString*)debug;

@end
