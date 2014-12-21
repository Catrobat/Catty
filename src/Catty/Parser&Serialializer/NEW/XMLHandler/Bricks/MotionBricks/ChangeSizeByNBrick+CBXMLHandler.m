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

#import "ChangeSizeByNBrick+CBXMLHandler.h"
#import "CBXMLParserHelper.h"
#import "GDataXMLElement+CustomExtensions.h"
#import "Formula+CBXMLHandler.h"
#import "CBXMLContext.h"
#import "CBXMLSerializerHelper.h"

@implementation ChangeSizeByNBrick (CBXMLHandler)

+ (instancetype)parseFromElement:(GDataXMLElement*)xmlElement withContext:(CBXMLContext*)context
{
    [CBXMLParserHelper validateXMLElement:xmlElement forNumberOfChildNodes:1 AndFormulaListWithTotalNumberOfFormulas:1];
    
    Formula *formula = [CBXMLParserHelper formulaInXMLElement:xmlElement forCategoryName:@"SIZE_CHANGE"];
    ChangeSizeByNBrick *changeSizeByNBrick = [self new];
    changeSizeByNBrick.size = formula;
    return changeSizeByNBrick;
}

- (GDataXMLElement*)xmlElementWithContext:(CBXMLContext*)context
{
    NSUInteger indexOfBrick = [CBXMLSerializerHelper indexOfElement:self inArray:context.brickList];
    GDataXMLElement *brick = [GDataXMLElement elementWithName:@"brick" xPathIndex:(indexOfBrick+1) context:context];
    [brick addAttribute:[GDataXMLNode attributeWithName:@"type" stringValue:@"ChangeSizeByNBrick"]];
    GDataXMLElement *formulaList = [GDataXMLElement elementWithName:@"formulaList" context:context];
    GDataXMLElement *formula = [self.size xmlElementWithContext:context];
    [formula addAttribute:[GDataXMLNode attributeWithName:@"category" stringValue:@"SIZE_CHANGE"]];
    [formulaList addChild:formula context:context];
    [brick addChild:formulaList context:context];
    return brick;
}

@end
