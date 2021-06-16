/**
 *  Copyright (C) 2010-2021 The Catrobat Team
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
#import "CBXMLAbstractContext.h"

@class CBXMLOpenedNestingBricksStack;
@class CBXMLPositionStack;
@class SpriteObject;
@class UserDataContainer;
@class GDataXMLElement;
@protocol CBXMLNodeProtocol;

@interface CBXMLParserContext : CBXMLAbstractContext

@property (nonatomic, readonly) CGFloat languageVersion;

@property (nonatomic, strong) GDataXMLElement *rootElement;
@property (nonatomic, strong) GDataXMLElement *currentSceneElement;

//------------------------------------------------------------------------------------------------------------
// resources data used while traversing the tree
//------------------------------------------------------------------------------------------------------------
@property (nonatomic, strong) NSMutableArray *programVariableList; // (used for parsing only)
@property (nonatomic, strong) NSMutableArray *programListOfLists; // (used for parsing only)

@property (nonatomic, strong) NSMutableSet<NSString*> *unsupportedElements; // (used for parsing only)

- (instancetype)initWithLanguageVersion:(CGFloat)languageVersion andRootElement:(GDataXMLElement *)rootElement NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

- (id)parseFromElement:(GDataXMLElement*)xmlElement withClass:(Class<CBXMLNodeProtocol>)modelClass;
- (id)mutableCopy;

@end
