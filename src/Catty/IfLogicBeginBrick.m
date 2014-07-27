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

#import "IfLogicBeginBrick.h"
#import "Formula.h"
#import "GDataXMLNode.h"

@implementation IfLogicBeginBrick

- (NSString*)brickTitle
{
    return kBrickCellControlTitleIf;
}

-(BOOL)checkCondition
{
    NSDebug(@"Performing: %@", self.description);
    return [self.ifCondition interpretBOOLForSprite:self.object];
}


#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"If Logic Begin Brick"];
}

- (GDataXMLElement*)toXMLforObject:(SpriteObject*)spriteObject
{
    GDataXMLElement *brickXMLElement = [super toXMLforObject:spriteObject];

    // ifCondition
    GDataXMLElement *ifConditionXMLElement = [GDataXMLNode elementWithName:@"ifCondition"];
    [ifConditionXMLElement addChild:[self.ifCondition toXMLforObject:spriteObject]];
    [brickXMLElement addChild:ifConditionXMLElement];

    // ifElseBrick
    GDataXMLElement *ifElseBrickXMLElement = [GDataXMLNode elementWithName:@"ifElseBrick"];
    GDataXMLElement *brickToObjectReferenceXMLElement = [GDataXMLNode elementWithName:@"object"];
    [brickToObjectReferenceXMLElement addAttribute:[GDataXMLNode elementWithName:@"reference" stringValue:@"../../../../../.."]];
    [ifElseBrickXMLElement addChild:brickToObjectReferenceXMLElement];
    GDataXMLElement *ifBeginBrickXMLElement = [GDataXMLNode elementWithName:@"ifBeginBrick"];
    [ifBeginBrickXMLElement addAttribute:[GDataXMLNode elementWithName:@"reference" stringValue:@"../.."]];
    [ifElseBrickXMLElement addChild:ifBeginBrickXMLElement];
    GDataXMLElement *ifInnerEndBrickXMLElement = [GDataXMLNode elementWithName:@"ifEndBrick"];
//    [ifEndBrickXMLElement addAttribute:[GDataXMLNode elementWithName:@"reference" stringValue:@"../.."]];
    brickToObjectReferenceXMLElement = [GDataXMLNode elementWithName:@"object"];
    [brickToObjectReferenceXMLElement addAttribute:[GDataXMLNode elementWithName:@"reference" stringValue:@"../../../../../../.."]];
    [ifInnerEndBrickXMLElement addChild:brickToObjectReferenceXMLElement];
    ifBeginBrickXMLElement = [GDataXMLNode elementWithName:@"ifBeginBrick"];
    [ifBeginBrickXMLElement addAttribute:[GDataXMLNode elementWithName:@"reference" stringValue:@"../../.."]];
    [ifInnerEndBrickXMLElement addChild:ifBeginBrickXMLElement];
    GDataXMLElement *ifInnerElseBrickXMLElement = [GDataXMLNode elementWithName:@"ifElseBrick"];
    [ifInnerElseBrickXMLElement addAttribute:[GDataXMLNode elementWithName:@"reference" stringValue:@"../.."]];
    [ifInnerEndBrickXMLElement addChild:ifInnerElseBrickXMLElement];
    [ifElseBrickXMLElement addChild:ifInnerEndBrickXMLElement];
    [brickXMLElement addChild:ifElseBrickXMLElement];

    // ifEndBrick
    GDataXMLElement *ifEndBrickXMLElement = [GDataXMLNode elementWithName:@"ifEndBrick"];
    [ifEndBrickXMLElement addAttribute:[GDataXMLNode elementWithName:@"reference" stringValue:@"../ifElseBrick/ifEndBrick"]];
    [brickXMLElement addChild:ifEndBrickXMLElement];

    return brickXMLElement;
}

@end
