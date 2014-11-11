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

#import "WaitBrick+CBXMLHandler.h"
#import "CBXMLValidator.h"
#import "GDataXMLNode+CustomExtensions.h"
#import "Formula+CBXMLHandler.h"

@implementation WaitBrick (CBXMLHandler)

+ (instancetype)parseFromElement:(GDataXMLElement*)xmlElement withContext:(CBXMLContext*)context
{
    [XMLError exceptionIf:[xmlElement childCount] notEquals:1 message:@"Too less or too many child nodes found..."];
    GDataXMLElement *formulaListElement = [xmlElement childWithElementName:@"formulaList"];
    [XMLError exceptionIfNil:formulaListElement message:@"No formulaList element found..."];
    [XMLError exceptionIf:[formulaListElement childCount] notEquals:1 message:@"Too less or many formulas found"];

    GDataXMLElement *formulaElement = [formulaListElement childWithElementName:@"formula"
                                                           containingAttribute:@"category"
                                                                     withValue:@"TIME_TO_WAIT_IN_SECONDS"];
    [XMLError exceptionIfNil:formulaElement message:@"No formula element for time-to-wait-in-seconds found..."];
    Formula *formula = [Formula parseFromElement:formulaElement withContext:nil];
    [XMLError exceptionIfNil:formula message:@"Unable to parse formula..."];

    WaitBrick *waitBrick = [self new];
    waitBrick.timeToWaitInSeconds = formula;
    return waitBrick;
}

@end
