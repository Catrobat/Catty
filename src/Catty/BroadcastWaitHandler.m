/**
 *  Copyright (C) 2010-2013 The Catrobat Team
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

#import "BroadcastWaitHandler.h"
#import "SpriteObject.h"

@interface BroadcastWaitHandler()
@property (strong, nonatomic) NSMutableDictionary *spritesForMessages; // key: (NSString*)msg   value: (NSArray*)sprites
@property (strong, nonatomic) NSLock *lock;
@end


@implementation BroadcastWaitHandler



-(NSMutableDictionary *)spritesForMessages
{
    if (!_spritesForMessages)
        _spritesForMessages = [[NSMutableDictionary alloc]init];
    return _spritesForMessages;
}


-(void)registerSprite:(SpriteObject *)sprite forMessage:(NSString *)message
{
    [self.lock lock];
    NSArray *sprites = [self.spritesForMessages objectForKey:message];
    [self.spritesForMessages removeObjectForKey:message];
    if (sprites == nil) {
        sprites = [NSArray arrayWithObject:sprite];
    } else {
        sprites = [sprites arrayByAddingObject:sprite];
    }
    [self.spritesForMessages setObject:sprites forKey:message];
    [self.lock unlock];
}

-(void)dealloc
{
    
}
-(void)performBroadcastWaitForMessage:(NSString*)message
{
    
    NSOperationQueue* queue = [[NSOperationQueue alloc] init];
    queue.name = [NSString stringWithFormat:@"at.tugraz.ist.%@", message];

    NSArray *sprites = [self.spritesForMessages objectForKey:message];
    for (SpriteObject *sprite in sprites) {

        if ([sprite isKindOfClass:[SpriteObject class]] == NO) {
            NSError(@"sprite is not a SpriteObject...abort()");
        }
        else {

            [queue addOperationWithBlock:^{
                 [sprite performBroadcastWaitScriptWithMessage:message];
            }];
        }
        
    }
    
    [queue waitUntilAllOperationsAreFinished];
}

@end
