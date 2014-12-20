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

#import "ChangeVariableBrick+CBXMLHandler.h"
#import "CBXMLValidator.h"
#import "GDataXMLNode+CustomExtensions.h"
#import "Formula+CBXMLHandler.h"
#import "UserVariable+CBXMLHandler.h"
#import "CBXMLParser.h"
#import "CBXMLContext.h"
#import "CBXMLParserHelper.h"

@implementation ChangeVariableBrick (CBXMLHandler)

+ (instancetype)parseFromElement:(GDataXMLElement*)xmlElement withContext:(CBXMLContext*)context
{
    NSUInteger childCount = [xmlElement childCount];
    if (childCount == 3) {
        [CBXMLParserHelper validateXMLElement:xmlElement forNumberOfChildNodes:3 AndFormulaListWithTotalNumberOfFormulas:1];
        // optional
        GDataXMLElement *inUserBrickElement = [xmlElement childWithElementName:@"inUserBrick"];
        [XMLError exceptionIfNil:inUserBrickElement message:@"No inUserBrickElement element found..."];

        // TODO: handle inUserBrick here...

    } else if (childCount == 2) {
        [CBXMLParserHelper validateXMLElement:xmlElement forNumberOfChildNodes:2 AndFormulaListWithTotalNumberOfFormulas:1];
    } else {
        [XMLError exceptionWithMessage:@"Too many or too less child elements..."];
    }

    GDataXMLElement *userVariableElement = [xmlElement childWithElementName:@"userVariable"];
    [XMLError exceptionIfNil:userVariableElement message:@"No userVariableElement element found..."];

    UserVariable *userVariable = [UserVariable parseFromElement:userVariableElement withContext:nil];
    [XMLError exceptionIfNil:userVariable message:@"Unable to parse userVariable..."];

    Formula *formula = [CBXMLParserHelper formulaInXMLElement:xmlElement forCategoryName:@"VARIABLE_CHANGE"];
    ChangeVariableBrick *changeVariableBrick = [self new];
    changeVariableBrick.userVariable = userVariable;
    changeVariableBrick.variableFormula = formula;
    return changeVariableBrick;
}

- (GDataXMLElement*)xmlElementWithContext:(CBXMLContext*)context
{
    GDataXMLElement *brick = [GDataXMLNode elementWithName:@"brick"];
    [brick addAttribute:[GDataXMLNode elementWithName:@"type" stringValue:@"ChangeVariableBrick"]];
    GDataXMLElement *formulaList = [GDataXMLNode elementWithName:@"formulaList"];
    GDataXMLElement *formula = [self.variableFormula xmlElementWithContext:context];
    [formula addAttribute:[GDataXMLNode elementWithName:@"category" stringValue:@"VARIABLE_CHANGE"]];
    [formulaList addChild:formula];
    [brick addChild:formulaList];
    [brick addChild:[GDataXMLNode elementWithName:@"inUserBrick" stringValue:@"false"]]; // TODO: implement this...
    [brick addChild:[self.userVariable xmlElementWithContext:context]];
    return brick;
}

@end
