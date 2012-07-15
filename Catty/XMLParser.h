//
//  XMLParser.h
//  Catty
//
//  Created by Christof Stromberger on 15.07.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMLParserProtocol.h"

@class XMLAppDelegate;
@class Level;
@class Sprite;
@class Costume;

@interface XMLParser : NSObject <NSXMLParserDelegate>

@property (nonatomic, strong) NSMutableString *currentElementValue;
@property (nonatomic, strong) XMLAppDelegate *appDelegate;
@property (nonatomic, strong) Level *level;

//helper
@property (nonatomic, strong) Sprite *currentSprite;
@property (nonatomic, strong) Costume *currentCostume;

- (XMLParser *) initXMLParser;

@end
