/**
 *  Copyright (C) 2010-2017 The Catrobat Team
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

#import "PreviousLookBrick.h"
#import "ObjectTableViewController.h"
#import "Look.h"
#import "Script.h"
#import "Pocket_Code-Swift.h"

@implementation PreviousLookBrick

- (NSString*)brickTitle
{
    NSEnumerator *vcStack = [[[[[UIApplication sharedApplication] keyWindow] rootViewController] childViewControllers] reverseObjectEnumerator];
    ObjectTableViewController *programVC;
    
    for (UIViewController *vc in vcStack) {
        if ([vc isKindOfClass:[ObjectTableViewController class]]) {
            programVC = (ObjectTableViewController*)vc;
            break;
        }
    }

    if (programVC != nil) {
        BOOL isBackground = [[programVC object] isBackground];
        return isBackground ? kLocalizedPreviousBackground : kLocalizedPreviousLook;
    }
    else {
        return [self.script.object isBackground] ? kLocalizedPreviousBackground : kLocalizedPreviousLook;
    }
}

- (NSString*)pathForLook:(Look*)look
{
    return [NSString stringWithFormat:@"%@%@/%@", [self.script.object projectPath], kProgramImagesDirName, look.fileName];
}

#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"Previouslookbrick"];
}

#pragma mark - Resources
- (NSInteger)getRequiredResources
{
    return kNoResources;
}
@end
