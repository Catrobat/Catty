//
//  DataModelBricksTest.m
//  Catty
//
//  Created by Dominik Ziegler on 9/27/12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "DataModelBricksTest.h"
#import "Sprite.h"
#import "Script.h"
#import "Brick.h"
#import "SetLookBrick.h"
#import "WaitBrick.h"
#import "Sound.h"
#import "PlaceAtBrick.h"
#import "GlideToBrick.h"
#import "NextLookBrick.h"
#import "HideBrick.h"
#import "ShowBrick.h"
#import "SetXBrick.h"
#import "SetYBrick.h"
#import "ChangeSizeByNBrick.h"
#import "BroadcastBrick.h"
#import "BroadcastWaitBrick.h"
#import "ChangeXByNBrick.h"
#import "ChangeYByNBrick.h"
#import "PlaySoundBrick.h"
#import "StopAllSoundsBrick.h"
#import "ComeToFrontBrick.h"
#import "SetSizeToBrick.h"
#import "ForeverBrick.h"
#import "RepeatBrick.h"
#import "LoopEndBrick.h"
#import "GoNStepsBackBrick.h"
#import "SetGhostEffectBrick.h"
#import "SetVolumeToBrick.h"
#import "ChangeVolumeByBrick.h"
#import "ChangeGhostEffectByNBrick.h"
#import "SpeakBrick.h"
#import "BroadcastWaitDelegate.h"
#import "BroadcastWaitHandler.h"
#import "SetLookBrick.h"

@interface DataModelBricksTest()

@property (nonatomic, assign) BOOL stop;

@end


@implementation DataModelBricksTest


#pragma mark - test cases
//just a basic test
//- (void)test001_setCostume
//{
//    SetLookBrick *brick = [[SetLookBrick alloc]init];
//    brick.indexOfCostumeInArray = 0;
//    
//    Sprite *sprite = [[Sprite alloc]init];
//    Costume *costume1 = [Costume alloc]initWithName:@"costume1" andPath:<#(NSString *)#>
//    
//}
//
-(void)test002_Wait
{
    int timeToWaitInMilliSecs = 300;
    WaitBrick *brick = [[WaitBrick alloc]init];
    
    Script *script = [[Script alloc]init];
    
    brick.timeToWaitInMilliSeconds = [NSNumber numberWithInt:timeToWaitInMilliSecs];
    NSTimeInterval before = [[NSDate date]timeIntervalSince1970];
    [brick performFromScript:script];
    NSTimeInterval after = [[NSDate date]timeIntervalSince1970];
    NSLog(@"Needed Time: %f", after-before);
    STAssertFalse((after-before) < timeToWaitInMilliSecs/1000.0f,         @"Wait-time was too short");
    STAssertFalse((after-before) > timeToWaitInMilliSecs/1000.0f + 0.05f, @"Wait-time was too long - note: tolerance-value big enough?!");// NOTE: tolerance-value?!
}

-(void)test003_HideAndShow
{
    Sprite *sprite = [[Sprite alloc]initWithEffect:nil];

    HideBrick *hideBrick = [[HideBrick alloc]initWithSprite:sprite];
    ShowBrick *showBrick = [[ShowBrick alloc]initWithSprite:sprite];
    
    [hideBrick performFromScript:nil];
    STAssertFalse(sprite.showSprite, @"Sprite is visible - that's bad!");
    [showBrick performFromScript:nil];
    STAssertTrue(sprite.showSprite, @"Sprite is invisible - that's bad!");
}

-(void)test004_PlaceAt
{
    GLKVector3 position = GLKVector3Make(1.2f, 2.3f, 0.0f);

    Sprite *sprite = [[Sprite alloc]initWithEffect:nil];
    PlaceAtBrick *brick = [[PlaceAtBrick alloc]initWithXPosition:[NSNumber numberWithFloat:position.x] yPosition:[NSNumber numberWithFloat:position.y]];
    brick.sprite = sprite;

    [brick performFromScript:nil];
    STAssertTrue(GLKVector3AllEqualToVector3(sprite.position, position), @"Position of sprite is wrong!");
}

-(void)test005_SetXY
{
    NSNumber *xPosition = [NSNumber numberWithFloat:123.4f];
    NSNumber *yPosition = [NSNumber numberWithFloat:-45.7f];
    SetXBrick *xBrick = [[SetXBrick alloc]initWithXPosition:xPosition];
    SetYBrick *yBrick = [[SetYBrick alloc]initWithYPosition:yPosition];

    Sprite *sprite = [[Sprite alloc]initWithEffect:nil];
    xBrick.sprite = sprite;
    yBrick.sprite = sprite;
    
    GLKVector3 oldPosition = sprite.position;
    
    [xBrick performFromScript:nil];
    STAssertTrue(GLKVector3AllEqualToVector3(sprite.position, GLKVector3Make(oldPosition.x+xPosition.floatValue, oldPosition.y, oldPosition.z)), @"x-position of sprite is wrong!");
    
    oldPosition = sprite.position;
    [yBrick performFromScript:nil];
    STAssertTrue(GLKVector3AllEqualToVector3(sprite.position, GLKVector3Make(oldPosition.x, oldPosition.y+yPosition.floatValue, oldPosition.z)), @"y-position of sprite is wrong!");
}

-(void)test006_changeXYBy
{
    NSNumber *xPosition = [NSNumber numberWithInt:-5];
    NSNumber *yPosition = [NSNumber numberWithInt:10];
    ChangeXByNBrick *xBrick = [[ChangeXByNBrick alloc]initWithChangeValueForX:xPosition];
    ChangeYByNBrick *yBrick = [[ChangeYByNBrick alloc]initWithChangeValueForY:yPosition];
    
    Sprite *sprite = [[Sprite alloc]initWithEffect:nil];
    xBrick.sprite = sprite;
    yBrick.sprite = sprite;
    
    GLKVector3 oldPosition = sprite.position;
    
    [xBrick performFromScript:nil];
    STAssertTrue(GLKVector3AllEqualToVector3(sprite.position, GLKVector3Make(oldPosition.x+xPosition.floatValue, oldPosition.y, oldPosition.z)), @"x-position of sprite is wrong!");
    
    oldPosition = sprite.position;
    [yBrick performFromScript:nil];
    STAssertTrue(GLKVector3AllEqualToVector3(sprite.position, GLKVector3Make(oldPosition.x, oldPosition.y+yPosition.floatValue, oldPosition.z)), @"y-position of sprite is wrong!");
}

//-(void)test007_speak
//{
//    SpeakBrick* speakBrick = [[SpeakBrick alloc] initWithText:@"This is a test!"];
//    Sprite *sprite = [[Sprite alloc]initWithEffect:nil];
//    
//    sprite.spriteManagerDelegate = self;
//    
//    [speakBrick performOnSprite:sprite fromScript:nil];
//}
//
//-(void)test008_playSound
//{
//    
//    NSString* locale = [[NSLocale preferredLanguages] objectAtIndex:0];
//    NSString* fileName;
//    
//    if([locale isEqualToString:@"en"])
//    {
//        fileName = @"1ebbaf4b682faba548ac1bb2d69ab0281d556853.mp3";
//    }
//    
//    if([locale isEqualToString:@"de"])
//    {
//        fileName = @"1834508dbef875bfaf1d8543eba8fc6c1d1bd300.mp3";
//    }
//    
//    PlaySoundBrick* playSoundBrick = [[PlaySoundBrick alloc] initWithFileName:fileName];
//    
//    Sprite *sprite = [[Sprite alloc]initWithEffect:nil];
//    sprite.spriteManagerDelegate = self;
//    NSBundle *thisBundle = [NSBundle bundleForClass:[self class]];
//    sprite.projectPath = [[NSString alloc] initWithFormat:@"%@/", [thisBundle bundlePath]];
//        
//    [playSoundBrick performOnSprite:sprite fromScript:nil];
//}
//
//-(void)test009_stopAllSounds
//{
//    StopAllSoundsBrick* stopSoundBrick = [[StopAllSoundsBrick alloc] init];    
//    Sprite *sprite = [[Sprite alloc]initWithEffect:nil];
//    sprite.spriteManagerDelegate = self;
//    
//    self.stop = NO;
//    [stopSoundBrick performOnSprite:sprite fromScript:nil];
//    
//    STAssertTrue(self.stop, @"Stop Delegate Method was not called!");
//    self.stop = NO;
//}
//
//-(void)test010_setGhostEffect
//{
//    float transparency = 40.0f;
//    SetGhostEffectBrick* ghostEffectBrick = [[SetGhostEffectBrick alloc] initWithTransparencyInPercent:transparency];
//    Sprite *sprite = [[Sprite alloc]initWithEffect:nil];
//    
//    [ghostEffectBrick performOnSprite:sprite fromScript:nil];
//    
//    STAssertTrue(sprite.alphaValue != transparency/100.0f, @"Alpha Value not correct");
//}
//
//-(void)test011_changeGhostEffect
//{
//    float increase = 0.10f;
//    Sprite *sprite = [[Sprite alloc]initWithEffect:nil];
//    float alpha = [sprite alphaValue];
//    ChangeGhostEffectByNBrick* changeGhostEffectBrick = [[ChangeGhostEffectByNBrick alloc] initWithIncrease:increase];
//    [changeGhostEffectBrick performOnSprite:sprite fromScript:nil];
//    
//    STAssertTrue((alpha-(increase/100.0f)) == [sprite alphaValue], @"Alpha Value not the same");
//}
//
//-(void)test012_broadcast
//{
//    NSString *broadcastMessage = @"BROADCAST";
//    
//    //sprite1
//    BroadcastBrick *broadcastBrick = [[BroadcastBrick alloc]initWithMessage:broadcastMessage];
//    
//    Script *whenScript = [[Script alloc]init];
//    [whenScript addBricks:[NSMutableArray arrayWithObjects: broadcastBrick, nil]];
//    
//    
//    Sprite *sprite1 = [[Sprite alloc] initWithEffect:nil];
//    [sprite1 addWhenScript:whenScript];
//    
//    
//    //sprite2
//    GLKVector3 position = GLKVector3Make(1.3f, 2.2f, 3.1f);
//    PlaceAtBrick *brick = [[PlaceAtBrick alloc]initWithPosition:position];
//    
//    Script *broadcastScript = [[Script alloc]init];
//    [broadcastScript addBricks:[NSArray arrayWithObject:brick]];
//    
//    Sprite *sprite2 = [[Sprite alloc] initWithEffect:nil];
//    [sprite2 addBroadcastScript:broadcastScript forMessage:broadcastMessage];
//
//    STAssertFalse(GLKVector3AllEqualToVector3(sprite2.position, position), @"Init-position should not be the same as target-position");
//
//    [broadcastBrick performOnSprite:sprite1 fromScript:nil];
//    [NSThread sleepForTimeInterval:0.1]; // wait for async-blocks...
//    
//    STAssertTrue(GLKVector3AllEqualToVector3(sprite2.position, position), @"Broadcast-script was not performed correct");
//}
//
//-(void)test013_broadcastWait
//{
//    BroadcastWaitHandler *handler = [[BroadcastWaitHandler alloc] init];
//    NSString *broadcastMessage = @"BROADCAST_WAIT";
//    
//    //sprite1
//    BroadcastWaitBrick *broadcastWaitBrick = [[BroadcastWaitBrick alloc]initWithMessage:broadcastMessage];
//    GLKVector3 position = GLKVector3Make(4.3f, 1.2f, 2.1f);
//    PlaceAtBrick *placeAtBrick = [[PlaceAtBrick alloc]initWithPosition:position];
//    
//    Script *startScript = [[Script alloc]init];
//    [startScript addBricks:[NSArray arrayWithObjects: broadcastWaitBrick, placeAtBrick, nil]];
//    
//    Sprite *sprite1 = [[Sprite alloc] initWithEffect:nil];
//    sprite1.broadcastWaitDelegate = handler;
//    [sprite1 addStartScript:startScript];
//    
//    
//    //sprite2
//    int timeToWaitInMilliSecs = 300;
//    WaitBrick *waitBrick = [[WaitBrick alloc]init];
//    waitBrick.timeToWaitInMilliSeconds = [NSNumber numberWithInt:timeToWaitInMilliSecs];
//
//    Script *broadcastScript = [[Script alloc]init];
//    [broadcastScript addBricks:[NSArray arrayWithObject:waitBrick]];
//    
//    Sprite *sprite2 = [[Sprite alloc] initWithEffect:nil];
//    sprite2.broadcastWaitDelegate = handler;
//    [sprite2 addBroadcastScript:broadcastScript forMessage:broadcastMessage];
//    
//    
//    // start
//    [sprite1 start];
//    NSDate *startTime       = [NSDate date];
//    NSDate *expectedEndTime = [startTime dateByAddingTimeInterval:((float)timeToWaitInMilliSecs/1000.0f)];
//    NSDate *realEndTime     = nil;
//    
//    
//    NSTimeInterval timeout = 1.1;   // Number of seconds before giving up
//    NSTimeInterval idle = 0.01;   // Number of seconds to pause within loop
//    BOOL timedOut = NO;
//    BOOL operationCompleted = NO;
//    
//    NSDate *timeoutDate = [[NSDate alloc] initWithTimeIntervalSinceNow:timeout];
//    while (!timedOut && !operationCompleted)
//    {
//        if (GLKVector3AllEqualToVector3(sprite1.position, position)) {
//            realEndTime = [NSDate date];
//            operationCompleted = YES;
//        } else {
//            NSDate *tick = [[NSDate alloc] initWithTimeIntervalSinceNow:idle];
//            [[NSRunLoop currentRunLoop] runUntilDate:tick];
//            timedOut = ([tick compare:timeoutDate] == NSOrderedDescending);
//        }
//    }
//    
//    if (timedOut == YES) {
//        STAssertTrue(NO, @"Timeout!");
//    } else if (realEndTime == nil || expectedEndTime == nil) {
//        STAssertTrue(NO, @"ERROR - this should not happen...");
//    } else if ([realEndTime compare:expectedEndTime] == NSOrderedAscending) {
//        STAssertTrue(NO, @"Sender-sprite didn't wait after broadcast!");
//    } else {
//        STAssertTrue(GLKVector3AllEqualToVector3(sprite1.position, position), @"Next brick after BroadcastWait-brick was not performed");
//    }
//    
//}
//
//
//-(void)test014_glideToBrick
//{
////    EAGLContext *context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
////    STAssertNotNil(context, @"Failed to create ES context");
////    
////    GLKView *view = [[GLKView alloc]init];
////    view.context = context;
////    view.delegate = self;
////    [EAGLContext setCurrentContext:self.context];
////
////    GLKBaseEffect *effect = [[GLKBaseEffect alloc]init];
////    GLKMatrix4 projectionMatrix = GLKMatrix4MakeOrtho(0, 320, 0, 480, -1024, 1024); // TODO: do not use constants
////    effect.transform.projectionMatrix = projectionMatrix;
////
////    Sprite *sprite = [[Sprite alloc] initWithEffect:effect];
////
////    GLKVector3 finalPosition = GLKVector3Make(10.0, 0.0, 0.0);
////    int        duration      = 300;
////    GlideToBrick *brick = [[GlideToBrick alloc]initWithPosition:finalPosition andDurationInMilliSecs:duration];
////    
////    GLKVector3 startPosition = GLKVector3Make(0.0, 0.0, 0.0);
////    PlaceAtBrick *placeAtBrick = [[PlaceAtBrick alloc] initWithPosition:startPosition];    
//// 
////    Script *startScript = [[Script alloc]init];
////    [startScript addBricks:[NSArray arrayWithObjects:placeAtBrick, brick, nil]];
////    [sprite addStartScript:startScript];
////    
////    [sprite start];
////    NSDate *startTime       = [NSDate date];
////    NSDate *expectedEndTime = [startTime dateByAddingTimeInterval:((float)duration/1000.0f)];
////    NSDate *realEndTime     = nil;
////        
////    NSTimeInterval timeout = 5;   // Number of seconds before giving up
////    NSTimeInterval idle = 0.01;   // Number of seconds to pause within loop
////    BOOL timedOut = NO;
////    BOOL operationCompleted = NO;
////    
////    NSDate *timeoutDate = [[NSDate alloc] initWithTimeIntervalSinceNow:timeout];
////    while (!timedOut && !operationCompleted)
////    {
////        NSLog(@">>>>>>>>>>>>>>>>>>>>>> %f", sprite.position.x);
////        STAssertTrue((sprite.position.x >= startPosition.x) &&
////                      sprite.position.x <= finalPosition.x, @"Position is not correct");
////        
////        if (GLKVector3AllEqualToVector3(sprite.position, finalPosition)) {
////            realEndTime = [NSDate date];
////            operationCompleted = YES;
////        } else {
////            NSDate *tick = [[NSDate alloc] initWithTimeIntervalSinceNow:idle];
////            [[NSRunLoop currentRunLoop] runUntilDate:tick];
////            timedOut = ([tick compare:timeoutDate] == NSOrderedDescending);
////        }
////    }
////    
////    if (timedOut == YES) {
////        STAssertTrue(NO, @"Timeout!");
////    } else if (realEndTime == nil || expectedEndTime == nil) {
////        STAssertTrue(NO, @"ERROR - this should not happen...");
////    } else if ([realEndTime compare:expectedEndTime] == NSOrderedAscending) {
////        STAssertTrue(NO, @"Animation was too fast");
////    } else {
////        STAssertTrue(GLKVector3AllEqualToVector3(sprite.position, finalPosition), @"Endposition is not correct");
////    }
//
//}
//
//
//-(void)test015_changeSizeByN
//{
//    Sprite *sprite = [[Sprite alloc]initWithEffect:nil];
//    
//    float size = 0.5f;
//    
//    ChangeSizeByNBrick *brick = [[ChangeSizeByNBrick alloc]initWithSizeChangeRate:size];
//    
//    STAssertTrue(sprite.scaleWidth  == 1.0f, @"Wrong inital value for scale-width");
//    STAssertTrue(sprite.scaleHeight == 1.0f, @"Wrong inital value for scale-height");
//
//    [brick performOnSprite:sprite fromScript:nil];
//    
//    STAssertTrue(sprite.scaleWidth  == 1.0f + size/100.0f, @"Wrong value for scale-width");
//    STAssertTrue(sprite.scaleHeight == 1.0f + size/100.0f, @"Wrong value for scale-height");
//}
//
//
//
//////////////////////////////////////////////////////////////////////////////////
//
//
//#pragma mark - Delegates
//-(void)addSound:(AVAudioPlayer*)sound forSprite:(Sprite*)sprite
//{
//    
//    STAssertNotNil(sound, @"Sound should not be nil");
//    
//    NSString* locale = [[NSLocale preferredLanguages] objectAtIndex:0];
//    
//    NSString* fileName;
//    
//    if([locale isEqualToString:@"en"])
//    {
//        fileName = @"1ebbaf4b682faba548ac1bb2d69ab0281d556853.mp3";
//    }
//    
//    if([locale isEqualToString:@"de"])
//    {
//        fileName = @"1834508dbef875bfaf1d8543eba8fc6c1d1bd300.mp3";
//    }
//    
//    NSBundle *thisBundle = [NSBundle bundleForClass:[self class]];
//
//    NSString* soundPath = [[NSString alloc] initWithFormat:@"%@/sounds/%@", [thisBundle bundlePath], fileName];
//    AVAudioPlayer* test = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:soundPath] error:NULL];
//    
//    STAssertTrue(test.duration == sound.duration, @"Files do not have the same length!");
//        
//    [sound play]; // You will not hear anything because of scope!
//    
//    STAssertTrue(sound.playing, @"Sound not playing!");
//}
//
//
//-(void)bringToFrontSprite:(Sprite*)sprite
//{}
//
//-(void)bringNStepsBackSprite:(Sprite*)sprite numberOfSteps:(int)n
//{}
//
//-(void)stopAllSounds
//{
//    self.stop = YES;
//}
//
//-(void)setVolumeTo:(float)volume forSprite:(Sprite*)sprite
//{}
//
//-(void)changeVolumeBy:(float)percent forSprite:(Sprite*)sprite
//{}
//
//

//
//-(void)test015_changeGhostEffect
//{
//    float increase = 0.1f;
//    Sprite *sprite = [[Sprite alloc]initWithEffect:nil];
//    ChangeGhostEffectBrick* changeGhostEffectBrick = [[ChangeGhostEffectBrick alloc] initWithIncrease:increase];
//    [changeGhostEffectBrick performOnSprite:sprite fromScript:nil];
//    STAssertTrue(0.9f== sprite.alphaValue, @"Alpha Value not the same");
//}
//
//-(void)test016_setGhostEffect
//{
//    float transparency = 200.0f;
//    SetGhostEffectBrick* ghostEffectBrick = [[SetGhostEffectBrick alloc] initWithTransparencyInPercent:transparency];
//    Sprite *sprite = [[Sprite alloc]initWithEffect:nil];
//    
//    [ghostEffectBrick performOnSprite:sprite fromScript:nil];
//    
//    STAssertTrue(sprite.alphaValue == 0.0f, @"Alpha Value not correct");
//}
//
//-(void)test017_changeGhostEffect
//{
//    float transparency = 100.0f;
//    SetGhostEffectBrick* ghostEffectBrick = [[SetGhostEffectBrick alloc] initWithTransparencyInPercent:transparency];
//    Sprite *sprite = [[Sprite alloc]initWithEffect:nil];
//    
//    [ghostEffectBrick performOnSprite:sprite fromScript:nil];
//    
//    STAssertTrue(sprite.alphaValue == 0.0f, @"Alpha Value not correct");
//    
//    ChangeGhostEffectBrick* changeGhostEffectBrick = [[ChangeGhostEffectBrick alloc] initWithIncrease:-0.1f];
//    [changeGhostEffectBrick performOnSprite:sprite fromScript:nil];
//    
//    
//    STAssertTrue(sprite.alphaValue == 0.1f, @"Alpha Value not correct");
//}
//
//
//-(void)test015_changeSizeByN
//{
//    Sprite *sprite = [[Sprite alloc]initWithEffect:nil];
//    
//    float size = 0.5f;
//    
//    ChangeSizeByNBrick *brick = [[ChangeSizeByNBrick alloc]initWithSizeChangeRate:size];
//    
//    STAssertTrue(sprite.scaleWidth  == 1.0f, @"Wrong inital value for scale-width");
//    STAssertTrue(sprite.scaleHeight == 1.0f, @"Wrong inital value for scale-height");
//
//    [brick performOnSprite:sprite fromScript:nil];
//    
//    STAssertTrue(sprite.scaleWidth  == 1.0f + size/100.0f, @"Wrong value for scale-width");
//    STAssertTrue(sprite.scaleHeight == 1.0f + size/100.0f, @"Wrong value for scale-height");
//}
//


////////////////////////////////////////////////////////////////////////////////


#pragma mark - Delegates
-(void)addSound:(AVAudioPlayer*)sound forSprite:(Sprite*)sprite
{
    
    STAssertNotNil(sound, @"Sound should not be nil");
    
    NSString* locale = [[NSLocale preferredLanguages] objectAtIndex:0];
    
    NSString* fileName;
    
    if([locale isEqualToString:@"en"])
    {
        fileName = @"1ebbaf4b682faba548ac1bb2d69ab0281d556853.mp3";
    }
    
    if([locale isEqualToString:@"de"])
    {
        fileName = @"1834508dbef875bfaf1d8543eba8fc6c1d1bd300.mp3";
    }
    
    NSBundle *thisBundle = [NSBundle bundleForClass:[self class]];

    NSString* soundPath = [[NSString alloc] initWithFormat:@"%@/sounds/%@", [thisBundle bundlePath], fileName];
    AVAudioPlayer* test = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:soundPath] error:NULL];
    
    STAssertTrue(test.duration == sound.duration, @"Files do not have the same length!");
        
    [sound play]; // You will not hear anything because of scope!
    
    STAssertTrue(sound.playing, @"Sound not playing!");
}


-(void)bringToFrontSprite:(Sprite*)sprite
{}

-(void)bringNStepsBackSprite:(Sprite*)sprite numberOfSteps:(int)n
{}

-(void)stopAllSounds
{
    self.stop = YES;
}

-(void)setVolumeTo:(float)volume forSprite:(Sprite*)sprite
{}

-(void)changeVolumeBy:(float)percent forSprite:(Sprite*)sprite
{}




//"SetCostumeBrick.h"
//"StartScript.h"
//"WhenScript.h"
//"Sound.h"
//"NextCostumeBrick.h"
//"ChangeSizeByNBrick.h"
//"PlaySoundBrick.h"
//"StopAllSoundsBrick.h"
//"ComeToFrontBrick.h"
//"SetSizeToBrick.h"
//"LoopBrick.h"
//"RepeatBrick.h"
//"EndLoopBrick.h"
//"GoNStepsBackBrick.h"

//"SetGhostEffectBrick.h"
//"SetVolumeToBrick.h"
//"ChangeVolumeByBrick.h"
//"ChangeGhostEffectBrick.h"


@end
