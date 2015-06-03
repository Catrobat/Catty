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

#import "GoNStepsBackBrick.h"
#import "Formula.h"
#import "Script.h"
#import "Pocket_Code-Swift.h"

@implementation GoNStepsBackBrick

- (Formula*)formulaForLineNumber:(NSInteger)lineNumber andParameterNumber:(NSInteger)paramNumber
{
    return self.steps;
}

- (void)setFormula:(Formula*)formula forLineNumber:(NSInteger)lineNumber andParameterNumber:(NSInteger)paramNumber
{
    self.steps = formula;
}

- (void)setDefaultValuesForObject:(SpriteObject*)spriteObject
{
    self.steps = [[Formula alloc] initWithInteger:1];
}

- (BOOL)isSelectableForObject
{
    return (! [self.script.object isBackground]);
}

- (NSString*)brickTitle
{
    return kLocalizedGoNStepsBack;
}

- (SKAction*)action
{

    return [SKAction runBlock:[self actionBlock]];

}

- (dispatch_block_t)actionBlock
{
    return ^{
        NSDebug(@"Performing: %@", self.description);
        CGFloat zValue = self.script.object.spriteNode.zPosition;
        int steps = [self.steps interpretIntegerForSprite:self.script.object];
        NSDebug(@"%f",self.script.object.spriteNode.zPosition-steps);
        self.script.object.spriteNode.zPosition = MAX(1, self.script.object.spriteNode.zPosition-steps);
        for(SpriteObject *obj in self.script.object.program.objectList){
            if ((obj.spriteNode.zPosition < zValue) && (obj.spriteNode.zPosition >= self.script.object.spriteNode.zPosition) && (obj != self.script.object)) {
                obj.spriteNode.zPosition +=1;
            }
        }
    };
    
}

#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"GoNStepsBack (%d)", [self.steps interpretIntegerForSprite:self.script.object]];
}

@end
