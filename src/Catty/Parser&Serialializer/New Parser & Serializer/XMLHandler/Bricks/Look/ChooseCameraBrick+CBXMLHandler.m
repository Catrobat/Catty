/**
 *  Copyright (C) 2010-2018 The Catrobat Team
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

#import "ChooseCameraBrick+CBXMLHandler.h"
#import "GDataXMLElement+CustomExtensions.h"
#import "CBXMLValidator.h"
#import "CBXMLParserHelper.h"
#import "CBXMLParserContext.h"
#import "CBXMLSerializerContext.h"
#import "CBXMLSerializerHelper.h"

@implementation ChooseCameraBrick (CBXMLHandler)

+ (instancetype)parseFromElement:(GDataXMLElement*)xmlElement withContext:(CBXMLParserContext*)context
{
    NSString *brickType = [xmlElement XMLRootElementAsString];
    ChooseCameraBrick *brick = [self new];
    
    if([brickType rangeOfString:@"ChooseCameraBrick"].location != NSNotFound){
        [CBXMLParserHelper validateXMLElement:xmlElement forNumberOfChildNodes:1];
        GDataXMLElement *cameraChoiceElement = [xmlElement childWithElementName:@"spinnerSelectionID"];
        [XMLError exceptionIfNil:cameraChoiceElement
                         message:@"ChooseCameraBrick element does not contain a spinnerSelectionID child element!"];
        
        NSString *cameraChoice = [cameraChoiceElement stringValue];
        [XMLError exceptionIfNil:cameraChoice message:@"No cameraChoice given..."];
        
        int choiceInt = (int)[cameraChoice integerValue];
        if ((choiceInt < 0) || (choiceInt > 1))
        {
            [XMLError exceptionWithMessage:@"Parameter for spinnerSelectionID is not valid. Must be 0 or 1"];
        }
        brick.cameraPosition = choiceInt;
    } else {
        [XMLError exceptionWithMessage:@"ChooseCameraBrick is faulty"];
    }
    
    return brick;
}

- (GDataXMLElement*)xmlElementWithContext:(CBXMLSerializerContext*)context
{
    NSString *numberString = [NSString stringWithFormat:@"%i", self.cameraPosition];
    
    NSUInteger indexOfBrick = [CBXMLSerializerHelper indexOfElement:self inArray:context.brickList];
    GDataXMLElement *brick = [GDataXMLElement elementWithName:@"brick" xPathIndex:(indexOfBrick+1) context:context];
    GDataXMLElement *spinnerID = [GDataXMLElement elementWithName:@"spinnerSelectionID" stringValue:numberString context:context];
    
    [brick addAttribute:[GDataXMLElement attributeWithName:@"type" escapedStringValue:@"ChooseCameraBrick"]];
    [brick addChild:spinnerID context:context];
    return brick;
}

@end
