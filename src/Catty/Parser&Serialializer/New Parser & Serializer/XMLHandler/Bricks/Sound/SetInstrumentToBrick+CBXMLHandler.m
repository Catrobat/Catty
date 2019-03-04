/**
 *  Copyright (C) 2010-2019 The Catrobat Team
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

#import "SetInstrumentToBrick+CBXMLHandler.h"
#import "GDataXMLElement+CustomExtensions.h"
#import "GDataXMLNode+CustomExtensions.h"
#import "CBXMLValidator.h"
#import "CBXMLParserHelper.h"
#import "CBXMLParserContext.h"
#import "CBXMLSerializerContext.h"
#import "CBXMLSerializerHelper.h"
#import "Pocket_Code-Swift.h"

@implementation SetInstrumentToBrick (CBXMLHandler)

+ (instancetype)parseFromElement:(GDataXMLElement*)xmlElement withContext:(CBXMLParserContext*)context
{
    SetInstrumentToBrick *setInstrumentToBrick = [self new];
    [CBXMLParserHelper validateXMLElement:xmlElement forNumberOfChildNodes:1];
    GDataXMLElement *instrumentChoiceElement = [[xmlElement children] firstObject];
    [XMLError exceptionIfNil:instrumentChoiceElement
                     message:@"SetInstrumentToBrick element does not contain a spinnerSelectionID child element!"];
    NSString *instrumentChoice = [instrumentChoiceElement stringValue];
    int choiceInt = (int)[instrumentChoice integerValue];
    if ((choiceInt < 0) || (choiceInt > 20))
    {
        [XMLError exceptionWithMessage:@"Parameter for spinnerSelectionID is not valid. Must be between 1 and 21"];
    }
    setInstrumentToBrick.instrumentChoice = choiceInt;

    return setInstrumentToBrick;
}

- (GDataXMLElement*)xmlElementWithContext:(CBXMLSerializerContext*)context
{
    NSString *numberString = [NSString stringWithFormat:@"%i", self.instrumentChoice];
    NSUInteger indexOfBrick = [CBXMLSerializerHelper indexOfElement:self inArray:context.brickList];
    GDataXMLElement *brick = [GDataXMLElement elementWithName:@"brick" xPathIndex:(indexOfBrick+1) context:context];
    
    GDataXMLElement *spinnerID = [GDataXMLElement elementWithName:@"spinnerSelectionID" stringValue:numberString context:context];
    
    [brick addAttribute:[GDataXMLElement attributeWithName:@"type" escapedStringValue:@"SetInstrumentToBrick"]];
    [brick addChild:spinnerID context:context];
    return brick;
}

@end
