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

#import "ProgramManager.h"
#import "ProgramLoadingInfo.h"
#import "ProgramDefines.h"
#import "Util.h"
#import "CatrobatLanguageDefines.h"
#import "CBXMLParser.h"
#import "AppDelegate.h"
#import "CBXMLSerializer.h"
#import "NSArray+CustomExtension.h"
#import "Scene.h"
#import "FileSystemStorage.h"

@interface ProgramManager ()
@property (nonatomic, readonly) FileManager *fileManager;
@end

@implementation ProgramManager

static ProgramManager *_instance = nil;

- (instancetype)initWithFileManager:(FileManager *)fileManager {
    self = [super init];
    if (self) {
        _fileManager = fileManager;
    }
    return self;
}

+ (void)setInstance:(ProgramManager *)instance {
    NSParameterAssert(instance);
    NSAssert(_instance == nil, @"Instance should be set only once");
    _instance = instance;
}

+ (instancetype)instance {
    NSAssert(_instance != nil, @"Instance should be initialized before using");
    return _instance;
}


- (Program *)programWithLoadingInfo:(ProgramLoadingInfo *)programLoadingInfo {
    NSParameterAssert(programLoadingInfo);
    
    NSDebug(@"Try to load project '%@'", programLoadingInfo.visibleName);
    NSDebug(@"Path: %@", programLoadingInfo.basePath);
    
    NSString *xmlPath = [FileSystemStorage xmlPathForProgramWithLoadingInfo:programLoadingInfo];
    NSDebug(@"XML-Path: %@", xmlPath);
    
    CGFloat languageVersion = [Util detectCBLanguageVersionFromXMLWithPath:xmlPath];
    
    if (languageVersion == kCatrobatInvalidVersion) {
        NSDebug(@"Invalid catrobat language version!");
        return nil;
    }
    
    CBXMLParser *catrobatParser = [[CBXMLParser alloc] initWithPath:xmlPath];
    if (! [catrobatParser isSupportedLanguageVersion:languageVersion]) {
        NSAssert(false, @"Unsupported");
    }
    
    Program *program = [catrobatParser parseAndCreateProgram];
    
    program.header.programID = programLoadingInfo.programID;
    
    if (! program)
        return nil;
    
    if ([self hasOldImagesDirectory:program] || [self hasOldSoundsDirectory:program]) {
        NSAssert(languageVersion <= 0.991, @"Inconsistency");
        [self migrameToNewFolderStructureWithProgram:program];
    }
    
    NSDebug(@"%@", [program description]);
    NSDebug(@"ProjectResolution: width/height:  %f / %f", program.header.screenWidth.floatValue, program.header.screenHeight.floatValue);
    
    [self updateLastModificationTimeForProgramWithLoadingInfo:programLoadingInfo];
    return program;
}

- (void)updateLastModificationTimeForProgramWithLoadingInfo:(ProgramLoadingInfo *)programLoadingInfo {
    NSParameterAssert(programLoadingInfo);
    
    NSString *xmlPath = [FileSystemStorage xmlPathForProgramWithLoadingInfo:programLoadingInfo];
    [self.fileManager changeModificationDate:[NSDate date] forFileAtPath:xmlPath];
}

- (NSDate *)lastModificationTimeForProgramWithLoadingInfo:(ProgramLoadingInfo *)programLoadingInfo {
    NSParameterAssert(programLoadingInfo);
    
    NSString *xmlPath = [FileSystemStorage xmlPathForProgramWithLoadingInfo:programLoadingInfo];
    return [self.fileManager lastModificationTimeOfFile:xmlPath];
}

- (ProgramLoadingInfo *)addProgram:(Program *)program {
    NSParameterAssert(program);
    NSAssert(![[self allProgramNames] containsObject:program.programName], @"Program with such name already exists");
    
    ProgramLoadingInfo *loadingInfo = [ProgramLoadingInfo programLoadingInfoForProgram:program];
    
    NSAssert(![self.fileManager directoryExists:loadingInfo.basePath], @"Inconsistency");
    [self.fileManager createDirectory:loadingInfo.basePath];
    
    for (Scene *scene in program.scenes) {
        [self createDirectoriesForScene:scene];
    }
    
    [self saveProgram:program];
    
    return loadingInfo;
}

- (void)removeProgramWithLoadingInfo:(ProgramLoadingInfo *)programLoadingInfo {
    NSParameterAssert(programLoadingInfo);
    
    NSString *projectPath = programLoadingInfo.basePath;
    
    if ([self.fileManager directoryExists:projectPath]) {
        [self.fileManager deleteDirectory:projectPath];
    }
    
    // if this is currently set as last used program, then look for next program to set it as
    // the last used program
    if ([[self lastUsedProgramLoadingInfo] isEqualToLoadingInfo:programLoadingInfo]) {
        [self setAsLastUsedProgramWithLoadingInfo:[self allProgramLoadingInfos].firstObject];
    }
    
    // if there are no programs left, then automatically recreate default program
    [self addDefaultProgramToProgramsRootDirectoryIfNoProgramsExist];
}

- (void)addDefaultProgramToProgramsRootDirectoryIfNoProgramsExist {
    if ([self allProgramLoadingInfos].count > 0) {
        return;
    }
    [self addNewBundleProgramWithName:kDefaultProgramBundleName];
    ProgramLoadingInfo *loadingInfo = [ProgramLoadingInfo programLoadingInfoForProgramWithName:kDefaultProgramBundleName programID:nil];
    Program *program = [self programWithLoadingInfo:loadingInfo];
    [self translateDefaultProgram:program];
    [self setAsLastUsedProgramWithLoadingInfo:loadingInfo];
}

- (void)addNewBundleProgramWithName:(NSString*)projectName {
    if (! [self.fileManager directoryExists:[FileSystemStorage programsDirectory]]) {
        [self.fileManager createDirectory:[FileSystemStorage programsDirectory]];
    }
    NSString *filePath = [[NSBundle mainBundle] pathForResource:projectName ofType:@"catrobat"];
    NSData *defaultProject = [NSData dataWithContentsOfFile:filePath];
    [self.fileManager unzipAndStore:defaultProject withProgramID:nil withName:projectName];
}

- (void)translateDefaultProgram:(Program *)program {
    NSUInteger index = 0;
    for (SpriteObject *spriteObject in program.scenes[0].objectList) {
        if (index == kBackgroundObjectIndex) {
            spriteObject.name = kLocalizedBackground;
        } else {
            NSMutableString *spriteObjectName = [NSMutableString stringWithString:spriteObject.name];
            [spriteObjectName replaceOccurrencesOfString:kDefaultProgramBundleOtherObjectsNamePrefix
                                              withString:kLocalizedMole
                                                 options:NSCaseInsensitiveSearch
                                                   range:NSMakeRange(0, spriteObjectName.length)];
            spriteObject.name = (NSString*)spriteObjectName;
        }
        ++index;
    }
    [self renameProgram:program toName:kLocalizedMyFirstProgram]; // saves to disk!
}

+ (NSString *)directoryNameForProgramWithLoadingInfo:(ProgramLoadingInfo *)info {
    NSParameterAssert(info);
    return [info.basePath lastPathComponent];
}

- (void)setAsLastUsedProgram:(Program *)program {
    ProgramLoadingInfo *info = (program != nil ? [ProgramLoadingInfo programLoadingInfoForProgram:program] : nil);
    [self setAsLastUsedProgramWithLoadingInfo:info];
}

- (void)setAsLastUsedProgramWithLoadingInfo:(ProgramLoadingInfo *)programLoadingInfo {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSString *lastProgramDirectoryName;
    if (programLoadingInfo != nil) {
        lastProgramDirectoryName = [[self class] directoryNameForProgramWithLoadingInfo:programLoadingInfo];
    }
    
    [userDefaults setObject:lastProgramDirectoryName forKey:kLastUsedProgram];
    [userDefaults synchronize];
}

- (ProgramLoadingInfo *)lastUsedProgramLoadingInfo {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *lastUsedProgramDirectoryName = [userDefaults objectForKey:kLastUsedProgram];
    if (lastUsedProgramDirectoryName == nil) {
        return nil;
    }
    
    return [self programLoadingInfoForProgramDirectoryName:lastUsedProgramDirectoryName];
    
}

- (Program *)lastUsedProgram {
    ProgramLoadingInfo *info = [self lastUsedProgramLoadingInfo];
    if (info == nil) {
        return nil;
    }
    
    return [self programWithLoadingInfo:info];
}

- (ProgramLoadingInfo *)programLoadingInfoForProgramDirectoryName:(NSString *)directoryName
{
    NSParameterAssert(directoryName);
    NSArray<NSString *> *directoryNameParts = [directoryName componentsSeparatedByString:kProgramIDSeparator];
    if (directoryNameParts.count < 2) {
        return nil;
    }
    
    NSString *programID = directoryNameParts.lastObject;
    NSString *programName = [directoryName substringToIndex:directoryName.length - programID.length - 1];
    if ([programID isEqualToString:kNoProgramIDYetPlaceholder]) {
        programID = nil;
    }
    
    return [ProgramLoadingInfo programLoadingInfoForProgramWithName:programName programID:programID];
}

- (ProgramLoadingInfo *)copyProgramWithLoadingInfo:(ProgramLoadingInfo *)programLoadingInfo destinationProgramName:(NSString *)destinationProgramName {
    NSParameterAssert(programLoadingInfo);
    NSParameterAssert(destinationProgramName);
    
    NSAssert(![[self allProgramNames] containsObject:destinationProgramName], @"Program with such name already exists");
    ProgramLoadingInfo *destinationProgramLoadingInfo = [ProgramLoadingInfo programLoadingInfoForProgramWithName:destinationProgramName
                                                                                                       programID:nil];
    NSString *sourceProgramPath = programLoadingInfo.basePath;
    NSString *destinationProgramPath = destinationProgramLoadingInfo.basePath;
    
    [self.fileManager copyExistingDirectoryAtPath:sourceProgramPath toPath:destinationProgramPath];
    
    Program *destinationProgram = [self programWithLoadingInfo:destinationProgramLoadingInfo];
    destinationProgram.header.programName = destinationProgramLoadingInfo.visibleName;
    [self saveProgram:destinationProgram];
    
    return destinationProgramLoadingInfo;
}

- (NSArray<NSString *> *)allProgramNames {
    return [[self allProgramLoadingInfos] cb_mapUsingBlock:^NSString *(ProgramLoadingInfo *item) {
        return item.visibleName;
    }];
}

- (NSArray<ProgramLoadingInfo *> *)allProgramLoadingInfos {
    NSArray<NSString *> *subdirNames = [self.fileManager getContentsOfDirectory:[FileSystemStorage programsDirectory]];
    
    NSMutableArray<ProgramLoadingInfo *> *programLoadingInfos = [[NSMutableArray alloc] initWithCapacity:subdirNames.count];
    for (NSString *subdirName in subdirNames) {
        // exclude .DS_Store folder on MACOSX simulator
        if ([subdirName isEqualToString:@".DS_Store"]) {
            continue;
        }
        
        ProgramLoadingInfo *info = [self programLoadingInfoForProgramDirectoryName:subdirName];
        if (info == nil) {
            NSDebug(@"Unable to load program located in directory %@", subdirName);
            continue;
        }
        NSDebug(@"Adding loaded program: %@", info.basePath);
        
        [programLoadingInfos addObject:info];
    }
    return [programLoadingInfos copy];
}

- (void)renameProgram:(Program *)program toName:(NSString *)name {
    NSParameterAssert(program);
    NSParameterAssert(name);
    
    if ([program.programName isEqualToString:name]) {
        return;
    }
    NSAssert(![[self allProgramNames] containsObject:name], @"Program with such name already exists");
    
    ProgramLoadingInfo *oldLoadingInfo = [ProgramLoadingInfo programLoadingInfoForProgram:program];
    program.header.programName = name;
    ProgramLoadingInfo *newLoadingInfo = [ProgramLoadingInfo programLoadingInfoForProgram:program];
    
    [self moveProgramWithLoadingInfo:oldLoadingInfo toLoadingInfo:newLoadingInfo];
    [self saveProgram:program];
}

- (void)setProgramIDOfProgram:(Program *)program toID:(NSString *)programID {
    NSParameterAssert(program);
    NSParameterAssert(programID);
    
    if ([program.programID isEqualToString:programID]) {
        return;
    }
    
    ProgramLoadingInfo *oldLoadingInfo = [ProgramLoadingInfo programLoadingInfoForProgram:program];
    program.header.programID = programID;
    ProgramLoadingInfo *newLoadingInfo = [ProgramLoadingInfo programLoadingInfoForProgram:program];
    
    [self moveProgramWithLoadingInfo:oldLoadingInfo toLoadingInfo:newLoadingInfo];
    [self saveProgram:program];
}

- (void)moveProgramWithLoadingInfo:(ProgramLoadingInfo *)oldLoadingInfo toLoadingInfo:(ProgramLoadingInfo *)newLoadingInfo {
    [self.fileManager moveExistingDirectoryAtPath:oldLoadingInfo.basePath toPath:newLoadingInfo.basePath];
    
    if ([[self lastUsedProgramLoadingInfo] isEqualToLoadingInfo:oldLoadingInfo]) {
        [self setAsLastUsedProgramWithLoadingInfo:newLoadingInfo];
    }
}

- (void)addScene:(Scene *)scene toProgram:(Program *)program {
    NSParameterAssert(scene);
    NSParameterAssert(program);
    NSAssert(![[program allSceneNames] containsObject:scene.name], @"Scene with such name already exists");
    
    scene.program = program;
    [program.scenes addObject:scene];
    
    [self createDirectoriesForScene:scene];
    
    [self saveProgram:program];
}

- (void)removeScenes:(NSArray<Scene *> *)scenes fromProgram:(Program *)program {
    NSParameterAssert(scenes.count);
    NSParameterAssert(program);
    
    for (Scene *scene in scenes) {
        BOOL hasScene = [program.scenes cb_findFirst:^BOOL(Scene *item) {
            return item == scene;
        }];
        NSAssert(hasScene && scene.program == program, @"Scene doesn't belong to program");
        
        [self.fileManager deleteDirectory:[FileSystemStorage directoryForScene:scene]];
        
        scene.program = nil;
        [program.scenes removeObject:scene];
    }
    
    if ([program.scenes count] == 0) {
        [self addScene:[Scene defaultSceneWithName:@"Scene 1"]  toProgram:program];
    }
    
    [self saveProgram:program];
}

- (void)renameScene:(Scene *)scene toName:(NSString *)name {
    NSParameterAssert(scene);
    NSParameterAssert(name);
    
    if ([scene.name isEqualToString:name]) {
        return;
    }
    NSAssert(![[scene.program allSceneNames] containsObject:name], @"Scene with such name already exists");
    
    NSString *oldDirectory = [FileSystemStorage directoryForScene:scene];
    scene.name = name;
    NSString *newDirectory = [FileSystemStorage directoryForScene:scene];
    
    [self.fileManager moveExistingDirectoryAtPath:oldDirectory toPath:newDirectory];
    
    [self saveProgram:scene.program];
}

- (void)copyScene:(Scene *)sourceScene destinationSceneName:(NSString *)destinationSceneName {
    NSParameterAssert(sourceScene);
    NSParameterAssert(destinationSceneName);
    
    NSAssert(![[sourceScene.program allSceneNames] containsObject:destinationSceneName], @"Scene with such name already exists");
    
    Scene *sceneCopy = [[Scene alloc] initWithName:destinationSceneName
                                        objectList:sourceScene.objectList
                                objectVariableList:sourceScene.objectVariableList
                                     originalWidth:sourceScene.originalWidth
                                    originalHeight:sourceScene.originalHeight];
    
    sceneCopy.program = sourceScene.program;
    [sourceScene.program.scenes addObject:sceneCopy];
    
    NSString *sourceSceneDirectory = [FileSystemStorage directoryForScene:sourceScene];
    NSString *sceneCopyDirectory = [FileSystemStorage directoryForScene:sceneCopy];
    
    [self.fileManager copyExistingDirectoryAtPath:sourceSceneDirectory toPath:sceneCopyDirectory];
    
    [self saveProgram:sourceScene.program];
}

- (void)saveProgram:(Program *)program {
    NSParameterAssert(program);
    
    ProgramLoadingInfo *info = [ProgramLoadingInfo programLoadingInfoForProgram:program];
    NSAssert([self.fileManager directoryExists:info.basePath], @"Program doesn't exit");
    
    NSString *xmlPath = [FileSystemStorage xmlPathForProgramWithLoadingInfo:info];
    CBXMLSerializer *serializer = [[CBXMLSerializer alloc] initWithPath:xmlPath];
    [serializer serializeProgram:program];
    
    [self updateLastModificationTimeForProgramWithLoadingInfo:info];
}

- (void)createDirectoriesForScene:(Scene *)scene {
    NSParameterAssert(scene);
    
    NSString *sceneDirectory = [FileSystemStorage directoryForScene:scene];
    NSAssert(![self.fileManager directoryExists:sceneDirectory], @"Already exists");
    [self.fileManager createDirectory:sceneDirectory];
    
    NSString *imagesDirName = [FileSystemStorage imagesDirectoryForScene:scene];
    NSAssert(![self.fileManager directoryExists:imagesDirName], @"Already exists");
    [self.fileManager createDirectory:imagesDirName];
    
    NSString *soundsDirName = [FileSystemStorage soundsDirectoryForScene:scene];
    NSAssert(![self.fileManager directoryExists:soundsDirName], @"Already exists");
    [self.fileManager createDirectory:soundsDirName];
}

- (NSString *)oldImagesDirectoryForProgram:(Program *)program {
    NSString *programDirectory = [FileSystemStorage directoryForProgramWithName:program.programName programID:program.programID];
    return [NSString stringWithFormat:@"%@/images/", programDirectory];
}

- (BOOL)hasOldImagesDirectory:(Program *)program {
    return [self.fileManager directoryExists:[self oldImagesDirectoryForProgram:program]];
}

- (NSString *)oldSoundsDirectoryForProgram:(Program *)program {
    NSString *programDirectory = [FileSystemStorage directoryForProgramWithName:program.programName programID:program.programID];
    return [NSString stringWithFormat:@"%@/sounds/", programDirectory];
}

- (BOOL)hasOldSoundsDirectory:(Program *)program {
    return [self.fileManager directoryExists:[self oldSoundsDirectoryForProgram:program]];
}

- (void)migrameToNewFolderStructureWithProgram:(Program *)program {
    NSAssert([program.scenes count] == 1, @"Inconsistency");
    
    Scene *scene = [program.scenes objectAtIndex:0];
    
    NSString *sceneDirectory = [FileSystemStorage directoryForScene:scene];
    [self.fileManager createDirectory:sceneDirectory];
    
    NSString *programImagesDirectory = [self oldImagesDirectoryForProgram:program];
    NSString *sceneImagesDirectory = [FileSystemStorage imagesDirectoryForScene:scene];
    [self.fileManager moveExistingDirectoryAtPath:programImagesDirectory toPath:sceneImagesDirectory];
    
    NSString *programSoundsDirectory = [self oldSoundsDirectoryForProgram:program];
    NSString *sceneSoundsDirectory = [FileSystemStorage soundsDirectoryForScene:scene];
    [self.fileManager moveExistingDirectoryAtPath:programSoundsDirectory toPath:sceneSoundsDirectory];
}

@end
