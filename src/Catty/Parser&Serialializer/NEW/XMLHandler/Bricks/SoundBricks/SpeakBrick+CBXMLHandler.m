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

#import "SpeakBrick+CBXMLHandler.h"
#import "CBXMLValidator.h"
#import "CBXMLParserHelper.h"
#import "GDataXMLElement+CustomExtensions.h"
#import "Formula+CBXMLHandler.h"
#import "FormulaElement.h"

@implementation SpeakBrick (CBXMLHandler)

+ (instancetype)parseFromElement:(GDataXMLElement*)xmlElement withContext:(CBXMLContext*)context
{
    [CBXMLParserHelper validateXMLElement:xmlElement forNumberOfChildNodes:1];
    Formula *formula = [CBXMLParserHelper formulaInXMLElement:xmlElement forCategoryName:@"SPEAK"];
    [XMLError exceptionIf:formula.formulaTree.type notEquals:STRING
                  message:@"FormulaElement contains unknown type %lu! Should be STRING!",
     (unsigned long)formula.formulaTree.type];
    [XMLError exceptionIfNil:formula.formulaTree.value message:@"FormulaElement contains no value!!"];
    
    SpeakBrick *speakBrick = [self new];
    speakBrick.text = formula.formulaTree.value;
    return speakBrick;
}

- (GDataXMLElement*)xmlElementWithContext:(CBXMLContext*)context
{
    Formula *speakFormula = [Formula new];
    FormulaElement *formulaElement = [FormulaElement new];
    formulaElement.type = STRING;
    formulaElement.value = self.text;
    speakFormula.formulaTree = formulaElement;
    
    GDataXMLElement *brick = [GDataXMLElement elementWithName:@"brick" context:context];
    [brick addAttribute:[GDataXMLNode attributeWithName:@"type" stringValue:@"SpeakBrick"]];
    GDataXMLElement *formulaList = [GDataXMLElement elementWithName:@"formulaList" context:context];
    GDataXMLElement *formula = [speakFormula xmlElementWithContext:context];
    [formula addAttribute:[GDataXMLNode attributeWithName:@"category" stringValue:@"SPEAK"]];
    [formulaList addChild:formula context:context];
    [brick addChild:formulaList context:context];
    return brick;
}

@end
