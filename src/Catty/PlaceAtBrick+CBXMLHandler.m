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

#import "PlaceAtBrick+CBXMLHandler.h"
#import "CBXMLValidator.h"
#import "GDataXMLNode+CustomExtensions.h"
#import "Formula+CBXMLHandler.h"

@implementation PlaceAtBrick (CBXMLHandler)

+ (instancetype)parseFromElement:(GDataXMLElement*)xmlElement withContext:(CBXMLContext*)context
{
    [XMLError exceptionIf:[xmlElement childCount] notEquals:1 message:@"Too less or too many child nodes found..."];
    GDataXMLElement *formulaListElement = [xmlElement childWithElementName:@"formulaList"];
    [XMLError exceptionIfNil:formulaListElement message:@"No formulaList element found..."];
    [XMLError exceptionIf:[formulaListElement childCount] notEquals:2 message:@"Too less or many formulas found"];

    GDataXMLElement *formulaXPositionElement = [formulaListElement childWithElementName:@"formula"
                                                                    containingAttribute:@"category"
                                                                              withValue:@"X_POSITION"];
    [XMLError exceptionIfNil:formulaXPositionElement message:@"No formula element for x-position found..."];
    GDataXMLElement *formulaYPositionElement = [formulaListElement childWithElementName:@"formula"
                                                                    containingAttribute:@"category"
                                                                              withValue:@"Y_POSITION"];
    [XMLError exceptionIfNil:formulaYPositionElement message:@"No formula element for y-position found..."];

    Formula *formulaXPosition = [Formula parseFromElement:formulaXPositionElement withContext:nil];
    [XMLError exceptionIfNil:formulaXPosition message:@"Unable to parse formula..."];
    Formula *formulaYPosition = [Formula parseFromElement:formulaYPositionElement withContext:nil];
    [XMLError exceptionIfNil:formulaXPosition message:@"Unable to parse formula..."];

    PlaceAtBrick *placeAtBrick = [self new];
    placeAtBrick.xPosition = formulaXPosition;
    placeAtBrick.yPosition = formulaYPosition;
    return placeAtBrick;
}

@end
