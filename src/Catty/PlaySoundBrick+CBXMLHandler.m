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

#import "PlaySoundBrick+CBXMLHandler.h"
#import "CBXMLValidator.h"
#import "GDataXMLNode+CustomExtensions.h"
#import "CBXMLParser.h"
#import "Sound+CBXMLHandler.h"
#import "CBXMLContext.h"
#import "CBXMLParserHelper.h"

@implementation PlaySoundBrick (CBXMLHandler)

+ (instancetype)parseFromElement:(GDataXMLElement*)xmlElement withContext:(CBXMLContext*)context
{
    [CBXMLParserHelper validateXMLElement:xmlElement forNumberOfChildNodes:1];
    GDataXMLElement *soundElement = [[xmlElement children] firstObject];
    NSMutableArray *soundList = context.soundList;

    Sound *sound = nil;
    if ([CBXMLParser isReferenceElement:soundElement]) {
        GDataXMLNode *referenceAttribute = [soundElement attributeForName:@"reference"];
        NSString *xPath = [referenceAttribute stringValue];
        soundElement = [soundElement singleNodeForCatrobatXPath:xPath];
        [XMLError exceptionIfNil:soundElement message:@"Invalid reference in PlaySoundBrick. No or too many sounds found!"];
        GDataXMLNode *nameElement = [soundElement childWithElementName:@"name"];
        [XMLError exceptionIfNil:nameElement message:@"Sound element does not contain a name child element!"];
        sound = [CBXMLParser findSoundInArray:soundList withName:[nameElement stringValue]];
        [XMLError exceptionIfNil:sound message:@"Fatal error: no sound found in list, but should already exist!"];
    } else {
        // OMG!! a look has been defined within the brick element...
        sound = [Sound parseFromElement:xmlElement withContext:nil];
        [XMLError exceptionIfNil:sound message:@"Unable to parse sound..."];
        [soundList addObject:sound];
    }
    PlaySoundBrick *playSoundBrick = [self new];
    playSoundBrick.sound = sound;
    return playSoundBrick;
}

@end
