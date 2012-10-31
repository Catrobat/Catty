//
//  DataModelBricksTest.m
//  Catty
//
//  Created by Dominik Ziegler on 9/27/12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "DataModelBricksTest.h"
#import "Sprite.h"
#import "Costume.h"
#import "Script.h"
#import "Brick.h"
#import "SetCostumeBrick.h"
#import "WaitBrick.h"
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


@interface DataModelBricksTest()

@property (nonatomic, assign) BOOL stop;

@end


@implementation DataModelBricksTest


#pragma mark - test cases
//just a basic test
//- (void)test001_setCostume
//{
//    SetCostumeBrick *brick = [[SetCostumeBrick alloc]init];
//    brick.indexOfCostumeInArray = 0;
//    
//    Sprite *sprite = [[Sprite alloc]init];
//    Costume *costume1 = [Costume alloc]initWithName:@"costume1" andPath:<#(NSString *)#>
//    
//}

-(void)test002_Wait
{
    int timeToWaitInMilliSecs = 300;
    WaitBrick *brick = [[WaitBrick alloc]init];
    
    Script *script = [[Script alloc]init];
    
    brick.timeToWaitInMilliseconds = [NSNumber numberWithInt:timeToWaitInMilliSecs];
    NSTimeInterval before = [[NSDate date]timeIntervalSince1970];
    [brick performOnSprite:nil fromScript:script];
    NSTimeInterval after = [[NSDate date]timeIntervalSince1970];
    NSLog(@"Needed Time: %f", after-before);
    STAssertFalse((after-before) < timeToWaitInMilliSecs/1000.0f,         @"Wait-time was too short");
    STAssertFalse((after-before) > timeToWaitInMilliSecs/1000.0f + 0.05f, @"Wait-time was too long - note: tolerance-value big enough?!");// NOTE: tolerance-value?!
}

-(void)test003_HideAndShow
{
    HideBrick *hideBrick = [[HideBrick alloc]init];
    ShowBrick *showBrick = [[ShowBrick alloc]init];
    Sprite *sprite = [[Sprite alloc]initWithEffect:nil];
    
    [hideBrick performOnSprite:sprite fromScript:nil];
    STAssertFalse(sprite.showSprite, @"Sprite is visible - that's bad!");
    [showBrick performOnSprite:sprite fromScript:nil];
    STAssertTrue(sprite.showSprite, @"Sprite is invisible - that's bad!");
}

-(void)test004_PlaceAt
{
    GLKVector3 position = GLKVector3Make(1.2f, 2.3f, 3.4f);

    PlaceAtBrick *brick = [[PlaceAtBrick alloc]initWithPosition:position];
    Sprite *sprite = [[Sprite alloc]initWithEffect:nil];

    [brick performOnSprite:sprite fromScript:nil];
    STAssertTrue(GLKVector3AllEqualToVector3(sprite.position, position), @"Position of sprite is wrong!");
}

-(void)test005_SetXY
{
    float xPosition = 123.4f;
    float yPosition = -45.7f;
    SetXBrick *xBrick = [[SetXBrick alloc]initWithXPosition:xPosition];
    SetYBrick *yBrick = [[SetYBrick alloc]initWithYPosition:yPosition];

    Sprite *sprite = [[Sprite alloc]initWithEffect:nil];
    
    GLKVector3 oldPosition = sprite.position;
    
    [xBrick performOnSprite:sprite fromScript:nil];
    STAssertTrue(GLKVector3AllEqualToVector3(sprite.position, GLKVector3Make(oldPosition.x+xPosition, oldPosition.y, oldPosition.z)), @"x-position of sprite is wrong!");
    
    oldPosition = sprite.position;
    [yBrick performOnSprite:sprite fromScript:nil];
    STAssertTrue(GLKVector3AllEqualToVector3(sprite.position, GLKVector3Make(oldPosition.x, oldPosition.y+yPosition, oldPosition.z)), @"y-position of sprite is wrong!");
}

-(void)test006_changeXYBy
{
    int xPosition = -5;
    int yPosition = 10;
    ChangeXByBrick *xBrick = [[ChangeXByBrick alloc]initWithChangeValueForX:xPosition];
    ChangeYByBrick *yBrick = [[ChangeYByBrick alloc]initWithChangeValueForY:yPosition];
    
    Sprite *sprite = [[Sprite alloc]initWithEffect:nil];
    
    GLKVector3 oldPosition = sprite.position;
    
    [xBrick performOnSprite:sprite fromScript:nil];
    STAssertTrue(GLKVector3AllEqualToVector3(sprite.position, GLKVector3Make(oldPosition.x+xPosition, oldPosition.y, oldPosition.z)), @"x-position of sprite is wrong!");
    
    oldPosition = sprite.position;
    [yBrick performOnSprite:sprite fromScript:nil];
    STAssertTrue(GLKVector3AllEqualToVector3(sprite.position, GLKVector3Make(oldPosition.x, oldPosition.y+yPosition, oldPosition.z)), @"y-position of sprite is wrong!");
}

-(void)test007_speak
{
    SpeakBrick* speakBrick = [[SpeakBrick alloc] initWithText:@"This is a test!"];
    Sprite *sprite = [[Sprite alloc]initWithEffect:nil];
    
    sprite.spriteManagerDelegate = self;
    
    [speakBrick performOnSprite:sprite fromScript:nil];
}

-(void)test008_playSound
{
    
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
    
    PlaySoundBrick* playSoundBrick = [[PlaySoundBrick alloc] initWithFileName:fileName];
    
    Sprite *sprite = [[Sprite alloc]initWithEffect:nil];
    sprite.spriteManagerDelegate = self;
    NSBundle *thisBundle = [NSBundle bundleForClass:[self class]];
    sprite.projectPath = [[NSString alloc] initWithFormat:@"%@/", [thisBundle bundlePath]];
        
    [playSoundBrick performOnSprite:sprite fromScript:nil];
}

-(void)test009_stopAllSounds
{
    StopAllSoundsBrick* stopSoundBrick = [[StopAllSoundsBrick alloc] init];    
    Sprite *sprite = [[Sprite alloc]initWithEffect:nil];
    sprite.spriteManagerDelegate = self;
    
    self.stop = NO;
    [stopSoundBrick performOnSprite:sprite fromScript:nil];
    
    STAssertTrue(self.stop, @"Stop Delegate Method was not called!");
    self.stop = NO;
}

-(void)test010_setGhostEffect
{
    float transparency = 40.0f;
    SetGhostEffectBrick* ghostEffectBrick = [[SetGhostEffectBrick alloc] initWithTransparencyInPercent:transparency];
    Sprite *sprite = [[Sprite alloc]initWithEffect:nil];
    
    [ghostEffectBrick performOnSprite:sprite fromScript:nil];
    
    STAssertTrue(sprite.alphaValue != transparency/100.0f, @"Alpha Value not correct");
}

-(void)test011_changeGhostEffect
{
    float increase = 0.10f;
    Sprite *sprite = [[Sprite alloc]initWithEffect:nil];
    float alpha = [sprite alphaValue];
    ChangeGhostEffectBrick* changeGhostEffectBrick = [[ChangeGhostEffectBrick alloc] initWithIncrease:increase];
    [changeGhostEffectBrick performOnSprite:sprite fromScript:nil];
    
    STAssertTrue((alpha-(increase/100.0f)) == [sprite alphaValue], @"Alpha Value not the same");
}




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
//"GlideToBrick.h"
//"NextCostumeBrick.h"
//"ChangeSizeByNBrick.h"
//"BroadcastBrick.h"
//"BroadcastWaitBrick.h"
//"ChangeXByBrick.h"
//"ChangeYByBrick.h"
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
