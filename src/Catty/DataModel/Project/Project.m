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

#import "Project.h"
#import "Util.h"
#import "CBFileManager.h"
#import "Parser.h"
#import "Script.h"
#import "Brick.h"
#import "CatrobatLanguageDefines.h"
#import "CBXMLParser.h"
#import "CBXMLSerializer.h"
#import "CBMutableCopyContext.h"
#import "Pocket_Code-Swift.h"

@implementation Project

@synthesize scene = _scene;

- (instancetype)init
{
    if (self = [super init])
    {
        _allBroadcastMessages = [[NSMutableOrderedSet alloc] init];
    }
    return self;
}

#pragma mark - Custom getter and setter
- (UserDataContainer*)userData
{
    // lazy instantiation
    if (! _userData)
        _userData = [[UserDataContainer alloc] init];
    return _userData;
}

- (NSString*)projectPath
{
    return [Project projectPathForProjectWithName:[Util replaceBlockedCharactersForString:self.header.programName] projectID:self.header.programID];
}

- (void)removeFromDisk
{
    [Project removeProjectFromDiskWithProjectName:[Util enableBlockedCharactersForString:self.header.programName] projectID:self.header.programID];
}

- (void)saveToDiskWithNotification:(BOOL)notify
{
    [self saveToDiskWithNotification:notify andCompletion:nil];
}

- (void)saveToDiskWithNotification:(BOOL)notify andCompletion:(void (^)(void))completion
{
    CBFileManager *fileManager = [CBFileManager sharedManager];
    dispatch_queue_t saveToDiskQ = dispatch_queue_create("save to disk", NULL);
    dispatch_async(saveToDiskQ, ^{
        // show saved view bezel
        if (notify) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
                [notificationCenter postNotificationName:kShowSavedViewNotification object:self];
            });
        }
        // TODO: find correct serializer class dynamically
        NSString *xmlPath = [NSString stringWithFormat:@"%@%@", [self projectPath], kProjectCodeFileName];
        id<CBSerializerProtocol> serializer = [[CBXMLSerializer alloc] initWithPath:xmlPath fileManager:fileManager];
        [serializer serializeProject:self];
        
        if (completion) {
            completion();
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:kHideLoadingViewNotification object:self];
            [[NSNotificationCenter defaultCenter] postNotificationName:kReadyToUpload object:self];
        });
    });
}

- (void)changeProjectOrientation
{
    NSNumber *tmpScreenWidth = self.header.screenWidth;
    self.header.screenWidth = self.header.screenHeight;
    self.header.screenHeight = tmpScreenWidth;
    
    if (self.header.landscapeMode) {
        self.header.landscapeMode = false;
    } else {
        self.header.landscapeMode = true;
    }
}

- (BOOL)isLastUsedProject
{
    return [Project isLastUsedProject:self.header.programName projectID:self.header.programID];
}

- (void)setAsLastUsedProject
{
    [Project setLastUsedProject:self];
}

- (void)renameToProjectName:(NSString*)projectName andShowSaveNotification:(BOOL)showSaveNotification
{
    return [self renameToProjectName:projectName andProjectId:self.header.programID andShowSaveNotification:showSaveNotification];
}

- (void)renameToProjectName:(NSString*)projectName andProjectId:(NSString*)projectId andShowSaveNotification:(BOOL)showSaveNotification
{
    BOOL updateName = ![self.header.programName isEqualToString:projectName];
    
    if (!updateName && ((self.header.programID == nil && projectId == nil) || [self.header.programID isEqualToString:projectId])) {
        return;
    }
    
    BOOL isLastProject = [self isLastUsedProject];
    NSString *oldPath = [self projectPath];
    
    self.header.programID = projectId;
    
    if (updateName) {
        self.header.programName = [Util uniqueName:projectName existingNames:[[self class] allProjectNames]];
    }
    
    NSString *newPath = [self projectPath];
    
    [[CBFileManager sharedManager] moveExistingDirectoryAtPath:oldPath toPath:newPath];
    if (isLastProject) {
        [Util setLastProjectWithName:self.header.programName projectID:projectId];
    }
    [self saveToDiskWithNotification:showSaveNotification];
}

- (NSArray<SpriteObject*>*)allObjects
{
    return self.scene.objects;
}

- (void)setDescription:(NSString*)description
{
    self.header.programDescription = description;
}

- (void)removeReferences
{
    [self.scene.objects makeObjectsPerformSelector:@selector(removeReferences)];
}

- (BOOL)isEqualToProject:(Project*)project
{
    if (! [self.header isEqualToHeader:project.header])
        return NO;
    if (! [self.userData isEqual:project.userData])
        return NO;
    if (![self.scene isEqual:project.scene])
        return NO;
    return YES;
}

- (NSInteger)getRequiredResources
{
    return [self.scene getRequiredResources];
}
#pragma mark - helpers

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
    [ret appendFormat:@"Screen Mode: %@\n", self.header.screenMode];
    [ret appendFormat:@"Scene: %@\n", self.scene];
    [ret appendFormat:@"URL: %@\n", self.header.url];
    [ret appendFormat:@"User Handle: %@\n", self.header.userHandle];
    [ret appendFormat:@"Variables: %@\n", self.userData];
    [ret appendFormat:@"------------------------------------------------\n"];
    return [ret copy];
}

- (void)updateReferences
{
    NSArray <SpriteObject*> *allObjects = [[NSMutableArray alloc] initWithArray: self.allObjects];
    for (SpriteObject *sprite in allObjects) {
        sprite.scene.project = self;
        for (Script *script in sprite.scriptList) {
            script.object = sprite;
            for (Brick *brick in script.brickList) {
                brick.script = script;
            }
        }
    }
}

#pragma mark - Manager

+ (NSString*)projectDirectoryNameForProjectName:(NSString*)projectName projectID:(NSString*)projectID
{
    return [NSString stringWithFormat:@"%@%@%@", projectName, kProjectIDSeparator,
            (projectID ? projectID : kNoProjectIDYetPlaceholder)];
}

+ (nullable ProjectLoadingInfo*)projectLoadingInfoForProjectDirectoryName:(NSString*)directoryName
{
    CBAssert(directoryName);
    NSArray *directoryNameParts = [directoryName componentsSeparatedByString:kProjectIDSeparator];
    if (directoryNameParts.count < 2) {
        return nil;
    }
    NSString *projectID = (NSString*)directoryNameParts.lastObject;
    NSString *projectName = [directoryName substringToIndex:directoryName.length - projectID.length - 1];
    return [ProjectLoadingInfo projectLoadingInfoForProjectWithName:projectName projectID:projectID];
}

+ (nullable NSString *)projectNameForProjectID:(NSString*)projectID
{
    if ((! projectID) || (! [projectID length])) {
        return nil;
    }
    NSArray *allProjectLoadingInfos = [[self class] allProjectLoadingInfos];
    for (ProjectLoadingInfo *projectLoadingInfo in allProjectLoadingInfos) {
        if ([projectLoadingInfo.projectID isEqualToString:projectID]) {
            return projectLoadingInfo.visibleName;
        }
    }
    return nil;
}

// returns true if either same projectID and/or same projectName already exists
+ (BOOL)projectExistsWithProjectName:(NSString*)projectName projectID:(NSString*)projectID
{
    NSArray *allProjectLoadingInfos = [[self class] allProjectLoadingInfos];

    // check if project with same ID already exists
    if (projectID && [projectID length]) {
        if ([[self class] projectExistsWithProjectID:projectID]) {
            return YES;
        }
    }

    // no projectID match => check if project with same name already exists
    for (ProjectLoadingInfo *projectLoadingInfo in allProjectLoadingInfos) {
        if ([projectName isEqualToString:projectLoadingInfo.visibleName]) {
            return YES;
        }
    }
    return NO;
}

// returns true if either same projectID and/or same projectName already exists
+ (BOOL)projectExistsWithProjectID:(NSString*)projectID
{
    NSArray *allProjectLoadingInfos = [[self class] allProjectLoadingInfos];
    for (ProjectLoadingInfo *projectLoadingInfo in allProjectLoadingInfos) {
        if ([projectID isEqualToString:projectLoadingInfo.projectID]) {
            return YES;
        }
    }
    return NO;
}

+ (nullable instancetype)projectWithLoadingInfo:(ProjectLoadingInfo*)loadingInfo
{
    NSDebug(@"Try to load project '%@'", loadingInfo.visibleName);
    NSDebug(@"Path: %@", loadingInfo.basePath);
    NSString *xmlPath = [NSString stringWithFormat:@"%@%@", loadingInfo.basePath, kProjectCodeFileName];
    NSDebug(@"XML-Path: %@", xmlPath);

    //    //######### FIXME remove that later!! {
    //        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    //        xmlPath = [bundle pathForResource:@"ValidProjectAllBricks093" ofType:@"xml"];
    //    // }

    Project *project = nil;
    CGFloat languageVersion = [Util detectCBLanguageVersionFromXMLWithPath:xmlPath];

    if (languageVersion == kCatrobatInvalidVersion) {
        NSDebug(@"Invalid catrobat language version!");
        [[NSNotificationCenter defaultCenter] postNotificationName:NotificationName.projectInvalidVersion object:loadingInfo];
        return nil;
    }

    // detect right parser for correct catrobat language version
    CBXMLParser *catrobatParser = [[CBXMLParser alloc] initWithPath:xmlPath];
    if (! [catrobatParser isSupportedLanguageVersion:languageVersion]) {
        Parser *parser = [[Parser alloc] init];
        project = [parser generateObjectForProjectWithPath:xmlPath];
    } else {
        project = [catrobatParser parseAndCreateProject];
    }
    project.header.programName = loadingInfo.visibleName;
    project.header.programID = loadingInfo.projectID;

    if (! project) {
        [[NSNotificationCenter defaultCenter] postNotificationName:NotificationName.projectInvalidXml object:loadingInfo];
        return nil;
    }

    NSDebug(@"%@", [project description]);
    NSDebug(@"ProjectResolution: width/height:  %f / %f", project.header.screenWidth.floatValue, project.header.screenHeight.floatValue);
    [self updateLastModificationTimeForProjectWithName:loadingInfo.visibleName projectID:loadingInfo.projectID];
    
    CBFileManager *fileManager = [[CBFileManager alloc] init];
    NSString *defaultSceneDirectoryPath = [NSString stringWithFormat:@"%@%@", [project projectPath], [Util defaultSceneNameForSceneNumber:1]];
    if (![fileManager directoryExists:defaultSceneDirectoryPath]) {
        project.header.catrobatLanguageVersion = Util.catrobatLanguageVersion;
        ProjectMigrator *migrator = [[ProjectMigrator alloc] initWithFileManager:fileManager];
        NSError *error;
        [migrator migrateToSceneWithProject:project error:&error];
    }
    
    return project;
}

+ (instancetype)lastUsedProject
{
    return [Project projectWithLoadingInfo:[Util lastUsedProjectLoadingInfo]];
}

+ (void)updateLastModificationTimeForProjectWithName:(NSString*)projectName projectID:(NSString*)projectID
{
    NSString *xmlPath = [NSString stringWithFormat:@"%@%@",
                         [self projectPathForProjectWithName:projectName projectID:projectID],
                         kProjectCodeFileName];
    CBFileManager *fileManager = [CBFileManager sharedManager];
    [fileManager changeModificationDate:[NSDate date] forFileAtPath:xmlPath];
}

+ (void)copyProjectWithSourceProjectName:(NSString*)sourceProjectName
                         sourceProjectID:(NSString*)sourceProjectID
                  destinationProjectName:(NSString*)destinationProjectName
{
    NSString *sourceProjectPath = [[self class] projectPathForProjectWithName:sourceProjectName projectID:sourceProjectID];
    destinationProjectName = [Util uniqueName:destinationProjectName existingNames:[self allProjectNames]];
    NSString *destinationProjectPath = [[self class] projectPathForProjectWithName:destinationProjectName projectID:nil];

    CBFileManager *fileManager = [CBFileManager sharedManager];
    [fileManager copyExistingDirectoryAtPath:sourceProjectPath toPath:destinationProjectPath];
    ProjectLoadingInfo *destinationProjectLoadingInfo = [ProjectLoadingInfo projectLoadingInfoForProjectWithName:destinationProjectName projectID:nil];
    Project *project = [Project projectWithLoadingInfo:destinationProjectLoadingInfo];
    project.header.programName = destinationProjectLoadingInfo.visibleName;
    [project saveToDiskWithNotification:YES];
}

+ (void)removeProjectFromDiskWithProjectName:(NSString*)projectName projectID:(NSString*)projectID
{
    CBFileManager *fileManager = [CBFileManager sharedManager];
    NSString *projectPath = [self projectPathForProjectWithName:projectName projectID:projectID];
    if ([fileManager directoryExists:projectPath]) {
        [fileManager deleteDirectory:projectPath];
    }

    // if this is currently set as last used project, then look for next project to set it as
    // the last used project
    if ([Project isLastUsedProject:projectName projectID:projectID]) {
        [Util setLastProjectWithName:nil projectID:nil];
        NSArray *allProjectLoadingInfos = [[self class] allProjectLoadingInfos];
        for (ProjectLoadingInfo *projectLoadingInfo in allProjectLoadingInfos) {
            [Util setLastProjectWithName:projectLoadingInfo.visibleName projectID:projectLoadingInfo.projectID];
            break;
        }
    }

    // if there are no projects left, then automatically recreate default project
    [fileManager addDefaultProjectToProjectsRootDirectoryIfNoProjectsExist];
}

- (void)translateDefaultProject
{
    NSUInteger index = 0;
    for (SpriteObject *spriteObject in self.scene.objects) {
        if (index == kBackgroundObjectIndex) {
            spriteObject.name = kLocalizedBackground;
        } else {
            NSMutableString *spriteObjectName = [NSMutableString stringWithString:spriteObject.name];
            [spriteObjectName replaceOccurrencesOfString:kDefaultProjectBundleOtherObjectsNamePrefix
                                              withString:kLocalizedMole
                                                 options:NSCaseInsensitiveSearch
                                                   range:NSMakeRange(0, spriteObjectName.length)];
            spriteObject.name = (NSString*)spriteObjectName;
        }
        ++index;
    }
    [self renameToProjectName:kLocalizedMyFirstProject andShowSaveNotification:NO]; // saves to disk!
}

+ (NSString*)basePath
{
    return [NSString stringWithFormat:@"%@/%@/", [Util applicationDocumentsDirectory], kProjectsFolder];
}


+ (NSArray*)allProjectNames
{
    NSArray *allProjectLoadingInfos = [[self class] allProjectLoadingInfos];
    NSMutableArray *projectNames = [[NSMutableArray alloc] initWithCapacity:[allProjectLoadingInfos count]];
    for (ProjectLoadingInfo *loadingInfo in allProjectLoadingInfos) {
        [projectNames addObject:loadingInfo.visibleName];
    }
    return [projectNames copy];
}

+ (NSArray*)allProjectLoadingInfos
{
    NSString *basePath = [Project basePath];
    NSError *error;
    NSArray *subdirNames = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:basePath error:&error];
    NSLogError(error);
    subdirNames = [subdirNames sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];

    NSMutableArray *projectLoadingInfos = [[NSMutableArray alloc] initWithCapacity:subdirNames.count];
    for (NSString *subdirName in subdirNames) {
        // exclude .DS_Store folder on MACOSX simulator
        if ([subdirName isEqualToString:@".DS_Store"]) {
            continue;
        }

        ProjectLoadingInfo *info = [[self class] projectLoadingInfoForProjectDirectoryName:subdirName];
        if (! info) {
            NSDebug(@"Unable to load project located in directory %@", subdirName);
            continue;
        }
        NSDebug(@"Adding loaded project: %@", info.basePath);
        [projectLoadingInfos addObject:info];
    }
    return projectLoadingInfos;
}

+ (BOOL)areThereAnyProjects
{
    return ((BOOL)[[self allProjectNames] count]);
}

+ (BOOL)isLastUsedProject:(NSString*)projectName projectID:(NSString*)projectID
{
    ProjectLoadingInfo *lastUsedInfo = [Util lastUsedProjectLoadingInfo];
    ProjectLoadingInfo *info = [ProjectLoadingInfo projectLoadingInfoForProjectWithName:projectName
                                                                              projectID:projectID];
    return [lastUsedInfo isEqualToLoadingInfo:info];
}

+ (void)setLastUsedProject:(Project*)project
{
    [Util setLastProjectWithName:project.header.programName projectID:project.header.programID];
}

+ (NSString*)projectPathForProjectWithName:(NSString*)projectName projectID:(NSString*)projectID
{
    return [NSString stringWithFormat:@"%@%@/", [Project basePath], [[self class] projectDirectoryNameForProjectName:[Util replaceBlockedCharactersForString:projectName] projectID:projectID]];
}

@end
