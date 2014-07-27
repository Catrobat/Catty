/**
 *  Copyright (C) 2010-2014 The Catrobat Team
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
#import "AppDefines.h"
#import "SpriteObject.h"
#import "AppDelegate.h"
#import "FileManager.h"
#import "GDataXMLNode+PrettyFormatterExtensions.h"
#import "SensorHandler.h"
#import "ProgramLoadingInfo.h"
#import "Parser.h"
#import "Script.h"
#import "Brick.h"
#import "LanguageTranslationDefines.h"
#import "UserVariable.h"
#import "OrderedMapTable.h"

@implementation Program

@synthesize objectList = _objectList;

- (void)dealloc
{
    NSDebug(@"Dealloc Program");
}

# pragma mark - factories
+ (instancetype)defaultProgramWithName:(NSString*)programName
{
    programName = [Util uniqueName:programName existingNames:[[self class] allProgramNames]];
    Program* program = [[Program alloc] init];
    program.header = [[Header alloc] init];
    program.header.applicationBuildName = nil;
    program.header.applicationBuildNumber = kCatrobatApplicationBuildNumber;
    program.header.applicationName = [Util getProjectName];
    program.header.applicationVersion = [Util getProjectVersion];
    program.header.catrobatLanguageVersion = kCatrobatLanguageVersion;
    program.header.dateTimeUpload = nil;
    program.header.description = @"********** TODO: CHANGE THIS **********"; // TODO: has to be changed
    program.header.deviceName = [Util getDeviceName];
    program.header.mediaLicense = kCatrobatMediaLicense;
    program.header.platform = [Util getPlatformName];
    program.header.platformVersion = [Util getPlatformVersion];
    program.header.programLicense = kCatrobatProgramLicense;
    program.header.programName = programName;
    program.header.remixOf = nil; // no remix
    program.header.screenHeight = @([Util getScreenHeight]);
    program.header.screenWidth = @([Util getScreenWidth]);
    program.header.screenMode = kCatrobatScreenModeStretch;
    program.header.url = nil;
    program.header.userHandle = nil;
    program.header.programScreenshotManuallyTaken = kCatrobatProgramScreenshotDefaultValue;
    program.header.tags = nil;

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

    [program addObjectWithName:kGeneralBackgroundObjectName];
    [program addObjectWithName:kGeneralDefaultObjectName];
    NSLog(@"%@", [program description]);
    return program;
}

+ (instancetype)programWithLoadingInfo:(ProgramLoadingInfo*)loadingInfo;
{
    NSDebug(@"Try to load project '%@'", loadingInfo.visibleName);
    NSDebug(@"Path: %@", loadingInfo.basePath);
    NSString *xmlPath = [NSString stringWithFormat:@"%@%@", loadingInfo.basePath, kProgramCodeFileName];
    NSDebug(@"XML-Path: %@", xmlPath);
    Parser *parser = [[Parser alloc] init];
    Program *program = [parser generateObjectForProgramWithPath:xmlPath];
    program.XMLdocument = parser.XMLdocument;

    if (! program)
        return nil;

    NSLog(@"%@", [program description]);
    NSDebug(@"ProjectResolution: width/height:  %f / %f", program.header.screenWidth.floatValue, program.header.screenHeight.floatValue);

    // setting effect
    for (SpriteObject *sprite in program.objectList) {
        for (Script *script in sprite.scriptList) {
            for (Brick *brick in script.brickList) {
                brick.object = sprite;
            }
        }
    }

    [self updateLastModificationTimeForProgramWithName:loadingInfo.visibleName];
    return program;
}

+ (instancetype)lastProgram
{
    NSString *lastProgramName = [Util lastProgram];
    ProgramLoadingInfo *loadingInfo = [Util programLoadingInfoForProgramWithName:lastProgramName];
    return [Program programWithLoadingInfo:loadingInfo];
}

+ (void)updateLastModificationTimeForProgramWithName:(NSString*)programName
{
    NSString *xmlPath = [NSString stringWithFormat:@"%@%@",
                         [self projectPathForProgramWithName:programName],
                         kProgramCodeFileName];

    AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [appDelegate.fileManager changeModificationDate:[NSDate date]
                                      forFileAtPath:xmlPath];
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
    //object.spriteManagerDelegate;
    //object.broadcastWaitDelegate = self.broadcastWaitHandler;
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
            // TODO: remove all sounds, images from disk that are not needed any more...
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
- (NSMutableArray*)objectList
{
    // lazy instantiation
    if (! _objectList)
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

- (VariablesContainer*)variables
{
    // lazy instantiation
    if (! _variables)
        _variables = [[VariablesContainer alloc] init];
    return _variables;
}

- (NSString*)projectPath
{
    return [Program projectPathForProgramWithName:self.header.programName];
}

+ (NSString*)projectPathForProgramWithName:(NSString*)programName
{
    return [NSString stringWithFormat:@"%@%@/", [Program basePath], programName];
}

- (void)removeFromDisk
{
    [Program removeProgramFromDiskWithProgramName:self.header.programName];
}

+ (void)copyProgramWithName:(NSString*)sourceProgramName
     destinationProgramName:(NSString*)destinationProgramName
{
    NSString *sourceProgramPath = [[self class] projectPathForProgramWithName:sourceProgramName];
    destinationProgramName = [Util uniqueName:destinationProgramName existingNames:[self allProgramNames]];
    NSString *destinationProgramPath = [[self class] projectPathForProgramWithName:destinationProgramName];

    AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [appDelegate.fileManager copyExistingDirectoryAtPath:sourceProgramPath toPath:destinationProgramPath];
    ProgramLoadingInfo *destinationProgramLoadingInfo = [[ProgramLoadingInfo alloc] init];
    destinationProgramLoadingInfo.basePath = destinationProgramPath;
    destinationProgramLoadingInfo.visibleName = destinationProgramName;
    Program *program = [Program programWithLoadingInfo:destinationProgramLoadingInfo];
    program.header.programName = destinationProgramLoadingInfo.visibleName;
    [program saveToDisk];
}

+ (void)removeProgramFromDiskWithProgramName:(NSString*)programName
{
    FileManager *fileManager = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).fileManager;
    NSString *projectPath = [self projectPathForProgramWithName:programName];
    if ([fileManager directoryExists:projectPath]) {
        [fileManager deleteDirectory:projectPath];
    }

    NSString *basePath = [Program basePath];
    NSError *error;
    NSArray *programLoadingInfos = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:basePath error:&error];
    NSLogError(error);

    // if this is currently set as last program, then look for next program to set it as the last program
    if ([Program isLastProgram:programName]) {
        [Util setLastProgram:nil];
        for (NSString *programLoadingInfo in programLoadingInfos) {
            // exclude .DS_Store folder on MACOSX simulator
            if ([programLoadingInfo isEqualToString:@".DS_Store"])
                continue;

            [Util setLastProgram:programLoadingInfo];
            break;
        }
    }

    // if there are no programs left, then automatically recreate default program
    [fileManager addDefaultProgramToProgramsRootDirectoryIfNoProgramsExist];
}

- (GDataXMLElement*)toXML
{
    GDataXMLElement *rootXMLElement = [GDataXMLNode elementWithName:@"program"];
    [rootXMLElement addChild:[self.header toXML]];

    GDataXMLElement *objectListXMLElement = [GDataXMLNode elementWithName:@"objectList"];
    for (id object in self.objectList) {
        if ([object isKindOfClass:[SpriteObject class]])
            [objectListXMLElement addChild:[((SpriteObject*) object) toXML]];
    }
    [rootXMLElement addChild:objectListXMLElement];

    if (self.variables) {
        GDataXMLElement *variablesXMLElement = [GDataXMLNode elementWithName:@"variables"];
        VariablesContainer *variableLists = self.variables;

        GDataXMLElement *objectVariableListXMLElement = [GDataXMLNode elementWithName:@"objectVariableList"];
        // TODO: uncomment this after toXML methods are implemented
        NSUInteger totalNumOfObjectVariables = [variableLists.objectVariableList count];
//        NSUInteger totalNumOfProgramVariables = [variableLists.programVariableList count];
        for (NSUInteger index = 0; index < totalNumOfObjectVariables; ++index) {
            NSArray *variables = [variableLists.objectVariableList objectAtIndex:index];
            GDataXMLElement *entryXMLElement = [GDataXMLNode elementWithName:@"entry"];
            GDataXMLElement *entryToObjectReferenceXMLElement = [GDataXMLNode elementWithName:@"object"];
            [entryToObjectReferenceXMLElement addAttribute:[GDataXMLNode elementWithName:@"reference" stringValue:@"../../../../objectList/object[6]"]];
            [entryXMLElement addChild:entryToObjectReferenceXMLElement];
            GDataXMLElement *listXMLElement = [GDataXMLNode elementWithName:@"list"];
            for (id variable in variables) {
                if ([variable isKindOfClass:[UserVariable class]])
                    [listXMLElement addChild:[((UserVariable*)variable) toXMLforProgram:self]];
            }
            [entryXMLElement addChild:listXMLElement];
            [objectVariableListXMLElement addChild:entryXMLElement];
        }
//        if (totalNumOfObjectVariables) {
            [variablesXMLElement addChild:objectVariableListXMLElement];
//        }

        GDataXMLElement *programVariableListXMLElement = [GDataXMLNode elementWithName:@"programVariableList"];
        for (id variable in variableLists.programVariableList) {
            if ([variable isKindOfClass:[UserVariable class]])
                [programVariableListXMLElement addChild:[((UserVariable*) variable) toXMLforProgram:self]];
        }
//        if (totalNumOfProgramVariables) {
            [variablesXMLElement addChild:programVariableListXMLElement];
//        }

//        if (totalNumOfObjectVariables || totalNumOfProgramVariables) {
            [rootXMLElement addChild:variablesXMLElement];
//        }
    }

    return rootXMLElement;
}

#define SIMULATOR_DEBUGGING_ENABLED 1
#define SIMULATOR_DEBUGGING_BASE_PATH @"/Users/ralph/Desktop/diff"

- (void)saveToDisk
{
    dispatch_queue_t saveToDiskQ = dispatch_queue_create("save to disk", NULL);
    dispatch_async(saveToDiskQ, ^{
        // background thread
        GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithRootElement:[self toXML]];
        //    NSData *xmlData = document.XMLData;
        NSString *xmlString = [NSString stringWithFormat:@"%@\n%@",
                               kCatrobatXMLDeclaration,
                               [document.rootElement XMLStringPrettyPrinted:YES]];
        // TODO: outsource this to file manager
        NSError *error = nil;
        NSString *xmlPath = [NSString stringWithFormat:@"%@%@", [self projectPath], kProgramCodeFileName];
        [xmlString writeToFile:xmlPath atomically:YES encoding:NSUTF8StringEncoding error:&error];
        NSLogError(error);
#ifdef SIMULATOR_DEBUGGING_ENABLED
        NSString *referenceXmlString = [NSString stringWithFormat:@"%@\n%@",
                                        kCatrobatXMLDeclaration,
                                        [self.XMLdocument.rootElement XMLStringPrettyPrinted:YES]];
//        NSLog(@"Reference XML-Document:\n\n%@\n\n", referenceXmlString);
//        NSLog(@"XML-Document:\n\n%@\n\n", xmlString);
        NSString *referenceXmlPath = [NSString stringWithFormat:@"%@/reference.xml", SIMULATOR_DEBUGGING_BASE_PATH];
        NSString *generatedXmlPath = [NSString stringWithFormat:@"%@/generated.xml", SIMULATOR_DEBUGGING_BASE_PATH];
        [referenceXmlString writeToFile:referenceXmlPath
                             atomically:YES
                               encoding:NSUTF8StringEncoding
                                  error:&error];
        [xmlString writeToFile:generatedXmlPath
                    atomically:YES
                      encoding:NSUTF8StringEncoding
                         error:&error];

//#import <Foundation/NSTask.h> // debugging for OSX
//        NSTask *task = [[NSTask alloc] init];
//        [task setLaunchPath:@"/usr/bin/diff"];
//        [task setArguments:[NSArray arrayWithObjects:referenceXmlPath, generatedXmlPath, nil]];
//        [task setStandardOutput:[NSPipe pipe]];
//        [task setStandardInput:[NSPipe pipe]]; // piping to NSLog-tty (terminal emulator)
//        [task launch];
//        [task release];
#endif

        // update last access time
        [[self class] updateLastModificationTimeForProgramWithName:self.header.programName];

        // maybe later call some functions back here, that should update the UI on main thread...
        dispatch_async(dispatch_get_main_queue(), ^{
            NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
            [notificationCenter postNotificationName:kHideLoadingViewNotification object:self];
            [notificationCenter postNotificationName:kShowSavedViewNotification object:self];
        });
//        // execute 2 seconds later => just for testing purposes
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
//            [[NSNotificationCenter defaultCenter] postNotificationName:kHideLoadingViewNotification object:self];
//        });
    });
}

- (BOOL)isLastProgram
{
    return [Program isLastProgram:self.header.programName];
}

- (void)setAsLastProgram
{
    [Program setLastProgram:self];
}

- (void)renameToProgramName:(NSString *)programName
{
    if ([self.header.programName isEqualToString:programName]) {
        return;
    }
    BOOL isLastProgram = [self isLastProgram];
    NSString *oldPath = [self projectPath];
    self.header.programName = [Util uniqueName:programName existingNames:[[self class] allProgramNames]];
    NSString *newPath = [self projectPath];
    [[[FileManager alloc] init] moveExistingDirectoryAtPath:oldPath toPath:newPath];
    if (isLastProgram) {
        [Util setLastProgram:self.header.programName];
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

- (void)updateDescriptionWithText:(NSString *)descriptionText
{
    self.header.description = descriptionText;
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
    SpriteObject *copiedObject = [sourceObject deepCopy];
    copiedObject.name = [Util uniqueName:nameOfCopiedObject existingNames:[self allObjectNames]];
    [self.objectList addObject:copiedObject];
    [self saveToDisk];
    return copiedObject;
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
    [ret appendFormat:@"------------------------------------------------\n"];
    return [NSString stringWithString:ret];
}

+ (BOOL)programExists:(NSString*)programName
{
    NSString *projectPath = [NSString stringWithFormat:@"%@%@/", [Program basePath], programName];
    return [[[FileManager alloc] init] directoryExists:projectPath];
}

+ (BOOL)isLastProgram:(NSString*)programName
{
    return ([programName isEqualToString:[Util lastProgram]]);
}

+ (void)setLastProgram:(Program*)program
{
    [Util setLastProgram:program.header.programName];
}

+ (NSString*)basePath
{
    return [NSString stringWithFormat:@"%@/%@/", [Util applicationDocumentsDirectory], kProgramsFolder];
}

+ (NSArray*)allProgramNames
{
    NSString *basePath = [Program basePath];
    NSError *error;
    NSArray *subdirectoryNames = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:basePath error:&error];
    NSLogError(error);

    NSMutableArray *programNames = [[NSMutableArray alloc] initWithCapacity:[subdirectoryNames count]];
    for (NSString *subdirectoryName in subdirectoryNames) {
        // exclude .DS_Store folder on MACOSX simulator
        if ([subdirectoryName isEqualToString:@".DS_Store"])
            continue;
        [programNames addObject:subdirectoryName];
    }
    return [programNames copy];
}

+ (NSArray*)allProgramLoadingInfos
{
    NSString *basePath = [Program basePath];
    NSError *error;
    NSArray *subdirectoryNames = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:basePath error:&error];
    NSLogError(error);

    NSMutableArray *programLoadingInfos = [[NSMutableArray alloc] initWithCapacity:[subdirectoryNames count]];
    for (NSString *subdirectoryName in subdirectoryNames) {
        // exclude .DS_Store folder on MACOSX simulator
        if ([subdirectoryName isEqualToString:@".DS_Store"])
            continue;

        ProgramLoadingInfo *info = [[ProgramLoadingInfo alloc] init];
        info.basePath = [NSString stringWithFormat:@"%@%@/", basePath, subdirectoryName];
        info.visibleName = subdirectoryName;
        NSDebug(@"Adding loaded program: %@", info.basePath);
        [programLoadingInfos addObject:info];
    }
    return [programLoadingInfos copy];
}

@end
