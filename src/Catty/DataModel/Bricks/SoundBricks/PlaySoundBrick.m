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

#import "PlaySoundBrick.h"
#import "Sound.h"
#import "AudioManager.h"
#import "Script.h"

@implementation PlaySoundBrick

- (NSString*)brickTitle
{
    return kLocalizedPlaySound;
}

- (SKAction*)action
{
    NSDebug(@"Adding: %@", self.description);
    NSDebug(@"Test: %@", [self.script.object description]);
    return [SKAction runBlock:^{
        NSDebug(@"Performing: %@", self.description);
        [[AudioManager sharedAudioManager] playSoundWithFileName:self.sound.fileName andKey:self.script.object.name atFilePath:[NSString stringWithFormat:@"%@%@", [self.script.object projectPath], kProgramSoundsDirName]];
    }];
}

#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"PlaySound (File Name: %@)", self.sound.fileName];
}

- (BOOL)isEqualToBrick:(Brick*)brick
{
    if(![self.sound isEqualToSound:((PlaySoundBrick*)brick).sound])
        return NO;
    return YES;
}

@end
