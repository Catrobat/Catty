//
//  XMLParser.m
//  Catty
//
//  Created by Christof Stromberger on 15.07.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "XMLParser.h"
#import "XMLAppDelegate.h"
#import "Level.h"
#import "Sprite.h"
#import "Costume.h"
#import "Script.h"
#import "StartScript.h"
#import "WhenScript.h"
#import "Brick.h"
#import "SetCostumeBrick.h"
#import "WaitBrick.h"

//private declaration
@interface XMLParser()

- (void)setCurrentLevelTo:(NSString*)currentFoundElement;
- (BOOL)abort:(NSString*)elementName;
- (BOOL)setValueAllowed:(NSString*)elementName;

@end

//implementation of XMLParser
@implementation XMLParser

@synthesize currentElementValue = _currentElementValue;
@synthesize appDelegate = _appDelegate;
@synthesize level = _level;
@synthesize currentSprite = _currentSprite;
@synthesize currentCostume = _currentCostume;
@synthesize currentLevel = _currentLevel;
@synthesize currentScript = _currentScript;
@synthesize currentBrick = _currentBrick;
@synthesize currentAttributeValue = _currentAttributeValue;

- (XMLParser *) initXMLParser 
{
    self.appDelegate = (XMLAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    return self;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName
    attributes:(NSDictionary *)attributeDict {
    
    [self setCurrentLevelTo:elementName];
    
    if ([attributeDict count] > 0 )
    {
        self.currentAttributeValue = attributeDict;
    }
    
    //start tag found - now allocate objects...
    if (![self setValueAllowed:elementName])
    switch (self.currentLevel)
    {
        case kContentProject:
            //if (self.level == nil)
            //{
                self.level = [[Level alloc] init];
                self.level.spritesArray = [[NSMutableArray alloc] init];

            //}
            break;
        case kSpriteList:
            break;
        case kContentSprite:
            self.currentSprite = [[Sprite alloc] init];
            self.currentSprite.startScriptsArray = [[NSMutableArray alloc] init];
            self.currentSprite.whenScriptsArray = [[NSMutableArray alloc] init];
            self.currentSprite.costumesArray = [[NSMutableArray alloc] init];
            [self.level.spritesArray addObject:self.currentSprite]; //dunno
            break;
        case kCostumeDataList:
            break;
        case kCommonCostumeData:
            self.currentCostume = [[Costume alloc] init];
            [self.currentSprite.costumesArray addObject:self.currentCostume]; //dunno
            break;
        case kSoundList:
            //todo...
            break;
        case kScriptList:
            break;
        case kContentStartScript:
            self.currentScript = [[StartScript alloc] init];
            self.currentScript.bricksArray = [[NSMutableArray alloc] init];
            [self.currentSprite.startScriptsArray addObject:self.currentScript]; //dunno
            break;
        case kBrickList:
            break;
        case kBricksSetCostumeBrick:
            self.currentBrick = [[SetCostumeBrick alloc] init];
            [self.currentScript.bricksArray addObject:self.currentBrick]; //dunno
            break;
        case kBricksWaitBrick:
            self.currentBrick = [[WaitBrick alloc] init];
            [self.currentScript.bricksArray addObject:self.currentBrick]; //dunno
            break;
        case kContentWhenScript:
            self.currentScript = [[WhenScript alloc] init];
            self.currentScript.bricksArray = [[NSMutableArray alloc] init];
            [self.currentSprite.whenScriptsArray addObject:self.currentScript]; //dunno
            break;
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string 
{    
    if(self.currentElementValue == nil)
        self.currentElementValue = [[NSMutableString alloc] initWithString:string];
    else
        [self.currentElementValue appendString:string];
    
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName 
{
    if ([self abort:elementName])
    {
        return;
    }
    
    if ([self setValueAllowed:elementName])
    switch (self.currentLevel)
    {
        case kContentProject:
            [self.level setValue:self.currentElementValue forKey:elementName];
            break;
        case kSpriteList:
            //do nothing
            break;
        case kContentSprite:
            [self.currentSprite setValue:self.currentElementValue forKey:elementName]; //should set the name (e.g. to 'background')
            break;
        case kCostumeDataList:
            //do nothing
            break;
        case kCommonCostumeData:
            [self.currentCostume setValue:self.currentElementValue forKey:elementName];
            break;
        case kSoundList:
            //todo...
            break;
        case kScriptList:
            //todo: add sprite ref property in script and add value here
            break;
        case kContentStartScript:
            //todo: add name of script (and add property to script)
            break;
        case kBrickList:
            //do nothing
            break;
        case kBricksSetCostumeBrick:
            if ([elementName isEqualToString:@"costumeData"])
            {
                //todo: add reference property to setcostumebrick and set value
            }
            else if ([elementName isEqualToString:@"sprite"])
            {
                //todo: add reference property to setcostumebrick and set value

            }
            break;
        case kBricksWaitBrick:
            if ([elementName isEqualToString:@"costumeData"])
            {
                //todo: add reference property to setcostumebrick and set value
            }
            else if ([elementName isEqualToString:@"timeToWaitInMilliSeconds"])
            {
                //todo: add reference property to setcostumebrick and set value
                
            }
            break;
        case kContentWhenScript:
            //todo: add name of script (and add property to script)
            break;
    }

 
    self.currentElementValue = nil;
}

//check if it is allowed to set a value (attribute or property of a class)
- (BOOL)setValueAllowed:(NSString*)elementName
{    
    if (   //add unused xml levels here
           ([elementName isEqualToString:@"costumeDataList"])
        || ([elementName isEqualToString:@"scriptList"])
        || ([elementName isEqualToString:@"soundList"])
        || ([elementName isEqualToString:@"spriteList"])
        || (self.currentLevel == kContentProject && [elementName isEqualToString:@"Content.Project"])
        || (self.currentLevel == kSpriteList && [elementName isEqualToString:@"spriteList"])
        || (self.currentLevel == kContentSprite && [elementName isEqualToString:@"Content.Sprite"])
        || (self.currentLevel == kCostumeDataList && [elementName isEqualToString:@"costumeDataList"])
        || (self.currentLevel == kCommonCostumeData && [elementName isEqualToString:@"Common.CostumeData"])
        || (self.currentLevel == kSoundList && [elementName isEqualToString:@"soundList"])
        || (self.currentLevel == kScriptList && [elementName isEqualToString:@"scriptList"])
        || (self.currentLevel == kContentStartScript && [elementName isEqualToString:@"Content.StartScript"])
        || (self.currentLevel == kBrickList && [elementName isEqualToString:@"brickList"])
        || (self.currentLevel == kBricksSetCostumeBrick && [elementName isEqualToString:@"Bricks.SetCostumeBrick"])
        || (self.currentLevel == kBricksWaitBrick && [elementName isEqualToString:@"Bricks.WaitBrick"])
        || (self.currentLevel == kContentWhenScript && [elementName isEqualToString:@"Content.WhenScript"]))
    {
        return NO;
    }
    
    return YES;
}

//check if it is necessery to abort
- (BOOL)abort:(NSString*)elementName
{
    if (self.currentLevel == kContentProject 
        && [elementName isEqualToString:@"Content.Project"])
    {
        return YES;
    }
    return NO;
}

//check the currentElement and set the corresponding level depth
- (void)setCurrentLevelTo:(NSString*)currentFoundElement
{
    if ([currentFoundElement isEqualToString:@"Content.Project"])
    {
        self.currentLevel = kContentProject;
    }
    else if ([currentFoundElement isEqualToString:@"spriteList"])
    {
        self.currentLevel = kSpriteList;
    }
    else if ([currentFoundElement isEqualToString:@"Content.Sprite"])
    {
        self.currentLevel = kContentSprite;
    }
    else if ([currentFoundElement isEqualToString:@"costumeDataList"])
    {
        self.currentLevel = kCostumeDataList;
    }
    else if ([currentFoundElement isEqualToString:@"Common.CostumeData"])
    {
        self.currentLevel = kCommonCostumeData;
    }
    else if ([currentFoundElement isEqualToString:@"soundList"])
    {
        self.currentLevel = kSoundList;
    }
    //todo: add sound specification
    else if ([currentFoundElement isEqualToString:@"scriptList"])
    {
        self.currentLevel = kScriptList;
    }
    else if ([currentFoundElement isEqualToString:@"Content.StartScript"])
    {
        self.currentLevel = kContentStartScript;
    }
    else if ([currentFoundElement isEqualToString:@"brickList"])
    {
        self.currentLevel = kBrickList;
    }
    else if ([currentFoundElement isEqualToString:@"Bricks.SetCostumeBrick"])
    {
        self.currentLevel = kBricksSetCostumeBrick;
    }
    else if ([currentFoundElement isEqualToString:@"Bricks.WaitBrick"])
    {
        self.currentLevel = kBricksWaitBrick;
    }
    //todo: add further bricks
    else if ([currentFoundElement isEqualToString:@"Content.WhenScript"])
    {
        self.currentLevel = kContentWhenScript;
    }
}



@end
