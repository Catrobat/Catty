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

#import "SetSizeToBrick+CBXMLHandler.h"
#import "CBXMLValidator.h"
#import "GDataXMLNode+CustomExtensions.h"
#import "Formula+CBXMLHandler.h"

@implementation SetSizeToBrick (CBXMLHandler)

+ (instancetype)parseFromElement:(GDataXMLElement*)xmlElement withContext:(CBXMLContext*)context
{
    // FIXME: validate...

    [XMLError exceptionIf:[xmlElement childCount] notEquals:1 message:@"Too less or too many child nodes found..."];
    GDataXMLElement *formulaListElement = [xmlElement childWithElementName:@"formulaList"];
    [XMLError exceptionIfNil:formulaListElement message:@"No formulaList element found..."];
    [XMLError exceptionIf:[formulaListElement childCount] notEquals:1 message:@"Too many formulas found"];

    GDataXMLElement *formulaElement = [formulaListElement childWithElementName:@"formula"];
    [XMLError exceptionIfNil:formulaElement message:@"No formula element found..."];
    [XMLError exceptionIfString:[[formulaElement attributeForName:@"category"] stringValue] isNotEqualToString:@"SIZE" message:@"Formula has wrong category"];

    Formula *formula = [Formula parseFromElement:formulaElement withContext:nil];
    [XMLError exceptionIfNil:formula message:@"Unable to parse formula..."];

    SetSizeToBrick *setSizeToBrick = [self new];
    setSizeToBrick.size = formula;
    return setSizeToBrick;
}

@end
