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

#import "BroadcastWaitBrick.h"
#import "Script.h"
#import "Util.h"
#import "Pocket_Code-Swift.h"

@implementation BroadcastWaitBrick

- (NSString*)brickTitle
{
    return kLocalizedBroadcastAndWait;
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
        NSArray *messages = [Util allMessagesForProgram:spriteObject.program];
        if([messages count] > 0)
            self.broadcastMessage = [messages objectAtIndex:0];
        else
            self.broadcastMessage = nil;
    }
    if(!self.broadcastMessage)
        self.broadcastMessage = [NSString stringWithString:kLocalizedMessage1];
}

- (void)performBroadcastAndWait
{
    NSDebug(@"Performing: %@", self.description);
    [self.script.object.program broadcastAndWait:self.broadcastMessage senderScript:self.script];
    __weak BroadcastWaitBrick *weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // wait here on other queue!!
        [weakSelf.script.object.program waitingForBroadcastWithMessage:weakSelf.broadcastMessage];
        // now switch back to the main queue for executing the sequence!
        dispatch_async(dispatch_get_main_queue(), ^{
            // the script must continue here. upcoming actions are executed!!
            [[CBPlayerScheduler sharedInstance] runNextInstructionOfScript:weakSelf.script];
        });
    });
}

- (void)performBroadcastButDontWait
{
    // acts like a normal broadcast!
    [self.script.object.program broadcast:self.broadcastMessage senderScript:self.script];
}

- (void)setMessage:(NSString *)message forLineNumber:(NSInteger)lineNumber andParameterNumber:(NSInteger)paramNumber
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

@end
