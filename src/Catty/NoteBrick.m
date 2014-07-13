/**
 *  Copyright (C) 2010-2013 The Catrobat Team
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

#import "NoteBrick.h"
#import "GDataXMLNode.h"

@implementation NoteBrick

- (NSString*)brickTitle
{
    return kBrickCellControlTitleNote;
}

- (SKAction*)action
{
    NSError(@"NoteBrick should not be executed!");
    return [SKAction runBlock:^{
        NSDebug(@"Performing: %@", self.description);
        
    }];
}

- (NSString*)description
{
    return [NSString stringWithFormat:@"NoteBrick: %@", self.note];
}

- (GDataXMLElement*)toXML
{
    GDataXMLElement *brickXMLElement = [super toXML];
    if (self.note) {
        GDataXMLElement *noteXMLElement = [GDataXMLNode elementWithName:@"note" stringValue:self.note];
        [brickXMLElement addChild:noteXMLElement];
    } else {
        // remove object reference
        [brickXMLElement removeChild:[[brickXMLElement children] firstObject]];
    }
    return brickXMLElement;
}

@end
