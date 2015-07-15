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

#import "SetTransparencyBrick.h"
#import "Formula.h"
#import "Script.h"
#import "Pocket_Code-Swift.h"

@implementation SetTransparencyBrick

@synthesize transparency = _transparency;

- (Formula*)formulaForLineNumber:(NSInteger)lineNumber andParameterNumber:(NSInteger)paramNumber
{
    return self.transparency;
}

- (void)setFormula:(Formula*)formula forLineNumber:(NSInteger)lineNumber andParameterNumber:(NSInteger)paramNumber
{
    self.transparency = formula;
}

- (void)setDefaultValuesForObject:(SpriteObject*)spriteObject
{
    self.transparency = [[Formula alloc] initWithZero];
}

- (NSString*)brickTitle
{
    return kLocalizedSetGhostEffect;
}

- (SKAction*)action
{
  return [SKAction runBlock:[self actionBlock]];
}

- (dispatch_block_t)actionBlock
{
  return ^{
    NSDebug(@"Performing: %@", self.description);
    double transparency = [self.transparency interpretDoubleForSprite:self.script.object];
      double alpha = 1.0-transparency/100.0f;
      if (alpha < 0) {
          self.script.object.spriteNode.alpha = 0;
      }
      else if (alpha > 1){
          self.script.object.spriteNode.alpha = 1;
      }
      else{
          self.script.object.spriteNode.alpha = (CGFloat)alpha;
      }
      };
}

#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"SetTransparencyBrick (%f%%)", [self.transparency interpretDoubleForSprite:self.script.object]];
}

@end
