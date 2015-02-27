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

#import "BroadcastBrick.h"
#import "Script.h"

@implementation BroadcastBrick

- (NSString*)brickTitle
{
    return kLocalizedBroadcast;
}

- (id)initWithMessage:(NSString *)message
{
    self = [super init];
    if (self)
    {
        self.broadcastMessage = message;
    }
    return self;
}

- (SKAction*)action
{
    __weak BroadcastBrick* weakSelf = self;
    return [SKAction runBlock:^{
        NSDebug(@"Performing: %@", [weakSelf description]);
        [weakSelf.script.object.program broadcast:weakSelf.broadcastMessage senderScript:weakSelf.script];
    }];
}

#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"Broadcast (Msg: %@)", self.broadcastMessage];
}

@end
