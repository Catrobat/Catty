/**
 *  Copyright (C) 2010-2021 The Catrobat Team
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

#import "GlideToBrick+CBXMLHandler.h"
#import "GDataXMLElement+CustomExtensions.h"
#import "Formula+CBXMLHandler.h"
#import "CBXMLParserHelper.h"
#import "CBXMLParserContext.h"
#import "CBXMLSerializerContext.h"
#import "CBXMLSerializerHelper.h"
#import "Pocket_Code-Swift.h"

@implementation GlideToBrick (CBXMLHandler)

+ (instancetype)parseFromElement:(GDataXMLElement*)xmlElement withContext:(CBXMLParserContext*)context
{
    [CBXMLParserHelper validateXMLElement:xmlElement forNumberOfChildNodes:1 AndFormulaListWithTotalNumberOfFormulas:3];
    Formula *formulaDuration = [CBXMLParserHelper formulaInXMLElement:xmlElement
                                                      forCategoryName:@"DURATION_IN_SECONDS" withContext:context];
    Formula *formulaXDestination = [CBXMLParserHelper formulaInXMLElement:xmlElement
                                                          forCategoryName:@"X_DESTINATION" withContext:context];
    Formula *formulaYDestination = [CBXMLParserHelper formulaInXMLElement:xmlElement
                                                          forCategoryName:@"Y_DESTINATION" withContext:context];
    GlideToBrick *glideToBrick = [self new];
    glideToBrick.durationInSeconds = formulaDuration;
    glideToBrick.xDestination = formulaXDestination;
    glideToBrick.yDestination = formulaYDestination;
    return glideToBrick;
}

- (GDataXMLElement*)xmlElementWithContext:(CBXMLSerializerContext*)context
{
    GDataXMLElement *brick = [super xmlElementForBrickType:@"GlideToBrick" withContext:context];
    GDataXMLElement *formulaList = [GDataXMLElement elementWithName:@"formulaList" context:context];
    GDataXMLElement *formula = [self.durationInSeconds xmlElementWithContext:context];;
    [formula addAttribute:[GDataXMLElement attributeWithName:@"category" escapedStringValue:@"DURATION_IN_SECONDS"]];
    [formulaList addChild:formula context:context];
    formula = [self.yDestination xmlElementWithContext:context];
    [formula addAttribute:[GDataXMLElement attributeWithName:@"category" escapedStringValue:@"Y_DESTINATION"]];
    [formulaList addChild:formula context:context];
    formula = [self.xDestination xmlElementWithContext:context];
    [formula addAttribute:[GDataXMLElement attributeWithName:@"category" escapedStringValue:@"X_DESTINATION"]];
    [formulaList addChild:formula context:context];
    [brick addChild:formulaList context:context];
    return brick;
}

@end
