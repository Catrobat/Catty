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

#import "ChangeGhostEffectByNBrick.h"
#import "Formula.h"
#import "Script.h"

@implementation ChangeGhostEffectByNBrick

@synthesize changeGhostEffect = _changeGhostEffect;

- (Formula*)getFormulaForLineNumber:(NSInteger)lineNumber AndParameterNumber:(NSInteger)paramNumber
{
    return self.changeGhostEffect;
}

- (void)setFormula:(Formula*)formula ForLineNumber:(NSInteger)lineNumber AndParameterNumber:(NSInteger)paramNumber
{
    self.changeGhostEffect = formula;
}

- (NSString*)brickTitle
{
    return kLocalizedChangeGhostEffectByN;
}

- (SKAction*)action
{
  return [SKAction runBlock:[self actionBlock]];
}

- (dispatch_block_t)actionBlock
{
  return ^{
    NSDebug(@"Performing: %@", self.description);
    double transparency = [self.changeGhostEffect interpretDoubleForSprite:self.script.object];
      CGFloat alpha = (CGFloat)(self.script.object.alpha - transparency/100.0f);
      if (alpha < 0) {
          self.script.object.alpha = 0;
          
      }
      else if (alpha > 1){
          self.script.object.alpha = 1;
      }
      else{
          self.script.object.alpha = alpha;
      }
  };
}

#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"ChangeGhostEffect by (%f)", [self.changeGhostEffect interpretDoubleForSprite:self.script.object]];
}

@end
