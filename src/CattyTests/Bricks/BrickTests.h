/**
 *  Copyright (C) 2010-2016 The Catrobat Team
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


#import <XCTest/XCTest.h>
#import <XCTest/XCTest.h>
#import "SpriteObject.h"
#import "Script.h"
#import "Formula.h"
#import "FormulaElement.h"
#import "ProgramLoadingInfo.h"
#import "Program.h"
#import "Parser.h"
#import "Look.h"
#import <SpriteKit/SpriteKit.h>
#import "UserVariable.h"
#import "VariablesContainer.h"
#import "Util.h"

//BrickImports
#import "Brick+UnitTestingExtensions.h"
#import "ComeToFrontBrick.h"
#import "SetXBrick.h"
#import "SetYBrick.h"
#import "Brick.h"
#import "LoopBeginBrick.h"
#import "LoopEndBrick.h"
#import "LoopBeginBrick.h"
#import "LoopEndBrick.h"
#import "BroadcastWaitBrick.h"
#import "IfLogicBeginBrick.h"
#import "IfLogicElseBrick.h"
#import "IfLogicEndBrick.h"
#import "NoteBrick.h"
#import "ForeverBrick.h"
#import "SetSizeToBrick.h"
#import "ShowBrick.h"
#import "SetVariableBrick.h"
#import "SetTransparencyBrick.h"
#import "ChangeTransparencyByNBrick.h"
#import "PointInDirectionBrick.h"
#import "PlaceAtBrick.h"
#import "HideBrick.h"
#import "ChangeYByNBrick.h"
#import "ChangeXByNBrick.h"
#import "ChangeSizeByNBrick.h"
#import "TurnLeftBrick.h"
#import "TurnRightBrick.h"
#import "GoNStepsBackBrick.h"
#import "SetBrightnessBrick.h"
#import "SetColorToBrick.h"
#import "MoveNStepsBrick.h"
#import "ClearGraphicEffectBrick.h"
#import "ChangeBrightnessByNBrick.h"
#import "ChangeColorByNBrick.h"
#import "NextLookBrick.h"


@interface BrickTests : XCTestCase

@property (strong, nonatomic) NSMutableArray* programs;
@property (strong, nonatomic) SKView *skView;
@property (strong, nonatomic) SKScene *scene;

@end
