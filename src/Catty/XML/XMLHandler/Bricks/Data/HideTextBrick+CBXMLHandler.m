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

#import "HideTextBrick+CBXMLHandler.h"
#import "CBXMLValidator.h"
#import "GDataXMLElement+CustomExtensions.h"
#import "GDataXMLNode+CustomExtensions.h"
#import "Formula+CBXMLHandler.h"
#import "CBXMLParserContext.h"
#import "CBXMLSerializerContext.h"
#import "CBXMLSerializerHelper.h"
#import "Pocket_Code-Swift.h"

@implementation HideTextBrick (CBXMLHandler)

+ (instancetype)parseFromElement:(GDataXMLElement*)xmlElement withContext:(CBXMLParserContext*)context
{
    GDataXMLElement *userVariableElement = [xmlElement childWithElementName:@"userVariable"];
    
    HideTextBrick *hideTextBrick = [self new];
    
    if (userVariableElement != nil) {
        UserVariable *userVariable = [context parseFromElement:userVariableElement withClass:[UserVariable class]];
        [XMLError exceptionIfNil:userVariable message:@"Unable to parse userVariable..."];
        
        hideTextBrick.userVariable = userVariable;
    }
    
    return hideTextBrick;
}

- (GDataXMLElement*)xmlElementWithContext:(CBXMLSerializerContext*)context
{
    GDataXMLElement *brick = [super xmlElementForBrickType:@"HideTextBrick" withContext:context];
    
    Formula *formulaForCatroidCompatibility = [[Formula alloc] initWithZero];
    GDataXMLElement *formulaList = [GDataXMLElement elementWithName:@"formulaList" context:context];
    
    GDataXMLElement *formula = [formulaForCatroidCompatibility xmlElementWithContext:context];
    [formula addAttribute:[GDataXMLElement attributeWithName:@"category" escapedStringValue:@"X_POSITION"]];
    [formulaList addChild:formula context:context];
    
    formula = [formulaForCatroidCompatibility xmlElementWithContext:context];
    [formula addAttribute:[GDataXMLElement attributeWithName:@"category" escapedStringValue:@"Y_POSITION"]];
    [formulaList addChild:formula context:context];
    
    [brick addChild:formulaList context:context];

    if (self.userVariable) {
        [brick addChild:[self.userVariable xmlElementWithContext:context] context:context];
    }
    
    return brick;
}

@end
