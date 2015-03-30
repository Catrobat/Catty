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

#import "Header.h"
#import "ProgramDefines.h"

@class VariablesContainer;
@class SpriteObject;
@class ProgramLoadingInfo;
@class GDataXMLDocument;
@class Script;
@class BroadcastScript;

@interface Program : NSObject

@property (nonatomic, strong) Header *header;
@property (nonatomic, strong) NSMutableArray *objectList;
@property (nonatomic, strong) VariablesContainer *variables;
@property (nonatomic, getter=isPlaying) BOOL playing;

// FIXME: remove this property after serialization works
@property (nonatomic, strong) GDataXMLDocument *XMLdocument;

- (NSInteger)numberOfTotalObjects;
- (NSInteger)numberOfBackgroundObjects;
- (NSInteger)numberOfNormalObjects;
- (SpriteObject*)addObjectWithName:(NSString*)objectName;
- (void)removeObjects:(NSArray*)objects;
- (void)removeObject:(SpriteObject*)object;
- (NSString*)projectPath;
- (void)removeFromDisk;
- (void)removeReferences;
- (void)saveToDisk;
- (BOOL)isLastUsedProgram;
- (void)setAsLastUsedProgram;
- (void)translateDefaultProgram;
- (void)renameToProgramName:(NSString*)programName;
- (void)renameObject:(SpriteObject*)object toName:(NSString*)newObjectName;
- (void)updateDescriptionWithText:(NSString*)descriptionText;
- (NSArray*)allObjectNames;
- (BOOL)hasObject:(SpriteObject*)object;
- (SpriteObject*)copyObject:(SpriteObject*)sourceObject
    withNameForCopiedObject:(NSString*)nameOfCopiedObject;
- (BOOL)isEqualToProgram:(Program*)program;
- (void)setupBroadcastHandling;
- (void)broadcast:(NSString*)message senderScript:(Script*)script;
- (void)broadcastAndWait:(NSString*)message senderScript:(Script*)script;
- (void)signalForWaitingBroadcastWithMessage:(NSString*)message;
- (void)waitingForBroadcastWithMessage:(NSString*)message;

+ (instancetype)defaultProgramWithName:(NSString*)programName programID:(NSString*)programID;
+ (instancetype)lastUsedProgram;
+ (void)updateLastModificationTimeForProgramWithName:(NSString*)programName programID:(NSString*)programID;
+ (instancetype)programWithLoadingInfo:(ProgramLoadingInfo*)loadingInfo;
+ (BOOL)programExistsWithProgramName:(NSString*)programName programID:(NSString*)programID;
+ (BOOL)programExistsWithProgramID:(NSString*)programID;
+ (BOOL)areThereAnyPrograms;

+ (void)copyProgramWithSourceProgramName:(NSString*)sourceProgramName
                         sourceProgramID:(NSString*)sourceProgramID
                  destinationProgramName:(NSString*)destinationProgramName;
+ (void)removeProgramFromDiskWithProgramName:(NSString*)programName programID:(NSString*)programID;
+ (BOOL)isLastUsedProgram:(NSString*)programName programID:(NSString*)programID;
+ (void)setLastUsedProgram:(Program*)program;
+ (NSString*)basePath;
+ (NSArray*)allProgramNames;
+ (NSArray*)allProgramLoadingInfos;
+ (NSString*)programDirectoryNameForProgramName:(NSString*)programName programID:(NSString*)programID;
+ (ProgramLoadingInfo*)programLoadingInfoForProgramDirectoryName:(NSString*)programDirectoryName;
+ (NSString*)programNameForProgramID:(NSString*)programID;

// FIXME: remove that later... after serialization works... (issue#84)
+ (NSString*)projectPathForProgramWithName:(NSString*)programName programID:(NSString*)programID;

@end
