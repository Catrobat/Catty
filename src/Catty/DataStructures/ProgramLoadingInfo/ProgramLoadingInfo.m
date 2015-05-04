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

#import "ProgramLoadingInfo.h"
#import "ProgramDefines.h"
#import "Util.h"
#import "Program.h"

@implementation ProgramLoadingInfo

+ (ProgramLoadingInfo*)programLoadingInfoForProgramWithName:(NSString*)programName programID:(NSString*)programID
{
    NSString *documentsDirectory = [Util applicationDocumentsDirectory];
    NSString *programsPath = [NSString stringWithFormat:@"%@/%@", documentsDirectory, kProgramsFolder];
    ProgramLoadingInfo *info = [[ProgramLoadingInfo alloc] init];
    NSString *programDirectoryName = [Program programDirectoryNameForProgramName:programName programID:programID];
    info.basePath = [NSString stringWithFormat:@"%@/%@/", programsPath, programDirectoryName];
    info.visibleName = programName;
    info.programID = programID;
    return info;
}

- (BOOL)isEqualToLoadingInfo:(ProgramLoadingInfo*)loadingInfo
{
    if ([self.visibleName isEqualToString:loadingInfo.visibleName]) {
        NSString *programID = self.programID;
        NSString *cmpProgramID = loadingInfo.programID;
        if ([programID isEqualToString:kNoProgramIDYetPlaceholder]) {
            programID = nil;
        }
        if ([cmpProgramID isEqualToString:kNoProgramIDYetPlaceholder]) {
            cmpProgramID = nil;
        }

        if (programID == nil && cmpProgramID == nil) {
            return YES;
        }
        if ([programID isEqualToString:cmpProgramID]) {
            return YES;
        }
    }
    return NO;
}

@end
