/**
 *  Copyright (C) 2010-2016 The Catrobat Team
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

#import "BrickTests.h"
#import "WaitBrick.h"
#import "RepeatBrick.h"
#import "BroadcastBrick.h"
#import "ChangeVariableBrick.h"
#import "StopAllSoundsBrick.h"
#import "SpeakBrick.h"
#import "SetVolumeToBrick.h"
#import "ChangeVolumeByNBrick.h"
#import "VibrationBrick.h"
#import "LedOnBrick.h"
#import "LedOffBrick.h"
#import "PointToBrick.h"
#import "IfOnEdgeBounceBrick.h"
#import "GlideToBrick.h"
#import "ArduinoSendDigitalValueBrick.h"
#import "ArduinoSendPWMValueBrick.h"
#import "PhiroMotorMoveBackwardBrick.h"
#import "PhiroMotorMoveForwardBrick.h"
#import "PhiroMotorStopBrick.h"
#import "PhiroPlayToneBrick.h"
#import "PhiroRGBLightBrick.h"
#import "SensorManager.h"

@interface RequiredRescourses : XCTestCase

@end

@implementation RequiredRescourses

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

NSString * const sensorTestStringArray[] = {
    @"X_ACCELERATION",
    @"Y_ACCELERATION",
    @"Z_ACCELERATION",
    @"COMPASS_DIRECTION",
    @"X_INCLINATION",
    @"Y_INCLINATION",
    @"OBJECT_X",
    @"OBJECT_Y",
    @"OBJECT_GHOSTEFFECT",
    @"OBJECT_BRIGHTNESS",
    @"OBJECT_SIZE",
    @"OBJECT_ROTATION",
    @"OBJECT_LAYER",
    @"LOUDNESS",
    @"FACE_DETECTED",
    @"FACE_SIZE",
    @"FACE_POSITION_X",
    @"FACE_POSITION_Y",
    @"front_left",
    @"front_right",
    @"side_left",
    @"side_right",
    @"bottom_left",
    @"bottom_right",
    @"analogPin",
    @"digitalPin"
};


-(Program*)getProgramWithOneSpriteWithBrick:(Brick*)brick
{
    Program * program = [Program new];
    SpriteObject* obj = [SpriteObject new];
    Script *script = [Script new];
    [script.brickList addObject:brick];
    [obj.scriptList addObject:script];
    [program.objectList addObject:obj];
    
    return program;
}

#pragma mark-Look
- (void)testHideBrickResources
{
    HideBrick *brick = [HideBrick new];
    Program *prog = [self getProgramWithOneSpriteWithBrick:brick];
    
    NSInteger resources = [prog getRequiredResources];
    XCTAssertEqual(resources, kNoResources, @"Resourses HideBrick not correctly calculated");
}

- (void)testShowBrickResources
{
    ShowBrick *brick = [ShowBrick new];
    Program *prog = [self getProgramWithOneSpriteWithBrick:brick];
    
    NSInteger resources = [prog getRequiredResources];
    XCTAssertEqual(resources, kNoResources, @"Resourses ShowBrick not correctly calculated");
}

- (void)testSetTransparencyBrickResources
{
    SetTransparencyBrick *brick = [SetTransparencyBrick new];
    brick.transparency = [[Formula alloc] initWithInteger:1];
    Program *prog = [self getProgramWithOneSpriteWithBrick:brick];
    
    NSInteger resources = [prog getRequiredResources];
    XCTAssertEqual(resources, kNoResources, @"Resourses SetTransparencyBrick not correctly calculated");
}

- (void)testSetTransparencyBrick2Resources
{
    SetTransparencyBrick *brick = [SetTransparencyBrick new];
    FormulaElement *element = [[FormulaElement alloc] initWithElementType:SENSOR value:@"X_ACCELERATION" leftChild:nil rightChild:nil parent:nil];
    brick.transparency = [[Formula alloc] initWithFormulaElement:element];
    Program *prog = [self getProgramWithOneSpriteWithBrick:brick];
    
    NSInteger resources = [prog getRequiredResources];
    XCTAssertEqual(resources, kAccelerometer, @"Resourses ShowBrick not correctly calculated");
}

- (void)testSetSizeBrickResources
{
    SetSizeToBrick *brick = [SetSizeToBrick new];
    brick.size = [[Formula alloc] initWithInteger:1];
    Program *prog = [self getProgramWithOneSpriteWithBrick:brick];
    
    NSInteger resources = [prog getRequiredResources];
    XCTAssertEqual(resources, kNoResources, @"Resourses SetSizeToBrick not correctly calculated");
}

- (void)testSetSizeBrick2Resources
{
    SetSizeToBrick *brick = [SetSizeToBrick new];
    FormulaElement *element = [[FormulaElement alloc] initWithElementType:SENSOR value:@"Y_ACCELERATION" leftChild:nil rightChild:nil parent:nil];
    brick.size = [[Formula alloc] initWithFormulaElement:element];
    Program *prog = [self getProgramWithOneSpriteWithBrick:brick];
    
    NSInteger resources = [prog getRequiredResources];
    XCTAssertEqual(resources, kAccelerometer, @"Resourses SetSizeToBrick not correctly calculated");
}

- (void)testSetBrightnessBrickResources
{
    SetBrightnessBrick *brick = [SetBrightnessBrick new];
    brick.brightness = [[Formula alloc] initWithInteger:1];
    Program *prog = [self getProgramWithOneSpriteWithBrick:brick];
    
    NSInteger resources = [prog getRequiredResources];
    XCTAssertEqual(resources, kNoResources, @"Resourses SetBrightnessBrick not correctly calculated");
}

- (void)testSetBrightnessBrick2Resources
{
    SetBrightnessBrick *brick = [SetBrightnessBrick new];
    FormulaElement *element = [[FormulaElement alloc] initWithElementType:SENSOR value:sensorTestStringArray[3] leftChild:nil rightChild:nil parent:nil];
    brick.brightness = [[Formula alloc] initWithFormulaElement:element];
    Program *prog = [self getProgramWithOneSpriteWithBrick:brick];
    
    NSInteger resources = [prog getRequiredResources];
    XCTAssertEqual(resources, kLocation, @"Resourses SetBrightnessBrick not correctly calculated");
}
- (void)testClearGraphicEffectBrickResources
{
    ClearGraphicEffectBrick *brick = [ClearGraphicEffectBrick new];
    Program *prog = [self getProgramWithOneSpriteWithBrick:brick];
    
    NSInteger resources = [prog getRequiredResources];
    XCTAssertEqual(resources, kNoResources, @"Resourses ClearGraphicEffectBrick not correctly calculated");
}
- (void)testChangeTransparencyByNBrickResources
{
    ChangeTransparencyByNBrick *brick = [ChangeTransparencyByNBrick new];
    brick.changeTransparency = [[Formula alloc] initWithInteger:1];
    Program *prog = [self getProgramWithOneSpriteWithBrick:brick];
    
    NSInteger resources = [prog getRequiredResources];
    XCTAssertEqual(resources, kNoResources, @"Resourses ChangeTransparencyByNBrick not correctly calculated");
}

- (void)testChangeTransparencyByNBrick2Resources
{
    ChangeTransparencyByNBrick *brick = [ChangeTransparencyByNBrick new];
    FormulaElement *element = [[FormulaElement alloc] initWithElementType:SENSOR value:sensorTestStringArray[4] leftChild:nil rightChild:nil parent:nil];
    brick.changeTransparency = [[Formula alloc] initWithFormulaElement:element];
    Program *prog = [self getProgramWithOneSpriteWithBrick:brick];
    
    NSInteger resources = [prog getRequiredResources];
    XCTAssertEqual(resources, kAccelerometer, @"Resourses ChangeTransparencyByNBrick not correctly calculated");
}
- (void)testChangeBrightnessByNBrickResources
{
    ChangeBrightnessByNBrick *brick = [ChangeBrightnessByNBrick new];
    brick.changeBrightness = [[Formula alloc] initWithInteger:1];
    Program *prog = [self getProgramWithOneSpriteWithBrick:brick];
    
    NSInteger resources = [prog getRequiredResources];
    XCTAssertEqual(resources, kNoResources, @"Resourses ChangeBrightnessByNBrick not correctly calculated");
}
- (void)testChangeBrightnessByNBrick2Resources
{
    ChangeBrightnessByNBrick *brick = [ChangeBrightnessByNBrick new];
    FormulaElement *element = [[FormulaElement alloc] initWithElementType:SENSOR value:sensorTestStringArray[5] leftChild:nil rightChild:nil parent:nil];
    brick.changeBrightness = [[Formula alloc] initWithFormulaElement:element];
    Program *prog = [self getProgramWithOneSpriteWithBrick:brick];
    
    NSInteger resources = [prog getRequiredResources];
    XCTAssertEqual(resources, kAccelerometer, @"Resourses ChangeBrightnessByNBrick not correctly calculated");
}
- (void)testChangeColorByNBrickResources
{
    ChangeColorByNBrick *brick = [ChangeColorByNBrick new];
    brick.changeColor = [[Formula alloc] initWithInteger:1];
    Program *prog = [self getProgramWithOneSpriteWithBrick:brick];
    
    NSInteger resources = [prog getRequiredResources];
    XCTAssertEqual(resources, kNoResources, @"Resourses ChangeBrightnessByNBrick not correctly calculated");
}
- (void)testChangeColorByNBrick2Resources
{
    ChangeColorByNBrick *brick = [ChangeColorByNBrick new];
    FormulaElement *element = [[FormulaElement alloc] initWithElementType:SENSOR value:sensorTestStringArray[5] leftChild:nil rightChild:nil parent:nil];
    brick.changeColor = [[Formula alloc] initWithFormulaElement:element];
    Program *prog = [self getProgramWithOneSpriteWithBrick:brick];
    
    NSInteger resources = [prog getRequiredResources];
    XCTAssertEqual(resources, kAccelerometer, @"Resourses ChangeBrightnessByNBrick not correctly calculated");
}
- (void)testSetColorToBrickResources
{
    SetColorToBrick *brick = [SetColorToBrick new];
    brick.color = [[Formula alloc] initWithInteger:1];
    Program *prog = [self getProgramWithOneSpriteWithBrick:brick];
    
    NSInteger resources = [prog getRequiredResources];
    XCTAssertEqual(resources, kNoResources, @"Resourses ChangeBrightnessByNBrick not correctly calculated");
}
- (void)testSetColorToBrick2Resources
{
    SetColorToBrick *brick = [SetColorToBrick new];
    FormulaElement *element = [[FormulaElement alloc] initWithElementType:SENSOR value:sensorTestStringArray[5] leftChild:nil rightChild:nil parent:nil];
    brick.color = [[Formula alloc] initWithFormulaElement:element];
    Program *prog = [self getProgramWithOneSpriteWithBrick:brick];
    
    NSInteger resources = [prog getRequiredResources];
    XCTAssertEqual(resources, kAccelerometer, @"Resourses ChangeBrightnessByNBrick not correctly calculated");
}
#pragma mark-Control
- (void)testWaitBrickResources
{
    WaitBrick *brick = [WaitBrick new];
    brick.timeToWaitInSeconds = [[Formula alloc] initWithInteger:1];
    Program *prog = [self getProgramWithOneSpriteWithBrick:brick];
    
    NSInteger resources = [prog getRequiredResources];
    XCTAssertEqual(resources, kNoResources, @"Resourses WaitBrick not correctly calculated");
}

- (void)testWaitBrick2Resources
{
    WaitBrick *brick = [WaitBrick new];
    FormulaElement *element = [[FormulaElement alloc] initWithElementType:SENSOR value:sensorTestStringArray[13] leftChild:nil rightChild:nil parent:nil];
    brick.timeToWaitInSeconds = [[Formula alloc] initWithFormulaElement:element];
    Program *prog = [self getProgramWithOneSpriteWithBrick:brick];
    
    NSInteger resources = [prog getRequiredResources];
    XCTAssertEqual(resources, kLoudness, @"Resourses WaitBrick not correctly calculated");
}
- (void)testRepeatBrickResources
{
    RepeatBrick *brick = [RepeatBrick new];
    brick.timesToRepeat = [[Formula alloc] initWithInteger:1];
    Program *prog = [self getProgramWithOneSpriteWithBrick:brick];
    
    NSInteger resources = [prog getRequiredResources];
    XCTAssertEqual(resources, kNoResources, @"Resourses RepeatBrick not correctly calculated");
}
- (void)testRepeatBrick2Resources
{
    RepeatBrick *brick = [RepeatBrick new];
    FormulaElement *element = [[FormulaElement alloc] initWithElementType:SENSOR value:sensorTestStringArray[14] leftChild:nil rightChild:nil parent:nil];
    brick.timesToRepeat = [[Formula alloc] initWithFormulaElement:element];
    Program *prog = [self getProgramWithOneSpriteWithBrick:brick];
    
    NSInteger resources = [prog getRequiredResources];
    XCTAssertEqual(resources, kFaceDetection, @"Resourses RepeatBrick not correctly calculated");
}
- (void)testNoteBrickResources
{
    NoteBrick *brick = [NoteBrick new];
    Program *prog = [self getProgramWithOneSpriteWithBrick:brick];
    
    NSInteger resources = [prog getRequiredResources];
    XCTAssertEqual(resources, kNoResources, @"Resourses NoteBrick not correctly calculated");
}
- (void)testIfLogicBeginBrickResources
{
    IfLogicBeginBrick *brick = [IfLogicBeginBrick new];
    brick.ifCondition = [[Formula alloc] initWithInteger:1];
    Program *prog = [self getProgramWithOneSpriteWithBrick:brick];
    
    NSInteger resources = [prog getRequiredResources];
    XCTAssertEqual(resources, kNoResources, @"Resourses IfLogicBeginBrick not correctly calculated");
}
- (void)testIfLogicBeginBrick2Resources
{
    IfLogicBeginBrick *brick = [IfLogicBeginBrick new];
    FormulaElement *element = [[FormulaElement alloc] initWithElementType:SENSOR value:sensorTestStringArray[15] leftChild:nil rightChild:nil parent:nil];
    brick.ifCondition = [[Formula alloc] initWithFormulaElement:element];
    Program *prog = [self getProgramWithOneSpriteWithBrick:brick];
    
    NSInteger resources = [prog getRequiredResources];
    XCTAssertEqual(resources, kFaceDetection, @"Resourses IfLogicBeginBrick not correctly calculated");
}
- (void)testBroadcastBrickResources
{
    BroadcastBrick *brick = [BroadcastBrick new];
    Program *prog = [self getProgramWithOneSpriteWithBrick:brick];
    
    NSInteger resources = [prog getRequiredResources];
    XCTAssertEqual(resources, kNoResources, @"Resourses BroadcastBrick not correctly calculated");
}
#pragma mark-Data
- (void)testSetVariableBrickResources
{
    SetVariableBrick *brick = [SetVariableBrick new];
    brick.variableFormula = [[Formula alloc] initWithInteger:1];
    Program *prog = [self getProgramWithOneSpriteWithBrick:brick];
    
    NSInteger resources = [prog getRequiredResources];
    XCTAssertEqual(resources, kNoResources, @"Resourses SetVariableBrick not correctly calculated");
}
- (void)testSetVariableBrick2Resources
{
    SetVariableBrick *brick = [SetVariableBrick new];
    FormulaElement *element = [[FormulaElement alloc] initWithElementType:SENSOR value:sensorTestStringArray[16] leftChild:nil rightChild:nil parent:nil];
    brick.variableFormula = [[Formula alloc] initWithFormulaElement:element];
    Program *prog = [self getProgramWithOneSpriteWithBrick:brick];
    
    NSInteger resources = [prog getRequiredResources];
    XCTAssertEqual(resources, kFaceDetection, @"Resourses SetVariableBrick not correctly calculated");
}
- (void)testChangeVariableBrickResources
{
    ChangeVariableBrick *brick = [ChangeVariableBrick new];
    brick.variableFormula = [[Formula alloc] initWithInteger:1];
    Program *prog = [self getProgramWithOneSpriteWithBrick:brick];
    
    NSInteger resources = [prog getRequiredResources];
    XCTAssertEqual(resources, kNoResources, @"Resourses ChangeVariableBrick not correctly calculated");
}
- (void)testChangeVariableBrick2Resources
{
    ChangeVariableBrick *brick = [ChangeVariableBrick new];
    FormulaElement *element = [[FormulaElement alloc] initWithElementType:SENSOR value:sensorTestStringArray[17] leftChild:nil rightChild:nil parent:nil];
    brick.variableFormula = [[Formula alloc] initWithFormulaElement:element];
    Program *prog = [self getProgramWithOneSpriteWithBrick:brick];
    
    NSInteger resources = [prog getRequiredResources];
    XCTAssertEqual(resources, kFaceDetection, @"Resourses ChangeVariableBrick not correctly calculated");
}
#pragma mark-Sound
- (void)testStopAllSoundsBrickResources
{
    StopAllSoundsBrick *brick = [StopAllSoundsBrick new];
    Program *prog = [self getProgramWithOneSpriteWithBrick:brick];
    
    NSInteger resources = [prog getRequiredResources];
    XCTAssertEqual(resources, kNoResources, @"Resourses StopAllSoundsBrick not correctly calculated");
}
- (void)testSpeakBrickResources
{
    SpeakBrick *brick = [SpeakBrick new];
    brick.text = @"Hallo";
    Program *prog = [self getProgramWithOneSpriteWithBrick:brick];
    
    NSInteger resources = [prog getRequiredResources];
    XCTAssertEqual(resources, kTextToSpeech, @"Resourses SpeakBrick not correctly calculated");
}
- (void)testSetVolumeToBrickResources
{
    SetVolumeToBrick *brick = [SetVolumeToBrick new];
    brick.volume =[[Formula alloc] initWithInteger:1];
    Program *prog = [self getProgramWithOneSpriteWithBrick:brick];
    
    NSInteger resources = [prog getRequiredResources];
    XCTAssertEqual(resources, kNoResources, @"Resourses SetVolumeToBrick not correctly calculated");
}
- (void)testSetVolumeToBrick2Resources
{
    SetVolumeToBrick *brick = [SetVolumeToBrick new];
    FormulaElement *element = [[FormulaElement alloc] initWithElementType:SENSOR value:sensorTestStringArray[18] leftChild:nil rightChild:nil parent:nil];
    brick.volume = [[Formula alloc] initWithFormulaElement:element];
    Program *prog = [self getProgramWithOneSpriteWithBrick:brick];
    
    NSInteger resources = [prog getRequiredResources];
    XCTAssertEqual(resources, kBluetoothPhiro, @"Resourses SetVolumeToBrick not correctly calculated");
}
- (void)testChangeVolumeByNBrickResources
{
    ChangeVolumeByNBrick *brick = [ChangeVolumeByNBrick new];
    brick.volume =[[Formula alloc] initWithInteger:1];
    Program *prog = [self getProgramWithOneSpriteWithBrick:brick];
    
    NSInteger resources = [prog getRequiredResources];
    XCTAssertEqual(resources, kNoResources, @"Resourses SetVolumeToBrick not correctly calculated");
}
- (void)testChangeVolumeByNBrick2Resources
{
    ChangeVolumeByNBrick *brick = [ChangeVolumeByNBrick new];
    FormulaElement *element = [[FormulaElement alloc] initWithElementType:SENSOR value:sensorTestStringArray[19] leftChild:nil rightChild:nil parent:nil];
    brick.volume = [[Formula alloc] initWithFormulaElement:element];
    Program *prog = [self getProgramWithOneSpriteWithBrick:brick];
    
    NSInteger resources = [prog getRequiredResources];
    XCTAssertEqual(resources, kBluetoothPhiro, @"Resourses SetVolumeToBrick not correctly calculated");
}
#pragma mark-IO

- (void)testVibrationBrickResources
{
    VibrationBrick *brick = [VibrationBrick new];
    brick.durationInSeconds =[[Formula alloc] initWithInteger:1];
    Program *prog = [self getProgramWithOneSpriteWithBrick:brick];
    
    NSInteger resources = [prog getRequiredResources];
    XCTAssertEqual(resources, kVibration, @"Resourses VibrationBrick not correctly calculated");
}
- (void)testLedOnBrickResources
{
    LedOnBrick *brick = [LedOnBrick new];
    Program *prog = [self getProgramWithOneSpriteWithBrick:brick];
    
    NSInteger resources = [prog getRequiredResources];
    XCTAssertEqual(resources, kLED, @"Resourses LedOnBrick not correctly calculated");
}
- (void)testLedOffBrickResources
{
    LedOffBrick *brick = [LedOffBrick new];
    Program *prog = [self getProgramWithOneSpriteWithBrick:brick];
    
    NSInteger resources = [prog getRequiredResources];
    XCTAssertEqual(resources, kLED, @"Resourses LedOffBrick not correctly calculated");
}
#pragma mark-Motion

- (void)testTurnRightBrickResources
{
    TurnRightBrick *brick = [TurnRightBrick new];
    brick.degrees =[[Formula alloc] initWithInteger:1];
    Program *prog = [self getProgramWithOneSpriteWithBrick:brick];
    
    NSInteger resources = [prog getRequiredResources];
    XCTAssertEqual(resources, kNoResources, @"Resourses TurnRightBrick not correctly calculated");
}
- (void)testTurnRightBrick2Resources
{
    TurnRightBrick *brick = [TurnRightBrick new];
    FormulaElement *element = [[FormulaElement alloc] initWithElementType:SENSOR value:sensorTestStringArray[20] leftChild:nil rightChild:nil parent:nil];
    brick.degrees = [[Formula alloc] initWithFormulaElement:element];
    Program *prog = [self getProgramWithOneSpriteWithBrick:brick];
    
    NSInteger resources = [prog getRequiredResources];
    XCTAssertEqual(resources, kBluetoothPhiro, @"Resourses TurnRightBrick not correctly calculated");
}

- (void)testTurnLeftBrickResources
{
    TurnLeftBrick *brick = [TurnLeftBrick new];
    brick.degrees =[[Formula alloc] initWithInteger:1];
    Program *prog = [self getProgramWithOneSpriteWithBrick:brick];
    
    NSInteger resources = [prog getRequiredResources];
    XCTAssertEqual(resources, kNoResources, @"Resourses TurnLeftBrick not correctly calculated");
}

- (void)testTurnLeftBrick2Resources
{
    TurnLeftBrick *brick = [TurnLeftBrick new];
    FormulaElement *element = [[FormulaElement alloc] initWithElementType:SENSOR value:sensorTestStringArray[21] leftChild:nil rightChild:nil parent:nil];
    brick.degrees = [[Formula alloc] initWithFormulaElement:element];
    Program *prog = [self getProgramWithOneSpriteWithBrick:brick];
    
    NSInteger resources = [prog getRequiredResources];
    XCTAssertEqual(resources, kBluetoothPhiro, @"Resourses TurnLeftBrick not correctly calculated");
}

- (void)testSetYBrickResources
{
    SetYBrick *brick = [SetYBrick new];
    brick.yPosition =[[Formula alloc] initWithInteger:1];
    Program *prog = [self getProgramWithOneSpriteWithBrick:brick];
    
    NSInteger resources = [prog getRequiredResources];
    XCTAssertEqual(resources, kNoResources, @"Resourses SetYBrick not correctly calculated");
}
- (void)testSetYBrick2Resources
{
    SetYBrick *brick = [SetYBrick new];
    FormulaElement *element = [[FormulaElement alloc] initWithElementType:SENSOR value:sensorTestStringArray[22] leftChild:nil rightChild:nil parent:nil];
    brick.yPosition = [[Formula alloc] initWithFormulaElement:element];
    Program *prog = [self getProgramWithOneSpriteWithBrick:brick];
    
    NSInteger resources = [prog getRequiredResources];
    XCTAssertEqual(resources, kBluetoothPhiro, @"Resourses SetYBrick not correctly calculated");
}
- (void)testSetXBrickResources
{
    SetXBrick *brick = [SetXBrick new];
    brick.xPosition =[[Formula alloc] initWithInteger:1];
    Program *prog = [self getProgramWithOneSpriteWithBrick:brick];
    
    NSInteger resources = [prog getRequiredResources];
    XCTAssertEqual(resources, kNoResources, @"Resourses SetXBrick not correctly calculated");
}
- (void)testSetXBrick2Resources
{
    SetXBrick *brick = [SetXBrick new];
    FormulaElement *element = [[FormulaElement alloc] initWithElementType:SENSOR value:sensorTestStringArray[23] leftChild:nil rightChild:nil parent:nil];
    brick.xPosition = [[Formula alloc] initWithFormulaElement:element];
    Program *prog = [self getProgramWithOneSpriteWithBrick:brick];
    
    NSInteger resources = [prog getRequiredResources];
    XCTAssertEqual(resources, kBluetoothPhiro, @"Resourses SetXBrick not correctly calculated");
}
- (void)testPointToBrickResources
{
    PointToBrick *brick = [PointToBrick new];
    Program *prog = [self getProgramWithOneSpriteWithBrick:brick];
    
    NSInteger resources = [prog getRequiredResources];
    XCTAssertEqual(resources, kNoResources, @"Resourses PointToBrick not correctly calculated");
}
- (void)testPointInDirectionBrickResources
{
    PointInDirectionBrick *brick = [PointInDirectionBrick new];
    brick.degrees  =[[Formula alloc] initWithInteger:1];
    Program *prog = [self getProgramWithOneSpriteWithBrick:brick];
    
    NSInteger resources = [prog getRequiredResources];
    XCTAssertEqual(resources, kNoResources, @"Resourses PointInDirectionBrick not correctly calculated");
}
- (void)testPointInDirectionBrick2Resources
{
    PointInDirectionBrick *brick = [PointInDirectionBrick new];
    FormulaElement *element = [[FormulaElement alloc] initWithElementType:SENSOR value:sensorTestStringArray[23] leftChild:nil rightChild:nil parent:nil];
    brick.degrees = [[Formula alloc] initWithFormulaElement:element];
    Program *prog = [self getProgramWithOneSpriteWithBrick:brick];
    
    NSInteger resources = [prog getRequiredResources];
    XCTAssertEqual(resources, kBluetoothPhiro, @"Resourses PointInDirectionBrick not correctly calculated");
}
- (void)testPlaceAtBrickResources
{
    PlaceAtBrick *brick = [PlaceAtBrick new];
    brick.xPosition  =[[Formula alloc] initWithInteger:1];
    brick.yPosition  =[[Formula alloc] initWithInteger:1];
    Program *prog = [self getProgramWithOneSpriteWithBrick:brick];
    
    NSInteger resources = [prog getRequiredResources];
    XCTAssertEqual(resources, kNoResources, @"Resourses PlaceAtBrick not correctly calculated");
}
- (void)testPlaceAtBrick2Resources
{
    PlaceAtBrick *brick = [PlaceAtBrick new];
    FormulaElement *element = [[FormulaElement alloc] initWithElementType:SENSOR value:sensorTestStringArray[23] leftChild:nil rightChild:nil parent:nil];
    brick.xPosition = [[Formula alloc] initWithFormulaElement:element];

    brick.yPosition = [[Formula alloc] initWithFormulaElement:element];
    Program *prog = [self getProgramWithOneSpriteWithBrick:brick];
    
    NSInteger resources = [prog getRequiredResources];
    XCTAssertEqual(resources, kBluetoothPhiro, @"Resourses PlaceAtBrick not correctly calculated");
}
- (void)testMoveNStepsBrickResources
{
    MoveNStepsBrick *brick = [MoveNStepsBrick new];
    brick.steps  =[[Formula alloc] initWithInteger:1];
    Program *prog = [self getProgramWithOneSpriteWithBrick:brick];
    
    NSInteger resources = [prog getRequiredResources];
    XCTAssertEqual(resources, kNoResources, @"Resourses MoveNStepsBrick not correctly calculated");
}
- (void)testMoveNStepsBrick2Resources
{
    MoveNStepsBrick *brick = [MoveNStepsBrick new];
    FormulaElement *element = [[FormulaElement alloc] initWithElementType:SENSOR value:sensorTestStringArray[23] leftChild:nil rightChild:nil parent:nil];
    brick.steps = [[Formula alloc] initWithFormulaElement:element];
    Program *prog = [self getProgramWithOneSpriteWithBrick:brick];
    
    NSInteger resources = [prog getRequiredResources];
    XCTAssertEqual(resources, kBluetoothPhiro, @"Resourses MoveNStepsBrick not correctly calculated");
}
- (void)testIfOnEdgeBounceBrickResources
{
    IfOnEdgeBounceBrick *brick = [IfOnEdgeBounceBrick new];
    Program *prog = [self getProgramWithOneSpriteWithBrick:brick];
    
    NSInteger resources = [prog getRequiredResources];
    XCTAssertEqual(resources, kNoResources, @"Resourses IfOnEdgeBounceBrick not correctly calculated");
}
- (void)testGoNStepsBackBrickResources
{
    GoNStepsBackBrick *brick = [GoNStepsBackBrick new];
     brick.steps  =[[Formula alloc] initWithInteger:1];
    Program *prog = [self getProgramWithOneSpriteWithBrick:brick];
    
    NSInteger resources = [prog getRequiredResources];
    XCTAssertEqual(resources, kNoResources, @"Resourses GoNStepsBackBrick not correctly calculated");
}
- (void)testGoNStepsBackBrick2Resources
{
    GoNStepsBackBrick *brick = [GoNStepsBackBrick new];
    FormulaElement *element = [[FormulaElement alloc] initWithElementType:SENSOR value:sensorTestStringArray[23] leftChild:nil rightChild:nil parent:nil];
    brick.steps = [[Formula alloc] initWithFormulaElement:element];
    Program *prog = [self getProgramWithOneSpriteWithBrick:brick];
    
    NSInteger resources = [prog getRequiredResources];
    XCTAssertEqual(resources, kBluetoothPhiro, @"Resourses GoNStepsBackBrick not correctly calculated");
}
- (void)testGlideToBrickResources
{
    GlideToBrick *brick = [GlideToBrick new];
    brick.durationInSeconds = [[Formula alloc] initWithInteger:1];
    brick.xDestination= [[Formula alloc] initWithInteger:1];
    brick.yDestination= [[Formula alloc] initWithInteger:1];
    Program *prog = [self getProgramWithOneSpriteWithBrick:brick];
    
    NSInteger resources = [prog getRequiredResources];
    XCTAssertEqual(resources, kNoResources, @"Resourses GlideToBrick not correctly calculated");
}
- (void)testGlideToBrick2Resources
{
    GlideToBrick *brick = [GlideToBrick new];
    FormulaElement *element = [[FormulaElement alloc] initWithElementType:SENSOR value:sensorTestStringArray[23] leftChild:nil rightChild:nil parent:nil];
    brick.durationInSeconds = [[Formula alloc] initWithFormulaElement:element];
    brick.xDestination = [[Formula alloc] initWithFormulaElement:element];
    brick.yDestination = [[Formula alloc] initWithFormulaElement:element];
    Program *prog = [self getProgramWithOneSpriteWithBrick:brick];
    
    NSInteger resources = [prog getRequiredResources];
    XCTAssertEqual(resources, kBluetoothPhiro, @"Resourses GlideToBrick not correctly calculated");
}
- (void)testComeToFrontBrickResources
{
    ComeToFrontBrick *brick = [ComeToFrontBrick new];
    Program *prog = [self getProgramWithOneSpriteWithBrick:brick];
    
    NSInteger resources = [prog getRequiredResources];
    XCTAssertEqual(resources, kNoResources, @"Resourses ComeToFrontBrick not correctly calculated");
}
- (void)testChangeYByNBrickResources
{
    ChangeYByNBrick *brick = [ChangeYByNBrick new];
    FormulaElement *element = [[FormulaElement alloc] initWithElementType:SENSOR value:sensorTestStringArray[23] leftChild:nil rightChild:nil parent:nil];
    brick.yMovement = [[Formula alloc] initWithFormulaElement:element];
    Program *prog = [self getProgramWithOneSpriteWithBrick:brick];
    
    NSInteger resources = [prog getRequiredResources];
    XCTAssertEqual(resources, kBluetoothPhiro, @"Resourses ChangeYByNBrick not correctly calculated");
}
- (void)testChangeYByNBrick2Resources
{
    ChangeYByNBrick *brick = [ChangeYByNBrick new];
    brick.yMovement= [[Formula alloc] initWithInteger:1];
    Program *prog = [self getProgramWithOneSpriteWithBrick:brick];
    
    NSInteger resources = [prog getRequiredResources];
    XCTAssertEqual(resources, kNoResources, @"Resourses ChangeYByNBrick not correctly calculated");
}

- (void)testChangeXByNBrickResources
{
    ChangeXByNBrick *brick = [ChangeXByNBrick new];
    brick.xMovement= [[Formula alloc] initWithInteger:1];
    Program *prog = [self getProgramWithOneSpriteWithBrick:brick];
    
    NSInteger resources = [prog getRequiredResources];
    XCTAssertEqual(resources, kNoResources, @"Resourses ChangeXByNBrick not correctly calculated");
}
- (void)testChangeXByNBrick2Resources
{
    ChangeXByNBrick *brick = [ChangeXByNBrick new];
    FormulaElement *element = [[FormulaElement alloc] initWithElementType:SENSOR value:sensorTestStringArray[23] leftChild:nil rightChild:nil parent:nil];
    brick.xMovement = [[Formula alloc] initWithFormulaElement:element];
    Program *prog = [self getProgramWithOneSpriteWithBrick:brick];
    
    NSInteger resources = [prog getRequiredResources];
    XCTAssertEqual(resources, kBluetoothPhiro, @"Resourses ChangeXByNBrick not correctly calculated");
}
- (void)testChangeSizeByNBrickResources
{
    ChangeSizeByNBrick *brick = [ChangeSizeByNBrick new];
    brick.size= [[Formula alloc] initWithInteger:1];
    Program *prog = [self getProgramWithOneSpriteWithBrick:brick];
    
    NSInteger resources = [prog getRequiredResources];
    XCTAssertEqual(resources, kNoResources, @"Resourses ChangeSizeByNBrick not correctly calculated");
}
- (void)testChangeSizeByNBrick2Resources
{
    ChangeSizeByNBrick *brick = [ChangeSizeByNBrick new];
    FormulaElement *element = [[FormulaElement alloc] initWithElementType:SENSOR value:sensorTestStringArray[23] leftChild:nil rightChild:nil parent:nil];
    brick.size = [[Formula alloc] initWithFormulaElement:element];
    Program *prog = [self getProgramWithOneSpriteWithBrick:brick];
    
    NSInteger resources = [prog getRequiredResources];
    XCTAssertEqual(resources, kBluetoothPhiro, @"Resourses ChangeSizeByNBrick not correctly calculated");
}

#pragma mark-Arduino
- (void)testArduinoSendDigitalValueBrickResources
{
    ArduinoSendDigitalValueBrick *brick = [ArduinoSendDigitalValueBrick new];
    brick.pin = [[Formula alloc] initWithInteger:1];
    brick.value = [[Formula alloc] initWithInteger:1];
    Program *prog = [self getProgramWithOneSpriteWithBrick:brick];
    
    NSInteger resources = [prog getRequiredResources];
    XCTAssertEqual(resources, kBluetoothArduino, @"Resourses ArduinoSendDigitalValueBrick not correctly calculated");
}
- (void)testArduinoSendPWMValueBrickResources
{
    ArduinoSendPWMValueBrick *brick = [ArduinoSendPWMValueBrick new];
    brick.pin = [[Formula alloc] initWithInteger:1];
    brick.value = [[Formula alloc] initWithInteger:1];
    Program *prog = [self getProgramWithOneSpriteWithBrick:brick];
    
    NSInteger resources = [prog getRequiredResources];
    XCTAssertEqual(resources, kBluetoothArduino, @"Resourses ArduinoSendPWMValueBrick not correctly calculated");
}
#pragma mark-Phiro
- (void)testPhiroMotorMoveBackwardBrickResources
{
    PhiroMotorMoveBackwardBrick *brick = [PhiroMotorMoveBackwardBrick new];
    brick.formula = [[Formula alloc] initWithInteger:1];
    Program *prog = [self getProgramWithOneSpriteWithBrick:brick];
    
    NSInteger resources = [prog getRequiredResources];
    XCTAssertEqual(resources, kBluetoothPhiro, @"Resourses PhiroMotorMoveBackwardBrick not correctly calculated");
}
- (void)testPhiroMotorMoveForwardBrickResources
{
    PhiroMotorMoveForwardBrick *brick = [PhiroMotorMoveForwardBrick new];
    brick.formula = [[Formula alloc] initWithInteger:1];
    Program *prog = [self getProgramWithOneSpriteWithBrick:brick];
    
    NSInteger resources = [prog getRequiredResources];
    XCTAssertEqual(resources, kBluetoothPhiro, @"Resourses PhiroMotorMoveForwardBrick not correctly calculated");
}
- (void)testPhiroMotorStopBrickResources
{
    PhiroMotorStopBrick *brick = [PhiroMotorStopBrick new];
    Program *prog = [self getProgramWithOneSpriteWithBrick:brick];
    
    NSInteger resources = [prog getRequiredResources];
    XCTAssertEqual(resources, kBluetoothPhiro, @"Resourses PhiroMotorStopBrick not correctly calculated");
}
- (void)testPhiroPlayToneBrickResources
{
    PhiroPlayToneBrick *brick = [PhiroPlayToneBrick new];
    brick.durationFormula =[[Formula alloc] initWithInteger:1];
    Program *prog = [self getProgramWithOneSpriteWithBrick:brick];
    
    NSInteger resources = [prog getRequiredResources];
    XCTAssertEqual(resources, kBluetoothPhiro, @"Resourses PhiroPlayToneBrick not correctly calculated");
}
- (void)testPhiroRGBLightBrickResources
{
    PhiroRGBLightBrick *brick = [PhiroRGBLightBrick new];
    brick.redFormula =[[Formula alloc] initWithInteger:1];
    brick.greenFormula =[[Formula alloc] initWithInteger:1];
    brick.blueFormula =[[Formula alloc] initWithInteger:1];
    Program *prog = [self getProgramWithOneSpriteWithBrick:brick];
    
    NSInteger resources = [prog getRequiredResources];
    XCTAssertEqual(resources, kBluetoothPhiro, @"Resourses PhiroRGBLightBrick not correctly calculated");
}


#pragma mark-NestedTests
- (void)testNestedResources
{
    GlideToBrick *brick = [GlideToBrick new];
    FormulaElement *element = [[FormulaElement alloc] initWithElementType:SENSOR value:sensorTestStringArray[24] leftChild:nil rightChild:nil parent:nil];
    brick.durationInSeconds = [[Formula alloc] initWithFormulaElement:element];
    element = [[FormulaElement alloc] initWithElementType:SENSOR value:sensorTestStringArray[0] leftChild:nil rightChild:nil parent:nil];
    brick.xDestination = [[Formula alloc] initWithFormulaElement:element];
    element = [[FormulaElement alloc] initWithElementType:SENSOR value:sensorTestStringArray[3] leftChild:nil rightChild:nil parent:nil];
    brick.yDestination = [[Formula alloc] initWithFormulaElement:element];
    Program *prog = [self getProgramWithOneSpriteWithBrick:brick];
    
    NSInteger resources = [prog getRequiredResources];
    XCTAssertGreaterThan(resources & kAccelerometer,0,@"Resourses nested not correctly calculated");
    XCTAssertGreaterThan(resources & kLocation,0,@"Resourses nested not correctly calculated");
    XCTAssertGreaterThan(resources & kBluetoothArduino,0,@"Resourses nested not correctly calculated");
    XCTAssertEqual(resources & kBluetoothPhiro, 0,@"Resourses nested not correctly calculated");
    XCTAssertEqual(resources & kFaceDetection, 0,@"Resourses nested not correctly calculated");
    XCTAssertEqual(resources & kMagnetometer, 0,@"Resourses nested not correctly calculated");
    XCTAssertEqual(resources & kLoudness, 0,@"Resourses nested not correctly calculated");
}
- (void)testNested2Resources
{
    GlideToBrick *brick = [GlideToBrick new];
    FormulaElement *element = [[FormulaElement alloc] initWithElementType:SENSOR value:sensorTestStringArray[14] leftChild:nil rightChild:nil parent:nil];
    brick.durationInSeconds = [[Formula alloc] initWithFormulaElement:element];
    element = [[FormulaElement alloc] initWithElementType:SENSOR value:sensorTestStringArray[1] leftChild:nil rightChild:nil parent:nil];
    brick.xDestination = [[Formula alloc] initWithFormulaElement:element];
    element = [[FormulaElement alloc] initWithElementType:SENSOR value:sensorTestStringArray[13] leftChild:nil rightChild:nil parent:nil];
    brick.yDestination = [[Formula alloc] initWithFormulaElement:element];
    Program *prog = [self getProgramWithOneSpriteWithBrick:brick];
    
    NSInteger resources = [prog getRequiredResources];
    XCTAssertGreaterThan(resources & kLoudness,0,@"Resourses nested not correctly calculated");
    XCTAssertGreaterThan(resources & kAccelerometer,0,@"Resourses nested not correctly calculated");
    XCTAssertGreaterThan(resources & kFaceDetection,0,@"Resourses nested not correctly calculated");
    XCTAssertEqual(resources & kBluetoothPhiro, 0,@"Resourses nested not correctly calculated");
    XCTAssertEqual(resources & kBluetoothArduino, 0,@"Resourses nested not correctly calculated");
    XCTAssertEqual(resources & kMagnetometer, 0,@"Resourses nested not correctly calculated");
    XCTAssertEqual(resources & kLocation, 0,@"Resourses nested not correctly calculated");
}

- (void)testNestedVibrationBrickResources
{
    VibrationBrick *brick = [VibrationBrick new];
    FormulaElement *element = [[FormulaElement alloc] initWithElementType:SENSOR value:sensorTestStringArray[14] leftChild:nil rightChild:nil parent:nil];
    brick.durationInSeconds = [[Formula alloc] initWithFormulaElement:element];
    Program *prog = [self getProgramWithOneSpriteWithBrick:brick];
    
    NSInteger resources = [prog getRequiredResources];
    XCTAssertGreaterThan(resources & kVibration,0,@"Resourses nested not correctly calculated");
    XCTAssertGreaterThan(resources & kFaceDetection,0,@"Resourses nested not correctly calculated");
    XCTAssertEqual(resources & kBluetoothPhiro, 0,@"Resourses nested not correctly calculated");
}

- (void)testNestedArduinoSendDigitalValueBrickResources
{
    ArduinoSendDigitalValueBrick *brick = [ArduinoSendDigitalValueBrick new];
    FormulaElement *element = [[FormulaElement alloc] initWithElementType:SENSOR value:sensorTestStringArray[13] leftChild:nil rightChild:nil parent:nil];
    brick.pin = [[Formula alloc] initWithFormulaElement:element];
    element = [[FormulaElement alloc] initWithElementType:SENSOR value:sensorTestStringArray[1] leftChild:nil rightChild:nil parent:nil];
    brick.value = [[Formula alloc] initWithFormulaElement:element];
    Program *prog = [self getProgramWithOneSpriteWithBrick:brick];
    
    NSInteger resources = [prog getRequiredResources];
    XCTAssertGreaterThan(resources & kBluetoothArduino,0,@"Resourses nested not correctly calculated");
    XCTAssertGreaterThan(resources & kAccelerometer,0,@"Resourses nested not correctly calculated");
    XCTAssertGreaterThan(resources & kLoudness,0,@"Resourses nested not correctly calculated");
    XCTAssertEqual(resources & kBluetoothPhiro, 0,@"Resourses nested not correctly calculated");
    XCTAssertEqual(resources & kMagnetometer, 0,@"Resourses nested not correctly calculated");
    XCTAssertEqual(resources & kLocation, 0,@"Resourses nested not correctly calculated");
}
- (void)testNestedArduinoSendPWMValueBrickResources
{
    ArduinoSendPWMValueBrick *brick = [ArduinoSendPWMValueBrick new];
    FormulaElement *element = [[FormulaElement alloc] initWithElementType:SENSOR value:sensorTestStringArray[13] leftChild:nil rightChild:nil parent:nil];
    brick.pin = [[Formula alloc] initWithFormulaElement:element];
    element = [[FormulaElement alloc] initWithElementType:SENSOR value:sensorTestStringArray[1] leftChild:nil rightChild:nil parent:nil];
    brick.value = [[Formula alloc] initWithFormulaElement:element];
    Program *prog = [self getProgramWithOneSpriteWithBrick:brick];
    
    NSInteger resources = [prog getRequiredResources];
    XCTAssertGreaterThan(resources & kBluetoothArduino,0,@"Resourses nested not correctly calculated");
    XCTAssertGreaterThan(resources & kAccelerometer,0,@"Resourses nested not correctly calculated");
    XCTAssertGreaterThan(resources & kLoudness,0,@"Resourses nested not correctly calculated");
    XCTAssertEqual(resources & kBluetoothPhiro, 0,@"Resourses nested not correctly calculated");
    XCTAssertEqual(resources & kMagnetometer, 0,@"Resourses nested not correctly calculated");
    XCTAssertEqual(resources & kLocation, 0,@"Resourses nested not correctly calculated");
}

#pragma mark-MoreScripts
-(Program*)getProgramWithTwoScriptsWithBricks:(NSArray*)brickArray andBrickArray2:(NSArray*)brickArray2
{
    Program * program = [Program new];
    SpriteObject* obj = [SpriteObject new];
    Script *script = [Script new];
    Script *script2 = [Script new];
    for (Brick* brick in brickArray) {
        [script.brickList addObject:brick];
    }
    for (Brick* brick in brickArray2) {
        [script2.brickList addObject:brick];
    }
    [obj.scriptList addObject:script];
    [obj.scriptList addObject:script2];
    [program.objectList addObject:obj];
    
    return program;
}

- (void)testNestedResourcesTwoScripts
{
    PlaceAtBrick *brick = [PlaceAtBrick new];
    FormulaElement *element = [[FormulaElement alloc] initWithElementType:SENSOR value:sensorTestStringArray[28] leftChild:nil rightChild:nil parent:nil];
    brick.xPosition = [[Formula alloc] initWithFormulaElement:element];
    element = [[FormulaElement alloc] initWithElementType:SENSOR value:sensorTestStringArray[0] leftChild:nil rightChild:nil parent:nil];
    brick.yPosition = [[Formula alloc] initWithFormulaElement:element];
    GlideToBrick *brick1 = [GlideToBrick new];
    element = [[FormulaElement alloc] initWithElementType:SENSOR value:sensorTestStringArray[14] leftChild:nil rightChild:nil parent:nil];
    brick1.durationInSeconds = [[Formula alloc] initWithFormulaElement:element];
    element = [[FormulaElement alloc] initWithElementType:SENSOR value:sensorTestStringArray[1] leftChild:nil rightChild:nil parent:nil];
    brick1.xDestination = [[Formula alloc] initWithFormulaElement:element];
    element = [[FormulaElement alloc] initWithElementType:SENSOR value:sensorTestStringArray[13] leftChild:nil rightChild:nil parent:nil];
    brick1.yDestination = [[Formula alloc] initWithFormulaElement:element];
    NSArray *brickArray = [NSArray arrayWithObjects:brick,brick1, nil];
    WaitBrick *brick2 = [WaitBrick new];
    brick2.timeToWaitInSeconds = [[Formula alloc] initWithInteger:1];
    HideBrick *brick3 = [HideBrick new];
    ArduinoSendPWMValueBrick *brick4 = [ArduinoSendPWMValueBrick new];
    element = [[FormulaElement alloc] initWithElementType:SENSOR value:sensorTestStringArray[13] leftChild:nil rightChild:nil parent:nil];
    brick4.pin = [[Formula alloc] initWithFormulaElement:element];
    element = [[FormulaElement alloc] initWithElementType:SENSOR value:sensorTestStringArray[1] leftChild:nil rightChild:nil parent:nil];
    brick4.value = [[Formula alloc] initWithFormulaElement:element];
    NSArray *brickArray2 = [NSArray arrayWithObjects:brick2,brick3,brick4, nil];
    
    Program *prog = [self getProgramWithTwoScriptsWithBricks:brickArray andBrickArray2:brickArray2];
    
    NSInteger resources = [prog getRequiredResources];
    XCTAssertGreaterThan(resources & kAccelerometer,0,@"Resourses nested not correctly calculated");
    XCTAssertGreaterThan(resources & kLoudness,0,@"Resourses nested not correctly calculated");
    XCTAssertGreaterThan(resources & kBluetoothArduino,0,@"Resourses nested not correctly calculated");
    XCTAssertEqual(resources & kBluetoothPhiro, 0,@"Resourses nested not correctly calculated");
    XCTAssertGreaterThan(resources & kFaceDetection, 0,@"Resourses nested not correctly calculated");
    XCTAssertEqual(resources & kMagnetometer, 0,@"Resourses nested not correctly calculated");
    XCTAssertEqual(resources & kLocation, 0,@"Resourses nested not correctly calculated");
}
- (void)testNestedResourcesTwoScripts2
{
    SetXBrick *brick = [SetXBrick new];
    FormulaElement *element = [[FormulaElement alloc] initWithElementType:SENSOR value:sensorTestStringArray[3] leftChild:nil rightChild:nil parent:nil];
    brick.xPosition = [[Formula alloc] initWithFormulaElement:element];
    GlideToBrick *brick1 = [GlideToBrick new];
    element = [[FormulaElement alloc] initWithElementType:SENSOR value:sensorTestStringArray[0] leftChild:nil rightChild:nil parent:nil];
    brick1.durationInSeconds = [[Formula alloc] initWithFormulaElement:element];
    element = [[FormulaElement alloc] initWithElementType:SENSOR value:sensorTestStringArray[1] leftChild:nil rightChild:nil parent:nil];
    brick1.xDestination = [[Formula alloc] initWithFormulaElement:element];
    element = [[FormulaElement alloc] initWithElementType:SENSOR value:sensorTestStringArray[2] leftChild:nil rightChild:nil parent:nil];
    brick1.yDestination = [[Formula alloc] initWithFormulaElement:element];
    NSArray *brickArray = [NSArray arrayWithObjects:brick,brick1, nil];
    WaitBrick *brick2 = [WaitBrick new];
    brick2.timeToWaitInSeconds = [[Formula alloc] initWithInteger:1];
    HideBrick *brick3 = [HideBrick new];
    
    ChangeTransparencyByNBrick *brick4 = [ChangeTransparencyByNBrick new];
     element = [[FormulaElement alloc] initWithElementType:SENSOR value:sensorTestStringArray[13] leftChild:nil rightChild:nil parent:nil];
    brick4.changeTransparency = [[Formula alloc] initWithFormulaElement:element];

    NSArray *brickArray2 = [NSArray arrayWithObjects:brick2,brick3,brick4, nil];
    
    Program *prog = [self getProgramWithTwoScriptsWithBricks:brickArray andBrickArray2:brickArray2];
    
    NSInteger resources = [prog getRequiredResources];
    XCTAssertGreaterThan(resources & kAccelerometer,0,@"Resourses nested not correctly calculated");
    XCTAssertGreaterThan(resources & kLoudness,0,@"Resourses nested not correctly calculated");
    XCTAssertEqual(resources & kBluetoothArduino,0,@"Resourses nested not correctly calculated");
    XCTAssertEqual(resources & kBluetoothPhiro, 0,@"Resourses nested not correctly calculated");
    XCTAssertEqual(resources & kFaceDetection, 0,@"Resourses nested not correctly calculated");
    XCTAssertEqual(resources & kMagnetometer, 0,@"Resourses nested not correctly calculated");
    XCTAssertGreaterThan(resources & kLocation, 0,@"Resourses nested not correctly calculated");
}

#pragma mark-MoreSprites
-(Program*)getProgramWithTwoSpritesWithBricks:(NSArray*)brickArray andBrickArray2:(NSArray*)brickArray2
{
    Program * program = [Program new];
    SpriteObject* obj = [SpriteObject new];
    SpriteObject* obj1 = [SpriteObject new];
    Script *script = [Script new];
    Script *script2 = [Script new];
    for (Brick* brick in brickArray) {
        [script.brickList addObject:brick];
    }
    for (Brick* brick in brickArray2) {
        [script2.brickList addObject:brick];
    }
    [obj.scriptList addObject:script];
    [obj1.scriptList addObject:script2];
    [program.objectList addObject:obj];
    [program.objectList addObject:obj1];
    
    return program;
}

- (void)testNestedResourcesTwoSprites
{
    PlaceAtBrick *brick = [PlaceAtBrick new];
    FormulaElement *element = [[FormulaElement alloc] initWithElementType:SENSOR value:sensorTestStringArray[28] leftChild:nil rightChild:nil parent:nil];
    brick.xPosition = [[Formula alloc] initWithFormulaElement:element];
    element = [[FormulaElement alloc] initWithElementType:SENSOR value:sensorTestStringArray[0] leftChild:nil rightChild:nil parent:nil];
    brick.yPosition = [[Formula alloc] initWithFormulaElement:element];
    GlideToBrick *brick1 = [GlideToBrick new];
    element = [[FormulaElement alloc] initWithElementType:SENSOR value:sensorTestStringArray[14] leftChild:nil rightChild:nil parent:nil];
    brick1.durationInSeconds = [[Formula alloc] initWithFormulaElement:element];
    element = [[FormulaElement alloc] initWithElementType:SENSOR value:sensorTestStringArray[1] leftChild:nil rightChild:nil parent:nil];
    brick1.xDestination = [[Formula alloc] initWithFormulaElement:element];
    element = [[FormulaElement alloc] initWithElementType:SENSOR value:sensorTestStringArray[13] leftChild:nil rightChild:nil parent:nil];
    brick1.yDestination = [[Formula alloc] initWithFormulaElement:element];
    NSArray *brickArray = [NSArray arrayWithObjects:brick,brick1, nil];
    WaitBrick *brick2 = [WaitBrick new];
    brick2.timeToWaitInSeconds = [[Formula alloc] initWithInteger:1];
    HideBrick *brick3 = [HideBrick new];
    ArduinoSendPWMValueBrick *brick4 = [ArduinoSendPWMValueBrick new];
    element = [[FormulaElement alloc] initWithElementType:SENSOR value:sensorTestStringArray[13] leftChild:nil rightChild:nil parent:nil];
    brick4.pin = [[Formula alloc] initWithFormulaElement:element];
    element = [[FormulaElement alloc] initWithElementType:SENSOR value:sensorTestStringArray[1] leftChild:nil rightChild:nil parent:nil];
    brick4.value = [[Formula alloc] initWithFormulaElement:element];
    NSArray *brickArray2 = [NSArray arrayWithObjects:brick2,brick3,brick4, nil];
    
    Program *prog = [self getProgramWithTwoSpritesWithBricks:brickArray andBrickArray2:brickArray2];
    
    NSInteger resources = [prog getRequiredResources];
    XCTAssertGreaterThan(resources & kAccelerometer,0,@"Resourses nested not correctly calculated");
    XCTAssertGreaterThan(resources & kLoudness,0,@"Resourses nested not correctly calculated");
    XCTAssertGreaterThan(resources & kBluetoothArduino,0,@"Resourses nested not correctly calculated");
    XCTAssertEqual(resources & kBluetoothPhiro, 0,@"Resourses nested not correctly calculated");
    XCTAssertGreaterThan(resources & kFaceDetection, 0,@"Resourses nested not correctly calculated");
    XCTAssertEqual(resources & kMagnetometer, 0,@"Resourses nested not correctly calculated");
    XCTAssertEqual(resources & kLocation, 0,@"Resourses nested not correctly calculated");
}

- (void)testNestedResourcesTwoSprites2
{
    SetXBrick *brick = [SetXBrick new];
    FormulaElement *element = [[FormulaElement alloc] initWithElementType:SENSOR value:sensorTestStringArray[3] leftChild:nil rightChild:nil parent:nil];
    brick.xPosition = [[Formula alloc] initWithFormulaElement:element];
    GlideToBrick *brick1 = [GlideToBrick new];
    element = [[FormulaElement alloc] initWithElementType:SENSOR value:sensorTestStringArray[0] leftChild:nil rightChild:nil parent:nil];
    brick1.durationInSeconds = [[Formula alloc] initWithFormulaElement:element];
    element = [[FormulaElement alloc] initWithElementType:SENSOR value:sensorTestStringArray[1] leftChild:nil rightChild:nil parent:nil];
    brick1.xDestination = [[Formula alloc] initWithFormulaElement:element];
    element = [[FormulaElement alloc] initWithElementType:SENSOR value:sensorTestStringArray[2] leftChild:nil rightChild:nil parent:nil];
    brick1.yDestination = [[Formula alloc] initWithFormulaElement:element];
    NSArray *brickArray = [NSArray arrayWithObjects:brick,brick1, nil];
    WaitBrick *brick2 = [WaitBrick new];
    brick2.timeToWaitInSeconds = [[Formula alloc] initWithInteger:1];
    HideBrick *brick3 = [HideBrick new];
    
    ChangeTransparencyByNBrick *brick4 = [ChangeTransparencyByNBrick new];
    element = [[FormulaElement alloc] initWithElementType:SENSOR value:sensorTestStringArray[13] leftChild:nil rightChild:nil parent:nil];
    brick4.changeTransparency = [[Formula alloc] initWithFormulaElement:element];
    
    NSArray *brickArray2 = [NSArray arrayWithObjects:brick2,brick3,brick4, nil];
    
    Program *prog = [self getProgramWithTwoSpritesWithBricks:brickArray andBrickArray2:brickArray2];
    
    NSInteger resources = [prog getRequiredResources];
    XCTAssertGreaterThan(resources & kAccelerometer,0,@"Resourses nested not correctly calculated");
    XCTAssertGreaterThan(resources & kLoudness,0,@"Resourses nested not correctly calculated");
    XCTAssertEqual(resources & kBluetoothArduino,0,@"Resourses nested not correctly calculated");
    XCTAssertEqual(resources & kBluetoothPhiro, 0,@"Resourses nested not correctly calculated");
    XCTAssertEqual(resources & kFaceDetection, 0,@"Resourses nested not correctly calculated");
    XCTAssertEqual(resources & kMagnetometer, 0,@"Resourses nested not correctly calculated");
    XCTAssertGreaterThan(resources & kLocation, 0,@"Resourses nested not correctly calculated");
}


@end
