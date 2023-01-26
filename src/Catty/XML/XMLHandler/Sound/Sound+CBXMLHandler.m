/**
 *  Copyright (C) 2010-2023 The Catrobat Team
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

#import "Sound+CBXMLHandler.h"
#import "GDataXMLElement+CustomExtensions.h"
#import "CBXMLValidator.h"
#import "CBXMLParserContext.h"
#import "CBXMLSerializerContext.h"
#import "CBXMLSerializerHelper.h"
#import "SpriteObject.h"
#import "CBXMLParserHelper.h"
#import "Brick.h"
#import "Script.h"
#import "PlaySoundBrick.h"
#import "PlaySoundAndWaitBrick.h"
#import "CBXMLPositionStack.h"
#import "CBXMLSerializerHelper.h"

@implementation Sound (CBXMLHandler)

#pragma mark - Parsing
+ (instancetype)parseFromElement:(GDataXMLElement*)xmlElement withContext:(CBXMLParserContext*)context
{
    [XMLError exceptionIfNode:xmlElement isNilOrNodeNameNotEquals:@"sound"];
    if ([CBXMLParserHelper isReferenceElement: xmlElement]) {
        return [self parseSoundWithReferenceForElement:xmlElement withContext:context];
    }
    
    GDataXMLNode *nameChildNode = nil;
    GDataXMLNode *fileNameChildNode = nil;
    
    if([context isGreaterThanLanguageVersion:0.995])
    {
        nameChildNode = [xmlElement attributeForName:@"name"];
        fileNameChildNode = [xmlElement attributeForName:@"fileName"];
    } else
    {
        nameChildNode = [xmlElement childWithElementName:@"name"];
        fileNameChildNode = [xmlElement childWithElementName:@"fileName"];
    }
    
    [XMLError exceptionIfNil:nameChildNode message:@"Sound name not present"];
    [XMLError exceptionIfNil:fileNameChildNode message:@"Sound fileName not present"];
    
    Sound *sound = [[Sound alloc] initWithName:[nameChildNode stringValue] andFileName:[fileNameChildNode stringValue]];

    return sound;
}

+ (Sound *)parseSoundWithReferenceForElement:(GDataXMLElement*)xmlElement withContext:(CBXMLParserContext*)context
{
    GDataXMLNode *referenceAttribute = [xmlElement attributeForName:@"reference"];
    [XMLError exceptionIfNil:referenceAttribute message:@"Reference for sound not present"];
    
    NSString *xPath = [referenceAttribute stringValue];
    
    GDataXMLElement *soundElement = [xmlElement singleNodeForCatrobatXPath:xPath];
    [XMLError exceptionIfNode:soundElement isNilOrNodeNameNotEquals:@"sound"];
    return [self parseFromElement:soundElement withContext:context];
}

#pragma mark - Serialization
- (GDataXMLElement*)xmlElementWithContext:(CBXMLSerializerContext*)context
{
    
    NSUInteger indexOfSound = [CBXMLSerializerHelper indexOfElement:self inArray:context.spriteObject.soundList];
    GDataXMLElement *xmlElement = [GDataXMLElement elementWithName:@"sound" xPathIndex:(indexOfSound+1) context:context];    
    
    CBXMLPositionStack *currentPositionStack = [context.currentPositionStack mutableCopy];
    CBXMLPositionStack *positionStackOfSound = context.soundNamePositions[self.name];
    
    if(positionStackOfSound) {
        NSString *refPath = [CBXMLSerializerHelper relativeXPathFromSourcePositionStack:currentPositionStack
                                                             toDestinationPositionStack:positionStackOfSound];
        [xmlElement addAttribute:[GDataXMLElement attributeWithName:@"reference" escapedStringValue:refPath]];
        return xmlElement;
    }
    
    [xmlElement addAttribute:[GDataXMLElement elementWithName:@"fileName" stringValue:self.fileName]];
    [xmlElement addAttribute:[GDataXMLElement elementWithName:@"name" stringValue:self.name]];
    
    context.soundNamePositions[self.name] = currentPositionStack;
    
    return xmlElement;
}

@end
