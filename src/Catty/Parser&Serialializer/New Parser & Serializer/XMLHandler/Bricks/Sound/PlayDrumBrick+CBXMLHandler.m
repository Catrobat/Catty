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

#import "Formula+CBXMLHandler.h"
#import "PlayDrumBrick+CBXMLHandler.h"
#import "GDataXMLElement+CustomExtensions.h"
#import "GDataXMLNode+CustomExtensions.h"
#import "CBXMLValidator.h"
#import "CBXMLParserHelper.h"
#import "CBXMLParserContext.h"
#import "CBXMLSerializerContext.h"
#import "CBXMLSerializerHelper.h"
#import "Pocket_Code-Swift.h"

@implementation PlayDrumBrick (CBXMLHandler)

+ (instancetype)parseFromElement:(GDataXMLElement*)xmlElement withContext:(CBXMLParserContext*)context
{
    PlayDrumBrick *playDrumBrick = [self new];
    [CBXMLParserHelper validateXMLElement:xmlElement forNumberOfChildNodes:2];
    [CBXMLParserHelper validateXMLElement:xmlElement forFormulaListWithTotalNumberOfFormulas:1];
    Formula *duration = [CBXMLParserHelper formulaInXMLElement:xmlElement forCategoryName:@"DRUM_DURATION" withContext:context];
    GDataXMLElement *drumChoiceElement = [xmlElement childWithElementName:@"spinnerSelectionID"];
    [XMLError exceptionIfNil:drumChoiceElement
                     message:@"PlayDrumBrick element does not contain a spinnerSelectionID child element!"];
    NSString *drumChoice = [drumChoiceElement stringValue];
    int choiceInt = (int)[drumChoice integerValue];
    if ((choiceInt < 0) || (choiceInt > 17))
    {
        [XMLError exceptionWithMessage:@"Parameter for spinnerSelectionID is not valid. Must be between 0 and 17"];
    }
    playDrumBrick.duration = duration;
    playDrumBrick.drumChoice = choiceInt;

    return playDrumBrick;
}

- (GDataXMLElement*)xmlElementWithContext:(CBXMLSerializerContext*)context
{
    NSString *numberString = [NSString stringWithFormat:@"%i", self.drumChoice];
    NSUInteger indexOfBrick = [CBXMLSerializerHelper indexOfElement:self inArray:context.brickList];
    GDataXMLElement *brick = [GDataXMLElement elementWithName:@"brick" xPathIndex:(indexOfBrick+1) context:context];
    GDataXMLElement *spinnerID = [GDataXMLElement elementWithName:@"spinnerSelectionID" stringValue:numberString context:context];
    GDataXMLElement *formulaList = [GDataXMLElement elementWithName:@"formulaList" context:context];
    GDataXMLElement *durationFormula = [self.duration xmlElementWithContext:context];

    [durationFormula addAttribute:[GDataXMLElement attributeWithName:@"category" escapedStringValue:@"DRUM_DURATION"]];
    [formulaList addChild:durationFormula context:context];
    
    [brick addAttribute:[GDataXMLElement attributeWithName:@"type" escapedStringValue:@"PlayDrumBrick"]];
    [brick addChild:formulaList context:context];
    [brick addChild:spinnerID context:context];

    return brick;
}

@end
