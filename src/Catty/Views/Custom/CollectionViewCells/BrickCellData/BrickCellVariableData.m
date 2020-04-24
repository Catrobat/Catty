/**
 *  Copyright (C) 2010-2020 The Catrobat Team
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


#import "BrickCellVariableData.h"
#import "BrickCell.h"
#import "Script.h"
#import "Brick.h"
#import "Util.h"
#import "BrickVariableProtocol.h"

NSString *const ACCESSABILITY_LABEL = @"VariableView_%@";


@implementation BrickCellVariableData

- (instancetype)initWithFrame:(CGRect)frame andBrickCell:(BrickCell *)brickCell andLineNumber:(NSInteger)line andParameterNumber:(NSInteger)parameter
{
    if(self = [super initWithFrame:frame]) {
        _brickCell = brickCell;
        _lineNumber = line;
        _parameterNumber = parameter;
        
        NSMutableArray *options = [[NSMutableArray alloc] init];
        [options addObject:kLocalizedNewElement];
        int currentOptionIndex = 0;
        if (!brickCell.isInserting) {
            int optionIndex = 1;
            if([brickCell.scriptOrBrick conformsToProtocol:@protocol(BrickVariableProtocol)]) {
                Brick<BrickVariableProtocol> *variableBrick = (Brick<BrickVariableProtocol>*)brickCell.scriptOrBrick;
                UserVariable *currentVariable = [variableBrick variableForLineNumber:line andParameterNumber:parameter];
                for(UserVariable *variable in [variableBrick.script.object.project.variables allVariablesForObject:variableBrick.script.object]) {
                    [options addObject:variable.name];
                    if([variable.name isEqualToString:currentVariable.name])
                        currentOptionIndex = optionIndex;
                    optionIndex++;
                }
                if (currentVariable && ![options containsObject:currentVariable.name]) {
                    [options addObject:currentVariable.name];
                    currentOptionIndex = optionIndex;
                }
            }

        }
        [self setValues:options];
        [self setCurrentValue:options[currentOptionIndex]];
        [self setDelegate:(id<iOSComboboxDelegate>)self];
        self.accessibilityLabel = [NSString stringWithFormat:ACCESSABILITY_LABEL, options[currentOptionIndex]];
    }
    return self;
}

- (void)comboboxDonePressed:(iOSCombobox *)combobox withValue:(NSString *)value
{
    [self.brickCell.dataDelegate updateBrickCellData:self withValue:value];
}

- (void)comboboxCancelPressed:(iOSCombobox *)combobox withValue:(NSString *)value
{
    [self.brickCell.dataDelegate enableUserInteractionAndResetHighlight];
}

- (void)comboboxOpened:(iOSCombobox *)combobox
{
    [self.brickCell.dataDelegate disableUserInteractionAndHighlight:self.brickCell withMarginBottom:kiOSComboboxTotalHeight];
    if (combobox.values.count == 1) {
        [self comboboxDonePressed: combobox withValue:combobox.values.firstObject];
    }
}

# pragma mark - User interaction
- (BOOL)isUserInteractionEnabled
{
    return self.brickCell.scriptOrBrick.isAnimatedInsertBrick == NO;
}

@end
