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

#import "CBXMLParserHelper.h"
#import "CBXMLValidator.h"
#import "GDataXMLNode+CustomExtensions.h"
#import "Formula+CBXMLHandler.h"

@implementation CBXMLParserHelper

+ (BOOL)validateXMLElement:(GDataXMLElement*)xmlElement forNumberOfChildNodes:(NSUInteger)numberOfChildNodes
{
    [XMLError exceptionIf:[xmlElement childCount] notEquals:numberOfChildNodes message:@"Too less or too many child nodes found... (%lu expected)", numberOfChildNodes];
    
    return true;
}

+ (BOOL)validateXMLElement:(GDataXMLElement*)xmlElement forNumberOfChildNodes:(NSUInteger)numberOfChildNodes AndFormulaListWithTotalNumberOfFormulas:(NSUInteger)numberOfFormulas
{
    [[self class] validateXMLElement:xmlElement forNumberOfChildNodes:numberOfChildNodes];
    
    GDataXMLElement *formulaListElement = [xmlElement childWithElementName:@"formulaList"];
    [XMLError exceptionIfNil:formulaListElement message:@"No formulaList element found..."];
    [XMLError exceptionIf:[formulaListElement childCount] notEquals:numberOfFormulas message:@"Too many formulas found (%lu expected)", (unsigned long)numberOfFormulas];
    
    return true;
}

+ (Formula*)formulaInXMLElement:(GDataXMLElement*)xmlElement forCategory:(NSString*)category
{
    GDataXMLElement *formulaListElement = [xmlElement childWithElementName:@"formulaList"];
    [XMLError exceptionIfNil:formulaListElement message:@"No formulaList element found..."];
    
    GDataXMLElement *formulaElement = [formulaListElement childWithElementName:@"formula"
                                                                    containingAttribute:@"category"
                                                                              withValue:category];
    
    [XMLError exceptionIfNil:formulaElement message:@"No formula with category %@ found...", category];

    Formula *formula = [Formula parseFromElement:formulaElement withContext:nil];
    [XMLError exceptionIfNil:formula message:@"Unable to parse formula..."];
    
    return formula;
}

@end
