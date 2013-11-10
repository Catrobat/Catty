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

#import <XCTest/XCTest.h>
#import "SpriteObject.h"
#import "Scene.h"
#import "ComeToFrontBrick.h"
#import "SetXBrick.h"
#import "Brick.h"
#import "Script.h"
#import "Formula.h"
#import "FormulaElement.h"
#import "ProgramLoadingInfo.h"
#import "Program.h"
#import "Parser.h"
#import "LoopBeginBrick.h"
#import "LoopEndBrick.h"
#import "LoopBeginBrick.h"
#import "LoopEndBrick.h"
#import "BroadcastWaitBrick.h"
#import "IfLogicBeginBrick.h"
#import "IfLogicElseBrick.h"
#import "IfLogicEndBrick.h"
#import "NoteBrick.h"
#import "ForeverBrick.h"
#import "BroadcastWaitHandler.h"
#import <SpriteKit/SpriteKit.h>

@interface BrickTests : XCTestCase

@property (strong, nonatomic) NSMutableArray* programs;
@property (strong, nonatomic) SKView *skView;
@property (strong, nonatomic) SKScene *scene;

@end

@implementation BrickTests

- (NSMutableArray*) programs
{
  if (! _programs)
    _programs = [NSMutableArray array];
  return _programs;
}

- (void)setUp
{
//    [super setUp];
//    // Put setup code here; it will be run once, before the first test case.
//    NSString *basePath = [Program basePath];
//    NSError *error;
//    NSArray *levels = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:basePath error:&error];
//    NSLogError(error);
//
//    NSMutableArray *levelLoadingInfos = [[NSMutableArray alloc] initWithCapacity:[levels count]];
//    for (NSString *level in levels) {
//      // exclude .DS_Store folder on MACOSX simulator
//      if ([level isEqualToString:@".DS_Store"])
//        continue;
//
//      ProgramLoadingInfo *info = [[ProgramLoadingInfo alloc] init];
//      info.basePath = [NSString stringWithFormat:@"%@%@/", basePath, level];
//      info.visibleName = level;
//      NSDebug(@"Adding level: %@", info.basePath);
//      [levelLoadingInfos addObject:info];
//
//      NSDebug(@"Try to load project '%@'", info.visibleName);
//      NSDebug(@"Path: %@", info.basePath);
//      NSString *xmlPath = [NSString stringWithFormat:@"%@", info.basePath];
//      NSDebug(@"XML-Path: %@", xmlPath);
//      Program *program = [[[Parser alloc] init] generateObjectForLevel:[xmlPath stringByAppendingFormat:@"%@", kProgramCodeFileName]];
//
//      if (! program)
//        continue;
//
//      NSDebug(@"ProjectResolution: width/height:  %f / %f", program.header.screenWidth.floatValue, program.header.screenHeight.floatValue);
//
//      // setting effect
//      for (SpriteObject *sprite in program.objectList)
//      {
//        //sprite.spriteManagerDelegate = self;
//        //sprite.broadcastWaitDelegate = self.broadcastWaitHandler;
//        
//        // TODO: change!
//        for (Script *script in sprite.scriptList) {
//          for (Brick *brick in script.brickList) {
//            brick.object = sprite;
//          }
//        }
//      }
//      [self.programs addObject:program];
//    }
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}


-(void)test_ComeToFrontBrick
{
//    Program *program = self.programs[0];
//    NSLog(@"Program: %@", program.header.programName);
//    BroadcastWaitHandler *handler = [[BroadcastWaitHandler alloc] init];
//    for (SpriteObject *object in program.objectList) {
//      object.broadcastWaitDelegate = handler;
//    }
//
//    CGSize programSize = CGSizeMake(program.header.screenWidth.floatValue, program.header.screenHeight.floatValue);
//    self.scene = [[Scene alloc] initWithSize:programSize andProgram:program];
//    self.scene.scaleMode = SKSceneScaleModeAspectFit;
//    self.skView = [[SKView alloc] init];
//    self.scene.scaleMode = SKSceneScaleModeAspectFit;
//    [self.skView presentScene:self.scene];
//
//    for (SpriteObject *object in program.objectList) {
//      for (Script *script in object.scriptList) {
//        for (Brick *brick in script.brickList) {
//          // exclude following bricks
//          NSDebug(@"Object name: %@, Brick: %@", object.name, [brick description]);
//          if ([brick isKindOfClass:[LoopBeginBrick class]] ||
//              [brick isKindOfClass:[LoopEndBrick class]] ||
//              [brick isKindOfClass:[BroadcastWaitBrick class]] ||
//              [brick isKindOfClass:[IfLogicBeginBrick class]] ||
//              [brick isKindOfClass:[IfLogicElseBrick class]] ||
//              [brick isKindOfClass:[IfLogicEndBrick class]] ||
//              [brick isKindOfClass:[NoteBrick class]] ||
//              [brick isKindOfClass:[ForeverBrick class]]) {
//            continue;
//          }
//
//          SKAction *action = [brick action];
//          if ([brick isKindOfClass:[ComeToFrontBrick class]]) {
//            ComeToFrontBrick *ctfBrick = (ComeToFrontBrick *)brick;
//            NSLog(@"ComeToFront action");
//            action = [ctfBrick action];
//          }
//          [script runAction:action completion:^{
//            NSLog(@"action completed");
//          }];
//
//          if ([brick isKindOfClass:[ComeToFrontBrick class]]) {
//            NSLog(@"ZPosition is: %f, should be: %d", object.zPosition, script.object.numberOfObjects);
//            XCTAssertEqual(script.object.numberOfObjects, object.zPosition, @"ComeToFront is not correctly calculated");
//          }
//        }
//      }
//    }

  ComeToFrontBrick *ctfB =[[ComeToFrontBrick alloc] init];
  SpriteObject *obj1 =[[SpriteObject alloc] init];
  SpriteObject *obj2 =[[SpriteObject alloc] init];
  obj1.zPosition = 1;
  obj2.zPosition = 2;
  ctfB.object = obj1;
  Program *program = [[Program alloc] init];
  [program.objectList addObject:obj1];
  [program.objectList addObject:obj2];
  obj1.program = program;
  obj2.program = program;
  
  Script *script = [[Script alloc] init];
  script.object = obj1;
  ctfB.object = obj1;
  script.object.numberOfObjects = 2;
  
  [script runAction:ctfB.action];

  XCTAssertEqual(script.object.numberOfObjects, obj1.zPosition, @"ComeToFront is not correctly calculated");
  XCTAssertEqual(obj2.zPosition, 1, @"ComeToFront is not correctly calculated");
}

-(void)test_SetXBrick
{
  SetXBrick *setxB = [[SetXBrick alloc]init];
  SpriteObject *obj = [[SpriteObject alloc] init];
  
  obj.position = CGPointMake(0, 0);
  
  Formula *formula =[[Formula alloc] init];
  FormulaElement * elem = [[FormulaElement alloc] initWithType:@"NUMBER" value:@"20" leftChild: nil rightChild:Nil parent:nil];
  
  [formula setFormulaTree:elem];
  
  setxB.xPosition = formula;
  
  
  Script *script = [[Script alloc] init];
  script.object = obj;
  setxB.object = obj;
  [obj.scriptList addObject:script];
  [script.brickList addObject:setxB];

  
  [script runAction:setxB.action];
  
  XCTAssertEqual(obj.xPosition, 20, @"SetxBrick is not correctly calculated");
}

@end
