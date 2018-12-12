/**
 *  Copyright (C) 2010-2018 The Catrobat Team
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
#import "GDataXMLElement+CustomExtensions.h"
#import "CBXMLNodeProtocol.h"
#import "Util.h"

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

#pragma mark - CatrobatLanguageVersion check
- (id)parseFromElement:(GDataXMLElement*)xmlElement withClass:(Class<CBXMLNodeProtocol>)modelClass
{
    if (self.languageVersion >= 0.93f && self.languageVersion <= [[Util catrobatLanguageVersion] floatValue]) {
        return [modelClass parseFromElement:xmlElement withContext:self];
    } else {
        NSError(@"Unsupported CatrobatLanguageVersion %g", self.languageVersion);
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

- (NSMutableArray*)programListOfLists
{
    if (! _programListOfLists) {
        _programListOfLists = [NSMutableArray array];
    }
    return _programListOfLists;
}

- (NSMutableDictionary*)spriteObjectNameVariableList
{
    if (! _spriteObjectNameVariableList) {
        _spriteObjectNameVariableList = [NSMutableDictionary dictionary];
    }
    return _spriteObjectNameVariableList;
}

- (NSMutableDictionary*)spriteObjectNameListOfLists
{
    if (! _spriteObjectNameListOfLists) {
        _spriteObjectNameListOfLists = [NSMutableDictionary dictionary];
    }
    return _spriteObjectNameListOfLists;
}

- (NSMutableDictionary*)formulaVariableNameList
{
    if (! _formulaVariableNameList) {
        _formulaVariableNameList = [NSMutableDictionary dictionary];
    }
    return _formulaVariableNameList;
}

- (NSMutableDictionary*)formulaListNameList
{
    if (! _formulaListNameList) {
        _formulaListNameList = [NSMutableDictionary dictionary];
    }
    return _formulaListNameList;
}

- (NSMutableSet<NSString*>*)unsupportedElements
{
    if (! _unsupportedElements) {
        _unsupportedElements = [[NSMutableSet alloc] init];
    }
    return _unsupportedElements;
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
    copiedContext.programListOfLists = [self.programListOfLists mutableCopy];
    copiedContext.formulaVariableNameList = [self.formulaVariableNameList mutableCopy];
    copiedContext.formulaListNameList = [self.formulaListNameList mutableCopy];
    copiedContext.spriteObjectNameVariableList = [self.spriteObjectNameVariableList mutableCopy];
    copiedContext.spriteObjectNameListOfLists = [self.spriteObjectNameListOfLists mutableCopy];
    [copiedContext setLanguageVersion:self.languageVersion];
    return copiedContext;
}

@end
