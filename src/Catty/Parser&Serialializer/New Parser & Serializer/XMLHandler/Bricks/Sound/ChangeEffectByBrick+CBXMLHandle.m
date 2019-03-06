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
#import "ChangeEffectByBrick+CBXMLHandler.h"
#import "GDataXMLElement+CustomExtensions.h"
#import "GDataXMLNode+CustomExtensions.h"
#import "CBXMLValidator.h"
#import "CBXMLParserHelper.h"
#import "CBXMLParserContext.h"
#import "CBXMLSerializerContext.h"
#import "CBXMLSerializerHelper.h"
#import "Pocket_Code-Swift.h"

@implementation ChangeEffectByBrick (CBXMLHandler)

+ (instancetype)parseFromElement:(GDataXMLElement*)xmlElement withContext:(CBXMLParserContext*)context
{
    ChangeEffectByBrick *changeEffectByBrick = [self new];
    [CBXMLParserHelper validateXMLElement:xmlElement forNumberOfChildNodes:2];
    [CBXMLParserHelper validateXMLElement:xmlElement forFormulaListWithTotalNumberOfFormulas:1];
    Formula *effectChange = [CBXMLParserHelper formulaInXMLElement:xmlElement forCategoryName:@"EFFECT_CHANGE" withContext:context];
    GDataXMLElement *effectChoiceElement = [xmlElement childWithElementName:@"spinnerSelectionID"];
    [XMLError exceptionIfNil:effectChoiceElement
                     message:@"ChangeEffectBy does not contain a spinnerSelectionID child element!"];
    NSString *effectChoice = [effectChoiceElement stringValue];
    int choiceInt = (int)[effectChoice integerValue];
    if ((choiceInt < 0) || (choiceInt > 1))
    {
        [XMLError exceptionWithMessage:@"Parameter for spinnerSelectionID is not valid. Must be between 0 and 1"];
    }
    changeEffectByBrick.effectChange = effectChange;
    changeEffectByBrick.effectChoice = choiceInt;

    return changeEffectByBrick;
}

- (GDataXMLElement*)xmlElementWithContext:(CBXMLSerializerContext*)context
{
    NSString *numberString = [NSString stringWithFormat:@"%i", self.effectChoice];
    NSUInteger indexOfBrick = [CBXMLSerializerHelper indexOfElement:self inArray:context.brickList];
    GDataXMLElement *brick = [GDataXMLElement elementWithName:@"brick" xPathIndex:(indexOfBrick+1) context:context];
    GDataXMLElement *spinnerID = [GDataXMLElement elementWithName:@"spinnerSelectionID" stringValue:numberString context:context];
    GDataXMLElement *formulaList = [GDataXMLElement elementWithName:@"formulaList" context:context];
    GDataXMLElement *effectChangeFormula = [self.effectChange xmlElementWithContext:context];

    [effectChangeFormula addAttribute:[GDataXMLElement attributeWithName:@"category" escapedStringValue:@"EFFECT_CHANGE"]];
    [formulaList addChild:effectChangeFormula context:context];
    
    [brick addAttribute:[GDataXMLElement attributeWithName:@"type" escapedStringValue:@"ChangeEffectByBrick"]];
    [brick addChild:formulaList context:context];
    [brick addChild:spinnerID context:context];

    return brick;
}

@end
