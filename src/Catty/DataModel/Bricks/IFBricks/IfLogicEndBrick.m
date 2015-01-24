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

#import "IfLogicEndBrick.h"
#import "IfLogicBeginBrick.h"
#import "IfLogicElseBrick.h"
#import "Util.h"

@implementation IfLogicEndBrick

- (BOOL)isSelectableForObject
{
    return NO;
}

- (NSString*)brickTitle
{
    return kLocalizedIfEnd;
}

- (void)performFromScript:(Script*)script
{
    
}

#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"If Logic End Brick"];
}

- (BOOL)isEqualToBrick:(Brick*)brick
{
    if(![Util isEqual:self.ifBeginBrick.brickTitle toObject:((IfLogicEndBrick*)brick).ifBeginBrick.brickTitle])
        return NO;
    if(![Util isEqual:self.ifElseBrick.brickTitle toObject:((IfLogicEndBrick*)brick).ifElseBrick.brickTitle])
        return NO;
    return YES;
}

@end
