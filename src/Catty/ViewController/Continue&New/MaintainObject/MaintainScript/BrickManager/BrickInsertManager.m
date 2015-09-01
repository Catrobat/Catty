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

#import "BrickInsertManager.h"
#import "Script.h"
#import "LoopBeginBrick.h"
#import "IfLogicBeginBrick.h"
#import "IfLogicElseBrick.h"
#import "IfLogicEndBrick.h"
#import "LoopEndBrick.h"
#import "ForeverBrick.h"
#import "BrickCell.h"

@interface BrickInsertManager()

@property (nonatomic, assign) BOOL moveToOtherScript;

@end

@implementation BrickInsertManager

+ (id)sharedInstance {
    static BrickInsertManager *sharedBrickInsertManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedBrickInsertManager = [[self alloc] init];
    });
    return sharedBrickInsertManager;
}

#pragma mark - check insert logic
- (BOOL)collectionView:(UICollectionView*)collectionView itemAtIndexPath:(NSIndexPath*)fromIndexPath
    canInsertToIndexPath:(NSIndexPath*)toIndexPath andObject:(SpriteObject*)object
{
    Script *fromScript = [object.scriptList objectAtIndex:fromIndexPath.section];
    Brick *fromBrick = [fromScript.brickList objectAtIndex:fromIndexPath.item - 1];
    
    if (fromBrick.isAnimatedInsertBrick) {
        if (toIndexPath.item != 0) {
            Script *script;
            if (self.moveToOtherScript) {
                script = [object.scriptList objectAtIndex:toIndexPath.section];
            }else{
                script = [object.scriptList objectAtIndex:fromIndexPath.section];
            }
            Brick *toBrick = [script.brickList objectAtIndex:toIndexPath.item - 1];
            if ([toBrick isKindOfClass:[LoopEndBrick class]]) {
                LoopEndBrick* loopEndBrick = (LoopEndBrick*) toBrick;
                if ([loopEndBrick.loopBeginBrick isKindOfClass:[ForeverBrick class]]) {
                    NSInteger counter = fromScript.brickList.count;
                    while ([[fromScript.brickList objectAtIndex:counter-1] isKindOfClass:[LoopEndBrick class]]) {
                        counter--;
                    }
                    if (toIndexPath.item < counter) {
                        return YES;
                    }
                    return NO;
                }
            }

            return YES;
        } else {
            BrickCell *brickCell = (BrickCell*)[collectionView cellForItemAtIndexPath:toIndexPath];
            self.moveToOtherScript = YES;
            if ([brickCell.scriptOrBrick isKindOfClass:[Script class]]) {
                Script *script = (Script*)brickCell.scriptOrBrick;
                if (script.brickList.count == 0) {
                    return YES;
                } else {
                    return NO;
                }
            }
            return NO;
        }
    }
    
    return NO;
}

-(void)reset
{
    self.moveToOtherScript = NO;
}

@end
