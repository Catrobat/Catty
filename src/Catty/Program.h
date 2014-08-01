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
@class GDataXMLDocument;

@interface Program : NSObject

@property (nonatomic, strong) Header *header;
@property (nonatomic, strong) NSMutableArray *objectList;
@property (nonatomic, strong) VariablesContainer *variables;

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
- (void)saveToDisk;
- (BOOL)isLastProgram;
- (void)setAsLastProgram;
- (void)translateDefaultProgram;
- (void)renameToProgramName:(NSString*)programName;
- (void)renameObject:(SpriteObject*)object toName:(NSString*)newObjectName;
- (void)updateDescriptionWithText:(NSString*)descriptionText;
- (NSArray*)allObjectNames;
- (BOOL)hasObject:(SpriteObject*)object;
- (SpriteObject*)copyObject:(SpriteObject*)sourceObject
    withNameForCopiedObject:(NSString*)nameOfCopiedObject;

+ (instancetype)defaultProgramWithName:(NSString*)programName;
+ (instancetype)lastProgram;
+ (void)updateLastModificationTimeForProgramWithName:(NSString*)programName;
+ (instancetype)programWithLoadingInfo:(ProgramLoadingInfo*)loadingInfo;
+ (BOOL)programExists:(NSString *)programName;
+ (void)copyProgramWithName:(NSString*)sourceProgramName
     destinationProgramName:(NSString*)destinationProgramName;
+ (void)removeProgramFromDiskWithProgramName:(NSString*)programName;
+ (BOOL)isLastProgram:(NSString*)programName;
+ (void)setLastProgram:(Program*)program;
+ (NSString*)basePath;
+ (NSArray*)allProgramNames;
+ (NSArray*)allProgramLoadingInfos;

// remove this signature after first release
#import "AppDefines.h"
#if kIsFirstRelease
+ (NSString*)projectPathForProgramWithName:(NSString*)programName;
#endif

@end
