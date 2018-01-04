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

#import "PlaySoundBrick.h"
#import "Sound.h"
#import "CBMutableCopyContext.h"

@implementation PlaySoundBrick

- (NSString*)brickTitle
{
    return [kLocalizedPlaySound stringByAppendingString:@"\n%@"];
}

#pragma mark - Copy
- (id)mutableCopyWithContext:(CBMutableCopyContext*)context
{
    if (! context) NSError(@"%@ must not be nil!", [CBMutableCopyContext class]);
    PlaySoundBrick *brick = [[self class] new];
    brick.sound = self.sound;
    [context updateReference:self WithReference:brick];
    
    return brick;
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

- (void)setSound:(Sound *)sound forLineNumber:(NSInteger)lineNumber andParameterNumber:(NSInteger)paramNumber
{
    if (sound) {
        self.sound = sound;
    }
}

- (Sound*)soundForLineNumber:(NSInteger)lineNumber andParameterNumber:(NSInteger)paramNumber
{
    return self.sound;
}

#pragma mark - Default values
- (void)setDefaultValuesForObject:(SpriteObject*)spriteObject
{
    if(spriteObject) {
        NSArray *sounds = spriteObject.soundList;
        if([sounds count] > 0)
            self.sound = [sounds objectAtIndex:0];
        else
            self.sound = nil;
    }
}

#pragma mark - Resources
- (NSInteger)getRequiredResources
{
    return kNoResources;
}

@end
