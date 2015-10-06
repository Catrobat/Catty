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

#import "PhiroPlayToneBrick.h"
#import "Script.h"

@implementation PhiroPlayToneBrick
- (NSString*)brickTitle
{
    return kLocalizedPhiroPlayTone;
}

- (SKAction*)action
{
    return [SKAction runBlock:[self actionBlock]];
}

- (dispatch_block_t)actionBlock
{
    return ^{
        
//        CGFloat durationInterpretation = [self.durationFormula interpretDoubleForSprite:self.script.object];
        
//        Phiro phiro = btService.getDevice(BluetoothDevice.PHIRO);
//        if (phiro == null) {
//            return;
//        }
        
        switch (self.tone) {
            case DO:
//                phiro.playTone(262, durationInterpretation);
                break;
            case RE:
//                phiro.playTone(294, durationInterpretation);
                break;
            case MI:
//                phiro.playTone(330, durationInterpretation);
                break;
            case FA:
//                phiro.playTone(349, durationInterpretation);
                break;
            case SO:
//                phiro.playTone(392, durationInterpretation);
                break;
            case LA:
//                phiro.playTone(440, durationInterpretation);
                break;
            case TI:
//                phiro.playTone(494, durationInterpretation);
                break;
        }
    };
}



#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"Play Phiro Tone (Tone: Duration: %f)",[self.durationFormula interpretDoubleForSprite:self.script.object]];
}

- (BOOL)isEqualToBrick:(Brick*)brick
{
    if (![self.durationFormula isEqualToFormula:((PhiroPlayToneBrick*)brick).durationFormula]) {
        return NO;
    }
    return YES;
}
- (Formula*)formulaForLineNumber:(NSInteger)lineNumber andParameterNumber:(NSInteger)paramNumber
{
    return self.durationFormula;
}

- (void)setFormula:(Formula*)formula forLineNumber:(NSInteger)lineNumber andParameterNumber:(NSInteger)paramNumber
{
    self.durationFormula = formula;
}
- (Tone)toneForLineNumber:(NSInteger)lineNumber andParameterNumber:(NSInteger)paramNumber
{
    return self.tone;
}

- (void)setTone:(Tone)tone forLineNumber:(NSInteger)lineNumber andParameterNumber:(NSInteger)paramNumber
{
    self.tone = tone;
}

#pragma mark - Default values
- (void)setDefaultValuesForObject:(SpriteObject*)spriteObject
{

    self.durationFormula = [[Formula alloc] initWithZero];
}
@end
