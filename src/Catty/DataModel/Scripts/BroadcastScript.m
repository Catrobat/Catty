/**
 *  Copyright (C) 2010-2016 The Catrobat Team
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

#import "BroadcastScript.h"
#import "SpriteObject.h"
#import "Util.h"

@implementation BroadcastScript

- (NSString*)brickTitle
{
    return kLocalizedWhenIReceive;
}

- (void)setDefaultValuesForObject:(SpriteObject*)spriteObject
{
    if(spriteObject) {
        NSArray *messages = [Util allMessagesForProgram:spriteObject.program];
        if([messages count] > 0)
            self.receivedMessage = [messages objectAtIndex:0];
        else
            self.receivedMessage = nil;
    }
    if(!self.receivedMessage)
        self.receivedMessage = [NSString stringWithString:kLocalizedMessage1];
}

- (void)setMessage:(NSString*)message forLineNumber:(NSInteger)lineNumber andParameterNumber:(NSInteger)paramNumber
{
    if (message)
        self.receivedMessage = message;
}

- (NSString*)messageForLineNumber:(NSInteger)lineNumber andParameterNumber:(NSInteger)paramNumber
{
    return self.receivedMessage;
}

@end
