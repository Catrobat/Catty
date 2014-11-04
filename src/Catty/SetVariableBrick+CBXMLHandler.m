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

#import "SetVariableBrick+CBXMLHandler.h"
#import "CBXMLValidator.h"
#import "GDataXMLNode+CustomExtensions.h"
#import "UserVariable+CBXMLHandler.h"
#import "CBXMLParser.h"

@implementation SetVariableBrick (CBXMLHandler)

+ (instancetype)parseFromElement:(GDataXMLElement*)xmlElement withContext:(CBXMLContext*)context
{
    // FIXME: validate...

    [XMLError exceptionIf:[xmlElement childCount] notEquals:3 message:@"Too less or too many child nodes found..."];
    GDataXMLElement *formulaListElement = [xmlElement childWithElementName:@"formulaList"];
    [XMLError exceptionIfNil:formulaListElement message:@"No formulaList element found..."];
    GDataXMLElement *inUserBrickElement = [xmlElement childWithElementName:@"inUserBrick"]; // TODO: implement this...
    [XMLError exceptionIfNil:inUserBrickElement message:@"No inUserBrickElement element found..."];
    GDataXMLElement *userVariableElement = [xmlElement childWithElementName:@"userVariable"];
    [XMLError exceptionIfNil:userVariableElement message:@"No userVariableElement element found..."];

    UserVariable *userVariable = [UserVariable parseFromElement:userVariableElement withContext:nil];

    SetVariableBrick *setVariableBrick = [self new];
    setVariableBrick.userVariable = userVariable;
    setVariableBrick.variableFormula = nil; // TODO: implement formula parser...
    return setVariableBrick;
}

@end
