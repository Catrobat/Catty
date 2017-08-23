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

#import <Foundation/Foundation.h>

@class Program;
@class ProgramLoadingInfo;
@class FileManager;

@interface ProgramManager : NSObject

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithFileManager:(FileManager *)fileManager;

+ (instancetype)instance;
+ (void)setInstance:(ProgramManager *)instance;

- (Program *)programWithLoadingInfo:(ProgramLoadingInfo *)programLoadingInfo;

- (ProgramLoadingInfo *)addProgram:(Program *)program;

- (void)removeProgramWithLoadingInfo:(ProgramLoadingInfo *)programLoadingInfo;
- (ProgramLoadingInfo *)copyProgramWithLoadingInfo:(ProgramLoadingInfo *)programLoadingInfo destinationProgramName:(NSString *)destinationProgramName;

+ (NSString *)basePath;
+ (NSString *)projectPathForProgram:(Program *)program;

- (NSArray<NSString *> *)allProgramNames;
- (NSArray<ProgramLoadingInfo *> *)allProgramLoadingInfos;

- (Program *)lastUsedProgram;
- (ProgramLoadingInfo *)lastUsedProgramLoadingInfo;
- (void)setAsLastUsedProgram:(Program *)program;

- (void)renameProgram:(Program *)program toName:(NSString *)name;
- (void)setProgramIDOfProgram:(Program *)program toID:(NSString *)programID;

- (void)saveProgram:(Program *)progarm;

- (void)addDefaultProgramToProgramsRootDirectoryIfNoProgramsExist;

@end
