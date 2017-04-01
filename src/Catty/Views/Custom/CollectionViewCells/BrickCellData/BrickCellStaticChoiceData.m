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


#import "BrickCellStaticChoiceData.h"
#import "BrickCell.h"
#import "Brick.h"
#import "BrickStaticChoiceProtocol.h"


@implementation BrickCellStaticChoiceData

static NSMutableArray *messages = nil;

- (instancetype)initWithFrame:(CGRect)frame andBrickCell:(BrickCell*)brickCell andLineNumber:(NSInteger)line andParameterNumber:(NSInteger)parameter
{
    if(self = [super initWithFrame:frame]) {
        _brickCell = brickCell;
        _lineNumber = line;
        _parameterNumber = parameter;
        
        NSMutableArray *options = [[NSMutableArray alloc] init];
        int currentOptionIndex = 0;
        int optionIndex = 0;
        if([brickCell.scriptOrBrick conformsToProtocol:@protocol(BrickStaticChoiceProtocol)]) {
            Brick<BrickStaticChoiceProtocol> *choiceBrick = (Brick<BrickStaticChoiceProtocol>*)brickCell.scriptOrBrick;
            NSString  *currentChoice = [choiceBrick choiceForLineNumber:line andParameterNumber:parameter];
            for(NSString *choice in [choiceBrick possibleChoicesForLineNumber:line andParameterNumber:parameter]) {
                [options addObject:choice];
                if([choice isEqualToString:currentChoice])
                    currentOptionIndex = optionIndex;
                optionIndex++;
            }
            if (currentChoice && ![options containsObject:currentChoice]) {
                [options addObject:currentChoice];
                currentOptionIndex = optionIndex;
            }
        }else {
            [options addObject:kLocalizedError];
        }
        
        [self setValues:options];
        [self setCurrentValue:options[currentOptionIndex]];
        [self setDelegate:(id<iOSComboboxDelegate>)self];
    }
    return self;
}

- (void)comboboxDonePressed:(iOSCombobox *)combobox withValue:(NSString *)value
{
    [self.brickCell.dataDelegate updateBrickCellData:self withValue:value];
}

- (void)comboboxOpened:(iOSCombobox *)combobox
{
    [self.brickCell.dataDelegate disableUserInteractionAndHighlight:self.brickCell withMarginBottom:kiOSComboboxTotalHeight];
}

# pragma mark - User interaction
- (BOOL)isUserInteractionEnabled
{
    return self.brickCell.scriptOrBrick.isAnimatedInsertBrick == NO;
}

@end
