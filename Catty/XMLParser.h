//
//  XMLParser.h
//  Catty
//
//  Created by Christof Stromberger on 15.07.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMLParserProtocol.h"
#import "XMLLevels.h"

@class XMLAppDelegate;
@class Level;
@class Sprite;
@class Script;
@class Costume;
@class Brick;

@interface XMLParser : NSObject <NSXMLParserDelegate>

@property (nonatomic, strong) NSMutableString *currentElementValue;
@property (nonatomic, strong) XMLAppDelegate *appDelegate;
@property (nonatomic, strong) Level *level;

//helper
@property (nonatomic, strong) Sprite *currentSprite;
@property (nonatomic, strong) Costume *currentCostume;
@property (nonatomic, strong) Script *currentScript;
@property (nonatomic, assign) XMLLevels currentLevel;
@property (nonatomic, strong) Brick *currentBrick;
@property (nonatomic, strong) NSDictionary *currentAttributeValue;

- (XMLParser *) initXMLParser;

@end
