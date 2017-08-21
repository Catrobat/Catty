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

#import "BrickTests.h"
#import "Scene.h"
#import "ProgramManager.h"
#import "FileManager.h"
#import "ProgramLoadingInfo.h"

@interface BrickTests ()
@property (nonatomic, strong) Program *createdProgram;
@property (nonatomic, strong) ProgramManager *programManager;
@end


@implementation BrickTests

- (void)setUp
{
}

- (void)tearDown
{
    if (self.createdProgram != nil) {
        [self.programManager removeProgramWithLoadingInfo:[ProgramLoadingInfo programLoadingInfoForProgram:self.createdProgram]];
        self.createdProgram = nil;
    }
    
    [super tearDown];
}

- (ProgramManager *)programManager {
    if (! _programManager) {
        _programManager = [[ProgramManager alloc] initWithFileManager:[[FileManager alloc] init]];
    }
    return _programManager;
}

- (Program *)createAndKeepReferenceToProgramWithObjects:(NSArray<SpriteObject *> *)objects saveToDisk:(BOOL)save {
    NSAssert(self.createdProgram == nil, @"Already created");
    
    Scene *scene = [[Scene alloc] initWithName:@"Scene"
                                    objectList:objects
                            objectVariableList:[OrderedMapTable weakToWeakObjectsMapTable]
                                 originalWidth:@"100" originalHeight:@"100"];
    
    Header *header = [Header defaultHeader];
    header.programName = @"Program";
    
    self.createdProgram = [[Program alloc] initWithHeader:header
                                                   scenes:@[scene]
                                      programVariableList:@[]];
    
    if (save) {
        [self.programManager addProgram:self.createdProgram];
    }
    
    return self.createdProgram;
}

- (void)testSetVariableBrick
{
//  Program* program = [[Program alloc] init];
//  
//  SpriteObject* object = [[SpriteObject alloc] init];
//  CBSpriteNode *spriteNode = [[CBSpriteNode alloc] initWithSpriteObject:object];
//  object.spriteNode = spriteNode;
//  spriteNode.position = CGPointMake(0, 0);
//  
//  object.program = program;
//
//  [program.objectList addObject:object];
//  Scene* scene = [[Scene alloc] init];
//  [scene addChild:object];
//  
//  Formula* formula =[[Formula alloc] init];
//  FormulaElement* formulaTree  = [[FormulaElement alloc] init];
//  formulaTree.type = NUMBER;
//  formulaTree.value = @"20";
//  formula.formulaTree = formulaTree;
//  
//  UserVariable *variable = [[UserVariable alloc] init];
//  variable.name = @"Test";
//  variable.value = @20;
//  
//  
//  SetVariableBrick* brick = [[SetVariableBrick alloc]init];
//  brick.object = object;
//  brick.userVariable = variable;
//  brick.variableFormula = formula;
//
//  
//  dispatch_block_t action = [brick actionBlock];
//  action();
//  
//  
//  
//  XCTAssertEqual([program.variables getUserVariableNamed:@"Test" forSpriteObject:object].value , @20, @"SetVariableBrick is not correctly calculated");
}


@end
