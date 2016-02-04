/**
 *  Copyright (C) 2010-2016 The Catrobat Team
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

@interface Program : NSObject

@property (nonatomic, strong, nonnull) Header *header;
@property (nonatomic, strong, nonnull) NSMutableArray *objectList;
@property (nonatomic, strong, nonnull) VariablesContainer *variables;
@property (nonatomic) BOOL requiresBluetooth;

- (NSInteger)numberOfTotalObjects;
- (NSInteger)numberOfBackgroundObjects;
- (NSInteger)numberOfNormalObjects;
- (SpriteObject* _Nonnull)addObjectWithName:(NSString* _Nonnull)objectName;
- (void)removeObjects:(NSArray* _Nonnull)objects;
- (void)removeObject:(SpriteObject* _Nonnull)object;
- (void)removeObjectFromList:(SpriteObject* _Nonnull)object;
- (NSString* _Nonnull)projectPath;
- (void)removeFromDisk;
- (void)removeReferences;
- (void)saveToDiskWithNotification:(BOOL)notify;
- (BOOL)isLastUsedProgram;
- (void)setAsLastUsedProgram;
- (void)translateDefaultProgram;
- (void)renameToProgramName:(NSString* _Nonnull)programName;
- (void)renameObject:(SpriteObject* _Nonnull)object toName:(NSString* _Nonnull)newObjectName;
- (void)updateDescriptionWithText:(NSString* _Nonnull)descriptionText;
- (nonnull NSArray*)allObjectNames;
- (BOOL)hasObject:(SpriteObject* _Nonnull)object;
- (SpriteObject* _Nonnull)copyObject:(SpriteObject* _Nonnull)sourceObject
    withNameForCopiedObject:(NSString* _Nonnull)nameOfCopiedObject;
- (BOOL)isEqualToProgram:(Program* _Nonnull)program;
- (NSInteger)getRequiredResources;

+ (instancetype _Nonnull)defaultProgramWithName:(NSString* _Nonnull)programName
                                      programID:(NSString* _Nullable)programID;
+ (instancetype _Nonnull)lastUsedProgram;
+ (void)updateLastModificationTimeForProgramWithName:(NSString* _Nonnull)programName
                                           programID:(NSString* _Nonnull)programID;
+ (instancetype _Nonnull)programWithLoadingInfo:(ProgramLoadingInfo* _Nonnull)loadingInfo;
+ (BOOL)programExistsWithProgramName:(NSString* _Nonnull)programName
                           programID:(NSString* _Nonnull)programID;
+ (BOOL)programExistsWithProgramID:(NSString* _Nonnull)programID;
+ (BOOL)areThereAnyPrograms;
+ (void)copyProgramWithSourceProgramName:(NSString* _Nonnull)sourceProgramName
                         sourceProgramID:(NSString* _Nonnull)sourceProgramID
                  destinationProgramName:(NSString* _Nonnull)destinationProgramName;
+ (void)removeProgramFromDiskWithProgramName:(NSString* _Nonnull)programName
                                   programID:(NSString* _Nonnull)programID;
+ (BOOL)isLastUsedProgram:(NSString* _Nonnull)programName programID:(NSString* _Nonnull)programID;
+ (void)setLastUsedProgram:(Program* _Nonnull)program;
+ (NSString* _Nonnull)basePath;
+ (NSArray* _Nonnull)allProgramNames;
+ (NSArray* _Nonnull)allProgramLoadingInfos;
+ (NSString* _Nonnull)programDirectoryNameForProgramName:(NSString* _Nonnull)programName
                                               programID:(NSString* _Nullable)programID;
+ (ProgramLoadingInfo* _Nonnull)programLoadingInfoForProgramDirectoryName:(NSString* _Nonnull)programDirectoryName;
+ (NSString* _Nonnull)programNameForProgramID:(NSString* _Nonnull)programID;

@end
