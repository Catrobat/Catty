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

#import "CBXMLParserContext.h"
#import "CBXMLOpenedNestingBricksStack.h"
#import "CBXMLPositionStack.h"
#import "VariablesContainer.h"
#import "GDataXMLElement+CustomExtensions.h"
#import "CBXMLNodeProtocol.h"

@implementation CBXMLParserContext

#pragma mark - Initialisation
- (id)initWithLanguageVersion:(CGFloat)languageVersion
{
    self = [super init];
    if (self) {
        _languageVersion = languageVersion;
    }
    return self;
}

#pragma mark - CatrobatLanguageVersion selection
- (id)parseFromElement:(GDataXMLElement*)xmlElement withClass:(Class<CBXMLNodeProtocol>)modelClass
{
    if (self.languageVersion == 0.93f) {
        return [modelClass parseFromElement:xmlElement withContextForLanguageVersion093:self];
    } else if (self.languageVersion >= 0.94f && self.languageVersion <= 0.97f) {
        return [modelClass parseFromElement:xmlElement withContextForLanguageVersion095:self];
    } else {
        NSError(@"Unsupported CatrobatLanguageVersion %.2f", self.languageVersion);
    }
    return nil;
}

#pragma mark - Getters and Setters
- (NSMutableArray*)programVariableList
{
    if (! _programVariableList) {
        _programVariableList = [NSMutableArray array];
    }
    return _programVariableList;
}

- (NSMutableDictionary*)spriteObjectNameVariableList
{
    if (! _spriteObjectNameVariableList) {
        _spriteObjectNameVariableList = [NSMutableDictionary dictionary];
    }
    return _spriteObjectNameVariableList;
}

- (NSMutableDictionary*)formulaVariableNameList
{
    if (! _formulaVariableNameList) {
        _formulaVariableNameList = [NSMutableDictionary dictionary];
    }
    return _formulaVariableNameList;
}

- (void)setLanguageVersion:(CGFloat)languageVersion
{
    _languageVersion = languageVersion;
}

#pragma mark - Copy
- (id)mutableCopy
{
    CBXMLParserContext *copiedContext = [super mutableCopy];
    copiedContext.programVariableList = [self.programVariableList mutableCopy];
    copiedContext.formulaVariableNameList = [self.formulaVariableNameList mutableCopy];
    copiedContext.spriteObjectNameVariableList = [self.spriteObjectNameVariableList mutableCopy];
    [copiedContext setLanguageVersion:self.languageVersion];
    return copiedContext;
}

@end
