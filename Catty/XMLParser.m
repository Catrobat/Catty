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

#define LEVEL @"Content.Project"
#define SPRITES @"Content.Sprite"
#define COSTUMES @"Common.CostumeData"

@implementation XMLParser

@synthesize currentElementValue = _currentElementValue;
@synthesize appDelegate = _appDelegate;
@synthesize level = _level;
@synthesize currentSprite = _currentSprite;
@synthesize currentCostume = _currentCostume;

- (XMLParser *) initXMLParser 
{
    self.appDelegate = (XMLAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    return self;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName
    attributes:(NSDictionary *)attributeDict {
    
    if([elementName isEqualToString:LEVEL]) 
    {
        self.level = [[Level alloc] init];
    }
    else if ([elementName isEqualToString:SPRITES])
    {
        self.currentSprite = [[Sprite alloc] init];
        
    }
    else if ([elementName isEqualToString:COSTUMES])
    {
        self.currentCostume = [[Costume alloc] init];
    }
    
    //todo: add rest...
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
    
    
    if([elementName isEqualToString:LEVEL]) 
    {
        return;
    }
    else if ([elementName isEqualToString:SPRITES])
    {
        if (self.level.spritesArray == nil)
            self.level.spritesArray = [[NSMutableArray alloc] init];
        
        [self.level.spritesArray addObject:self.currentSprite];
        self.currentSprite = nil;
    }
    else if ([elementName isEqualToString:COSTUMES])
    {
        if (self.currentSprite.costumesArray == nil)
            self.currentSprite.costumesArray = [[NSMutableArray alloc] init];
        
        [self.currentSprite.costumesArray addObject:self.currentCostume];
        self.currentCostume = nil;
    }
    else if (self.currentCostume != nil)
    {
        [self.currentCostume setValue:self.currentElementValue forKey:elementName];
    }
    else
    {
        [self.level setValue:self.currentElementValue forKey:elementName];
    }    
    
    self.currentElementValue = nil;
}



@end
