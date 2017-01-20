/**
 *  Copyright (C) 2010-2017 The Catrobat Team
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

#import "ShowTextBrick+CBXMLHandler.h"
#import "CBXMLValidator.h"
#import "GDataXMLElement+CustomExtensions.h"
#import "GDataXMLNode+CustomExtensions.h"
#import "Formula+CBXMLHandler.h"
#import "UserVariable+CBXMLHandler.h"
#import "CBXMLParser.h"
#import "CBXMLParserContext.h"
#import "CBXMLSerializerContext.h"
#import "CBXMLParserHelper.h"
#import "CBXMLSerializerHelper.h"

@implementation ShowTextBrick (CBXMLHandler)

+ (instancetype)parseFromElement:(GDataXMLElement*)xmlElement withContext:(CBXMLParserContext*)context
{
    NSUInteger childCount = [xmlElement.childrenWithoutComments count];
    GDataXMLElement *userVariableElement = nil;
    
    [CBXMLParserHelper validateXMLElement:xmlElement forFormulaListWithTotalNumberOfFormulas:2];
    
    GDataXMLElement *userVariableName = [xmlElement childWithElementName:@"userVariableName"];
    if (userVariableName != nil) {
        childCount -= 1;
    }
    
    if (childCount == 3) {
        userVariableElement = [xmlElement childWithElementName:@"userVariable"];
        [XMLError exceptionIfNil:userVariableElement message:@"No userVariableElement element found..."];
        
        GDataXMLElement *inUserBrickElement = [xmlElement childWithElementName:@"inUserBrick"];
        [XMLError exceptionIfNil:inUserBrickElement message:@"No inUserBrickElement element found..."];
        
        // inUserBrick code goes here...
    } else if (childCount == 2) {
        userVariableElement = [xmlElement childWithElementName:@"userVariable"];
        GDataXMLElement *inUserBrickElement = [xmlElement childWithElementName:@"inUserBrick"];
        
        if (userVariableElement == nil && inUserBrickElement == nil) {
            [XMLError exceptionWithMessage:@"Neither userVariableElement nor inUserBrickElement found..."];
        }
    } else if (childCount != 1) {
        [XMLError exceptionWithMessage:@"Too many or too less child elements..."];
    }

    Formula *formulaXPosition = [CBXMLParserHelper formulaInXMLElement:xmlElement forCategoryName:@"X_POSITION" withContext:context];
    Formula *formulaYPosition = [CBXMLParserHelper formulaInXMLElement:xmlElement forCategoryName:@"Y_POSITION" withContext:context];
    ShowTextBrick *showTextBrick = [self new];
    showTextBrick.xFormula = formulaXPosition;
    showTextBrick.yFormula = formulaYPosition;
    
    if (userVariableElement != nil) {
        UserVariable *userVariable = [context parseFromElement:userVariableElement withClass:[UserVariable class]];
        [XMLError exceptionIfNil:userVariable message:@"Unable to parse userVariable..."];
        
        showTextBrick.userVariable = userVariable;
    }
    
    return showTextBrick;
}

- (GDataXMLElement*)xmlElementWithContext:(CBXMLSerializerContext*)context
{
    NSUInteger indexOfBrick = [CBXMLSerializerHelper indexOfElement:self inArray:context.brickList];
    GDataXMLElement *brick = [GDataXMLElement elementWithName:@"brick" xPathIndex:(indexOfBrick+1) context:context];
    [brick addAttribute:[GDataXMLElement attributeWithName:@"type" escapedStringValue:@"ShowTextBrick"]];
    GDataXMLElement *formulaList = [GDataXMLElement elementWithName:@"formulaList" context:context];
    GDataXMLElement *formula = [self.yFormula xmlElementWithContext:context];
    [formula addAttribute:[GDataXMLElement attributeWithName:@"category" escapedStringValue:@"Y_POSITION"]];
    [formulaList addChild:formula context:context];
    formula = [self.xFormula xmlElementWithContext:context];
    [formula addAttribute:[GDataXMLElement attributeWithName:@"category" escapedStringValue:@"X_POSITION"]];
    [formulaList addChild:formula context:context];
    [brick addChild:formulaList context:context];

    // add pseudo <inUserBrick> element to produce a Catroid equivalent XML (unused at the moment)
    [brick addChild:[GDataXMLElement elementWithName:@"inUserBrick" stringValue:@"false" context:context] context:context];

    if (self.userVariable) {
        [brick addChild:[self.userVariable xmlElementWithContext:context] context:context];
        
        GDataXMLElement *userVariableName = [GDataXMLElement elementWithName:@"userVariableName" stringValue:self.userVariable.name context:context];
        [brick addChild:userVariableName context:context];
    }
    
    return brick;
}

@end
