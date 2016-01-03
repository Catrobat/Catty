/**
 *  Copyright (C) 2010-2016 The Catrobat Team
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
#import "CBXMLValidator.h"
#import "CBXMLParser.h"
#import "CBXMLParserContext.h"
#import "CBXMLSerializerContext.h"
#import "CBXMLOpenedNestingBricksStack.h"
#import "CBXMLParserHelper.h"
#import "Formula+CBXMLHandler.h"
#import "CBXMLSerializerHelper.h"

@implementation PhiroIfLogicBeginBrick (CBXMLHandler)

+ (instancetype)parseFromElement:(GDataXMLElement*)xmlElement withContextForLanguageVersion093:(CBXMLParserContext*)context
{
    [CBXMLParserHelper validateXMLElement:xmlElement forNumberOfChildNodes:2];
    PhiroIfLogicBeginBrick *ifLogicBeginBrick = [self new];
    Formula *formula = [CBXMLParserHelper formulaInXMLElement:xmlElement forCategoryName:@"IF_PHIRO_SENSOR_CONDITION" withContext:context];
    ifLogicBeginBrick.ifCondition = formula;
//    formula = [CBXMLParserHelper formulaInXMLElement:xmlElement forCategoryName:@"IF_CONDITION" withContext:context];
    GDataXMLElement *sensor = [xmlElement childWithElementName:@"sensorSpinnerPosition"];
    if ([sensor.stringValue isEqualToString:@"0"]) {
        ifLogicBeginBrick.sensor = [SensorManager stringForSensor:phiro_front_left];
    } else if ([sensor.stringValue isEqualToString:@"1"]) {
        ifLogicBeginBrick.sensor =[SensorManager stringForSensor:phiro_front_right];
    } else if ([sensor.stringValue isEqualToString:@"2"]) {
        ifLogicBeginBrick.sensor =[SensorManager stringForSensor:phiro_side_left];
    } else if ([sensor.stringValue isEqualToString:@"3"]) {
        ifLogicBeginBrick.sensor =[SensorManager stringForSensor:phiro_side_right];
    } else if ([sensor.stringValue isEqualToString:@"4"]) {
        ifLogicBeginBrick.sensor =[SensorManager stringForSensor:phiro_bottom_left];
    } else if ([sensor.stringValue isEqualToString:@"5"]) {
        ifLogicBeginBrick.sensor =[SensorManager stringForSensor:phiro_bottom_right];
    } else {
        ifLogicBeginBrick.sensor = [SensorManager stringForSensor:phiro_front_left];
    }
    
    // add opening nesting brick on stack
    [context.openedNestingBricksStack pushAndOpenNestingBrick:ifLogicBeginBrick];
    return ifLogicBeginBrick;
}

+ (instancetype)parseFromElement:(GDataXMLElement*)xmlElement withContextForLanguageVersion095:(CBXMLParserContext*)context
{
    return [self parseFromElement:xmlElement withContextForLanguageVersion093:context];
}

- (GDataXMLElement*)xmlElementWithContext:(CBXMLSerializerContext*)context
{
    NSUInteger indexOfBrick = [CBXMLSerializerHelper indexOfElement:self inArray:context.brickList];
    GDataXMLElement *brick = [GDataXMLElement elementWithName:@"brick" xPathIndex:(indexOfBrick+1) context:context];
    [brick addAttribute:[GDataXMLElement attributeWithName:@"type" escapedStringValue:@"PhiroIfLogicBeginBrick"]];
    
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
    
    NSString *sensor;
    switch (self.phiroSensor) {
        case phiro_front_left:
            sensor = @"0";
            break;
        case phiro_front_right:
            sensor = @"1";
            break;
        case phiro_side_left:
            sensor = @"2";
            break;
        case phiro_side_right:
            sensor = @"3";
            break;
        case phiro_bottom_left:
            sensor = @"4";
            break;
        case phiro_bottom_right:
            sensor = @"5";
            break;
            
        default:
            sensor = @"0";
            break;
    }
    GDataXMLElement *value = [GDataXMLElement elementWithName:@"sensorSpinnerPosition" stringValue:sensor context:context];
    [brick addChild:value context:context];
    // add opening nesting brick on stack
    [context.openedNestingBricksStack pushAndOpenNestingBrick:self];
    return brick;
}

@end
