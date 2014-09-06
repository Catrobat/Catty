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

#import "LoopEndbrick.h"
#import "GDataXMLNode.h"
#import "LoopBeginBrick.h"

@implementation LoopEndBrick

- (BOOL)isSelectableForObject
{
    return NO;
}

- (NSString*)brickTitle
{
    return kLocalizedEndOfLoop;
}

- (void)performFromScript:(Script*)script
{
    NSDebug(@"Performing: %@", self.description);
}

#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"EndLoop"];
}

- (GDataXMLElement*)toXMLforObject:(SpriteObject*)spriteObject
{
    GDataXMLElement *brickXMLElement = [super toXMLforObject:spriteObject];

    // remove object reference
    [brickXMLElement removeChild:[[brickXMLElement children] firstObject]];

    NSString *referencePath = [NSString stringWithFormat:@"%@/loopEndBrick",
                               [spriteObject xmlReferencePathForDestinationBrick:self.loopBeginBrick
                                                                     sourceBrick:self]];
    [brickXMLElement addAttribute:[GDataXMLNode elementWithName:@"reference" stringValue:referencePath]];
    return brickXMLElement;
}

@end
