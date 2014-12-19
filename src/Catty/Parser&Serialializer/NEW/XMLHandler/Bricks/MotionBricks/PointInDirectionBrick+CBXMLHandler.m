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

#import "PointInDirectionBrick+CBXMLHandler.h"
#import "CBXMLValidator.h"
#import "GDataXMLNode+CustomExtensions.h"
#import "Formula+CBXMLHandler.h"
#import "CBXMLParserHelper.h"

@implementation PointInDirectionBrick (CBXMLHandler)

+ (instancetype)parseFromElement:(GDataXMLElement*)xmlElement withContext:(CBXMLContext*)context
{
 [CBXMLParserHelper validateXMLElement:xmlElement forNumberOfChildNodes:1 AndFormulaListWithTotalNumberOfFormulas:1];
 Formula *formula = [CBXMLParserHelper formulaInXMLElement:xmlElement forCategoryName:@"DEGREES"];
 [XMLError exceptionIfNil:formula message:@"Unable to parse formula..."];

 PointInDirectionBrick *pointInDirectionBrick = [self new];
 pointInDirectionBrick.degrees = formula;
 return pointInDirectionBrick;
}

- (GDataXMLElement*)xmlElementWithContext:(CBXMLContext*)context
{
 GDataXMLElement *brick = [GDataXMLNode elementWithName:@"brick"];
 [brick addAttribute:[GDataXMLNode elementWithName:@"type" stringValue:@"PointInDirectionBrick"]];
 GDataXMLElement *formulaList = [GDataXMLNode elementWithName:@"formulaList"];
 GDataXMLElement *formula = [self.degrees xmlElementWithContext:context];
 [formula addAttribute:[GDataXMLNode elementWithName:@"category" stringValue:@"DEGREES"]];
 [formulaList addChild:formula];
 [brick addChild:formulaList];
 return brick;
}


@end
