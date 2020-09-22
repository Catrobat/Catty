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

#import "PlaySoundBrick+CBXMLHandler.h"
#import "CBXMLValidator.h"
#import "GDataXMLElement+CustomExtensions.h"
#import "GDataXMLNode+CustomExtensions.h"
#import "Sound+CBXMLHandler.h"
#import "CBXMLParserContext.h"
#import "CBXMLSerializerContext.h"
#import "CBXMLParserHelper.h"
#import "CBXMLSerializerHelper.h"
#import "Pocket_Code-Swift.h"

@implementation PlaySoundBrick (CBXMLHandler)

+ (instancetype)parseFromElement:(GDataXMLElement*)xmlElement withContext:(CBXMLParserContext*)context
{
    PlaySoundBrick *playSoundBrick = [self new];
    
    NSArray<GDataXMLElement*> *children = xmlElement.childrenWithoutCommentsAndCommentedOutTag;
    if([children count] == 0) {
        return playSoundBrick;
    }
    
    [CBXMLParserHelper validateXMLElement:xmlElement forNumberOfChildNodes:1];
    GDataXMLElement *soundElement = [children firstObject];
    NSMutableArray *soundList = context.spriteObject.soundList;
    
    Sound *sound = nil;
    if ([CBXMLParserHelper isReferenceElement:soundElement]) {
        GDataXMLNode *referenceAttribute = [soundElement attributeForName:@"reference"];
        NSString *xPath = [referenceAttribute stringValue];
        soundElement = [soundElement singleNodeForCatrobatXPath:xPath];
        [XMLError exceptionIfNil:soundElement message:@"Invalid reference in PlaySoundBrick. No or too many sounds found!"];
        GDataXMLNode *nameElement = [soundElement childWithElementName:@"name"];
        [XMLError exceptionIfNil:nameElement message:@"Sound element does not contain a name child element!"];
        sound = [CBXMLParserHelper findSoundInArray:soundList withName:[nameElement stringValue]];
        [XMLError exceptionIfNil:sound message:@"Fatal error: no sound found in list, but should already exist!"];
    } else {
        // OMG!! a sound has been defined within the brick element...
        GDataXMLElement *soundElement = [xmlElement childWithElementName:@"sound"];
        [XMLError exceptionIfNil:soundElement message:@"sound element not present"];
        
        GDataXMLElement *soundName = [soundElement childWithElementName:@"name"];
        [XMLError exceptionIfNil:soundName message:@"Sound name not present"];
        
        sound = [CBXMLParserHelper findSoundInArray:soundList withName:[soundName stringValue]];
        
        if (sound == nil) {
            sound = [context parseFromElement:soundElement withClass:[Sound class]];
            [XMLError exceptionIfNil:sound message:@"Unable to parse sound..."];
            [soundList addObject:sound];
        }
    }
    playSoundBrick.sound = sound;
    return playSoundBrick;
}

- (GDataXMLElement*)xmlElementWithContext:(CBXMLSerializerContext*)context
{
    GDataXMLElement *brick = [super xmlElementForBrickType:@"PlaySoundBrick" withContext:context];
    if (self.sound) {
        if([CBXMLSerializerHelper indexOfElement:self.sound inArray:context.spriteObject.soundList] == NSNotFound) {
            self.sound = nil;
        } else {
            [brick addChild:[self.sound xmlElementWithContext:context] context:context];
        }
    }
    return brick;
}

@end
