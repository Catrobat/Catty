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

@interface BrickTests : XCTestCase

@property (strong, nonatomic) NSMutableArray* programs;

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
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
    NSString *basePath = [Program basePath];
    NSError *error;
    NSArray *levels = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:basePath error:&error];
    NSLogError(error);

    NSMutableArray *levelLoadingInfos = [[NSMutableArray alloc] initWithCapacity:[levels count]];
    for (NSString *level in levels) {
      // exclude .DS_Store folder on MACOSX simulator
      if ([level isEqualToString:@".DS_Store"])
        continue;

      ProgramLoadingInfo *info = [[ProgramLoadingInfo alloc] init];
      info.basePath = [NSString stringWithFormat:@"%@%@/", basePath, level];
      info.visibleName = level;
      NSDebug(@"Adding level: %@", info.basePath);
      [levelLoadingInfos addObject:info];

      NSDebug(@"Try to load project '%@'", info.visibleName);
      NSDebug(@"Path: %@", info.basePath);
      NSString *xmlPath = [NSString stringWithFormat:@"%@", info.basePath];
      NSDebug(@"XML-Path: %@", xmlPath);
      Program *program = [[[Parser alloc] init] generateObjectForLevel:[xmlPath stringByAppendingFormat:@"%@", kProgramCodeFileName]];

      if (! program)
        continue;

      NSDebug(@"ProjectResolution: width/height:  %f / %f", program.header.screenWidth.floatValue, program.header.screenHeight.floatValue);

      // setting effect
      for (SpriteObject *sprite in program.objectList)
      {
        //sprite.spriteManagerDelegate = self;
        //sprite.broadcastWaitDelegate = self.broadcastWaitHandler;
        
        // TODO: change!
        for (Script *script in sprite.scriptList) {
          for (Brick *brick in script.brickList) {
            brick.object = sprite;
          }
        }
      }
      [self.programs addObject:program];
    }
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testExample
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}



-(void)test_ComeToFrontBrick
{
    Program *program = self.programs[0];
    NSLog(@"Program: %@", program.header.programName);
    BroadcastWaitHandler *handler = [[BroadcastWaitHandler alloc] init];
    for (SpriteObject *object in program.objectList) {
      object.broadcastWaitDelegate = handler;
    }

    CGSize programSize = CGSizeMake(program.header.screenWidth.floatValue, program.header.screenHeight.floatValue);
    Scene *scene = [[Scene alloc] initWithSize:programSize andProgram:program];
    scene.scaleMode = SKSceneScaleModeAspectFit;
    //[skView presentScene:scene];

    for (SpriteObject *object in program.objectList) {
      for (Script *script in object.scriptList) {
        for (Brick *brick in script.brickList) {
          // exclude following bricks
          NSDebug(@"Object name: %@, Brick: %@", object.name, [brick description]);
          if ([brick isKindOfClass:[LoopBeginBrick class]] ||
              [brick isKindOfClass:[LoopEndBrick class]] ||
              [brick isKindOfClass:[BroadcastWaitBrick class]] ||
              [brick isKindOfClass:[IfLogicBeginBrick class]] ||
              [brick isKindOfClass:[IfLogicElseBrick class]] ||
              [brick isKindOfClass:[IfLogicEndBrick class]] ||
              [brick isKindOfClass:[NoteBrick class]] ||
              [brick isKindOfClass:[ForeverBrick class]]) {
            continue;
          }

          SKAction *action = [brick action];
          if ([brick isKindOfClass:[ComeToFrontBrick class]]) {
            ComeToFrontBrick *ctfBrick = (ComeToFrontBrick *)brick;
            NSLog(@"ComeToFront");
            action = [ctfBrick action];
          }
          [script runAction:action];

          if ([brick isKindOfClass:[ComeToFrontBrick class]]) {
            NSLog(@"ZPosition is: %f, should be: %d", object.zPosition, script.object.numberOfObjects);
            XCTAssertEqual(script.object.numberOfObjects, object.zPosition, @"ComeToFront is not correctly calculated");
          }
        }
      }
    }
}

-(void)test_SetXBrick
{
//    CGPoint checkPoint = CGPointMake(200, 0);
//    SpriteObject *sprite1 =[[SpriteObject alloc] init];
//    Script *script = [[Script alloc]init];
//    SetXBrick *setXBrick =[[SetXBrick alloc]init];
//    Formula * formula = [[Formula alloc] init];
//    FormulaElement * fElement = [[FormulaElement alloc]initWithType:@"NUMBER" value:@"200" leftChild:nil rightChild:nil parent:nil];
//    
//    formula.formulaTree = fElement;
//    setXBrick.xPosition = formula;
//    
//    script.object = sprite1;
//    
//    
//    
////IMPLEMENTATION SETXBRICK//////////////////////////////////////
//    double xPosition = [setXBrick.xPosition interpretDoubleForSprite:script.object];
//    
//    script.object.position = CGPointMake(xPosition, 0);
//    
//    
////////////////////////////////////////////////
//    
//        XCTAssertEqual(checkPoint, script.object.position ,@"SetXBrick is not correctly calculated");
}




@end
