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

#import "Program.h"
#import "VariablesContainer.h"
#import "Util.h"
#import "SpriteObject.h"
#import "AppDelegate.h"
#import "FileManager.h"
#import "SensorHandler.h"
#import "ProgramLoadingInfo.h"
#import "Parser.h"
#import "Script.h"
#import "Brick.h"
#import "LanguageTranslationDefines.h"
#import "UserVariable.h"
#import "OrderedMapTable.h"
#import "CatrobatLanguageDefines.h"
#import "CBXMLParser.h"
#import "CBXMLSerializer.h"
#import "CBMutableCopyContext.h"
#import "BroadcastScript.h"
#import "BroadcastWaitHandler.h"
#import "Pocket_Code-Swift.h"

@interface Program()

@property (nonatomic, strong) BroadcastWaitHandler *broadcastWaitHandler;
@property (nonatomic, strong) NSMutableDictionary *spriteObjectBroadcastScripts;
@property (nonatomic, strong) NSMutableDictionary *broadcastScriptCounters;
@property (nonatomic, strong) NSMutableDictionary *broadcastMessageSemaphores;

@end

@implementation Program

@synthesize objectList = _objectList;

# pragma mark - factories
+ (instancetype)defaultProgramWithName:(NSString*)programName programID:(NSString*)programID
{
    programName = [Util uniqueName:programName existingNames:[[self class] allProgramNames]];
    Program *program = [[Program alloc] init];
    program.header = [Header defaultHeader];
    program.header.programName = programName;
    program.header.programID = programID;

    FileManager *fileManager = [[FileManager alloc] init];
    if (! [fileManager directoryExists:programName]) {
        [fileManager createDirectory:[program projectPath]];
    }

    NSString *imagesDirName = [NSString stringWithFormat:@"%@%@", [program projectPath], kProgramImagesDirName];
    if (! [fileManager directoryExists:imagesDirName]) {
        [fileManager createDirectory:imagesDirName];
    }

    NSString *soundsDirName = [NSString stringWithFormat:@"%@%@", [program projectPath], kProgramSoundsDirName];
    if (! [fileManager directoryExists:soundsDirName]) {
        [fileManager createDirectory:soundsDirName];
    }

    [program addObjectWithName:kLocalizedBackground];
    NSDebug(@"%@", [program description]);
    return program;
}

+ (instancetype)programWithLoadingInfo:(ProgramLoadingInfo*)loadingInfo;
{
    NSDebug(@"Try to load project '%@'", loadingInfo.visibleName);
    NSDebug(@"Path: %@", loadingInfo.basePath);
    NSString *xmlPath = [NSString stringWithFormat:@"%@%@", loadingInfo.basePath, kProgramCodeFileName];
    NSDebug(@"XML-Path: %@", xmlPath);

//    //######### FIXME remove that later!! {
//        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
//        xmlPath = [bundle pathForResource:@"ValidProgramAllBricks" ofType:@"xml"];
//    // }

    Program *program = nil;
    CGFloat languageVersion = [Util detectCBLanguageVersionFromXMLWithPath:xmlPath];

    if (languageVersion == kCatrobatInvalidVersion) {
        NSDebug(@"Invalid catrobat language version!");
        return nil;
    }

    // detect right parser for correct catrobat language version
    CBXMLParser *catrobatParser = [[CBXMLParser alloc] initWithPath:xmlPath];
    if (! [catrobatParser isSupportedLanguageVersion:languageVersion]) {
        Parser *parser = [[Parser alloc] init];
        program = [parser generateObjectForProgramWithPath:xmlPath];
    } else {
        program = [catrobatParser parseAndCreateProgram];
    }
    program.header.programID = loadingInfo.programID;

    if (! program)
        return nil;

    NSDebug(@"%@", [program description]);
    NSDebug(@"ProjectResolution: width/height:  %f / %f", program.header.screenWidth.floatValue, program.header.screenHeight.floatValue);
    [self updateLastModificationTimeForProgramWithName:loadingInfo.visibleName programID:loadingInfo.programID];
    return program;
}

+ (instancetype)lastUsedProgram
{
    return [Program programWithLoadingInfo:[Util lastUsedProgramLoadingInfo]];
}

+ (void)updateLastModificationTimeForProgramWithName:(NSString*)programName programID:(NSString*)programID
{
    NSString *xmlPath = [NSString stringWithFormat:@"%@%@",
                         [self projectPathForProgramWithName:programName programID:programID],
                         kProgramCodeFileName];
    AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [appDelegate.fileManager changeModificationDate:[NSDate date] forFileAtPath:xmlPath];
}

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
    SpriteObject* object = [[SpriteObject alloc] init];
    //object.originalSize;
    object.currentLook = nil;

    object.name = [Util uniqueName:objectName existingNames:[self allObjectNames]];
    object.program = self;
    [self.objectList addObject:object];
    [self saveToDisk];
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
            [currentObject.program.variables removeObjectVariablesForSpriteObject:currentObject];
            currentObject.program = nil;
            [self.objectList removeObjectAtIndex:index];
            break;
        }
        ++index;
    }
}

- (void)removeObject:(SpriteObject*)object
{
    [self removeObjectFromList:object];
    [self saveToDisk];
}

- (void)removeObjects:(NSArray*)objects
{
    for (id object in objects) {
        if ([object isKindOfClass:[SpriteObject class]]) {
            [self removeObject:((SpriteObject*)object)];
        }
    }
    [self saveToDisk];
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
- (BroadcastWaitHandler*)broadcastWaitHandler
{
    // lazy instantiation
    if (! _broadcastWaitHandler) {
        _broadcastWaitHandler = [BroadcastWaitHandler new];
    }
    return _broadcastWaitHandler;
}

- (NSMutableDictionary*)spriteObjectBroadcastScripts
{
    if (! _spriteObjectBroadcastScripts) {
        _spriteObjectBroadcastScripts = [NSMutableDictionary dictionary];
    }
    return _spriteObjectBroadcastScripts;
}

- (NSMutableDictionary*)broadcastScriptCounters
{
    if (! _broadcastScriptCounters) {
        _broadcastScriptCounters = [NSMutableDictionary dictionary];
    }
    return _broadcastScriptCounters;
}

- (NSMutableDictionary*)broadcastMessageSemaphores
{
    if (! _broadcastMessageSemaphores) {
        _broadcastMessageSemaphores = [NSMutableDictionary dictionary];
    }
    return _broadcastMessageSemaphores;
}

- (NSMutableArray*)objectList
{
    if (! _objectList) {
         _objectList = [NSMutableArray array];
    }
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

- (VariablesContainer*)variables
{
    // lazy instantiation
    if (! _variables)
        _variables = [VariablesContainer new];
    return _variables;
}

- (NSString*)projectPath
{
    return [Program projectPathForProgramWithName:self.header.programName programID:self.header.programID];
}

+ (NSString*)projectPathForProgramWithName:(NSString*)programName programID:(NSString*)programID
{
    return [NSString stringWithFormat:@"%@%@/", [Program basePath], [[self class] programDirectoryNameForProgramName:programName programID:programID]];
}

- (void)removeFromDisk
{
    [Program removeProgramFromDiskWithProgramName:self.header.programName programID:self.header.programID];
}

+ (void)copyProgramWithSourceProgramName:(NSString*)sourceProgramName
                         sourceProgramID:(NSString*)sourceProgramID
                  destinationProgramName:(NSString*)destinationProgramName
{
    NSString *sourceProgramPath = [[self class] projectPathForProgramWithName:sourceProgramName programID:sourceProgramID];
    destinationProgramName = [Util uniqueName:destinationProgramName existingNames:[self allProgramNames]];
    NSString *destinationProgramPath = [[self class] projectPathForProgramWithName:destinationProgramName programID:nil];

    AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [appDelegate.fileManager copyExistingDirectoryAtPath:sourceProgramPath toPath:destinationProgramPath];
    ProgramLoadingInfo *destinationProgramLoadingInfo = [ProgramLoadingInfo programLoadingInfoForProgramWithName:destinationProgramName programID:nil];
    Program *program = [Program programWithLoadingInfo:destinationProgramLoadingInfo];
    program.header.programName = destinationProgramLoadingInfo.visibleName;
    [program saveToDisk];
}

+ (void)removeProgramFromDiskWithProgramName:(NSString*)programName programID:(NSString*)programID
{
    FileManager *fileManager = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).fileManager;
    NSString *projectPath = [self projectPathForProgramWithName:programName programID:programID];
    if ([fileManager directoryExists:projectPath]) {
        [fileManager deleteDirectory:projectPath];
    }

    // if this is currently set as last used program, then look for next program to set it as
    // the last used program
    if ([Program isLastUsedProgram:programName programID:programID]) {
        [Util setLastProgramWithName:nil programID:nil];
        NSArray *allProgramLoadingInfos = [[self class] allProgramLoadingInfos];
        for (ProgramLoadingInfo *programLoadingInfo in allProgramLoadingInfos) {
            [Util setLastProgramWithName:programLoadingInfo.visibleName programID:programLoadingInfo.programID];
            break;
        }
    }

    // if there are no programs left, then automatically recreate default program
    [fileManager addDefaultProgramToProgramsRootDirectoryIfNoProgramsExist];
}

// TODO: Maybe this saveToDisk method should be outsourced to another helper class...
- (void)saveToDisk
{
    dispatch_queue_t saveToDiskQ = dispatch_queue_create("save to disk", NULL);
    dispatch_async(saveToDiskQ, ^{
        // show saved view bezel
        dispatch_sync(dispatch_get_main_queue(), ^{
            NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
            [notificationCenter postNotificationName:kHideLoadingViewNotification object:self];
            [notificationCenter postNotificationName:kShowSavedViewNotification object:self];
        });

        // TODO: find correct serializer class dynamically
        NSString *xmlPath = [NSString stringWithFormat:@"%@%@", [self projectPath], kProgramCodeFileName];
        id<CBSerializerProtocol> serializer = [[CBXMLSerializer alloc] initWithPath:xmlPath];
        [serializer serializeProgram:self];

        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:kHideLoadingViewNotification object:self];
        });
    });
}

- (BOOL)isLastUsedProgram
{
    return [Program isLastUsedProgram:self.header.programName programID:self.header.programID];
}

- (void)setAsLastUsedProgram
{
    [Program setLastUsedProgram:self];
}

- (void)translateDefaultProgram
{
    SpriteObject *backgroundObject = [self.objectList objectAtIndex:kBackgroundObjectIndex];
    backgroundObject.name = kLocalizedBackground;
    [self renameToProgramName:kLocalizedMyFirstProgram];
}

- (void)renameToProgramName:(NSString*)programName
{
    if ([self.header.programName isEqualToString:programName]) {
        return;
    }
    BOOL isLastProgram = [self isLastUsedProgram];
    NSString *oldPath = [self projectPath];
    self.header.programName = [Util uniqueName:programName existingNames:[[self class] allProgramNames]];
    NSString *newPath = [self projectPath];
    [[[FileManager alloc] init] moveExistingDirectoryAtPath:oldPath toPath:newPath];
    if (isLastProgram) {
        [Util setLastProgramWithName:self.header.programName programID:self.header.programID];
    }
    [self saveToDisk];
}

- (void)renameObject:(SpriteObject*)object toName:(NSString*)newObjectName
{
    if (! [self hasObject:object] || [object.name isEqualToString:newObjectName]) {
        return;
    }
    object.name = [Util uniqueName:newObjectName existingNames:[self allObjectNames]];
    [self saveToDisk];
}

- (void)updateDescriptionWithText:(NSString*)descriptionText
{
    self.header.programDescription = descriptionText;
    [self saveToDisk];
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
    SpriteObject *copiedObject = [sourceObject mutableCopyWithContext:context];
    copiedObject.name = [Util uniqueName:nameOfCopiedObject existingNames:[self allObjectNames]];
    [self.objectList addObject:copiedObject];
    [self saveToDisk];
    return copiedObject;
}

- (BOOL)isEqualToProgram:(Program*)program
{
    if (! [self.header isEqualToHeader:program.header])
        return NO;
    if (! [self.variables isEqualToVariablesContainer:program.variables])
        return NO;
    if ([self.objectList count] != [program.objectList count])
        return NO;

    NSUInteger idx;
    for (idx = 0; idx < [self.objectList count]; idx++) {
        SpriteObject *firstObject = [self.objectList objectAtIndex:idx];
        SpriteObject *secondObject = [program.objectList objectAtIndex:idx];
        if (! [firstObject isEqualToSpriteObject:secondObject])
            return NO;
    }
    return YES;
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

// returns true if either same programID and/or same programName already exists
+ (BOOL)programExistsWithProgramName:(NSString*)programName programID:(NSString*)programID
{
    NSArray *allProgramLoadingInfos = [[self class] allProgramLoadingInfos];

    // check if program with same ID already exists
    if (programID && [programID length]) {
        if ([[self class] programExistsWithProgramID:programID]) {
            return YES;
        }
    }

    // no programID match => check if program with same name already exists
    for (ProgramLoadingInfo *programLoadingInfo in allProgramLoadingInfos) {
        if ([programName isEqualToString:programLoadingInfo.visibleName]) {
            return YES;
        }
    }
    return NO;
}

// returns true if either same programID and/or same programName already exists
+ (BOOL)programExistsWithProgramID:(NSString*)programID
{
    NSArray *allProgramLoadingInfos = [[self class] allProgramLoadingInfos];
    for (ProgramLoadingInfo *programLoadingInfo in allProgramLoadingInfos) {
        if ([programID isEqualToString:programLoadingInfo.programID]) {
            return YES;
        }
    }
    return NO;
}

+ (BOOL)areThereAnyPrograms
{
    return ((BOOL)[[self allProgramNames] count]);
}

+ (BOOL)isLastUsedProgram:(NSString*)programName programID:(NSString*)programID
{
    ProgramLoadingInfo *lastUsedInfo = [Util lastUsedProgramLoadingInfo];
    ProgramLoadingInfo *info = [ProgramLoadingInfo programLoadingInfoForProgramWithName:programName
                                                                              programID:programID];
    return [lastUsedInfo isEqualToLoadingInfo:info];
}

+ (void)setLastUsedProgram:(Program*)program
{
    [Util setLastProgramWithName:program.header.programName programID:program.header.programID];
}

+ (NSString*)basePath
{
    return [NSString stringWithFormat:@"%@/%@/", [Util applicationDocumentsDirectory], kProgramsFolder];
}

+ (NSArray*)allProgramNames
{
    NSArray *allProgramLoadingInfos = [[self class] allProgramLoadingInfos];
    NSMutableArray *programNames = [[NSMutableArray alloc] initWithCapacity:[allProgramLoadingInfos count]];
    for (ProgramLoadingInfo *loadingInfo in allProgramLoadingInfos) {
        [programNames addObject:loadingInfo.visibleName];
    }
    return [programNames copy];
}

+ (NSArray*)allProgramLoadingInfos
{
    NSString *basePath = [Program basePath];
    NSError *error;
    NSArray *subdirNames = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:basePath error:&error];
    NSLogError(error);

    NSMutableArray *programLoadingInfos = [[NSMutableArray alloc] initWithCapacity:subdirNames.count];
    for (NSString *subdirName in subdirNames) {
        // exclude .DS_Store folder on MACOSX simulator
        if ([subdirName isEqualToString:@".DS_Store"]) {
            continue;
        }

        ProgramLoadingInfo *info = [[self class] programLoadingInfoForProgramDirectoryName:subdirName];
        if (! info) {
            NSDebug(@"Unable to load program located in directory %@", subdirName);
            continue;
        }
        NSDebug(@"Adding loaded program: %@", info.basePath);
        [programLoadingInfos addObject:info];
    }
    return programLoadingInfos;
}

+ (NSString*)programDirectoryNameForProgramName:(NSString*)programName programID:(NSString*)programID
{
    return [NSString stringWithFormat:@"%@%@%@", programName, kProgramIDSeparator,
            (programID ? programID : kNoProgramIDYetPlaceholder)];
}

+ (ProgramLoadingInfo*)programLoadingInfoForProgramDirectoryName:(NSString*)directoryName
{
    CBAssert(directoryName);
    NSArray *directoryNameParts = [directoryName componentsSeparatedByString:kProgramIDSeparator];
    if (directoryNameParts.count < 2) {
        return nil;
    }
    NSString *programID = (NSString*)directoryNameParts.lastObject;
    NSString *programName = [directoryName substringToIndex:directoryName.length - programID.length - 1];
    return [ProgramLoadingInfo programLoadingInfoForProgramWithName:programName programID:programID];
}

+ (NSString*)programNameForProgramID:(NSString*)programID
{
    if ((! programID) || (! [programID length])) {
        return nil;
    }
    NSArray *allProgramLoadingInfos = [[self class] allProgramLoadingInfos];
    for (ProgramLoadingInfo *programLoadingInfo in allProgramLoadingInfos) {
        if ([programLoadingInfo.programID isEqualToString:programID]) {
            return programLoadingInfo.visibleName;
        }
    }
    return nil;
}

- (void)removeReferences
{
    [self.broadcastWaitHandler removeSpriteMessages];
    self.broadcastWaitHandler = nil;
    self.spriteObjectBroadcastScripts = nil;
    [self.objectList makeObjectsPerformSelector:@selector(removeReferences)];
}

#pragma mark - broadcasting handling
- (void)setupBroadcastHandling
{
    // reset all lazy (!) instantiated objects
    self.broadcastWaitHandler = nil;
    self.spriteObjectBroadcastScripts = nil;

    for (SpriteObject *spriteObject in self.objectList) {
        NSMutableArray *broadcastScripts = [NSMutableArray array];
        for (Script *script in spriteObject.scriptList) {
            if (! [script isKindOfClass:[BroadcastScript class]]) {
                continue;
            }

            BroadcastScript *broadcastScript = (BroadcastScript*)script;
            [self.broadcastWaitHandler registerSprite:spriteObject forMessage:broadcastScript.receivedMessage];
            [broadcastScripts addObject:broadcastScript];
        }
        [self.spriteObjectBroadcastScripts setObject:broadcastScripts forKey:spriteObject.name];
    }
}

- (void)broadcastAndWait:(NSString*)message senderScript:(Script*)script
{
    NSDebug(@"BroadcastWait: %@", message);
    CBPlayerScheduler *scheduler = [CBPlayerScheduler sharedInstance];
    CBPlayerFrontend *frontend = [CBPlayerFrontend new];
    CBPlayerBackend *backend = [CBPlayerBackend new];
    for (NSString *spriteObjectName in self.spriteObjectBroadcastScripts) {
        NSArray *broadcastScriptList = self.spriteObjectBroadcastScripts[spriteObjectName];
        for (BroadcastScript *broadcastScript in broadcastScriptList) {
            if (! [broadcastScript.receivedMessage isEqualToString:message]) {
                continue;
            }

            dispatch_semaphore_t semaphore = self.broadcastMessageSemaphores[broadcastScript.receivedMessage];
            if (! semaphore) {
                semaphore = dispatch_semaphore_create(0);
                self.broadcastMessageSemaphores[broadcastScript.receivedMessage] = semaphore;
            }

            // case sender script equals receiver script => restart receiver script
            // (sets brick action instruction pointer to zero)
            if (broadcastScript == script) {
                if (! [scheduler isScriptRunning:broadcastScript]) {
                    if (self.broadcastMessageSemaphores[broadcastScript.receivedMessage]) {
                        dispatch_semaphore_signal(self.broadcastMessageSemaphores[broadcastScript.receivedMessage]);
                    }
                    return;
                }
                broadcastScript.calledByOtherScriptBroadcastWait = NO; // no synchronization required here
                NSNumber *counterNumber = self.broadcastScriptCounters[message];
                NSUInteger counter = 0;
                if (counterNumber) {
                    counter = [counterNumber integerValue];
                }
                if (++counter % 12) { // XXX: DIRTY HACK!!
                    [scheduler restartScript:broadcastScript];
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [scheduler restartScript:broadcastScript]; // restart this self-listening BroadcastScript
                    });
                }
                self.broadcastScriptCounters[message] = @(counter);
                continue;
            }

            // case sender script does not equal receiver script => check if receiver script
            // if broadcastScript is not running then start broadcastScript!
            broadcastScript.calledByOtherScriptBroadcastWait = YES; // synchronized!
            if (! [scheduler isScriptRunning:broadcastScript]) {
                // broadcastScript != senderScript
                CBScriptSequenceList *sequenceList = [frontend computeSequenceListForScript:broadcastScript];
                [scheduler addScriptExecContext:[backend executionContextForScriptSequenceList:sequenceList]];
                [scheduler startScript:broadcastScript];
            } else {
                // case broadcast script is already running!
                if (broadcastScript.isCalledByOtherScriptBroadcastWait) {
                    dispatch_semaphore_signal(semaphore); // signal finished broadcast!
                }
                [scheduler restartScript:broadcastScript]; // trigger script to restart
            }
        }
    }
}

- (void)signalForWaitingBroadcastWithMessage:(NSString*)message
{
    dispatch_semaphore_t semaphore = self.broadcastMessageSemaphores[message];
    assert(semaphore);
    dispatch_semaphore_signal(semaphore);
}

- (void)waitingForBroadcastWithMessage:(NSString*)message
{
    dispatch_semaphore_t semaphore = self.broadcastMessageSemaphores[message];
// FIXME: workaround for synchronization issue
    if (! semaphore) {
        semaphore = dispatch_semaphore_create(0);
        self.broadcastMessageSemaphores[message] = semaphore;
    }
    assert(semaphore);
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
}

@end
