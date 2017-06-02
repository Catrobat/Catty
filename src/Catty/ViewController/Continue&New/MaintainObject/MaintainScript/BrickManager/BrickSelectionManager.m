/**
 *  Copyright (C) 2010-2017 The Catrobat Team
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

#import "BrickSelectionManager.h"
#import "Script.h"
#import "LoopBeginBrick.h"
#import "IfLogicBeginBrick.h"
#import "IfThenLogicBeginBrick.h"
#import "IfLogicElseBrick.h"
#import "IfLogicEndBrick.h"

@interface BrickSelectionManager()

@property (nonatomic, strong) NSMutableArray *selectedIndexPaths;
@property (nonatomic, assign) BOOL selectedAllCells;

@end

@implementation BrickSelectionManager

+ (id)sharedInstance {
    static BrickSelectionManager *sharedBrickSelectionManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedBrickSelectionManager = [[self alloc] init];
        sharedBrickSelectionManager.selectedIndexPaths = [NSMutableArray new];
        [sharedBrickSelectionManager reset];
    });
    return sharedBrickSelectionManager;
}

- (NSMutableArray*) getSelectedIndexPaths {
    if (!self.selectedIndexPaths) {
        self.selectedIndexPaths = [NSMutableArray new];
    }
    return self.selectedIndexPaths;
}

- (void)addToSelectedIndexPaths:(NSIndexPath*)path {
    [self.selectedIndexPaths addObject:path];
}
- (void)removeFromSelectedIndexPaths:(NSIndexPath*)path {
    [self.selectedIndexPaths removeObject:path];
}

- (void)brickCell:(BrickCell*)brickCell didSelectBrickCellButton:(SelectButton*)selectButton IndexPath:(NSIndexPath*)indexPath andObject:(SpriteObject*)object
{

    Script *script = [object.scriptList objectAtIndex:indexPath.section];
    if (! script.brickList.count) {
        if (!selectButton.selected) {
            selectButton.selected = YES;
            script.isSelected = YES;
            [self.selectedIndexPaths addObject:indexPath];
        }else{
            selectButton.selected = NO;
            script.isSelected = NO;
            [self.selectedIndexPaths removeObject:indexPath];
        }
        return;
    }
    if (brickCell.isScriptBrick) {
        if (!selectButton.selected) {
            selectButton.selected = YES;
            script.isSelected = YES;
            [self.selectedIndexPaths addObject:indexPath];
            for (Brick *brick in script.brickList) {
                brick.isSelected = YES;
            }
        }else{
            selectButton.selected = NO;
            script.isSelected = NO;
            [self.selectedIndexPaths removeObject:indexPath];
            for (Brick *brick in script.brickList) {
                brick.isSelected = NO;
            }
            
        }
    }else{
        Brick *brick =[script.brickList objectAtIndex:indexPath.item - 1];
        if (!brick.script.isSelected) {
            if ([brick isKindOfClass:[LoopBeginBrick class]]) {
                [self selectLoopBeginWithBrick:brick Script:script IndexPath:indexPath andSelectButton:selectButton];
            } else if ([brick isKindOfClass:[LoopEndBrick class]]) {
                [self selectLoopEndWithBrick:brick Script:script IndexPath:indexPath andSelectButton:selectButton];
            } else if ([brick isKindOfClass:[IfLogicBeginBrick class]]) {
                [self selectLogicBeginWithBrick:brick Script:script IndexPath:indexPath andSelectButton:selectButton];
            } else if ([brick isKindOfClass:[IfLogicEndBrick class]]) {
                [self selectLogicEndWithBrick:brick Script:script IndexPath:indexPath andSelectButton:selectButton];
            } else if ([brick isKindOfClass:[IfLogicElseBrick class]]) {
                [self selectLogicElseWithBrick:brick Script:script IndexPath:indexPath andSelectButton:selectButton];
            } else if (! selectButton.selected) {
                selectButton.selected = selectButton.touchInside;
                brick.isSelected = selectButton.touchInside;
                [self.selectedIndexPaths addObject:indexPath];
            } else {
                selectButton.selected = NO;
                brick.isSelected = NO;
                [self.selectedIndexPaths removeObject:indexPath];
            }
        }
        
    }
}

#pragma mark - selectLogic/Loop bricks
-(void)selectLoopBeginWithBrick:(Brick*)brick Script:(Script*)script IndexPath:(NSIndexPath*)indexPath andSelectButton:(SelectButton *)selectButton
{
    LoopBeginBrick *beginBrick = (LoopBeginBrick*)brick;
    NSInteger count = 0;
    for (Brick *checkBrick in script.brickList) {
        if ([checkBrick isEqual:beginBrick.loopEndBrick]) {
            break;
        }
        count++;
    }
    NSIndexPath* endPath =[NSIndexPath indexPathForItem:count+1 inSection:indexPath.section];
    Brick *endBrick =[script.brickList objectAtIndex:endPath.item - 1];
    if (!selectButton.selected) {
        selectButton.selected = selectButton.touchInside;
        [self.selectedIndexPaths addObject:indexPath];
        [self.selectedIndexPaths addObject:endPath];
        endBrick.isSelected = YES;
        beginBrick.isSelected =YES;
    } else {
        selectButton.selected = NO;
        endBrick.isSelected = NO;
        beginBrick.isSelected = NO;
        [self.selectedIndexPaths removeObject:indexPath];
        [self.selectedIndexPaths removeObject:endPath];
    }
}

-(void)selectLoopEndWithBrick:(Brick*)brick Script:(Script*)script IndexPath:(NSIndexPath*)indexPath andSelectButton:(SelectButton*)selectButton
{
    LoopEndBrick *endBrick = (LoopEndBrick*)brick;
    NSInteger count = 0;
    for (Brick *checkBrick in script.brickList) {
        if ([checkBrick isEqual:endBrick.loopBeginBrick]) {
            break;
        }
        count++;
    }
    NSIndexPath* beginPath =[NSIndexPath indexPathForItem:count+1 inSection:indexPath.section];
    Brick *beginBrick =[script.brickList objectAtIndex:beginPath.item - 1];
    if (!selectButton.selected) {
        selectButton.selected = selectButton.touchInside;
        beginBrick.isSelected = YES;
        endBrick.isSelected = YES;
        [self.selectedIndexPaths addObject:indexPath];
        [self.selectedIndexPaths addObject:beginPath];
    } else {
        selectButton.selected = NO;
        beginBrick.isSelected = NO;
        endBrick.isSelected = NO;
        [self.selectedIndexPaths removeObject:indexPath];
        [self.selectedIndexPaths removeObject:beginPath];
    }
}

- (void)selectLogicBeginWithBrick:(Brick*)brick Script:(Script*)script IndexPath:(NSIndexPath*)indexPath andSelectButton:(SelectButton*)selectButton
{
    IfLogicBeginBrick *beginBrick = (IfLogicBeginBrick*)brick;
    NSInteger countElse = 0;
    NSInteger countEnd = 0;
    BOOL foundElse = NO;
    for (Brick *checkBrick in script.brickList) {
        if (! foundElse) {
            if ([checkBrick isEqual:beginBrick.ifElseBrick]) {
                foundElse = YES;
            } else {
                ++countElse;
            }
        }
        if ([checkBrick isEqual:beginBrick.ifEndBrick]) {
            break;
        } else {
            ++countEnd;
        }
    }
    NSIndexPath *elsePath =[NSIndexPath indexPathForItem:(countElse+1) inSection:indexPath.section];
    NSIndexPath *endPath =[NSIndexPath indexPathForItem:(countEnd+1) inSection:indexPath.section];
    Brick *elseBrick =[script.brickList objectAtIndex:elsePath.item - 1];
    Brick *endBrick =[script.brickList objectAtIndex:endPath.item - 1];
    if (selectButton.selected) {
        selectButton.selected = NO;
        endBrick.isSelected = NO;
        elseBrick.isSelected = NO;
        beginBrick.isSelected = NO;
        [self.selectedIndexPaths removeObject:indexPath];
        [self.selectedIndexPaths removeObject:elsePath];
        [self.selectedIndexPaths removeObject:endPath];
    } else {
        selectButton.selected = selectButton.touchInside;
        endBrick.isSelected = YES;
        elseBrick.isSelected = YES;
        beginBrick.isSelected = YES;
        [self.selectedIndexPaths addObject:indexPath];
        [self.selectedIndexPaths addObject:elsePath];
        [self.selectedIndexPaths addObject:endPath];
    }
}

- (void)selectLogicElseWithBrick:(Brick*)brick Script:(Script*)script IndexPath:(NSIndexPath*)indexPath andSelectButton:(SelectButton *)selectButton
{
    IfLogicElseBrick *elseBrick = (IfLogicElseBrick*)brick;
    NSInteger countBegin = 0;
    NSInteger countEnd = 0;
    BOOL foundIf = NO;
    for (Brick *checkBrick in script.brickList) {
        if (! foundIf) {
            if ([checkBrick isEqual:elseBrick.ifBeginBrick]) {
                foundIf = YES;
            } else {
                ++countBegin;
            }
        }
        if ([checkBrick isEqual:elseBrick.ifEndBrick]) {
            break;
        } else {
            ++countEnd;
        }
    }
    NSIndexPath *beginPath = [NSIndexPath indexPathForItem:(countBegin+1) inSection:indexPath.section];
    NSIndexPath *endPath = [NSIndexPath indexPathForItem:(countEnd+1) inSection:indexPath.section];
    Brick *beginBrick =[script.brickList objectAtIndex:beginPath.item - 1];
    Brick *endBrick =[script.brickList objectAtIndex:endPath.item - 1];
    if (! selectButton.selected) {
        selectButton.selected = selectButton.touchInside;
        endBrick.isSelected = YES;
        beginBrick.isSelected = YES;
        elseBrick.isSelected = YES;
        [self.selectedIndexPaths addObject:indexPath];
        [self.selectedIndexPaths addObject:beginPath];
        [self.selectedIndexPaths addObject:endPath];
    } else {
        selectButton.selected = NO;
        endBrick.isSelected = NO;
        beginBrick.isSelected = NO;
        elseBrick.isSelected = NO;
        [self.selectedIndexPaths addObject:indexPath];
        [self.selectedIndexPaths addObject:beginPath];
        [self.selectedIndexPaths addObject:endPath];
    }
    
}

- (void)selectLogicEndWithBrick:(Brick*)brick Script:(Script*)script IndexPath:(NSIndexPath*)indexPath andSelectButton:(SelectButton*)selectButton
{
    IfLogicEndBrick *endBrick = (IfLogicEndBrick*)brick;
    NSInteger countElse = 0;
    NSInteger countbegin = 0;
    BOOL foundIf = NO;
    for (Brick *checkBrick in script.brickList) {
        if (! foundIf) {
            if ([checkBrick isEqual:endBrick.ifBeginBrick]) {
                foundIf = YES;
            } else {
                ++countbegin;
            }
        }
        if ([checkBrick isEqual:endBrick.ifElseBrick]) {
            break;
        } else {
            ++countElse;
        }
    }
    NSIndexPath *beginPath =[NSIndexPath indexPathForItem:countbegin+1 inSection:indexPath.section];
    NSIndexPath *elsePath =[NSIndexPath indexPathForItem:countElse+1 inSection:indexPath.section];
    Brick *beginBrick =[script.brickList objectAtIndex:beginPath.item - 1];
    Brick *elseBrick =[script.brickList objectAtIndex:elsePath.item - 1];
    if (! selectButton.selected) {
        selectButton.selected = selectButton.touchInside;
        elseBrick.isSelected = YES;
        beginBrick.isSelected = YES;
        endBrick.isSelected = YES;
        [self.selectedIndexPaths addObject:indexPath];
        [self.selectedIndexPaths addObject:beginPath];
        [self.selectedIndexPaths addObject:elsePath];
    } else {
        selectButton.selected = NO;
        elseBrick.isSelected = NO;
        beginBrick.isSelected = NO;
        endBrick.isSelected = NO;
        [self.selectedIndexPaths removeObject:indexPath];
        [self.selectedIndexPaths removeObject:beginPath];
        [self.selectedIndexPaths removeObject:elsePath];
    }
}

- (void)selectAllBricks:(UICollectionView*)collectionView{
    [self deselectAllBricks];
    for (NSInteger section = 0; section < [collectionView numberOfSections]; section++)
    {
        for (NSInteger row = 0; row < [collectionView numberOfItemsInSection:section]; row++)
        {
            [self.selectedIndexPaths addObject:[NSIndexPath indexPathForItem:row inSection:section]];
        }
    }
}

-(void)deselectAllBricks
{
    [self.selectedIndexPaths removeAllObjects];
}

-(void)reset
{
    [self.selectedIndexPaths removeAllObjects];
    self.selectedAllCells = NO;
}

@end
