/**
 *  Copyright (C) 2010-2015 The Catrobat Team
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

#import "Turnrightbrick.h"
#import "Formula.h"
#import "Util.h"
#import "Script.h"
#import "Pocket_Code-Swift.h"

@implementation TurnRightBrick

- (Formula*)formulaForLineNumber:(NSInteger)lineNumber andParameterNumber:(NSInteger)paramNumber
{
    return self.degrees;
}

- (void)setFormula:(Formula*)formula forLineNumber:(NSInteger)lineNumber andParameterNumber:(NSInteger)paramNumber
{
    self.degrees = formula;
}

- (void)setDefaultValuesForObject:(SpriteObject*)spriteObject
{
    self.degrees = [[Formula alloc] initWithFloat:15];
}

- (NSString*)brickTitle
{
    return kLocalizedTurnRight;
}

- (SKAction*)action
{
    return [SKAction runBlock:[self actionBlock]];
}

- (dispatch_block_t)actionBlock
{
    return ^{
        NSDebug(@"Performing: %@", self.description);
        CGFloat rotation = [self.script.object.spriteNode rotation];
        rotation -= [self.degrees interpretDoubleForSprite:self.script.object];
        [self.script.object.spriteNode setRotation:rotation];
    };
}

#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"TurnRight (%f degrees)", [self.degrees interpretDoubleForSprite:self.script.object]];
}

@end
