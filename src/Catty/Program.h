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


#import <UIKit/UIKit.h>
#import "Header.h"
#import "ProgramDefines.h"

@class VariablesContainer;
@class SpriteObject;
@class ProgramLoadingInfo;

@interface Program : NSObject

@property (nonatomic, strong) Header *header;
@property (nonatomic, strong) NSMutableArray *objectList;
@property (nonatomic, strong) VariablesContainer *variables;
- (NSInteger)numberOfTotalObjects;
- (NSInteger)numberOfBackgroundObjects;
- (NSInteger)numberOfNormalObjects;
- (SpriteObject*)addNewObjectWithName:(NSString*)objectName;
- (void)removeObject:(SpriteObject*)object;
- (NSString*)projectPath;
- (void)removeFromDisk;
- (void)saveToDisk;
- (BOOL)isLastProgram;
- (void)setAsLastProgram;
- (void)renameToProgramName:(NSString*)programName;

+ (instancetype)defaultProgramWithName:(NSString*)programName;
+ (instancetype)lastProgram;
+ (instancetype)programWithLoadingInfo:(ProgramLoadingInfo*)loadingInfo;
+ (BOOL)programExists:(NSString *)programName;
+ (kProgramNameValidationResult)validateProgramName:(NSString*)programName;
+ (void)removeProgramFromDiskWithProgramName:(NSString*)programName;
+ (BOOL)isLastProgram:(NSString*)programName;
+ (void)setLastProgram:(Program*)program;
+ (NSString*)basePath;

@end
