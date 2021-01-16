/**
 *  Copyright (C) 2010-2021 The Catrobat Team
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

#import "ProjectLoadingInfo.h"
#import "ProjectDefines.h"
#import "Util.h"

@implementation ProjectLoadingInfo

+ (ProjectLoadingInfo*)projectLoadingInfoForProjectWithName:(NSString*)projectName projectID:(NSString*)projectID
{
    NSString *documentsDirectory = [Util applicationDocumentsDirectory];
    NSString *projectsPath = [NSString stringWithFormat:@"%@/%@", documentsDirectory, kProjectsFolder];
    ProjectLoadingInfo *info = [[ProjectLoadingInfo alloc] init];
    NSString *projectDirectoryName = [Project projectDirectoryNameForProjectName:projectName projectID:projectID];
    info.basePath = [NSString stringWithFormat:@"%@/%@/", projectsPath, projectDirectoryName];
    info.visibleName = [Util enableBlockedCharactersForString:projectName];
    info.projectID = projectID;
    return info;
}

- (BOOL)isEqualToLoadingInfo:(ProjectLoadingInfo*)loadingInfo
{
    if ([self.visibleName isEqualToString:loadingInfo.visibleName]) {
        NSString *projectID = self.projectID;
        NSString *cmpProjectID = loadingInfo.projectID;
        if ([projectID isEqualToString:kNoProjectIDYetPlaceholder]) {
            projectID = nil;
        }
        if ([cmpProjectID isEqualToString:kNoProjectIDYetPlaceholder]) {
            cmpProjectID = nil;
        }

        if (projectID == nil && cmpProjectID == nil) {
            return YES;
        }
        if ([projectID isEqualToString:cmpProjectID]) {
            return YES;
        }
    }
    return NO;
}

@end
