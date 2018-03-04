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

#import "ThinkForBubbleBrick+CBXMLHandler.h"
#import "CBXMLParserHelper.h"
#import "CBXMLValidator.h"
#import "GDataXMLElement+CustomExtensions.h"
#import "Formula+CBXMLHandler.h"
#import "CBXMLParserContext.h"
#import "CBXMLSerializerContext.h"
#import "CBXMLSerializerHelper.h"

@implementation ThinkForBubbleBrick (CBXMLHandler)

+ (instancetype)parseFromElement:(GDataXMLElement*)xmlElement withContext:(CBXMLParserContext*)context
{
    [CBXMLParserHelper validateXMLElement:xmlElement forNumberOfChildNodes:2];
    Formula *formula = [CBXMLParserHelper formulaInXMLElement:xmlElement forCategoryName:@"STRING" withContext:context];
    Formula *durationFormula = [CBXMLParserHelper formulaInXMLElement:xmlElement forCategoryName:@"DURATION_IN_SECONDS" withContext:context];
    ThinkForBubbleBrick *thinkBrick = [self new];
    thinkBrick.stringFormula = formula;
    thinkBrick.intFormula = durationFormula;
    
    [XMLError exceptionIfNil:[xmlElement childWithElementName:@"type"] message:@"Parsed type-attribute is invalid or empty!"];
    
    return thinkBrick;
}

- (GDataXMLElement*)xmlElementWithContext:(CBXMLSerializerContext*)context
{
    NSUInteger indexOfBrick = [CBXMLSerializerHelper indexOfElement:self inArray:context.brickList];
    GDataXMLElement *brick = [GDataXMLElement elementWithName:@"brick" xPathIndex:(indexOfBrick+1) context:context];
    [brick addAttribute:[GDataXMLElement attributeWithName:@"type" escapedStringValue:@"ThinkForBubbleBrick"]];
    GDataXMLElement *formulaList = [GDataXMLElement elementWithName:@"formulaList" context:context];
    GDataXMLElement *formula = [self.stringFormula xmlElementWithContext:context];
    [formula addAttribute:[GDataXMLElement attributeWithName:@"category" escapedStringValue:@"STRING"]];
    
    GDataXMLElement *durationFormula = [self.intFormula xmlElementWithContext:context];
    [durationFormula addAttribute:[GDataXMLElement attributeWithName:@"category" escapedStringValue:@"DURATION_IN_SECONDS"]];
    
    [formulaList addChild:durationFormula context:context];
    [formulaList addChild:formula context:context];
    [brick addChild:formulaList context:context];
    
    // Element to produce Catroid equivalent XML
    [brick addChild:[GDataXMLElement elementWithName:@"type" stringValue:@"1" context:context] context:context];
    
    return brick;
}


@end
