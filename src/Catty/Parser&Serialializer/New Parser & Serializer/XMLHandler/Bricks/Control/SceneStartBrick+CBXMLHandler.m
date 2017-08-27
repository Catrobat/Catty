/**
 *  Copyright (C) 2010-2017 The Catrobat Team
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


#import "SceneStartBrick+CBXMLHandler.h"
#import "SceneStartBrick.h"
#import "CBXMLParserHelper.h"
#import "GDataXMLElement+CustomExtensions.h"
#import "CBXMLParserContext.h"
#import "CBXMLSerializerContext.h"
#import "CBXMLSerializerHelper.h"

@implementation SceneStartBrick (CBXMLHandler)

+ (instancetype)parseFromElement:(GDataXMLElement*)xmlElement withContext:(CBXMLParserContext*)context {
    NSParameterAssert([[[xmlElement attributeForName:@"type"] stringValue] isEqualToString:@"SceneStartBrick"]);
    
    [CBXMLParserHelper validateXMLElement:xmlElement forNumberOfChildNodes:1];
    GDataXMLElement *sceneToStart = [CBXMLParserHelper onlyChildOfElement:xmlElement withName:@"sceneToStart"];
    NSAssert([sceneToStart stringValue].length, @"stringValue should be set");
    
    SceneStartBrick *brick = [[SceneStartBrick alloc] init];
    brick.sceneName = [sceneToStart stringValue];
    return brick;
}

- (GDataXMLElement*)xmlElementWithContext:(CBXMLSerializerContext*)context {
    NSUInteger indexOfBrick = [CBXMLSerializerHelper indexOfElement:self inArray:context.brickList];
    GDataXMLElement *brick = [GDataXMLElement elementWithName:@"brick" xPathIndex:(indexOfBrick+1) context:context];
    [brick addAttribute:[GDataXMLElement attributeWithName:@"type" escapedStringValue:@"SceneStartBrick"]];
    
    GDataXMLElement *sceneToStart = [GDataXMLElement elementWithName:@"sceneToStart" stringValue:self.sceneName context:context];
    [brick addChild:sceneToStart context:context];
    
    return brick;
}

@end
