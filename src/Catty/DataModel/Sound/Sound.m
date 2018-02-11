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

#import "Sound.h"
#import "CBMutableCopyContext.h"

@implementation Sound

- (instancetype)initWithName:(NSString *)name fileName:(NSString *)fileName {
    self = [super init];
    if (self) {
        self.name = name;
        self.fileName = fileName;
    }
    return self;
}

- (NSString*)description
{
    return [NSString stringWithFormat:@"Sound: %@\r", self.name];
}

- (BOOL)isEqualToSound:(Sound*)sound
{
    if([self.name isEqualToString:sound.name] && [self.fileName isEqualToString:sound.fileName])
        return YES;
    return NO;
}

#pragma mark - Copy
- (id)mutableCopyWithContext:(CBMutableCopyContext*)context;
{
    if(!context) NSError(@"%@ must not be nil!", [CBMutableCopyContext class]);
    
    Sound *copiedSound = [[Sound alloc] init];
    copiedSound.fileName = [NSString stringWithString:self.fileName];
    copiedSound.name = [NSString stringWithString:self.name];
    copiedSound.playing = NO;
    
    [context updateReference:self WithReference:copiedSound];
    return copiedSound;
}



@end
