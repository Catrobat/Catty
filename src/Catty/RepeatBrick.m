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

#import "Repeatbrick.h"
#import "Formula.h"

@interface RepeatBrick()

@property (nonatomic, assign) int loopCount;

@end

@implementation RepeatBrick


-(BOOL) checkCondition
{
    int timesToRepeat = [self.timesToRepeat interpretIntegerForSprite:self.object];
    return (self.loopCount++ < timesToRepeat) ? YES : NO;
}


-(SKAction*)actionWithNextAction:(SKAction*)forAction followAction:(SKAction*)afterForAction actionKey:(NSString*)actionKey
{
    self.nextAction = forAction;
    
    return [SKAction runBlock:^{
        int timesToRepeat = [self.timesToRepeat interpretIntegerForSprite:self.object];

        if (self.loopCount++ < timesToRepeat) {
            NSArray *array = [NSArray arrayWithObjects:self.nextAction, nil];
            [self.object runAction:[SKAction sequence:array] withKey:actionKey];
        } else {
            NSArray *array = [NSArray arrayWithObjects:afterForAction, nil];
            [self.object runAction:[SKAction sequence:array] withKey:actionKey];
        }
    }];
}


-(void)reset
{
    self.loopCount = 0;
}

#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"RepeatLoop with %d iterations", [self.timesToRepeat interpretIntegerForSprite:self.object]];
}

@end
