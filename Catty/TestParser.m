//
//  TestParser.m
//  Catty
//
//  Created by Christof Stromberger on 27.04.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "TestParser.h"
#import "Level.h"
#import "Sprite.h"
#import "Costume.h"
#import "Script.h"
#import "Brick.h"
#import "StartScript.h"
#import "SetCostumeBrick.h"
#import "WhenScript.h"
#import "PlaceAtBrick.h"
#import "GlideToBrick.h"
#import "WaitBrick.h"
#import "NextCostumeBrick.h"
#import "HideBrick.h"
#import "ShowBrick.h"
#import "SetXBrick.h"
#import "SetYBrick.h"
#import "BroadcastBrick.h"
#import "ComeToFrontBrick.h"
#import "ChangeSizeByNBrick.h"
#import "LoopBrick.h"
#import "RepeatBrick.h"
#import "EndLoopBrick.h"

@interface TestParser ()

- (Costume*)createCostumeFromPath:(NSString*)path withName:(NSString*)name;
- (Level*)createDefaultLevel;
- (Sprite*)createSprite:(NSString*)name withPositionX:(NSInteger)x withPositionY:(NSInteger)y withCostumes:(NSArray*)costumesArray setCostumeIndex:(NSInteger)index;


@end

@implementation TestParser

@synthesize effect = _effect;
@synthesize zIndex = _zIndex;


- (Level*)generateObjectForLevel:(NSString*)path
{
    self.zIndex = 0;
    /// TODO: call xml-parser instead of following lines... I know, wrong place...doesn't matter...
    
    NSMutableArray *startScriptsMutable = [[NSMutableArray alloc] init];
    NSMutableArray *whenScriptsMutable = [[NSMutableArray alloc] init];
        
    //creating new level (with some default values, such as name and version)
    Level *level = [self createDefaultLevel];
    
    //creating background costume
    Costume *costume1 = [self createCostumeFromPath:@"background.png" withName:@"Background"];
    
    //creating background sprite
    Sprite *sprite1 = [self createSprite:@"Background" 
                           withPositionX:0
                           withPositionY:0
                            withCostumes:[[NSArray alloc] initWithObjects:costume1, nil] 
                         setCostumeIndex:0];
    
    //creating background script
    Script *newScript = [[StartScript alloc]init];
    
    //setcostume brick for background at startup
    SetCostumeBrick *newBrick = [[SetCostumeBrick alloc]init];
    newBrick.indexOfCostumeInArray = 0;
//    newBrick.sprite = sprite1;
//    newScript.bricksArray = [[NSArray alloc]initWithObjects:newBrick, nil];
    [newScript addBrick:newBrick];
    
    //check if its a startup script or a when script
    if ([newScript isMemberOfClass:[StartScript class]])
//        [sprite1.startScriptsArray addObject:newScript];
        [sprite1 addStartScript:newScript];
        //[startScriptsMutable addObject:newScript];
    else if ([newScript isMemberOfClass:[WhenScript class]])
//        [sprite1.whenScriptsArray addObject:newScript];
        [sprite1 addWhenScript:newScript];
        //[whenScriptsMutable addObject:newScript];
    
    
    //creating cat costumes (normal and ceshire cat)
    Costume *costume2 = [self createCostumeFromPath:@"normalcat.png" withName:@"Normal cat"];
    Costume *costume3 = [self createCostumeFromPath:@"ceshirecat.png" withName:@"Ceshire cat"];
    
    //creating cat sprite
    Sprite *sprite2 = [self createSprite:@"Catroid" withPositionX:100 withPositionY:100 
                            withCostumes:[[NSArray alloc]initWithObjects:costume2, costume3, nil] setCostumeIndex:0];
    
    //creating cat script
    Script *newStartScript = [[StartScript alloc]init];
    
    //creating cat brick
    newBrick = [[SetCostumeBrick alloc]init];
    newBrick.indexOfCostumeInArray = 0;
//    newBrick.sprite = sprite2;
//    newStartScript.bricksArray = [[NSMutableArray alloc]initWithObjects:newBrick, nil];
    [newStartScript addBrick:newBrick];
    
    //creating new when script for cat (change costume on click and change position)
    WhenScript *newWhenScript = [[WhenScript alloc]init];
    newWhenScript.action = 0;
    newBrick = [[SetCostumeBrick alloc]init];
    newBrick.indexOfCostumeInArray = [NSNumber numberWithInt:1];
//    newBrick.sprite = sprite2;
    Brick *placeAtBrick = [[PlaceAtBrick alloc]initWithPosition:GLKVector3Make(50, 50, self.zIndex)];
//    placeAtBrick.sprite = sprite2;
    Brick *glideToBrick = [[GlideToBrick alloc]initWithPosition:GLKVector3Make(100, 100, self.zIndex) andDurationInMilliSecs:1000];
//    glideToBrick.sprite = sprite2;
    NSMutableArray *tmpMutableArray = [[NSMutableArray alloc]init];
    [tmpMutableArray addObject:newBrick];
    [tmpMutableArray addObject:placeAtBrick];
    [tmpMutableArray addObject:glideToBrick];
//    newWhenScript.bricksArray = [NSArray arrayWithArray:tmpMutableArray];    
    [newWhenScript addBricks:[NSArray arrayWithArray:tmpMutableArray]];
    
    
    //adding scripts to script arrays
    //[startScriptsMutable addObject:newStartScript];
    //[whenScriptsMutable addObject:newWhenScript];

//    [sprite2.startScriptsArray addObject:newStartScript];
//    [sprite2.whenScriptsArray addObject:newWhenScript];
    [sprite2 addStartScript:newStartScript];
    [sprite2 addWhenScript:newWhenScript];
    
    //adding sprites to level
    level.spritesArray = [[NSMutableArray alloc] initWithObjects: sprite1, sprite2, nil];

    //assuming start and when scripts
//    level.startScriptsArray = [[NSArray alloc] initWithArray:startScriptsMutable];
//    level.whenScriptsArray = [[NSArray alloc] initWithArray:whenScriptsMutable];
    
    return level;
}

#pragma mark - private methods
- (Costume*)createCostumeFromPath:(NSString*)path withName:(NSString*)name
{
    Costume *retCostume = [[Costume alloc] initWithName:name andPath:path];
    
    return retCostume;
}

- (Level*)createDefaultLevel
{
    Level *level = [[Level alloc]init];
    level.name = @"Catty1";
    //level.version = 1.1;
    level.resolution = CGSizeZero;
    
    return level;
}

- (Sprite*)createSprite:(NSString*)name 
          withPositionX:(NSInteger)x 
          withPositionY:(NSInteger)y 
           withCostumes:(NSArray*)costumesArray 
        setCostumeIndex:(NSInteger)index;

{
    Sprite *ret = [[Sprite alloc] initWithEffect:self.effect];
    ret.name = name;
    [ret placeAt:GLKVector3Make(x, y, self.zIndex++)];
    [ret addCostumes:costumesArray];
    [ret changeCostume:[NSNumber numberWithInt:index]];
    
    return ret;
}



// just4debugging
-(Level*)generateDebugLevel_GlideTo
{
    Level *level = [[Level alloc]init];
    level.name = @"debug";
    level.resolution = CGSizeMake(320, 480);
    
    
    Costume *costume = [self createCostumeFromPath:@"normalcat.png" withName:@"cat1"];
    
    SetCostumeBrick *setCostumeBrick = [[SetCostumeBrick alloc]init];
    setCostumeBrick.indexOfCostumeInArray = 0;
    GlideToBrick *glideBrick1 = [[GlideToBrick alloc]initWithPosition:GLKVector3Make(100, 100, 0) andDurationInMilliSecs:1000];
    GlideToBrick *glideBrick2 = [[GlideToBrick alloc]initWithPosition:GLKVector3Make(100, -50, 0) andDurationInMilliSecs:500];
    WaitBrick *waitBrick = [[WaitBrick alloc]init];
    waitBrick.timeToWaitInMilliseconds = [NSNumber numberWithInt:1000];
    PlaceAtBrick *placeAtBrick = [[PlaceAtBrick alloc]initWithPosition:GLKVector3Make(0, 0, 0)];
    
    Script *startScript = [[Script alloc]init];
    [startScript addBrick:setCostumeBrick];
    
    WhenScript *whenScript = [[WhenScript alloc]init];
    [whenScript addBricks:[NSMutableArray arrayWithObjects:glideBrick1, glideBrick2, waitBrick, placeAtBrick, nil]];

    
    NSArray *costumes = [NSArray arrayWithObject:costume];
    
    Sprite *sprite = [self createSprite:@"cat" withPositionX:(NSInteger)0 withPositionY:(NSInteger)0 withCostumes:costumes setCostumeIndex:(NSInteger)0];
    [sprite addWhenScript:whenScript];
    [sprite addStartScript:startScript];
    
    level.spritesArray = [NSMutableArray arrayWithObject:sprite];
    
    return level;
}

-(Level*)generateDebugLevel_nextCostume
{
    Level *level = [[Level alloc]init];
    level.name = @"nextCostumeTest";
    level.resolution = CGSizeMake(320, 480);
    
    
    Costume *costume1 = [self createCostumeFromPath:@"normalcat.png" withName:@"cat1"];
    Costume *costume2 = [self createCostumeFromPath:@"cheshirecat.png" withName:@"cat2"];

    NextCostumeBrick *nextCostumeBrick1 = [[NextCostumeBrick alloc]init];
    NextCostumeBrick *nextCostumeBrick2 = [[NextCostumeBrick alloc]init];

    WaitBrick *waitBrick = [[WaitBrick alloc]init];
    waitBrick.timeToWaitInMilliseconds = [NSNumber numberWithInt:1000];
    
    
    WhenScript *whenScript = [[WhenScript alloc]init];
    [whenScript addBricks:[NSMutableArray arrayWithObjects:nextCostumeBrick1, waitBrick, nextCostumeBrick2, nil]];
    
    
    NSArray *costumes = [NSArray arrayWithObjects:costume1, costume2, nil];
    
    Sprite *sprite = [self createSprite:@"cat" withPositionX:(NSInteger)0 withPositionY:(NSInteger)0 withCostumes:costumes setCostumeIndex:(NSInteger)0];
    [sprite addWhenScript:whenScript];
    
    level.spritesArray = [NSMutableArray arrayWithObject:sprite];
    
    return level;

}

-(Level*)generateDebugLevel_HideShow
{
    Level *level = [[Level alloc]init];
    level.name = @"nextCostumeTest";
    level.resolution = CGSizeMake(320, 480);
    
    HideBrick *hideBrick = [[HideBrick alloc]init];
    ShowBrick *showBrick = [[ShowBrick alloc]init];
    
    Costume *costume = [self createCostumeFromPath:@"normalcat.png" withName:@"cat1"];
    
    WaitBrick *waitBrick = [[WaitBrick alloc]init];
    waitBrick.timeToWaitInMilliseconds = [NSNumber numberWithInt:1000];
    
    
    WhenScript *whenScript = [[WhenScript alloc]init];
    [whenScript addBricks:[NSMutableArray arrayWithObjects: hideBrick, waitBrick, showBrick, nil]];
    
    
    NSArray *costumes = [NSArray arrayWithObjects:costume, nil];
    
    Sprite *sprite = [self createSprite:@"cat" withPositionX:(NSInteger)0 withPositionY:(NSInteger)0 withCostumes:costumes setCostumeIndex:(NSInteger)0];
    [sprite addWhenScript:whenScript];
    
    level.spritesArray = [NSMutableArray arrayWithObject:sprite];
    
    return level;
    
}

-(Level *)generateDebugLevel_SetXY
{
    Level *level = [[Level alloc]init];
    level.name = @"setX setY";
    level.resolution = CGSizeMake(320, 480);
    
        
    Costume *costume = [self createCostumeFromPath:@"normalcat.png" withName:@"cat1"];
    
    SetXBrick *setXBrick1 = [[SetXBrick alloc]initWithXPosition:-50];
    SetYBrick *setYBrick1 = [[SetYBrick alloc]initWithYPosition:-100];
    
    SetXBrick *setXBrick2 = [[SetXBrick alloc]initWithXPosition:0];
    SetYBrick *setYBrick2 = [[SetYBrick alloc]initWithYPosition:0];
    
    WaitBrick *waitBrick = [[WaitBrick alloc]init];
    waitBrick.timeToWaitInMilliseconds = [NSNumber numberWithInt:1000];
    
    
    WhenScript *whenScript = [[WhenScript alloc]init];
    [whenScript addBricks:[NSMutableArray arrayWithObjects: setXBrick1, waitBrick, setYBrick1, waitBrick, setXBrick2, setYBrick2, nil]];
    
    
    NSArray *costumes = [NSArray arrayWithObjects:costume, nil];
    
    Sprite *sprite = [self createSprite:@"cat" withPositionX:(NSInteger)0 withPositionY:(NSInteger)0 withCostumes:costumes setCostumeIndex:(NSInteger)0];
    [sprite addWhenScript:whenScript];
    
    level.spritesArray = [NSMutableArray arrayWithObject:sprite];
    
    return level;

}

-(Level *)generateDebugLevel_broadcast
{
    Level *level = [[Level alloc]init];
    level.name = @"broadcast";
    level.resolution = CGSizeMake(320, 480);
    
    NSString *broadcastMessage = @"BROADCAST";
    
    //sprite1
    
    Costume *costume = [self createCostumeFromPath:@"normalcat.png" withName:@"cat1"];
    
    BroadcastBrick *broadcastBrick = [[BroadcastBrick alloc]initWithMessage:broadcastMessage];
    
    WhenScript *whenScript = [[WhenScript alloc]init];
    [whenScript addBricks:[NSMutableArray arrayWithObjects: broadcastBrick, nil]];
    
    NSArray *costumes = [NSArray arrayWithObjects:costume, nil];
    
    Sprite *sprite1 = [self createSprite:@"cat1" withPositionX:(NSInteger)-70 withPositionY:(NSInteger)0 withCostumes:costumes setCostumeIndex:(NSInteger)0];
    [sprite1 addWhenScript:whenScript];
    
    
    //sprite2
    
    HideBrick *hideBrick1 = [[HideBrick alloc]init];
    WaitBrick *waitBrick1 = [[WaitBrick alloc]init];
    waitBrick1.timeToWaitInMilliseconds = [NSNumber numberWithInt:500];
    ShowBrick *showBrick1 = [[ShowBrick alloc]init];
    
    Script *broadcastScript1 = [[Script alloc]init];
    [broadcastScript1 addBricks:[NSArray arrayWithObjects:hideBrick1, waitBrick1, showBrick1, nil]];
    
    Sprite *sprite2 = [self createSprite:@"cat2" withPositionX:(NSInteger)70 withPositionY:(NSInteger)-100 withCostumes:costumes setCostumeIndex:(NSInteger)0];
    [sprite2 addBroadcastScript:broadcastScript1 forMessage:broadcastMessage];
    
    
    //sprite3
    HideBrick *hideBrick2 = [[HideBrick alloc]init];
    WaitBrick *waitBrick2 = [[WaitBrick alloc]init];
    waitBrick2.timeToWaitInMilliseconds = [NSNumber numberWithInt:500];
    ShowBrick *showBrick2 = [[ShowBrick alloc]init];

    Script *broadcastScript2 = [[Script alloc]init];
    [broadcastScript2 addBricks:[NSArray arrayWithObjects:hideBrick2, waitBrick2, showBrick2, nil]];
    
    Sprite *sprite3 = [self createSprite:@"cat3" withPositionX:(NSInteger)70 withPositionY:(NSInteger)100 withCostumes:costumes setCostumeIndex:(NSInteger)0];
    [sprite3 addBroadcastScript:broadcastScript2 forMessage:broadcastMessage];


    ///
    
    level.spritesArray = [NSMutableArray arrayWithObjects:sprite1, sprite2, sprite3, nil];
    
    return level;
    
}

-(Level *)generateDebugLevel_comeToFront
{
    Level *level = [[Level alloc]init];
    level.name = @"broadcast";
    level.resolution = CGSizeMake(320, 480);
        
    //sprite1
    Costume *costume = [self createCostumeFromPath:@"normalcat.png" withName:@"cat1"];
    ComeToFrontBrick *comeToFrontBrick = [[ComeToFrontBrick alloc]init];
    
    WhenScript *whenScript = [[WhenScript alloc]init];
    [whenScript addBricks:[NSMutableArray arrayWithObjects: comeToFrontBrick, nil]];
    
    NSArray *costumes = [NSArray arrayWithObjects:costume, nil];
    
    Sprite *sprite1 = [self createSprite:@"cat1" withPositionX:(NSInteger)0 withPositionY:(NSInteger)0 withCostumes:costumes setCostumeIndex:(NSInteger)0];
    [sprite1 addWhenScript:whenScript];
    
    //sprite2
    Sprite *sprite2 = [self createSprite:@"cat2" withPositionX:(NSInteger)50 withPositionY:(NSInteger)50 withCostumes:costumes setCostumeIndex:(NSInteger)0];
    [sprite2 addWhenScript:whenScript];
    
    //sprite3
    Sprite *sprite3 = [self createSprite:@"cat3" withPositionX:(NSInteger)-50 withPositionY:(NSInteger)-50 withCostumes:costumes setCostumeIndex:(NSInteger)0];
    [sprite3 addWhenScript:whenScript];
        
    
    ///
    
    level.spritesArray = [NSMutableArray arrayWithObjects:sprite3, sprite2, sprite1, nil];
    
    return level;
}

-(Level*)generateDebugLevel_changeSizeByN
{
    Level *level = [[Level alloc]init];
    level.name = @"changeSizeByN";
    level.resolution = CGSizeMake(320, 480);
    
    Costume *costume = [self createCostumeFromPath:@"normalcat.png" withName:@"cat1"];
    
    ChangeSizeByNBrick *changeSizeByNBrick1 = [[ChangeSizeByNBrick alloc]initWithSizeChangeRate:50];
    ChangeSizeByNBrick *changeSizeByNBrick2 = [[ChangeSizeByNBrick alloc]initWithSizeChangeRate:-100];
    ChangeSizeByNBrick *changeSizeByNBrick3 = [[ChangeSizeByNBrick alloc]initWithSizeChangeRate:50];
    
    WaitBrick *waitBrick = [[WaitBrick alloc]init];
    waitBrick.timeToWaitInMilliseconds = [NSNumber numberWithInt:500];
    
    WhenScript *whenScript = [[WhenScript alloc]init];
    [whenScript addBricks:[NSMutableArray arrayWithObjects: changeSizeByNBrick1, waitBrick, changeSizeByNBrick2, waitBrick, changeSizeByNBrick3, nil]];
    
    
    NSArray *costumes = [NSArray arrayWithObjects:costume, nil];
    
    Sprite *sprite = [self createSprite:@"cat" withPositionX:(NSInteger)0 withPositionY:(NSInteger)0 withCostumes:costumes setCostumeIndex:(NSInteger)0];
    [sprite addWhenScript:whenScript];
    
    level.spritesArray = [NSMutableArray arrayWithObject:sprite];
    
    return level;
    
}

-(Level *)generateDebugLevel_parallelScripts
{
    Level *level = [[Level alloc]init];
    level.name = @"parallelScripts";
    level.resolution = CGSizeMake(320, 480);
    
    Costume *costume = [self createCostumeFromPath:@"normalcat.png" withName:@"cat1"];
    
    Script *startScript = [[Script alloc]init];
    PlaceAtBrick *placeAtBrick = [[PlaceAtBrick alloc]initWithPosition:GLKVector3Make(-100, 100, 0)];
    GlideToBrick *glideToBrick = [[GlideToBrick alloc]initWithPosition:GLKVector3Make(100, 100, 0) andDurationInMilliSecs:5000];
    [startScript addBrick:placeAtBrick];
    [startScript addBrick:glideToBrick];
    
    
    WhenScript *whenScript = [[WhenScript alloc]init];
    GlideToBrick *glideToBrick2 = [[GlideToBrick alloc]initWithPosition:GLKVector3Make(-100, -100, 0) andDurationInMilliSecs:5000];
    [whenScript addBrick:glideToBrick2];
    
    NSArray *costumes = [NSArray arrayWithObjects:costume, nil];
    
    Sprite *sprite = [self createSprite:@"cat" withPositionX:(NSInteger)0 withPositionY:(NSInteger)0 withCostumes:costumes setCostumeIndex:(NSInteger)0];
    [sprite addWhenScript:whenScript];
    [sprite addStartScript:startScript];
    
    level.spritesArray = [NSMutableArray arrayWithObject:sprite];
    
    return level;
}

-(Level *)generateDebugLevel_loops
{
    Level *level = [[Level alloc]init];
    level.name = @"loops";
    level.resolution = CGSizeMake(320, 480);
    
    Costume *costume1 = [self createCostumeFromPath:@"normalcat.png" withName:@"cat1"];
    Costume *costume2 = [self createCostumeFromPath:@"cheshirecat.png" withName:@"cat2"];
    
    Script *startScript = [[Script alloc]init];
    RepeatBrick *loopStart = [[RepeatBrick alloc]initWithNumberOfLoops:5];
    NextCostumeBrick *nextCostumeBrick = [[NextCostumeBrick alloc]init];
    WaitBrick *waitBrick = [[WaitBrick alloc]init];
    waitBrick.timeToWaitInMilliseconds = [NSNumber numberWithInt:500];
    EndLoopBrick *loopEnd = [[EndLoopBrick alloc]init];
    [startScript addBrick:loopStart];
    [startScript addBrick:nextCostumeBrick];
    [startScript addBrick:waitBrick];
    [startScript addBrick:loopEnd];
    
    
    
    WhenScript *whenScript = [[WhenScript alloc]init];
    GlideToBrick *glideToBrick2 = [[GlideToBrick alloc]initWithPosition:GLKVector3Make(-100, -100, 0) andDurationInMilliSecs:5000];
    [whenScript addBrick:glideToBrick2];
    
    NSArray *costumes = [NSArray arrayWithObjects:costume1, costume2, nil];
    
    Sprite *sprite = [self createSprite:@"cat" withPositionX:(NSInteger)0 withPositionY:(NSInteger)0 withCostumes:costumes setCostumeIndex:(NSInteger)0];
    [sprite addWhenScript:whenScript];
    [sprite addStartScript:startScript];
    
    level.spritesArray = [NSMutableArray arrayWithObject:sprite];
    
    return level;
}

@end
