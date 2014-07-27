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

#import "Formula.h"
#import "FormulaElement.h"
#import "GDataXMLNode.h"

@implementation Formula

- (double)interpretDoubleForSprite:(SpriteObject*)sprite
{
    return [self.formulaTree interpretRecursiveForSprite:sprite];
}

- (int)interpretIntegerForSprite:(SpriteObject*)sprite
{
    return (int)[self.formulaTree interpretRecursiveForSprite:sprite];    
}

- (BOOL)interpretBOOLForSprite:(SpriteObject*)sprite
{
    int result = [self interpretIntegerForSprite:sprite];
    return result != 0 ? true : false;
}

- (GDataXMLElement*)toXMLforObject:(SpriteObject*)spriteObject
{
    GDataXMLElement *formulaTreeXMLElement = [GDataXMLNode elementWithName:@"formulaTree"];
    for (GDataXMLElement *childElement in [self.formulaTree XMLChildElements]) {
        [formulaTreeXMLElement addChild:childElement];
    }
    return formulaTreeXMLElement;
}

@end
