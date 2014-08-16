/**
 *  Copyright (C) 2010-2014 The Catrobat Team
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

- (NSString*)brickTitle
{
    return kBrickCellSoundTitleSetVolumeTo;
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
