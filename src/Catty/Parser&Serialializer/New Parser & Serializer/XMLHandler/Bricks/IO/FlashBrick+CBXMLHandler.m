/**
 *  Copyright (C) 2010-2016 The Catrobat Team
 *  (http://developer.catrobat.org/credits)
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU Affero General Public License as
 *  published by the Free Software Foundation, either version 3 of the
 *  License, or (at your option) any later version.
 *
 *  An additional term exception under section 7 of the GNU Affero
 *  General Public License, version 3, is available at
 *  (http://developer.catrobat.org/license_additional_term)
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 *  GNU Affero General Public License for more details.
 *
 *  You should have received a copy of the GNU Affero General Public License
 *  along with this program.  If not, see http://www.gnu.org/licenses/.
 */

#import "FlashBrick+CBXMLHandler.h"
#import "GDataXMLElement+CustomExtensions.h"
#import "CBXMLValidator.h"
#import "CBXMLParserHelper.h"
#import "CBXMLParserContext.h"
#import "CBXMLSerializerContext.h"
#import "CBXMLSerializerHelper.h"

@implementation FlashBrick (CBXMLHandler)

+ (instancetype)parseFromElement:(GDataXMLElement*)xmlElement withContextForLanguageVersion093:(CBXMLParserContext*)context
{
    [CBXMLParserHelper validateXMLElement:xmlElement forNumberOfChildNodes:1];
    GDataXMLElement *broadcastMessageElement = [xmlElement childWithElementName:@"broadcastMessage"];
    [XMLError exceptionIfNil:broadcastMessageElement
                     message:@"BroadcastBrick element does not contain a broadcastMessage child element!"];

    NSString *broadcastMessage = [broadcastMessageElement stringValue];
    [XMLError exceptionIfNil:broadcastMessage message:@"No broadcastMessage given..."];

    FlashBrick *flashBrick = [self new];
    flashBrick.broadcastMessage = broadcastMessage;
    return flashBrick;
}

+ (instancetype)parseFromElement:(GDataXMLElement*)xmlElement withContextForLanguageVersion095:(CBXMLParserContext*)context
{
    return [self parseFromElement:xmlElement withContextForLanguageVersion093:context];
}

- (GDataXMLElement*)xmlElementWithContext:(CBXMLSerializerContext*)context
{
    /* New Serializer. Uncomment once the brick is finished.
     
    NSUInteger indexOfBrick = [CBXMLSerializerHelper indexOfElement:self inArray:context.brickList];
    GDataXMLElement *brick = [GDataXMLElement elementWithName:@"brick" xPathIndex:(indexOfBrick+1) context:context];
    [brick addAttribute:[GDataXMLElement attributeWithName:@"type" escapedStringValue:@"FlashBrick"]];
    GDataXMLElement *spinnerID = [GDataXMLElement elementWithName:@"spinnerSelectionID" stringValue:@"0" context:context];
    GDataXMLElement *offString = [GDataXMLElement elementWithName:@"string" stringValue:@"off" context:context];
    GDataXMLElement *onString = [GDataXMLElement elementWithName:@"string" stringValue:@"on" context:context];
    GDataXMLElement *spinnerValues = [GDataXMLElement elementWithName:@"spinnerValues" context:context];
    
    [spinnerValues addChild:offString context:context];
    [spinnerValues addChild:onString context:context];
    [brick addChild:spinnerID context:context];
    [brick addChild:spinnerValues context:context];
    return brick;
     
    */
    
    NSUInteger indexOfBrick = [CBXMLSerializerHelper indexOfElement:self inArray:context.brickList];
    GDataXMLElement *brick = [GDataXMLElement elementWithName:@"brick" xPathIndex:(indexOfBrick+1) context:context];
    [brick addAttribute:[GDataXMLElement attributeWithName:@"type" escapedStringValue:@"BroadcastBrick"]];
    GDataXMLElement *message = [GDataXMLElement elementWithName:@"broadcastMessage" stringValue:self.broadcastMessage context:context];
    [brick addChild:message context:context];
    return brick;
}

@end
