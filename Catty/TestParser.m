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
    newScript.bricksArray = [[NSArray alloc]initWithObjects:newBrick, nil];
    
    //check if its a startup script or a when script
    if ([newScript isMemberOfClass:[StartScript class]])
        [sprite1.startScriptsArray addObject:newScript];
        //[startScriptsMutable addObject:newScript];
    else if ([newScript isMemberOfClass:[WhenScript class]])
        [sprite1.whenScriptsArray addObject:newScript];
                
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
    newStartScript.bricksArray = [[NSMutableArray alloc]initWithObjects:newBrick, nil];
    
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
    newWhenScript.bricksArray = [NSArray arrayWithArray:tmpMutableArray];    

    
    
    //adding scripts to script arrays
    //[startScriptsMutable addObject:newStartScript];
    //[whenScriptsMutable addObject:newWhenScript];

    [sprite2.startScriptsArray addObject:newStartScript];
    [sprite2.whenScriptsArray addObject:newWhenScript];
    
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
    ret.position = GLKVector3Make(x, y, self.zIndex++);
    ret.costumesArray = costumesArray;
    [ret setIndexOfCurrentCostumeInArray:[NSNumber numberWithInt:index]]; 
    
    return ret;
}




@end
