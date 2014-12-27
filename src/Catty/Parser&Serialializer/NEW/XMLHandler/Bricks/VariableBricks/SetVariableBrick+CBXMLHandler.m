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
#import "GDataXMLElement+CustomExtensions.h"
#import "Formula+CBXMLHandler.h"
#import "UserVariable+CBXMLHandler.h"
#import "CBXMLParser.h"
#import "CBXMLContext.h"
#import "CBXMLParserHelper.h"
#import "CBXMLSerializerHelper.h"

@implementation SetVariableBrick (CBXMLHandler)

+ (instancetype)parseFromElement:(GDataXMLElement*)xmlElement withContext:(CBXMLContext*)context
{
    NSUInteger childCount = [xmlElement childCount];
    if (childCount == 3) {
        [CBXMLParserHelper validateXMLElement:xmlElement forNumberOfChildNodes:3
      AndFormulaListWithTotalNumberOfFormulas:1];
        // optional
        GDataXMLElement *inUserBrickElement = [xmlElement childWithElementName:@"inUserBrick"];
        [XMLError exceptionIfNil:inUserBrickElement message:@"No inUserBrickElement element found..."];

        // TODO: handle inUserBrick here...

    } else if (childCount == 2) {
        [CBXMLParserHelper validateXMLElement:xmlElement forNumberOfChildNodes:2
      AndFormulaListWithTotalNumberOfFormulas:1];
    } else {
        [XMLError exceptionWithMessage:@"Too many or too less child elements..."];
    }

    GDataXMLElement *userVariableElement = [xmlElement childWithElementName:@"userVariable"];
    [XMLError exceptionIfNil:userVariableElement message:@"No userVariableElement element found..."];

    UserVariable *userVariable = [UserVariable parseFromElement:userVariableElement withContext:context];
    [XMLError exceptionIfNil:userVariable message:@"Unable to parse userVariable..."];

    Formula *formula = [CBXMLParserHelper formulaInXMLElement:xmlElement forCategoryName:@"VARIABLE"];
    SetVariableBrick *setVariableBrick = [self new];
    setVariableBrick.userVariable = userVariable;
    setVariableBrick.variableFormula = formula;
    return setVariableBrick;
}

- (GDataXMLElement*)xmlElementWithContext:(CBXMLContext*)context
{
    NSUInteger indexOfBrick = [CBXMLSerializerHelper indexOfElement:self inArray:context.brickList];
    GDataXMLElement *brick = [GDataXMLElement elementWithName:@"brick" xPathIndex:(indexOfBrick+1) context:context];
    [brick addAttribute:[GDataXMLElement attributeWithName:@"type" escapedStringValue:@"SetVariableBrick"]];
    GDataXMLElement *formulaList = [GDataXMLElement elementWithName:@"formulaList" context:context];
    GDataXMLElement *formula = [self.variableFormula xmlElementWithContext:context];
    [formula addAttribute:[GDataXMLElement attributeWithName:@"category" escapedStringValue:@"VARIABLE"]];
    [formulaList addChild:formula context:context];
    [brick addChild:formulaList context:context];

    //  Unused at the moment => TODO: implement this after Catroid has decided to officially use this feature!
    //    [brick addChild:[GDataXMLElement elementWithName:@"inUserBrick" stringValue:@"false"
    //                                             context:context] context:context];

    [brick addChild:[self.userVariable xmlElementWithContext:context] context:context];
    return brick;
}

@end
