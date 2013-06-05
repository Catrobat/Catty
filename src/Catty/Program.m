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


#import "Program.h"
#import "Script.h"
#import <objc/runtime.h>
#import <Foundation/NSObjCRuntime.h>

@implementation Program

@synthesize objectList = _objectList;

#pragma mark - Custom getter and setter
- (NSMutableArray*)spritesList {
    if (_objectList == nil)
        _objectList = [[NSMutableArray alloc] init];
    return _objectList;
}


- (NSString*)debug {
    NSMutableString *ret = [[NSMutableString alloc] init];
    [ret appendFormat:@"\n----------------- PROGRAM --------------------\n"];
    /*[ret appendFormat:@"Application Build Name: %@\n", self.applicationBuildName];
    [ret appendFormat:@"Application Build Number: %@\n", self.applicationBuildNumber];
    [ret appendFormat:@"Application Name: %@\n", self.applicationName];
    [ret appendFormat:@"Application Version: %@\n", self.applicationVersion];
    [ret appendFormat:@"Catrobat Language Version: %@\n", self.catrobatLanguageVersion];
    [ret appendFormat:@"Date Time Upload: %@\n", self.dateTimeUpload];
    [ret appendFormat:@"Description: %@\n", self.description];
    [ret appendFormat:@"Device Name: %@\n", self.deviceName];
    [ret appendFormat:@"Media License: %@\n", self.mediaLicense];
    [ret appendFormat:@"Platform: %@\n", self.platform];
    [ret appendFormat:@"Platform Version: %@\n", self.platformVersion];
    [ret appendFormat:@"Program License: %@\n", self.programLicense];
    [ret appendFormat:@"Program Name: %@\n", self.programName];
    [ret appendFormat:@"Remix of: %@\n", self.remixOf];
    [ret appendFormat:@"Screen Height: %@\n", self.screenHeight];
    [ret appendFormat:@"Screen Width: %@\n", self.screenWidth];
    [ret appendFormat:@"Sprite List: %@\n", self.spriteList];
    [ret appendFormat:@"URL: %@\n", self.uRL];
    [ret appendFormat:@"User Handle: %@\n", self.userHandle];*/
    [ret appendFormat:@"----------------------------------------------\n"];
    
    return [NSString stringWithString:ret];
}



@end
