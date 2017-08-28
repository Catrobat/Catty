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

#import "Header.h"
#import "ProgramDefines.h"

@class UserVariable;
@class Scene;
@class VariablesContainer;

NS_ASSUME_NONNULL_BEGIN

@interface Program : NSObject

@property (nonatomic, readonly) Header *header;
@property (nonatomic, readonly) NSMutableArray<Scene *> *scenes;
@property (nonatomic, readonly) NSMutableArray<UserVariable *> *programVariableList;

@property (nonatomic, readonly) NSString *programName;
@property (nonatomic, readonly, nullable) NSString *programID;
@property (nonatomic, nullable) NSString *programDescription;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithHeader:(Header *)header scenes:(NSArray<Scene *> *)scenes programVariableList:(NSArray<UserVariable *> *)programVariableList;
+ (instancetype)defaultProgramWithName:(NSString *)programName;

- (NSArray<UserVariable *> *)allVariables;
- (NSArray<NSString *> *)allVariableNames;

- (NSArray<NSString *> *)allSceneNames;

- (void)addScene:(Scene *)scene;
- (void)removeScenes:(NSArray<Scene *> *)scenes;

- (void)addProgramVariable:(UserVariable *)variable;
- (void)removeProgramVariable:(UserVariable *)variable;

- (void)removeReferences;

- (BOOL)isEqualToProgram:(Program *)program;

- (NSInteger)getRequiredResources;

@end

NS_ASSUME_NONNULL_END
