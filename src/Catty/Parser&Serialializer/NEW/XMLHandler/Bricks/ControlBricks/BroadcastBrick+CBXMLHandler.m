/**
*  Copyright (C) 2010-2014 The Catrobat Team
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

#import "BroadcastBrick+CBXMLHandler.h"
#import "GDataXMLElement+CustomExtensions.h"
#import "CBXMLValidator.h"
#import "CBXMLParserHelper.h"

@implementation BroadcastBrick (CBXMLHandler)

+ (instancetype)parseFromElement:(GDataXMLElement*)xmlElement withContext:(CBXMLContext*)context
{
[CBXMLParserHelper validateXMLElement:xmlElement forNumberOfChildNodes:1];
GDataXMLElement *broadcastMessageElement = [xmlElement childWithElementName:@"broadcastMessage"];
[XMLError exceptionIfNil:broadcastMessageElement
   message:@"BroadcastBrick element does not contain a broadcastMessage child element!"];

NSString *broadcastMessage = [broadcastMessageElement stringValue];
[XMLError exceptionIfNil:broadcastMessage message:@"No broadcastMessage given..."];

BroadcastBrick *broadcastBrick = [self new];
broadcastBrick.broadcastMessage = broadcastMessage;
return broadcastBrick;
}

- (GDataXMLElement*)xmlElementWithContext:(CBXMLContext*)context
{
GDataXMLElement *brick = [GDataXMLElement elementWithName:@"brick"];
[brick addAttribute:[GDataXMLElement elementWithName:@"type" stringValue:@"BroadcastBrick"]];
GDataXMLElement *message = [GDataXMLElement elementWithName:@"broadcastMessage" stringValue:self.broadcastMessage];
[brick addChild:message];
return brick;
}

@end
