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


#import "BrickCellPhiroLightData.h"
#import "iOSCombobox.h"
#import "BrickCell.h"
#import "Script.h"
#import "Look.h"
#import "Brick.h"
#import "BrickPhiroLightProtocol.h"
#import "PhiroHelper.h"
#import "LanguageTranslationDefines.h"


@implementation BrickCellPhiroLightData

- (instancetype)initWithFrame:(CGRect)frame andBrickCell:(BrickCell*)brickCell andLineNumber:(NSInteger)line andParameterNumber:(NSInteger)parameter
{
    if(self = [super initWithFrame:frame]) {
        _brickCell = brickCell;
        _lineNumber = line;
        _parameterNumber = parameter;
        NSMutableArray *options = [[NSMutableArray alloc] init];
        int currentOptionIndex = 0;
        if([brickCell.scriptOrBrick conformsToProtocol:@protocol(BrickPhiroLightProtocol)]) {
            Brick<BrickPhiroLightProtocol> *rgbBrick = (Brick<BrickPhiroLightProtocol>*)brickCell.scriptOrBrick;
            NSString* currentLight = [rgbBrick lightForLineNumber:line andParameterNumber:parameter];
            switch([PhiroHelper stringToLight:currentLight]) {
                case LBoth:
                    currentOptionIndex = 0;
                    break;
                case LRight:
                    currentOptionIndex = 1;
                    break;
                case LLeft:
                    currentOptionIndex = 2;
                    break;
                    
                default:
                    [NSException raise:NSGenericException format:@"Unexpected FormatType."];
            }

        }
        [options addObject:[PhiroHelper lightToString:LBoth]];
        [options addObject:[PhiroHelper lightToString:LRight]];
        [options addObject:[PhiroHelper lightToString:LLeft]];
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
