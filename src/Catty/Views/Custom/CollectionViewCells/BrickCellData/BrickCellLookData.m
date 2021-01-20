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


#import "BrickCellLookData.h"
#import "BrickCell.h"
#import "Script.h"
#import "Brick.h"
#import "BrickLookProtocol.h"
#import "RuntimeImageCache.h"
#import "Pocket_Code-Swift.h"

@implementation BrickCellLookData

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
            SpriteObject* object;
            int optionIndex = 1;
            if([brickCell.scriptOrBrick conformsToProtocol:@protocol(BrickLookProtocol)]) {
                Brick<BrickLookProtocol> *lookBrick = (Brick<BrickLookProtocol>*)brickCell.scriptOrBrick;
                Look *currentLook = [lookBrick lookForLineNumber:line andParameterNumber:parameter];
                
                NSArray *looks;
                
                if ([brickCell.scriptOrBrick isKindOfClass:[Script class]]){
                    Script<BrickLookProtocol> *lookScript = (Script<BrickLookProtocol>*)brickCell.scriptOrBrick;
                    object = lookScript.object;
                    looks = lookScript.object.lookList;
                }
                else {
                    object = lookBrick.script.object;
                    looks = lookBrick.script.object.lookList;
                }
                
                for(Look *look in looks) {
                    [options addObject:look.name];
                    if([look.name isEqualToString:currentLook.name]){
                        NSString *path = [look pathForScene:lookBrick.script.object.scene];
                        RuntimeImageCache *imageCache = [RuntimeImageCache sharedImageCache];
                        UIImage *image = [imageCache cachedImageForPath:path];
                        
                        if (!image) {
                            [imageCache loadImageFromDiskWithPath:path onCompletion:^(UIImage *image, NSString* path) {
                                dispatch_async(dispatch_get_main_queue(),^{
                                    if (! self.currentImage) {
                                        [self setCurrentImage:image];
                                    }
                                    [self setNeedsDisplay];
                                });
                            }];
                        } else if (! self.currentImage) {
                            [self setCurrentImage:image];
                        }
                        currentOptionIndex = optionIndex;
                    }
                    optionIndex++;
                }
            }
            
            self.object = object;
        }
        [self setValues:options];
        [self setCurrentValue:options[currentOptionIndex]];
        [self setDelegate:(id<iOSComboboxDelegate>)self];
        self.accessibilityLabel = [NSString stringWithFormat:@"%@_%@", UIDefines.lookPickerAccessibilityLabel, options[currentOptionIndex]];
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
}

# pragma mark - User interaction
- (BOOL)isUserInteractionEnabled
{
    return self.brickCell.scriptOrBrick.isAnimatedInsertBrick == NO;
}

@end
