/**
 *  Copyright (C) 2010-2018 The Catrobat Team
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
#import "PhiroHelper.h"

@implementation PhiroPlayToneBrick
- (NSString*)brickTitle
{
    return [[[[kLocalizedPhiroPlayTone stringByAppendingString:@"%@\n"] stringByAppendingString:kLocalizedPhiroPlayDuration] stringByAppendingString:@"%@ "] stringByAppendingString:kLocalizedPhiroSecondsToPlay];
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

- (NSArray*)getFormulas
{
    return @[self.durationFormula];
}

- (BOOL)allowsStringFormula
{
    return NO;
}

- (NSString*)toneForLineNumber:(NSInteger)lineNumber andParameterNumber:(NSInteger)paramNumber
{
    return self.tone;
}

- (void)setTone:(NSString*)tone forLineNumber:(NSInteger)lineNumber andParameterNumber:(NSInteger)paramNumber
{
    self.tone = tone;
}

#pragma mark - Default values
- (void)setDefaultValuesForObject:(SpriteObject*)spriteObject
{
    self.tone = [PhiroHelper toneToString:DO];
    self.durationFormula = [[Formula alloc] initWithZero];
}

-(Tone)phiroTone
{
    return [PhiroHelper stringToTone:self.tone];
};

#pragma mark - Resources
- (NSInteger)getRequiredResources
{
    return kBluetoothPhiro|[self.durationFormula getRequiredResources];
}
@end
