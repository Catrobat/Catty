//
//  ParserTests.m
//  Catty
//
//  Created by Christof Stromberger on 15.07.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "ParserTests.h"
#import "RetailParser.h"
#import "Level.h"
#import "Sprite.h"
#import "Costume.h"
#import "Brick.h"
#import "Script.h"
#import "StartScript.h"
#import "GDataXMLNode.h"
#import "LevelParser.h"
#import "Sprite.h"
#import "Costume.h"
#import "Script.h"
#import "Brick.h"
#import "SetCostumeBrick.h"
#import "WaitBrick.h"
#import "StartScript.h"
#import "WhenScript.h"
#import "Sound.h"
#import "PlaceAtBrick.h"
#import "GlideToBrick.h"
#import "NextCostumeBrick.h"
#import "HideBrick.h"
#import "ShowBrick.h"
#import "SetXBrick.h"
#import "SetYBrick.h"
#import "ChangeSizeByNBrick.h"
#import "BroadcastBrick.h"
#import "BroadcastWaitBrick.h"
#import "ChangeXByBrick.h"
#import "ChangeYByBrick.h"
#import "PlaySoundBrick.h"
#import "StopAllSoundsBrick.h"
#import "ComeToFrontBrick.h"
#import "SetSizeToBrick.h"
#import "LoopBrick.h"
#import "RepeatBrick.h"
#import "EndLoopBrick.h"
#import "GoNStepsBackBrick.h"
#import "SetGhostEffectBrick.h"
#import "SetVolumeToBrick.h"
#import "ChangeVolumeByBrick.h"
#import "ChangeGhostEffectBrick.h"
#import "SpeakBrick.h"

@interface ParserTests()
@property (nonatomic, strong) LevelParser *parser;
@end

@implementation ParserTests

@synthesize parser = _parser;

#pragma mark - tear up & down
- (void)setUp
{
    [super setUp];

//    self.parser = [[RetailParser alloc] init];
    self.parser = [[LevelParser alloc]init];
}


- (void)tearDown
{    
    [super tearDown];

}

//- (void)test001_testBasicParser
//{
//    NSString *fileName = @"defaultProject";
//    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
//    NSString *path = [bundle pathForResource:fileName ofType:@"xml"];
//    
//    Level *level = [self.parser generateObjectForLevel:path];
//    NSLog(@"Level: %@", level);
//    STAssertTrue([level.name isEqualToString:@"defaultProject"], @"checking if the name of the level is correct");
//    Sprite *sprite = [level.spritesArray objectAtIndex:0];
//    STAssertTrue([sprite.name isEqualToString:@"Background"], @"checking if the name of the first sprite is correct");
//    Costume *costume = [sprite.costumesArray objectAtIndex:0];
//    STAssertTrue([costume.costumeName isEqualToString:@"background"], @"checking if the name of the first costume in the sprite is correct");
//    Script *script = [sprite.startScriptsArray objectAtIndex:0];
//    STAssertTrue(script != nil, @"checking if script is valid");
////    Brick *brick = [script.bricksArray objectAtIndex:0];
////    STAssertTrue([brick isKindOfClass:[SetCostumeBrick class]], @"checking if brick is valid");
//
//}


#pragma mark - test cases

- (void)test001_setCostumeFirstCostume
{
    NSString *xmlString = @"<Bricks.SetCostumeBrick><costumeData reference=\"../../../../../costumeDataList/Common.CostumeData\"/><sprite reference=\"../../../../..\"/></Bricks.SetCostumeBrick>";
    NSError *error;
    NSData *xmlData = [xmlString dataUsingEncoding:NSASCIIStringEncoding];
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData
                                                           options:0 error:&error];
    Brick *newBrick = [self.parser loadSetCostumeBrick:doc.rootElement];
    if (![newBrick isMemberOfClass:[SetCostumeBrick class]])
        STFail(@"Wrong class-member");
    SetCostumeBrick *brick = (SetCostumeBrick*)newBrick;
    STAssertTrue(brick.indexOfCostumeInArray==[NSNumber numberWithInt:0], @"Wrong indexOfCostumeInArray-value");
}

- (void)test002_setCostumeSecondCostume
{
    NSString *xmlString = @"<Bricks.SetCostumeBrick><costumeData reference=\"../../../../../costumeDataList/Common.CostumeData[2]\"/><sprite reference=\"../../../../..\"/></Bricks.SetCostumeBrick>";
    NSError *error;
    NSData *xmlData = [xmlString dataUsingEncoding:NSASCIIStringEncoding];
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData
                                                           options:0 error:&error];
    Brick *newBrick = [self.parser loadSetCostumeBrick:doc.rootElement];
    if (![newBrick isMemberOfClass:[SetCostumeBrick class]])
        STFail(@"Wrong class-member");
    SetCostumeBrick *brick = (SetCostumeBrick*)newBrick;
    STAssertTrue(brick.indexOfCostumeInArray==[NSNumber numberWithInt:1], @"Wrong indexOfCostumeInArray-value");
}

- (void)test003_wait
{
    int timeToWaitInMilliSeconds = 500;
    NSString *xmlString = [NSString stringWithFormat:@"<Bricks.WaitBrick><sprite reference=\"../../../../..\"/><timeToWaitInMilliSeconds>%d</timeToWaitInMilliSeconds></Bricks.WaitBrick>", timeToWaitInMilliSeconds];
    NSError *error;
    NSData *xmlData = [xmlString dataUsingEncoding:NSASCIIStringEncoding];
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData
                                                           options:0 error:&error];
    Brick *newBrick = [self.parser loadWaitBrick:doc.rootElement];
    if (![newBrick isMemberOfClass:[WaitBrick class]])
        STFail(@"Wrong class-member");
    WaitBrick *brick = (WaitBrick*)newBrick;
    STAssertTrue(brick.timeToWaitInMilliseconds.intValue == timeToWaitInMilliSeconds, @"Wrong timeToWaitInMilliSeconds-value");
}

- (void)test004_placeAt
{
    CGPoint position = CGPointMake(-123, 456);
    NSString *xmlString = [NSString stringWithFormat:@"<Bricks.PlaceAtBrick><sprite reference=\"../../../../..\"/><xPosition>%f</xPosition><yPosition>%f</yPosition></Bricks.PlaceAtBrick>", position.x, position.y];
    NSError *error;
    NSData *xmlData = [xmlString dataUsingEncoding:NSASCIIStringEncoding];
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData
                                                           options:0 error:&error];
    Brick *newBrick = [self.parser loadPlaceAtBrick:doc.rootElement];
    if (![newBrick isMemberOfClass:[PlaceAtBrick class]])
        STFail(@"Wrong class-member");
    PlaceAtBrick *brick = (PlaceAtBrick*)newBrick;
    STAssertTrue(brick.position.x == position.x && brick.position.y == position.y, @"Wrong position-value");
}

- (void)test005_glideTo
{
    CGPoint position = CGPointMake(-123, 456);
    int duration = 1000;
    NSString *xmlString = [NSString stringWithFormat:@"<Bricks.GlideToBrick><durationInMilliSeconds>%d</durationInMilliSeconds><sprite reference=\"../../../../..\"/><xDestination>%f</xDestination><yDestination>%f</yDestination></Bricks.GlideToBrick>", duration, position.x, position.y];
    NSError *error;
    NSData *xmlData = [xmlString dataUsingEncoding:NSASCIIStringEncoding];
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData
                                                           options:0 error:&error];
    Brick *newBrick = [self.parser loadGlideToBrick:doc.rootElement];
    if (![newBrick isMemberOfClass:[GlideToBrick class]])
        STFail(@"Wrong class-member");
    GlideToBrick *brick = (GlideToBrick*)newBrick;
    STAssertTrue(brick.position.x == position.x && brick.position.y == position.y, @"Wrong position-value");
    STAssertTrue(brick.durationInMilliSecs == duration, @"Wrong duration-value");
}

- (void)test006_setX
{
    float x = 3.3f;
    NSString *xmlString = [NSString stringWithFormat:@"<Bricks.SetXBrick><sprite reference=\"../../../../..\"/><xPosition>%f</xPosition></Bricks.SetXBrick>", x];
    NSError *error;
    NSData *xmlData = [xmlString dataUsingEncoding:NSASCIIStringEncoding];
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData
                                                           options:0 error:&error];
    Brick *newBrick = [self.parser loadSetXBrick:doc.rootElement];
    if (![newBrick isMemberOfClass:[SetXBrick class]])
        STFail(@"Wrong class-member");
    SetXBrick *brick = (SetXBrick*)newBrick;
    STAssertTrue(brick.xPosition == x, @"Wrong position-value");
}

- (void)test007_setY
{
    float y = 324.234f;
    NSString *xmlString = [NSString stringWithFormat:@"<Bricks.SetYBrick><sprite reference=\"../../../../..\"/><yPosition>%f</yPosition></Bricks.SetYBrick>", y];
    NSError *error;
    NSData *xmlData = [xmlString dataUsingEncoding:NSASCIIStringEncoding];
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData
                                                           options:0 error:&error];
    Brick *newBrick = [self.parser loadSetYBrick:doc.rootElement];
    if (![newBrick isMemberOfClass:[SetYBrick class]])
        STFail(@"Wrong class-member");
    SetYBrick *brick = (SetYBrick*)newBrick;
    STAssertTrue(brick.yPosition == y, @"Wrong position-value");
}

- (void)test008_changeSizeByN
{
    float sizeInPercentage = 1.05f;
    NSString *xmlString = [NSString stringWithFormat:@"<Bricks.ChangeSizeByNBrick><size>%f</size><sprite reference=\"../../../../..\"/></Bricks.ChangeSizeByNBrick>", sizeInPercentage];
    NSError *error;
    NSData *xmlData = [xmlString dataUsingEncoding:NSASCIIStringEncoding];
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData
                                                           options:0 error:&error];
    Brick *newBrick = [self.parser loadChangeSizeByNBrick:doc.rootElement];
    if (![newBrick isMemberOfClass:[ChangeSizeByNBrick class]])
        STFail(@"Wrong class-member");
    ChangeSizeByNBrick *brick = (ChangeSizeByNBrick*)newBrick;
    STAssertTrue(brick.sizeInPercentage == sizeInPercentage, @"Wrong size-value");
}

- (void)test009_broadcast
{
    NSString *broadcastMessage = @"BroadCastMessage!";
    NSString *xmlString = [NSString stringWithFormat:@"<Bricks.BroadcastBrick><broadcastMessage>%@</broadcastMessage><sprite reference=\"../../../../..\"/></Bricks.BroadcastBrick>", broadcastMessage];
    NSError *error;
    NSData *xmlData = [xmlString dataUsingEncoding:NSASCIIStringEncoding];
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData
                                                           options:0 error:&error];
    Brick *newBrick = [self.parser loadBroadcastBrick:doc.rootElement];
    if (![newBrick isMemberOfClass:[BroadcastBrick class]])
        STFail(@"Wrong class-member");
    BroadcastBrick *brick = (BroadcastBrick*)newBrick;
    STAssertTrue([brick.message isEqualToString:broadcastMessage], @"Wrong broadcastMessage-value");
}

- (void)test010_broadcastWait
{
    NSString *broadcastMessage = @"BroadCastMessage!";
    NSString *xmlString = [NSString stringWithFormat:@"<Bricks.BroadcastWaitBrick><broadcastMessage>%@</broadcastMessage><sprite reference=\"../../../../..\"/></Bricks.BroadcastWaitBrick>", broadcastMessage];
    NSError *error;
    NSData *xmlData = [xmlString dataUsingEncoding:NSASCIIStringEncoding];
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData
                                                           options:0 error:&error];
    Brick* newBrick = [self.parser loadBroadcastWaitBrick:doc.rootElement];
    if (![newBrick isMemberOfClass:[BroadcastWaitBrick class]])
        STFail(@"Wrong class-member");
    BroadcastWaitBrick *brick = (BroadcastWaitBrick*)newBrick;
    STAssertTrue([brick.message isEqualToString:broadcastMessage], @"Wrong broadcastWaitMessage-value");
}

- (void)test011_changeXBy
{
    int x = 5;
    NSString *xmlString = [NSString stringWithFormat:@"<Bricks.ChangeXByBrick><sprite reference=\"../../../../..\"/><xMovement>%d</xMovement></Bricks.ChangeXByBrick>", x];
    NSError *error;
    NSData *xmlData = [xmlString dataUsingEncoding:NSASCIIStringEncoding];
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData
                                                           options:0 error:&error];
    Brick *newBrick = [self.parser loadChangeXByBrick:doc.rootElement];
    if (![newBrick isMemberOfClass:[ChangeXByBrick class]])
        STFail(@"Wrong class-member");
    ChangeXByBrick *brick = (ChangeXByBrick*)newBrick;
    STAssertTrue(brick.x == x, @"Wrong x-value");
}

- (void)test012_changeYBy
{
    int y = 500;
    NSString *xmlString = [NSString stringWithFormat:@"<Bricks.ChangeYByBrick><sprite reference=\"../../../../..\"/><yMovement>%d</yMovement></Bricks.ChangeYByBrick>", y];
    NSError *error;
    NSData *xmlData = [xmlString dataUsingEncoding:NSASCIIStringEncoding];
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData
                                                           options:0 error:&error];
    Brick *newBrick = [self.parser loadChangeYByBrick:doc.rootElement];
    if (![newBrick isMemberOfClass:[ChangeYByBrick class]])
        STFail(@"Wrong class-member");
    ChangeYByBrick *brick = (ChangeYByBrick*)newBrick;
    STAssertTrue(brick.y == y, @"Wrong y-value");
}

- (void)test013_setSizeTo
{
    float sizeInPercentage = 120.5f;
    NSString *xmlString = [NSString stringWithFormat:@"<Bricks.SetSizeToBrick><size>%f</size><sprite reference=\"../../../../..\"/></Bricks.SetSizeToBrick>", sizeInPercentage];
    NSError *error;
    NSData *xmlData = [xmlString dataUsingEncoding:NSASCIIStringEncoding];
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData
                                                           options:0 error:&error];
    Brick *newBrick = [self.parser loadSetSizeToBrick:doc.rootElement];
    if (![newBrick isMemberOfClass:[SetSizeToBrick class]])
        STFail(@"Wrong class-member");
    SetSizeToBrick *brick = (SetSizeToBrick*)newBrick;
    STAssertTrue(brick.sizeInPercentage == sizeInPercentage, @"Wrong size-value");
}

- (void)test014_Repeat
{
    int numberOfLoops = 123;
    NSString *xmlString = [NSString stringWithFormat:@"<Bricks.RepeatBrick><loopEndBrick><loopBeginBrick class=\"Bricks.RepeatBrick\" reference=\"../..\"/><sprite reference=\"../../../../../..\"/></loopEndBrick><sprite reference=\"../../../../..\"/><timesToRepeat>%d</timesToRepeat></Bricks.RepeatBrick>", numberOfLoops];
    NSError *error;
    NSData *xmlData = [xmlString dataUsingEncoding:NSASCIIStringEncoding];
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData
                                                           options:0 error:&error];
    Brick *newBrick = [self.parser loadRepeatBrick:doc.rootElement];
    if (![newBrick isMemberOfClass:[RepeatBrick class]])
        STFail(@"Wrong class-member");
    RepeatBrick *brick = (RepeatBrick*)newBrick;
    STAssertTrue(brick.numberOfLoops == numberOfLoops, @"Wrong numberOfLoops-value");
}

- (void)test015_GoNStepsBack
{
    int steps = 987;
    NSString *xmlString = [NSString stringWithFormat:@"<Bricks.GoNStepsBackBrick><sprite reference=\"../../../../..\"/><steps>%d</steps></Bricks.GoNStepsBackBrick>", steps];
    NSError *error;
    NSData *xmlData = [xmlString dataUsingEncoding:NSASCIIStringEncoding];
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData
                                                           options:0 error:&error];
    Brick *newBrick = [self.parser loadGoNStepsBackBrick:doc.rootElement];
    if (![newBrick isMemberOfClass:[GoNStepsBackBrick class]])
        STFail(@"Wrong class-member");
    GoNStepsBackBrick *brick = (GoNStepsBackBrick*)newBrick;
    STAssertTrue(brick.n == steps, @"Wrong steps-value");
}

- (void)test016_setGhostEffect
{
    float transparency = 0.45f;
    NSString *xmlString = [NSString stringWithFormat:@"<Bricks.SetGhostEffectBrick><sprite reference=\"../../../../..\"/><transparency>%f</transparency></Bricks.SetGhostEffectBrick>", transparency];
    NSError *error;
    NSData *xmlData = [xmlString dataUsingEncoding:NSASCIIStringEncoding];
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData
                                                           options:0 error:&error];
    Brick *newBrick = [self.parser loadGhostEffectBrick:doc.rootElement];
    if (![newBrick isMemberOfClass:[SetGhostEffectBrick class]])
        STFail(@"Wrong class-member");
    SetGhostEffectBrick *brick = (SetGhostEffectBrick*)newBrick;
    STAssertTrue(brick.transparency == transparency, @"Wrong transparency-value");
}

- (void)test017_changeGhostEffect
{
    float transparencyIncrease = 0.45f;
    NSString *xmlString = [NSString stringWithFormat:@"<Bricks.ChangeGhostEffectBrick><changeGhostEffect>%f</changeGhostEffect><sprite reference=\"../../../../..\"/></Bricks.ChangeGhostEffectBrick>", transparencyIncrease];
    NSError *error;
    NSData *xmlData = [xmlString dataUsingEncoding:NSASCIIStringEncoding];
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData
                                                           options:0 error:&error];
    Brick *newBrick = [self.parser loadChangeGhostEffectBrick:doc.rootElement];
    if (![newBrick isMemberOfClass:[ChangeGhostEffectBrick class]])
        STFail(@"Wrong class-member");
    ChangeGhostEffectBrick *brick = (ChangeGhostEffectBrick*)newBrick;
    STAssertTrue(brick.increase == transparencyIncrease, @"Wrong transparency-value");
}

- (void)test018_playSound
{
    NSString *fileName = @"ThisIsTheFileName";
    NSString *xmlString = [NSString stringWithFormat:@"<Bricks.PlaySoundBrick><soundInfo><fileName>%@</fileName><name>ABCD</name></soundInfo><sprite reference=\"../../../../..\"/></Bricks.PlaySoundBrick>", fileName];
    NSError *error;
    NSData *xmlData = [xmlString dataUsingEncoding:NSASCIIStringEncoding];
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData
                                                           options:0 error:&error];
    Brick *newBrick = [self.parser loadSoundBrick:doc.rootElement];
    if (![newBrick isMemberOfClass:[PlaySoundBrick class]])
        STFail(@"Wrong class-member");
    PlaySoundBrick *brick = (PlaySoundBrick*)newBrick;
    STAssertTrue([brick.fileName isEqualToString:fileName], @"Wrong fileName");
}

- (void)test019_setVolumeTo
{
    float volume = 5.1f;
    NSString *xmlString = [NSString stringWithFormat:@"<Bricks.SetVolumeToBrick><sprite reference=\"../../../../..\"/><volume>%f</volume></Bricks.SetVolumeToBrick>", volume];
    NSError *error;
    NSData *xmlData = [xmlString dataUsingEncoding:NSASCIIStringEncoding];
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData
                                                           options:0 error:&error];
    Brick *newBrick = [self.parser loadSetVolumeToBrick:doc.rootElement];
    if (![newBrick isMemberOfClass:[SetVolumeToBrick class]])
        STFail(@"Wrong class-member");
    SetVolumeToBrick *brick = (SetVolumeToBrick*)newBrick;
    STAssertTrue(brick.volume == volume, @"Wrong volume-value");
}

- (void)test020_changeVolumeBy
{
    float percent = 1.2f;
    NSString *xmlString = [NSString stringWithFormat:@"<Bricks.ChangeVolumeByBrick><sprite reference=\"../../../../..\"/><volume>%f</volume></Bricks.ChangeVolumeByBrick>", percent];
    NSError *error;
    NSData *xmlData = [xmlString dataUsingEncoding:NSASCIIStringEncoding];
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData
                                                           options:0 error:&error];
    Brick *newBrick = [self.parser loadChangeVolumeByBrick:doc.rootElement];
    if (![newBrick isMemberOfClass:[ChangeVolumeByBrick class]])
        STFail(@"Wrong class-member");
    ChangeVolumeByBrick *brick = (ChangeVolumeByBrick*)newBrick;
    STAssertTrue(brick.percent == percent, @"Wrong volume-percent-value");
}

- (void)test021_speak
{
    NSString* text = @"This is a test";
    NSString *xmlString = [NSString stringWithFormat:@"<Bricks.SpeakBrick><sprite reference=\"../../../../..\"/><text>%@</text></Bricks.SpeakBrick>", text];
    NSError *error;
    NSData *xmlData = [xmlString dataUsingEncoding:NSASCIIStringEncoding];
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData
                                                           options:0 error:&error];
    Brick *newBrick = [self.parser loadSpeakBrick:doc.rootElement];
    if (![newBrick isMemberOfClass:[SpeakBrick class]])
        STFail(@"Wrong class-member");
    SpeakBrick *brick = (SpeakBrick*)newBrick;
    STAssertEqualObjects(brick.text, text, @"Wrong text");
}


@end
