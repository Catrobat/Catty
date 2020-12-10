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

#import "BroadcastWaitBrick.h"
#import "Util.h"
#import "Pocket_Code-Swift.h"

@implementation BroadcastWaitBrick

- (kBrickCategoryType)category
{
    return kEventBrick;
}

- (id)initWithMessage:(NSString*)message
{
    self = [super init];
    
    if (self)
    {
        self.broadcastMessage = message;
    }
    return self;
}

- (void)setDefaultValuesForObject:(SpriteObject*)spriteObject
{
    if(spriteObject) {
        NSOrderedSet *messages = [Util allMessagesForProject:spriteObject.scene.project];
        if([messages count] > 0)
            self.broadcastMessage = [messages firstObject];
        else
            self.broadcastMessage = @"";
    }
    if(![self.broadcastMessage length])
        self.broadcastMessage = [NSString stringWithString:kLocalizedBroadcastMessage1];
}

- (void)setMessage:(NSString*)message forLineNumber:(NSInteger)lineNumber andParameterNumber:(NSInteger)paramNumber
{
    if(message)
        self.broadcastMessage = message;
}

- (NSString*)messageForLineNumber:(NSInteger)lineNumber andParameterNumber:(NSInteger)paramNumber
{
    return self.broadcastMessage;
}

#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"BroadcastWait (Msg: %@)", self.broadcastMessage];
}

#pragma mark - Resources
- (NSInteger)getRequiredResources
{
    return kNoResources;
}

@end
