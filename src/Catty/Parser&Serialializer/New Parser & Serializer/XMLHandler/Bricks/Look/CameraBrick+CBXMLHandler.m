/**
 *  Copyright (C) 2010-2020 The Catrobat Team
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

#import "CameraBrick+CBXMLHandler.h"
#import "GDataXMLElement+CustomExtensions.h"
#import "GDataXMLNode+CustomExtensions.h"
#import "CBXMLValidator.h"
#import "CBXMLParserHelper.h"
#import "CBXMLParserContext.h"
#import "CBXMLSerializerContext.h"
#import "CBXMLSerializerHelper.h"
#import "Pocket_Code-Swift.h"

@implementation CameraBrick (CBXMLHandler)

+ (instancetype)parseFromElement:(GDataXMLElement*)xmlElement withContext:(CBXMLParserContext*)context
{
    NSString *brickType = [xmlElement XMLRootElementAsString];
    CameraBrick *cameraBrick = [self new];
    
    if([brickType rangeOfString:@"CameraBrick"].location != NSNotFound) {
        
        NSUInteger childCount = [[xmlElement childrenWithoutCommentsAndCommentedOutTag] count];
        
        if (childCount != 1 && childCount != 2) {
            [XMLError exceptionWithMessage:@"Wrong number of child elements for CameraBrick"];
        } else if (childCount == 2) {
            GDataXMLElement *spinnerValuesElement = [xmlElement childWithElementName:@"spinnerValues"];
            [XMLError exceptionIfNil:spinnerValuesElement
                             message:@"CameraBrick element does not contain a spinnerValues child element!"];
        }

        GDataXMLElement *cameraChoiceElement = [xmlElement childWithElementName:@"spinnerSelectionID"];
        [XMLError exceptionIfNil:cameraChoiceElement
                         message:@"CameraBrick element does not contain a spinnerSelectionID child element!"];
        
        NSString *cameraChoice = [cameraChoiceElement stringValue];
        [XMLError exceptionIfNil:cameraChoice message:@"No cameraChoice given..."];
        
        int choiceInt = (int)[cameraChoice integerValue];
        if ((choiceInt < 0) || (choiceInt > 1))
        {
            [XMLError exceptionWithMessage:@"Parameter for spinnerSelectionID is not valid. Must be 0 or 1"];
        }
        cameraBrick.cameraChoice = choiceInt;
    } else {
        [XMLError exceptionWithMessage:@"Camera Brick is faulty"];
    }
    
    return cameraBrick;
}

- (GDataXMLElement*)xmlElementWithContext:(CBXMLSerializerContext*)context
{
    GDataXMLElement *brick = [super xmlElementForBrickType:@"CameraBrick" withContext:context];
    
    NSString *numberString = [NSString stringWithFormat:@"%i", self.cameraChoice];
    GDataXMLElement *spinnerID = [GDataXMLElement elementWithName:@"spinnerSelectionID" stringValue:numberString context:context];
    [brick addChild:spinnerID context:context];
    
    return brick;
}

@end
