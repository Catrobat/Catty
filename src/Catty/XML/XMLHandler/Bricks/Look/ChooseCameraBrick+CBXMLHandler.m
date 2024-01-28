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

#import "ChooseCameraBrick+CBXMLHandler.h"
#import "GDataXMLElement+CustomExtensions.h"
#import "GDataXMLNode+CustomExtensions.h"
#import "CBXMLValidator.h"
#import "CBXMLParserHelper.h"
#import "CBXMLParserContext.h"
#import "CBXMLSerializerContext.h"
#import "CBXMLSerializerHelper.h"
#import "Pocket_Code-Swift.h"

@implementation ChooseCameraBrick (CBXMLHandler)

+ (instancetype)parseFromElement:(GDataXMLElement*)xmlElement withContext:(CBXMLParserContext*)context
{
    NSString *brickType = [xmlElement XMLRootElementAsString];
    ChooseCameraBrick *brick = [self new];
    
    if([brickType rangeOfString:@"ChooseCameraBrick"].location != NSNotFound){
        
        NSUInteger childrenCount = [[xmlElement childrenWithoutCommentsAndCommentedOutTag] count];
        if (childrenCount != 1 && childrenCount != 2) {
            [XMLError exceptionWithMessage:@"Wrong number of child elements for ChooseCameraBrick"];
        } else if (childrenCount == 2) {
            GDataXMLElement *spinnerValuesElement = [xmlElement childWithElementName:@"spinnerValues"];
            [XMLError exceptionIfNil:spinnerValuesElement
                             message:@"ChooseCameraBrick element does not contain a spinnerValues child element!"];
        }
        
        GDataXMLElement *cameraChoiceElement = [xmlElement childWithElementName:@"spinnerSelectionID"];
        [XMLError exceptionIfNil:cameraChoiceElement
                         message:@"ChooseCameraBrick element does not contain a spinnerSelectionID child element!"];
        
        NSString *cameraChoice = [cameraChoiceElement stringValue];
        [XMLError exceptionIfNil:cameraChoice message:@"No cameraChoice given..."];
        
        int choiceInt = (int)[cameraChoice integerValue];
        if ((choiceInt < 0) || (choiceInt > 1))
        {
            [XMLError exceptionWithMessage:@"Parameter for spinnerSelectionID is not valid. Must be 0 or 1"];
        }
        brick.cameraPosition = choiceInt;
    } else {
        [XMLError exceptionWithMessage:@"ChooseCameraBrick is faulty"];
    }
    
    return brick;
}

- (GDataXMLElement*)xmlElementWithContext:(CBXMLSerializerContext*)context
{
    GDataXMLElement *brick = [super xmlElementForBrickType:@"ChooseCameraBrick" withContext:context];
    
    NSString *numberString = [NSString stringWithFormat:@"%i", self.cameraPosition];   
    GDataXMLElement *spinnerID = [GDataXMLElement elementWithName:@"spinnerSelectionID" stringValue:numberString context:context];
    [brick addChild:spinnerID context:context];

    return brick;
}

@end
