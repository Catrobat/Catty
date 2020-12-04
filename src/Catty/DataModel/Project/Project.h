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

#import "Header.h"
#import "ProjectDefines.h"

@class UserDataContainer;
@class SpriteObject;
@class ProjectLoadingInfo;
@class Scene;

@interface Project : NSObject

@property (nonatomic, strong, nonnull) Header *header;
@property (nonatomic, strong, nonnull) Scene *scene;
@property (nonatomic, strong, nonnull) UserDataContainer *userData;
@property (nonatomic, strong, nonnull) NSMutableSet<NSString*> *unsupportedElements;
@property (nonatomic) BOOL requiresBluetooth;
@property (nonatomic, strong, nullable) NSMutableOrderedSet *allBroadcastMessages;

- (instancetype _Nonnull)init;
- (NSString* _Nonnull)projectPath;
- (void)removeFromDisk;
- (void)removeReferences;
- (void)saveToDiskWithNotification:(BOOL)notify;
- (void)saveToDiskWithNotification:(BOOL)notify andCompletion:(void (^ _Nullable)(void))completion;
- (BOOL)isLastUsedProject;
- (void)setAsLastUsedProject;
- (void)translateDefaultProject;
- (void)renameToProjectName:(NSString* _Nonnull)projectName andShowSaveNotification:(BOOL)showSaveNotification;
- (void)renameToProjectName:(NSString* _Nonnull)projectName andProjectId:(NSString* _Nonnull)projectId andShowSaveNotification:(BOOL)showSaveNotification;
- (void)setDescription:(NSString* _Nonnull)description;
- (NSArray<SpriteObject*>* _Nonnull)allObjects;
- (BOOL)isEqualToProject:(Project* _Nonnull)project;
- (NSInteger)getRequiredResources;
-(void)changeProjectOrientation;

+ (instancetype _Nonnull)lastUsedProject;
+ (void)updateLastModificationTimeForProjectWithName:(NSString* _Nonnull)projectName
                                           projectID:(NSString* _Nonnull)projectID;
+ (nullable instancetype)projectWithLoadingInfo:(ProjectLoadingInfo* _Nonnull)loadingInfo;
+ (BOOL)projectExistsWithProjectName:(NSString* _Nonnull)projectName
                           projectID:(NSString* _Nonnull)projectID;
+ (BOOL)projectExistsWithProjectID:(NSString* _Nonnull)projectID;
+ (BOOL)areThereAnyProjects;
+ (void)copyProjectWithSourceProjectName:(NSString* _Nonnull)sourceProjectName
                         sourceProjectID:(NSString* _Nonnull)sourceProjectID
                  destinationProjectName:(NSString* _Nonnull)destinationProjectName;
+ (void)removeProjectFromDiskWithProjectName:(NSString* _Nonnull)projectName
                                   projectID:(NSString* _Nonnull)projectID;
+ (BOOL)isLastUsedProject:(NSString* _Nonnull)projectName projectID:(NSString* _Nonnull)projectID;
+ (void)setLastUsedProject:(Project* _Nonnull)project;
+ (NSString* _Nonnull)basePath;
+ (NSArray* _Nonnull)allProjectNames;
+ (NSArray* _Nonnull)allProjectLoadingInfos;
+ (NSString* _Nonnull)projectDirectoryNameForProjectName:(NSString* _Nonnull)projectName
                                               projectID:(NSString* _Nullable)projectID;
+ (nullable ProjectLoadingInfo *)projectLoadingInfoForProjectDirectoryName:(NSString* _Nonnull)projectDirectoryName;
+ (nullable NSString *)projectNameForProjectID:(NSString* _Nonnull)projectID;

@end
