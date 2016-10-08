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

+ (instancetype)parseFromElement:(GDataXMLElement*)xmlElement withContext:(CBXMLParserContext*)context
{
    NSString *brickType = [xmlElement XMLRootElementAsString];
    FlashBrick *flashBrick = [self new];

    if([brickType rangeOfString:@"LedOffBrick"].location != NSNotFound) {
        flashBrick.flashChoice = 0;
    } else if([brickType rangeOfString:@"LedOnBrick"].location != NSNotFound){
        flashBrick.flashChoice = 1;
    } else if([brickType rangeOfString:@"FlashBrick"].location != NSNotFound){
        [CBXMLParserHelper validateXMLElement:xmlElement forNumberOfChildNodes:2];
        GDataXMLElement *flashChoiceElement = [xmlElement childWithElementName:@"spinnerSelectionID"];
        [XMLError exceptionIfNil:flashChoiceElement
                         message:@"FlashBrick element does not contain a spinnerSelectionID child element!"];
        
        NSString *flashChoice = [flashChoiceElement stringValue];
        [XMLError exceptionIfNil:flashChoice message:@"No flashChoice given..."];
        
        
        int choiceInt = (int)[flashChoice integerValue];
        if ((choiceInt < 0) || (choiceInt > 1))
        {
            [XMLError exceptionWithMessage:@"Parameter for spinnerSelectionID is not valid. Must be 0 or 1"];
        }
        flashBrick.flashChoice = choiceInt;
    }else{
        [XMLError exceptionWithMessage:@"Flash Brick is faulty"];
    }
    
    return flashBrick;
}

- (GDataXMLElement*)xmlElementWithContext:(CBXMLSerializerContext*)context
{
    NSString *numberString = [NSString stringWithFormat:@"%i", self.flashChoice];
    
    NSUInteger indexOfBrick = [CBXMLSerializerHelper indexOfElement:self inArray:context.brickList];
    GDataXMLElement *brick = [GDataXMLElement elementWithName:@"brick" xPathIndex:(indexOfBrick+1) context:context];
    [brick addAttribute:[GDataXMLElement attributeWithName:@"type" escapedStringValue:@"FlashBrick"]];
    GDataXMLElement *spinnerID = [GDataXMLElement elementWithName:@"spinnerSelectionID" stringValue:numberString context:context];
    GDataXMLElement *offString = [GDataXMLElement elementWithName:@"string" stringValue:@"off" context:context];
    GDataXMLElement *onString = [GDataXMLElement elementWithName:@"string" stringValue:@"on" context:context];
    GDataXMLElement *spinnerValues = [GDataXMLElement elementWithName:@"spinnerValues" context:context];
    
    [spinnerValues addChild:offString context:context];
    [spinnerValues addChild:onString context:context];
    [brick addChild:spinnerID context:context];
    [brick addChild:spinnerValues context:context];
    return brick;
}

@end
