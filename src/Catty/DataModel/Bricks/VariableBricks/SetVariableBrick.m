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

#import "SetVariableBrick.h"
#import "Formula.h"
#import "UserVariable.h"
#import "ProgramManager.h"
#import "Program.h"
#import "VariablesContainer.h"
#import "GDataXMLNode.h"

@implementation SetVariableBrick

- (Formula*)getFormulaForLineNumber:(NSInteger)lineNumber AndParameterNumber:(NSInteger)paramNumber
{
    return self.variableFormula;
}

- (void)setFormula:(Formula*)formula ForLineNumber:(NSInteger)lineNumber AndParameterNumber:(NSInteger)paramNumber
{
    self.variableFormula = formula;
}

- (NSString*)brickTitle
{
    return kLocalizedSetVariable;
}

- (SKAction*)action
{
  return [SKAction runBlock:[self actionBlock]];
}

- (dispatch_block_t)actionBlock
{
  return ^{
    NSDebug(@"Performing: %@ on: %@", self.description, self.object);
    
    double result = [self.variableFormula interpretDoubleForSprite:self.object];
    
    Program* program = ProgramManager.sharedProgramManager.program;
    VariablesContainer* variables = program.variables;
    
    [variables setUserVariable:self.userVariable toValue:result];
  };
}

#pragma mark - Description
- (NSString*)description
{
    double result = [self.variableFormula interpretDoubleForSprite:self.object];
    return [NSString stringWithFormat:@"Set Variable Brick: Uservariable: %@, to: %f", self.userVariable, result];
}

- (GDataXMLElement*)toXMLforObject:(SpriteObject*)spriteObject
{
    GDataXMLElement *brickXMLElement = [super toXMLforObject:spriteObject];
    if (self.userVariable && self.variableFormula) {
        [brickXMLElement addChild:[self.userVariable toXMLforObject:spriteObject]];
        GDataXMLElement *variableFormulaXMLElement = [GDataXMLNode elementWithName:@"variableFormula"];
        [variableFormulaXMLElement addChild:[self.variableFormula toXMLforObject:spriteObject]];
        [brickXMLElement addChild:variableFormulaXMLElement];
    } else {
        // remove object reference
        [brickXMLElement removeChild:[[brickXMLElement children] firstObject]];
    }
    return brickXMLElement;
}

@end
