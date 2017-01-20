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

#import "Formula+CBXMLHandler.h"
#import "FormulaElement+CBXMLHandler.h"
#import "GDataXMLElement+CustomExtensions.h"
#import "CBXMLParserContext.h"

@implementation Formula (CBXMLHandler)

+ (instancetype)parseFromElement:(GDataXMLElement*)xmlElement withContext:(CBXMLParserContext*)context
{
    FormulaElement *formulaTree = [context parseFromElement:xmlElement withClass:[FormulaElement class]];
    Formula *formula = [Formula new];
    formula.formulaTree = formulaTree;
    return formula;
}

- (GDataXMLElement*)xmlElementWithContext:(CBXMLSerializerContext*)context
{
    GDataXMLElement *xmlElement = [GDataXMLElement elementWithName:@"formula" context:context];

    // WARNING!! no context passed to called method here!!
    //           This is because using the stack for generating the formulaTree is not allowed.
    //           If you ignore this warning, the stack will do weird things and
    //           serialization won't work any more!
    GDataXMLElement *formulaXmlElement = [self.formulaTree xmlElementWithContext:nil];
    NSArray *children = [formulaXmlElement children]; // extract child elements

    for (GDataXMLNode *node in children) {
        [xmlElement addChild:node context:nil];
    }
    return xmlElement;
}

@end
