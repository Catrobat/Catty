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

#import "PhiroRGBLightBrick+CBXMLHandler.h"
#import "GDataXMLElement+CustomExtensions.h"
#import "Formula+CBXMLHandler.h"
#import "CBXMLParserContext.h"
#import "CBXMLSerializerContext.h"
#import "CBXMLParserHelper.h"
#import "CBXMLSerializerHelper.h"

@implementation PhiroRGBLightBrick (CBXMLHandler)

+ (instancetype)parseFromElement:(GDataXMLElement*)xmlElement withContext:(CBXMLParserContext*)context
{
    [CBXMLParserHelper validateXMLElement:xmlElement forNumberOfChildNodes:1 AndFormulaListWithTotalNumberOfFormulas:2];
    Formula *red = [CBXMLParserHelper formulaInXMLElement:xmlElement forCategoryName:@"RED" withContext:context];
    Formula *green = [CBXMLParserHelper formulaInXMLElement:xmlElement forCategoryName:@"GREEN" withContext:context];
    Formula *blue = [CBXMLParserHelper formulaInXMLElement:xmlElement forCategoryName:@"BLUE" withContext:context];
    GDataXMLElement *light = [xmlElement childWithElementName:@"light"];
    PhiroRGBLightBrick *phiroRGBLightBrick = [self new];
    phiroRGBLightBrick.redFormula = red;
    phiroRGBLightBrick.greenFormula = green;
    phiroRGBLightBrick.blueFormula = blue;
    phiroRGBLightBrick.light = light.stringValue;
    return phiroRGBLightBrick;
}

- (GDataXMLElement*)xmlElementWithContext:(CBXMLSerializerContext*)context
{
    NSUInteger indexOfBrick = [CBXMLSerializerHelper indexOfElement:self inArray:context.brickList];
    GDataXMLElement *brick = [GDataXMLElement elementWithName:@"brick" xPathIndex:(indexOfBrick+1) context:context];
    [brick addAttribute:[GDataXMLElement attributeWithName:@"type" escapedStringValue:@"PhiroRGBLightBrick"]];
    GDataXMLElement *formulaList = [GDataXMLElement elementWithName:@"formulaList" context:context];
    GDataXMLElement *formula = [self.redFormula xmlElementWithContext:context];
    [formula addAttribute:[GDataXMLElement attributeWithName:@"category" escapedStringValue:@"PHIRO_LIGHT_RED"]];
    [formulaList addChild:formula context:context];
    formula = [self.greenFormula xmlElementWithContext:context];
    [formula addAttribute:[GDataXMLElement attributeWithName:@"category" escapedStringValue:@"PHIRO_LIGHT_GREEN"]];
    [formulaList addChild:formula context:context];
    formula = [self.blueFormula xmlElementWithContext:context];
    [formula addAttribute:[GDataXMLElement attributeWithName:@"category" escapedStringValue:@"PHIRO_LIGHT_BLUE"]];
    [formulaList addChild:formula context:context];
    [brick addChild:formulaList context:context];
    GDataXMLElement *value = [GDataXMLElement elementWithName:@"light" stringValue:self.light context:context];
    [brick addChild:value context:context];
    return brick;
}

@end
