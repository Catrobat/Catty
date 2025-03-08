/**
 *  Copyright (C) 2010-2024 The Catrobat Team
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

#import "PhiroIfLogicBeginBrick+CBXMLHandler.h"
#import "GDataXMLElement+CustomExtensions.h"
#import "CBXMLParserContext.h"
#import "CBXMLSerializerContext.h"
#import "CBXMLOpenedNestingBricksStack.h"
#import "CBXMLParserHelper.h"
#import "Formula+CBXMLHandler.h"
#import "CBXMLSerializerHelper.h"
#import "Pocket_Code-Swift.h"

@implementation PhiroIfLogicBeginBrick (CBXMLHandler)

+ (instancetype)parseFromElement:(GDataXMLElement*)xmlElement withContext:(CBXMLParserContext*)context
{
    [CBXMLParserHelper validateXMLElement:xmlElement forNumberOfChildNodes:2];
    PhiroIfLogicBeginBrick *ifLogicBeginBrick = [self new];
    Formula *formula = [CBXMLParserHelper formulaInXMLElement:xmlElement forCategoryName:@"IF_PHIRO_SENSOR_CONDITION" withContext:context];
    ifLogicBeginBrick.ifCondition = formula;
//    formula = [CBXMLParserHelper formulaInXMLElement:xmlElement forCategoryName:@"IF_CONDITION" withContext:context];
    GDataXMLElement *sensorSpinnerPosition = [xmlElement childWithElementName:@"sensorSpinnerPosition"];
    
    // Default value
    ifLogicBeginBrick.sensor = [[PhiroHelper class] tagWithPinNumber:[sensorSpinnerPosition.stringValue intValue]];
    
    // add opening nesting brick on stack
    [context.openedNestingBricksStack pushAndOpenNestingBrick:ifLogicBeginBrick];
    return ifLogicBeginBrick;
}

- (GDataXMLElement*)xmlElementWithContext:(CBXMLSerializerContext*)context
{
    GDataXMLElement *brick = [super xmlElementForBrickType:@"PhiroIfLogicBeginBrick" withContext:context];
    
    GDataXMLElement *formulaList = [GDataXMLElement elementWithName:@"formulaList" context:context];
    if (!self.ifCondition) {
        self.ifCondition = [[Formula alloc] initWithZero];
    }
    GDataXMLElement *formula = [self.ifCondition xmlElementWithContext:context];
    [formula addAttribute:[GDataXMLElement attributeWithName:@"category" escapedStringValue:@"IF_PHIRO_SENSOR_CONDITION"]];
    [formulaList addChild:formula context:context];

    GDataXMLElement *formula1 = [self.ifCondition xmlElementWithContext:context];
    [formula1 addAttribute:[GDataXMLElement attributeWithName:@"category" escapedStringValue:@"IF_CONDITION"]];
    [formulaList addChild:formula1 context:context];
    
    [brick addChild:formulaList context:context];
    
    NSString *sensorSpinnerPosition = [[NSNumber numberWithInteger:[[PhiroHelper class] pinNumberWithTag:self.sensor]] stringValue];
    GDataXMLElement *value = [GDataXMLElement elementWithName:@"sensorSpinnerPosition" stringValue:sensorSpinnerPosition context:context];
    [brick addChild:value context:context];
    
    // add opening nesting brick on stack
    [context.openedNestingBricksStack pushAndOpenNestingBrick:self];
    return brick;
}

@end
