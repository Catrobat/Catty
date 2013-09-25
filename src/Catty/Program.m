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
#import "VariablesContainer.h"
#import "Util.h"
#import "OrderedMapTable.h"
#import "AppDefines.h"
#import "SpriteObject.h"

@implementation Program

@synthesize objectList = _objectList;

+ (Program*)createWithProgramName:(NSString*)programName
{
  Program* program = [[Program alloc] init];
  program.header = [[Header alloc] init];

  // FIXME: check all constants for this default header properties...
  // maybe we wanna outsource that later to another factory method in Header class
  {
    program.header.applicationBuildName = nil;
    program.header.applicationBuildNumber = @"0";
    program.header.applicationName = [Util getProjectName];
    program.header.applicationVersion = [Util getProjectVersion];
    program.header.catrobatLanguageVersion = kCatrobatLanguageVersion;
    program.header.dateTimeUpload = nil;
    program.header.description = @"XStream kompatibel";
    program.header.deviceName = [Util getDeviceName];
    program.header.mediaLicense = nil;
    program.header.platform = [Util getPlatformName];
    program.header.platformVersion = [Util getPlatformVersion];
    program.header.programLicense = nil;
    program.header.programName = programName;
    program.header.remixOf = nil;
    program.header.screenHeight = @([Util getScreenHeight]);
    program.header.screenWidth = @([Util getScreenWidth]);
    program.header.url = nil;
    program.header.userHandle = nil;
    program.header.programScreenshotManuallyTaken = (YES ? @"true" : @"false");
    program.header.tags = nil;
  }
  program.objectList = [NSMutableArray array];
  program.variables = [[VariablesContainer alloc] init];
  program.variables.objectVariableList = [OrderedMapTable weakToStrongObjectsMapTable];
  program.variables.programVariableList = [NSMutableArray array];
  return program;
}

#pragma mark - Custom getter and setter
- (NSMutableArray*)spritesList
{
    if (_objectList == nil)
        _objectList = [[NSMutableArray alloc] init];
    return _objectList;
}

- (void)setObjectList:(NSMutableArray*)objectList
{
    for (id object in objectList) {
        if ([object isKindOfClass:[SpriteObject class]])
          ((SpriteObject*) object).program = self;
    }
    _objectList = objectList;
}

- (NSString*)description
{
    NSMutableString *ret = [[NSMutableString alloc] init];
    [ret appendFormat:@"\n----------------- PROGRAM --------------------\n"];
    [ret appendFormat:@"Application Build Name: %@\n", self.header.applicationBuildName];
    [ret appendFormat:@"Application Build Number: %@\n", self.header.applicationBuildNumber];
    [ret appendFormat:@"Application Name: %@\n", self.header.applicationName];
    [ret appendFormat:@"Application Version: %@\n", self.header.applicationVersion];
    [ret appendFormat:@"Catrobat Language Version: %@\n", self.header.catrobatLanguageVersion];
    [ret appendFormat:@"Date Time Upload: %@\n", self.header.dateTimeUpload];
    [ret appendFormat:@"Description: %@\n", self.header.description];
    [ret appendFormat:@"Device Name: %@\n", self.header.deviceName];
    [ret appendFormat:@"Media License: %@\n", self.header.mediaLicense];
    [ret appendFormat:@"Platform: %@\n", self.header.platform];
    [ret appendFormat:@"Platform Version: %@\n", self.header.platformVersion];
    [ret appendFormat:@"Program License: %@\n", self.header.programLicense];
    [ret appendFormat:@"Program Name: %@\n", self.header.programName];
    [ret appendFormat:@"Remix of: %@\n", self.header.remixOf];
    [ret appendFormat:@"Screen Height: %@\n", self.header.screenHeight];
    [ret appendFormat:@"Screen Width: %@\n", self.header.screenWidth];
    [ret appendFormat:@"Sprite List: %@\n", self.objectList];
    [ret appendFormat:@"URL: %@\n", self.header.url];
    [ret appendFormat:@"User Handle: %@\n", self.header.userHandle];
    [ret appendFormat:@"----------------------------------------------\n"];
    
    return [NSString stringWithString:ret];
}

-(void)dealloc
{
    NSDebug(@"Dealloc Program");
}


@end
