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

@implementation TestParser

- (Level*)generateObjectForLevel:(NSString*)path
{
    /// TODO: call xml-parser instead of following lines... I know, wrong place...doesn't matter...
    
    NSMutableArray *startScriptsMutable = [[NSMutableArray alloc] init];
    NSMutableArray *whenScriptsMutable = [[NSMutableArray alloc] init];
    
    GLKBaseEffect *effect = [[GLKBaseEffect alloc] init];
    
    // Level
    Level *level = [[Level alloc]init];
    level.name = @"Catty1";
    level.version = 1.1;
    level.resolution = CGSizeZero;
    
    // 1st Sprite (Background)
    Costume *newCostume = [[Costume alloc]init];
    newCostume.filePath = @"normalcat.png";
    newCostume.name = @"background";
    
    Sprite *newSprite1 = [[Sprite alloc] initWithCostume:newCostume effect:effect];
    newSprite1.name = @"Background";
    newSprite1.position = GLKVector2Make(0, 0);
    //newSprite1.effect = self.effect;
     
    //newSprite1.costumesArray = [[NSArray alloc]initWithObjects:newCostume, nil];
    
    Script *newScript = [[StartScript alloc]init];
    
    SetCostumeBrick *newBrick = [[SetCostumeBrick alloc]init];
    newBrick.indexOfCostumeInArray = 0;
    newBrick.sprite = newSprite1;
    newScript.bricksArray = [[NSArray alloc]initWithObjects:newBrick, nil];
    
    if ([newScript isMemberOfClass:[StartScript class]])
        [startScriptsMutable addObject:newScript];
    else if ([newScript isMemberOfClass:[WhenScript class]])
        [whenScriptsMutable addObject:newScript];
    
    // 2nd Sprite (Cat)
    Costume *newCostume1 = [[Costume alloc]init];
    newCostume1.filePath = @"normalcat.png";
    newCostume1.name = @"cat1";
    /*Costume *newCostume2 = [[Costume alloc]init];
    newCostume2.filePath = @"ceshirecat.png";
    newCostume2.name = @"cat2"; */
    //newSprite2.costumesArray = [[NSArray alloc]initWithObjects:newCostume1, newCostume2, nil];
    
    Sprite *newSprite2 = [[Sprite alloc]  initWithCostume:newCostume1 effect:effect];
    newSprite2.name = @"Catroid";
    newSprite2.position = GLKVector2Make(100, 100);
    //newSprite2.effect = self.effect;
    
    Script *newStartScript = [[StartScript alloc]init];
    
    newBrick = [[SetCostumeBrick alloc]init];
    newBrick.indexOfCostumeInArray = 0;
    newBrick.sprite = newSprite2;
    newStartScript.bricksArray = [[NSArray alloc]initWithObjects:newBrick, nil];
    
    WhenScript *newWhenScript = [[WhenScript alloc]init];
    newWhenScript.action = 0;
    newBrick = [[SetCostumeBrick alloc]init];
    newBrick.indexOfCostumeInArray = 1;
    newBrick.sprite = newSprite2;
    newWhenScript.bricksArray = [[NSArray alloc]initWithObjects:newBrick, nil];
    
    [startScriptsMutable addObject:newStartScript];
    [whenScriptsMutable addObject:newWhenScript];
    
    level.spritesArray = [[NSArray alloc] initWithObjects: newSprite1, newSprite2, nil];
    
    level.startScriptsArray = [[NSArray alloc] initWithArray:startScriptsMutable];
    level.whenScriptsArray = [[NSArray alloc] initWithArray:whenScriptsMutable];
    
    /// end of "xml-parsing" ;)
    
    
    return level;
}


@end
