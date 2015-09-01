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

#import "BrickInsertManagerAbstractTest.h"
#import "BrickInsertManager.h"
#import "WaitBrick.h"
#import "ForeverBrick.h"
#import "RepeatBrick.h"
#import "LoopEndBrick.h"
#import "SetVariableBrick.h"
#import "WhenScript.h"

@implementation BrickInsertManagerAbstractTest

- (void)setUp
{
    [super setUp];
    self.spriteObject = [[SpriteObject alloc] init];
    self.spriteObject.name = @"SpriteObject";
    
    UICollectionViewFlowLayout* layout = [[UICollectionViewFlowLayout alloc]init];
    layout.itemSize = CGSizeMake(100, 100);
    
    self.viewController = [[ScriptCollectionViewController alloc] initWithCollectionViewLayout:layout];
    
    XCTAssertNotNil(self.viewController, @"ScriptCollectionViewController must not be nil");
    
    self.viewController.object = self.spriteObject;
    
    self.startScript = [[StartScript alloc] init];
    self.startScript.object = self.spriteObject;
    
    [self.spriteObject.scriptList addObject:self.startScript];
    
    XCTAssertEqual(1, [self.viewController.collectionView numberOfSections]);
    XCTAssertEqual(1, [self.viewController.collectionView numberOfItemsInSection:0]);
    
    [[BrickInsertManager sharedInstance] reset];
}

@end
