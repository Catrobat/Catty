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

#import "TurnLeftBrick.h"
#import "Formula.h"
#import "Util.h"

@implementation TurnLeftBrick

- (Formula*)getFormulaForLineNumber:(NSInteger)lineNumber AndParameterNumber:(NSInteger)paramNumber
{
    return self.degrees;
}

- (void)setFormula:(Formula*)formula ForLineNumber:(NSInteger)lineNumber AndParameterNumber:(NSInteger)paramNumber
{
    self.degrees = formula;
}

- (NSString*)brickTitle
{
    return kLocalizedTurnLeft;
}

- (SKAction*)action
{
    return [SKAction runBlock: [self actionBlock]];
}

- (dispatch_block_t)actionBlock
{
    return ^{
        NSDebug(@"Performing: %@", self.description);
        double rad = [Util degreeToRadians:[self.degrees interpretDoubleForSprite:self.object]];
        double newRad = self.object.zRotation + rad;
        if (newRad >= 2*M_PI) {
            newRad -= 2*M_PI;
        }
        else if (newRad <= (- 2*M_PI)) {
            newRad += 2*M_PI;
        }
        self.object.zRotation = (CGFloat)newRad;
    };
}

#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"TurnLeft (%f degrees)", [self.degrees interpretDoubleForSprite:self.object]];
}

@end
