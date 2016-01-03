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

#import <Foundation/Foundation.h>
#import "CBXMLAbstractContext.h"

@class CBXMLOpenedNestingBricksStack;
@class CBXMLPositionStack;
@class SpriteObject;
@class VariablesContainer;
@class GDataXMLElement;
@protocol CBXMLNodeProtocol;

@interface CBXMLParserContext : CBXMLAbstractContext

@property (nonatomic, readonly) CGFloat languageVersion;

//------------------------------------------------------------------------------------------------------------
// ressources data used while traversing the tree
//------------------------------------------------------------------------------------------------------------
// TODO: refactor this later: remove brickList here and dynamically find brick in scriptList. maybe scripts should be referenced in bricks as well!!
@property (nonatomic, strong) NSMutableArray *programVariableList; // (used for parsing only)
@property (nonatomic, strong) NSMutableDictionary *spriteObjectNameVariableList; // (used for parsing only)
@property (nonatomic, strong) NSMutableDictionary *formulaVariableNameList; // (used for parsing only)

- (id)initWithLanguageVersion:(CGFloat)languageVersion;
- (id)parseFromElement:(GDataXMLElement*)xmlElement withClass:(Class<CBXMLNodeProtocol>)modelClass;
- (id)mutableCopy;

@end
