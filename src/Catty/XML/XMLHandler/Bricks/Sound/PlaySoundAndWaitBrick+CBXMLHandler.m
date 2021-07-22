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


#import "PlaySoundAndWaitBrick+CBXMLHandler.h"
#import "CBXMLValidator.h"
#import "GDataXMLElement+CustomExtensions.h"
#import "Sound+CBXMLHandler.h"
#import "CBXMLParserContext.h"
#import "CBXMLSerializerContext.h"
#import "CBXMLParserHelper.h"
#import "CBXMLSerializerHelper.h"

@implementation PlaySoundAndWaitBrick (CBXMLHandler)

+ (instancetype)parseFromElement:(GDataXMLElement*)xmlElement withContext:(CBXMLParserContext*)context
{
    PlaySoundAndWaitBrick *playSoundAndWaitBrick = [self new];
    if([xmlElement childCount] == 0) {
        return playSoundAndWaitBrick;
    }

    NSArray *soundNodes = [xmlElement elementsForName: @"sound"];
    if (soundNodes.count < 1) {
        return playSoundAndWaitBrick;
    }
    
    GDataXMLElement *soundElement = [soundNodes firstObject];
    NSMutableArray *soundList = context.spriteObject.soundList;

    Sound *sound = nil;
    if ([CBXMLParserHelper isReferenceElement:soundElement]) {
        GDataXMLNode *referenceAttribute = [soundElement attributeForName:@"reference"];
        [XMLError exceptionIfNil:referenceAttribute message:@"No reference to a sound defined!"];
        NSString *xPath = [referenceAttribute stringValue];
        soundElement = [soundElement singleNodeForCatrobatXPath:xPath];
        [XMLError exceptionIfNil:soundElement message:@"Invalid reference in PlaySoundAndWaitBrick. No or too many sounds found!"];
        
        GDataXMLNode *nameElement = nil;
        if([context isGreaterThanLanguageVersion:0.995])
        {
            nameElement = [soundElement attributeForName:@"name"];
        } else
        {
            nameElement = [soundElement childWithElementName:@"name"];
        }
        [XMLError exceptionIfNil:nameElement message:@"Sound name not present"];

        sound = [CBXMLParserHelper findSoundInArray:soundList withName:[nameElement stringValue]];
        [XMLError exceptionIfNil:sound message:@"Fatal error: no sound found in list, but should already exist!"];
    } else {
        GDataXMLElement *soundElement = [xmlElement childWithElementName:@"sound"];
        [XMLError exceptionIfNil:soundElement message:@"sound element not present"];
        
        GDataXMLNode *soundName = nil;
        
        if([context isGreaterThanLanguageVersion:0.995])
        {
            soundName = [soundElement attributeForName:@"name"];
        } else
        {
            soundName = [soundElement childWithElementName:@"name"];
        }
        [XMLError exceptionIfNil:soundName message:@"Sound name not present"];

        sound = [CBXMLParserHelper findSoundInArray:soundList withName:[soundName stringValue]];
        
        if (sound == nil) {
            sound = [context parseFromElement:soundElement withClass:[Sound class]];
            [XMLError exceptionIfNil:sound message:@"Unable to parse sound..."];
            [soundList addObject:sound];
        }
    }
        
    playSoundAndWaitBrick.sound = sound;
    return playSoundAndWaitBrick;
}

- (GDataXMLElement*)xmlElementWithContext:(CBXMLSerializerContext*)context
{
    GDataXMLElement *brick = [super xmlElementForBrickType:@"PlaySoundAndWaitBrick" withContext:context];
    if (self.sound) {
        if([CBXMLSerializerHelper indexOfElement:self.sound inArray:context.spriteObject.soundList] == NSNotFound) {
            self.sound = nil;
        } else {
            GDataXMLElement *referenceXMLElement = [GDataXMLElement elementWithName:@"sound" context:context];
            NSInteger depthOfResource = [CBXMLSerializerHelper getDepthOfResource:self forSpriteObject:context.spriteObject];
            NSString *refPath = [CBXMLSerializerHelper relativeXPathToSound:self.sound
                                                                inSoundList:context.spriteObject.soundList withDepth:depthOfResource];
            [referenceXMLElement addAttribute:[GDataXMLElement attributeWithName:@"reference" escapedStringValue:refPath]];
            [brick addChild:referenceXMLElement context:context];
        }
    }
    return brick;
}

@end
