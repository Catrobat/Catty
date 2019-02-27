/**
 *  Copyright (C) 2010-2019 The Catrobat Team
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

#import "PlayNoteBrick+CBXMLHandler.h"
#import "GDataXMLElement+CustomExtensions.h"
#import "Formula+CBXMLHandler.h"
#import "CBXMLParserHelper.h"
#import "CBXMLParserContext.h"
#import "CBXMLSerializerContext.h"
#import "CBXMLSerializerHelper.h"

@implementation PlayNoteBrick (CBXMLHandler)

+ (instancetype)parseFromElement:(GDataXMLElement*)xmlElement withContext:(CBXMLParserContext*)context
{
    [CBXMLParserHelper validateXMLElement:xmlElement forFormulaListWithTotalNumberOfFormulas:2];
    
    Formula *pitch = [CBXMLParserHelper formulaInXMLElement:xmlElement forCategoryName:@"NOTE_PITCH" withContext:context];
    Formula *duration = [CBXMLParserHelper formulaInXMLElement:xmlElement forCategoryName:@"NOTE_DURATION" withContext:context];

    PlayNoteBrick *playNoteBrick = [self new];
    playNoteBrick.duration = duration;
    playNoteBrick.pitch = pitch;
    
    return playNoteBrick;
}

- (GDataXMLElement*)xmlElementWithContext:(CBXMLSerializerContext*)context
{
    NSUInteger indexOfBrick = [CBXMLSerializerHelper indexOfElement:self inArray:context.brickList];
    GDataXMLElement *brick = [GDataXMLElement elementWithName:@"brick" xPathIndex:(indexOfBrick+1) context:context];
    [brick addAttribute:[GDataXMLElement attributeWithName:@"type" escapedStringValue:@"PlayNoteBrick"]];
        
    GDataXMLElement *formulaList = [GDataXMLElement elementWithName:@"formulaList" context:context];
    GDataXMLElement *durationFormula = [self.duration xmlElementWithContext:context];
    GDataXMLElement *pitchFormula = [self.pitch xmlElementWithContext:context];

    [durationFormula addAttribute:[GDataXMLElement attributeWithName:@"category" escapedStringValue:@"NOTE_PITCH"]];
    [pitchFormula addAttribute:[GDataXMLElement attributeWithName:@"category" escapedStringValue:@"NOTE_DURATION"]];

    [formulaList addChild:durationFormula context:context];
    [formulaList addChild:pitchFormula context:context];

    [brick addChild:formulaList context:context];
    
    return brick;
}

@end
