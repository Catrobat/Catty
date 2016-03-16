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


#import "BrickCellPhiroToneData.h"
#import "iOSCombobox.h"
#import "BrickCell.h"
#import "Script.h"
#import "Look.h"
#import "Brick.h"
#import "BrickPhiroToneProtocol.h"
#import "LanguageTranslationDefines.h"
#import "PhiroHelper.h"


@implementation BrickCellPhiroToneData

- (instancetype)initWithFrame:(CGRect)frame andBrickCell:(BrickCell*)brickCell andLineNumber:(NSInteger)line andParameterNumber:(NSInteger)parameter
{
    if(self = [super initWithFrame:frame]) {
        _brickCell = brickCell;
        _lineNumber = line;
        _parameterNumber = parameter;
        NSMutableArray *options = [[NSMutableArray alloc] init];
        int currentOptionIndex = 0;
        if([brickCell.scriptOrBrick conformsToProtocol:@protocol(BrickPhiroToneProtocol)]) {
            Brick<BrickPhiroToneProtocol> *toneBrick = (Brick<BrickPhiroToneProtocol>*)brickCell.scriptOrBrick;
            NSString* currentLight = [toneBrick toneForLineNumber:line andParameterNumber:parameter];
            Tone current = [PhiroHelper stringToTone:currentLight];
            currentOptionIndex = current - 1;

        }
        [options addObject:[PhiroHelper toneToString:DO]];
        [options addObject:[PhiroHelper toneToString:RE]];
        [options addObject:[PhiroHelper toneToString:MI]];
        [options addObject:[PhiroHelper toneToString:FA]];
        [options addObject:[PhiroHelper toneToString:SO]];
        [options addObject:[PhiroHelper toneToString:LA]];
        [options addObject:[PhiroHelper toneToString:TI]];
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
