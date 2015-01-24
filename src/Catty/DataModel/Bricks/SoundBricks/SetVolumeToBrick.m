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


#import "SetVolumeToBrick.h"

#import "Formula.h"
#import "AudioManager.h"

@implementation SetVolumeToBrick

- (Formula*)getFormulaForLineNumber:(NSInteger)lineNumber AndParameterNumber:(NSInteger)paramNumber
{
    return self.volume;
}

- (void)setFormula:(Formula*)formula ForLineNumber:(NSInteger)lineNumber AndParameterNumber:(NSInteger)paramNumber
{
    self.volume = formula;
}

- (NSString*)brickTitle
{
    return kLocalizedSetVolumeTo;
}

- (SKAction*)action
{
    NSDebug(@"Adding: %@", self.description);
    
    return [SKAction runBlock:^{
        NSDebug(@"Performing: %@", self.description);
        double volume = [self.volume interpretDoubleForSprite:self.object];
        [[AudioManager sharedAudioManager] setVolumeToPercent:(CGFloat)volume forKey:self.object.name];
        
    }];
}


#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"Set Volume to: %f%%)", [self.volume interpretDoubleForSprite:self.object]];
}


@end
