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

#import "VibrationBrick.h"
#import "Script.h"
#import "Formula.h"
#import <AudioToolbox/AudioToolbox.h>

@implementation VibrationBrick

- (Formula*)formulaForLineNumber:(NSInteger)lineNumber andParameterNumber:(NSInteger)paramNumber
{
    return self.durationInSeconds;
}

- (void)setFormula:(Formula*)formula forLineNumber:(NSInteger)lineNumber andParameterNumber:(NSInteger)paramNumber
{
    self.durationInSeconds = formula;
}

- (void)setDefaultValues
{
    self.durationInSeconds = [[Formula alloc] initWithZero];
}

- (NSString*)brickTitle
{
    return kLocalizedVibrateNSeconds;
}

- (SKAction*)action
{
    return [SKAction runBlock:[self actionBlock]];
}

- (dispatch_block_t)actionBlock
{
    return ^{
        NSDebug(@"Performing: %@", self.description);
        dispatch_queue_t serialQueue = dispatch_queue_create("org.catrobat.vibrate.queue", DISPATCH_QUEUE_SERIAL);
        dispatch_async(serialQueue, ^{
            double durationInSeconds = [self.durationInSeconds interpretDoubleForSprite:self.script.object];
            for (int i = 1; i < 2*durationInSeconds; i++) {
                dispatch_async(dispatch_get_main_queue(), ^(void){
                    [self performSelector:@selector(vibe:) withObject:self afterDelay:i *.5f];
                });
            }
        });
    };
}

- (void)vibe:(id)sender {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"VibrationBrick (%f Seconds)", [self.durationInSeconds interpretDoubleForSprite:self.script.object]];
}

@end
