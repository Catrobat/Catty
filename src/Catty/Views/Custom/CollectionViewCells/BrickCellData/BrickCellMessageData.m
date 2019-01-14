/**
 *  Copyright (C) 2010-2019 The Catrobat Team
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


#import "BrickCellMessageData.h"
#import "BrickCell.h"
#import "Script.h"
#import "Brick.h"
#import "BroadcastScript.h"

@implementation BrickCellMessageData

static NSMutableArray *messages = nil;

- (instancetype)initWithFrame:(CGRect)frame andBrickCell:(BrickCell*)brickCell andLineNumber:(NSInteger)line andParameterNumber:(NSInteger)parameter
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
            if ([brickCell.scriptOrBrick conformsToProtocol:@protocol(BrickMessageProtocol)]) {
                Brick<BrickMessageProtocol> *messageBrick = (Brick<BrickMessageProtocol>*)brickCell.scriptOrBrick;
                NSString *currentMessage = [messageBrick messageForLineNumber:line andParameterNumber:parameter];
                NSArray *messages;
                if ([brickCell.scriptOrBrick isKindOfClass:[Script class]]) {
                    messages = [Util allMessagesForProject:((Script*)brickCell.scriptOrBrick).object.project];
                } else {
                    messages = [Util allMessagesForProject:messageBrick.script.object.project];
                }
                for (NSString *message in messages) {
                    if (! [options containsObject:message]) {
                        [options addObject:message];
                        if ([message isEqualToString:currentMessage]) {
                            currentOptionIndex = optionIndex;
                        }
                        optionIndex++;
                    }
                }
                if (currentMessage && ![options containsObject:currentMessage]) {
                    [options addObject:currentMessage];
                    currentOptionIndex = optionIndex;
                }
            }

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
