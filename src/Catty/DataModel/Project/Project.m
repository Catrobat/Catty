/**
 *  Copyright (C) 2010-2020 The Catrobat Team
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
#import "VariablesContainer.h"
#import "Util.h"
#import "AppDelegate.h"
#import "Parser.h"
#import "Script.h"
#import "Brick.h"
#import "CatrobatLanguageDefines.h"
#import "CBXMLParser.h"
#import "CBXMLSerializer.h"
#import "CBMutableCopyContext.h"
#import "Pocket_Code-Swift.h"

@implementation Project

@synthesize objectList = _objectList;

- (NSInteger)numberOfTotalObjects
{
    return [self.objectList count];
}

- (NSInteger)numberOfBackgroundObjects
{
    NSInteger numberOfTotalObjects = [self numberOfTotalObjects];
    if (numberOfTotalObjects < kBackgroundObjects) {
        return numberOfTotalObjects;
    }
    return kBackgroundObjects;
}

- (NSInteger)numberOfNormalObjects
{
    NSInteger numberOfTotalObjects = [self numberOfTotalObjects];
    if (numberOfTotalObjects > kBackgroundObjects) {
        return (numberOfTotalObjects - kBackgroundObjects);
    }
    return 0;
}

- (SpriteObject*)addObjectWithName:(NSString*)objectName
{
    SpriteObject *object = [[SpriteObject alloc] init];
    //object.originalSize;
    object.spriteNode.currentLook = nil;

    object.name = [Util uniqueName:objectName existingNames:[self allObjectNames]];
    object.project = self;
    [self.objectList addObject:object];
    [self saveToDiskWithNotification:YES];
    return object;
}

- (void)removeObjectFromList:(SpriteObject*)object
{
    // do not use NSArray's removeObject here
    // => if isEqual is overriden this would lead to wrong results
    NSUInteger index = 0;
    for (SpriteObject *currentObject in self.objectList) {
        if (currentObject == object) {
            [currentObject removeSounds:currentObject.soundList AndSaveToDisk:NO];
            [currentObject removeLooks:currentObject.lookList AndSaveToDisk:NO];
            [currentObject.project.variables removeObjectVariablesForSpriteObject:currentObject];
            [currentObject.project.variables removeObjectListsForSpriteObject:currentObject];
            currentObject.project = nil;
            [self.objectList removeObjectAtIndex:index];
            break;
        }
        ++index;
    }
}

- (void)removeObject:(SpriteObject*)object
{
    [self removeObjectFromList:object];
    [self saveToDiskWithNotification:YES];
}

- (void)removeObjects:(NSArray*)objects
{
    for (id object in objects) {
        if ([object isKindOfClass:[SpriteObject class]]) {
            [self removeObject:((SpriteObject*)object)];
        }
    }
    [self saveToDiskWithNotification:YES];
}

- (BOOL)objectExistsWithName:(NSString*)objectName
{
    for (SpriteObject *object in self.objectList) {
        if ([object.name isEqualToString:objectName]) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - Custom getter and setter
- (NSMutableArray<SpriteObject*>*)objectList
{
    if (! _objectList) {
         _objectList = [NSMutableArray array];
    }
    return _objectList;
}

- (void)setObjectList:(NSMutableArray<SpriteObject*>*)objectList
{
    for (id object in objectList) {
        if ([object isKindOfClass:[SpriteObject class]]) {
            ((SpriteObject*)object).project = self;
        }
    }
    _objectList = objectList;
}

- (VariablesContainer*)variables
{
    // lazy instantiation
    if (! _variables)
        _variables = [VariablesContainer new];
    return _variables;
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
    CBFileManager *fileManager = [CBFileManager sharedManager];
    dispatch_queue_t saveToDiskQ = dispatch_queue_create("save to disk", NULL);
    dispatch_async(saveToDiskQ, ^{
        // show saved view bezel
        if (notify) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
                [notificationCenter postNotificationName:kHideLoadingViewNotification object:self];
                [notificationCenter postNotificationName:kShowSavedViewNotification object:self];
            });
        }
        // TODO: find correct serializer class dynamically
        NSString *xmlPath = [NSString stringWithFormat:@"%@%@", [self projectPath], kProjectCodeFileName];
        id<CBSerializerProtocol> serializer = [[CBXMLSerializer alloc] initWithPath:xmlPath fileManager:fileManager];
        [serializer serializeProject:self];

        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:kHideLoadingViewNotification object:self];
            [[NSNotificationCenter defaultCenter] postNotificationName:kReadyToUpload object:self];
        });
    });
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

- (void)renameObject:(SpriteObject*)object toName:(NSString*)newObjectName
{
    if (! [self hasObject:object] || [object.name isEqualToString:newObjectName]) {
        return;
    }
    object.name = [Util uniqueName:newObjectName existingNames:[self allObjectNames]];
    [self saveToDiskWithNotification:YES];
}

- (void)updateDescriptionWithText:(NSString*)descriptionText
{
    self.header.programDescription = descriptionText;
    [self saveToDiskWithNotification:YES];
}

- (void)removeReferences
{
    [self.objectList makeObjectsPerformSelector:@selector(removeReferences)];
}

- (NSArray*)allObjectNames
{
    NSMutableArray *objectNames = [NSMutableArray arrayWithCapacity:[self.objectList count]];
    for (id spriteObject in self.objectList) {
        if ([spriteObject isKindOfClass:[SpriteObject class]]) {
            [objectNames addObject:((SpriteObject*)spriteObject).name];
        }
    }
    return [objectNames copy];
}

- (BOOL)hasObject:(SpriteObject *)object
{
    return [self.objectList containsObject:object];
}

- (SpriteObject*)copyObject:(SpriteObject*)sourceObject
    withNameForCopiedObject:(NSString *)nameOfCopiedObject
{
    if (! [self hasObject:sourceObject]) {
        return nil;
    }
    CBMutableCopyContext *context = [CBMutableCopyContext new];
    NSMutableArray<UserVariable*> *copiedVariablesAndLists = [NSMutableArray new];
    
    NSMutableArray<UserVariable*> *variablesAndLists = [[NSMutableArray alloc] initWithArray:[self.variables objectVariablesForObject:sourceObject]];
    [variablesAndLists addObjectsFromArray: [self.variables objectListsForObject:sourceObject]];
    
    for (UserVariable *variableOrList in variablesAndLists) {
        UserVariable *copiedVariableOrList = [[UserVariable alloc] initWithVariable:variableOrList];
        
        [copiedVariablesAndLists addObject:copiedVariableOrList];
        [context updateReference:variableOrList WithReference:copiedVariableOrList];
    }
    
    SpriteObject *copiedObject = [sourceObject mutableCopyWithContext:context];
    copiedObject.name = [Util uniqueName:nameOfCopiedObject existingNames:[self allObjectNames]];
    [self.objectList addObject:copiedObject];
    
    for (UserVariable *variableOrList in copiedVariablesAndLists) {
        if (variableOrList.isList) {
            [self.variables addObjectList:variableOrList forObject:copiedObject];
        } else {
            [self.variables addObjectVariable:variableOrList forObject:copiedObject];
        }
    }
    
    [self saveToDiskWithNotification:YES];
    return copiedObject;
}

- (BOOL)isEqualToProject:(Project*)project
{
    if (! [self.header isEqualToHeader:project.header])
        return NO;
    if (! [self.variables isEqualToVariablesContainer:project.variables])
        return NO;
    if ([self.objectList count] != [project.objectList count])
        return NO;
    
    NSUInteger idx;
    for (idx = 0; idx < [self.objectList count]; idx++) {
        SpriteObject *firstObject = [self.objectList objectAtIndex:idx];
        SpriteObject *secondObject = nil;
        
        NSUInteger projectIdx;
        for (projectIdx = 0; projectIdx < [project.objectList count]; projectIdx++) {
            SpriteObject *projectObject = [project.objectList objectAtIndex:projectIdx];
            
            if ([projectObject.name isEqualToString:firstObject.name]) {
                secondObject = projectObject;
                break;
            }
        }
        
        if (secondObject == nil || ! [firstObject isEqualToSpriteObject:secondObject])
            return NO;
    }
    return YES;
}

- (NSInteger)getRequiredResources
{
    NSInteger resources = kNoResources;
    
    for (SpriteObject *obj in self.objectList) {
        resources |= [obj getRequiredResources];
    }
    return resources;

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
    [ret appendFormat:@"Sprite List: %@\n", self.objectList];
    [ret appendFormat:@"URL: %@\n", self.header.url];
    [ret appendFormat:@"User Handle: %@\n", self.header.userHandle];
    [ret appendFormat:@"Variables: %@\n", self.variables];
    [ret appendFormat:@"------------------------------------------------\n"];
    return [ret copy];
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

+ (instancetype)defaultProjectWithName:(NSString*)projectName projectID:(NSString*)projectID
{
    projectName = [Util uniqueName:projectName existingNames:[[self class] allProjectNames]];
    Project *project = [[Project alloc] init];
    project.header = [Header defaultHeader];
    project.header.programName = projectName;
    project.header.programID = projectID;

    CBFileManager *fileManager = [CBFileManager sharedManager];
    if (! [fileManager directoryExists:projectName]) {
        [fileManager createDirectory:[project projectPath]];
    }

    NSString *imagesDirName = [NSString stringWithFormat:@"%@%@", [project projectPath], kProjectImagesDirName];
    if (! [fileManager directoryExists:imagesDirName]) {
        [fileManager createDirectory:imagesDirName];
    }

    NSString *soundsDirName = [NSString stringWithFormat:@"%@%@", [project projectPath], kProjectSoundsDirName];
    if (! [fileManager directoryExists:soundsDirName]) {
        [fileManager createDirectory:soundsDirName];
    }

    [project addObjectWithName:kLocalizedBackground];
    NSDebug(@"%@", [project description]);
    return project;
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

    if (! project)
        return nil;

    NSDebug(@"%@", [project description]);
    NSDebug(@"ProjectResolution: width/height:  %f / %f", project.header.screenWidth.floatValue, project.header.screenHeight.floatValue);
    [self updateLastModificationTimeForProjectWithName:loadingInfo.visibleName projectID:loadingInfo.projectID];
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
    for (SpriteObject *spriteObject in self.objectList) {
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
