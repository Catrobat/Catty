//
//  SPViewController.h
//  Sparrow
//
//  Created by Daniel Sperl on 26.01.13.
//  Copyright 2013 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>

@class SPStage;
@class SPJuggler;
@class SPProgram;
@class SPDisplayObject;

typedef void (^SPRootCreatedBlock)(id root);

@interface SPViewController : GLKViewController

- (void)startWithRoot:(Class)rootClass;
- (void)startWithRoot:(Class)rootClass supportHighResolutions:(BOOL)hd;
- (void)startWithRoot:(Class)rootClass supportHighResolutions:(BOOL)hd doubleOnPad:(BOOL)doubleOnPad;
- (void)updateStageSize;

- (void)registerProgram:(SPProgram *)program name:(NSString *)name;
- (void)unregisterProgram:(NSString *)name;
- (SPProgram *)programByName:(NSString *)name;

@property (nonatomic, readonly) SPDisplayObject *root;
@property (nonatomic, readonly) SPStage *stage;
@property (nonatomic, readonly) SPJuggler *juggler;
@property (nonatomic, readonly) EAGLContext *context;

@property (nonatomic, assign) BOOL multitouchEnabled;
@property (nonatomic, assign) BOOL showStats;
@property (nonatomic, readonly) BOOL supportHighResolutions;
@property (nonatomic, readonly) BOOL doubleResolutionOnPad;
@property (nonatomic, readonly) float contentScaleFactor;
@property (nonatomic, copy) SPRootCreatedBlock onRootCreated;

@end