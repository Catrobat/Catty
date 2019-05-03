/**
 *  Copyright (C) 2010-2019 The Catrobat Team
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
#import "ExternInternRepresentationMapping.h"
#import "InternFormulaTokenSelection.h"
#import "InternToken.h"
#import "InternFormulaParser.h"
#import "InternFormulaUtils.h"
#import "InternToExternGenerator.h"
#import "InternFormulaState.h"

typedef enum {
    LEFT = 600,
    MIDDLE,
    RIGHT
    
}CursorTokenPosition;

typedef enum{
    AM_LEFT = 700,
    AM_RIGHT,
    SELECT,
    DO_NOT_MODIFY
}CursorTokenPropertiesAfterModification;

typedef enum TokenSelectionType{
    USER_SELECTION = 800,
    PARSER_ERROR_SELECTION = 801
}TokenSelectionType;


@interface InternFormula : NSObject

- (InternFormula *)initWithInternTokenList:(NSMutableArray<InternToken*>*)internTokenList;
- (InternFormula *)initWithInternTokenList:(NSMutableArray<InternToken*>*)internTokenList
              internFormulaTokenSelection:(InternFormulaTokenSelection *)internFormulaTokenSelection
                     externCursorPosition:(int)externCursorPosition;
- (void)handleKeyInputWithName:(NSString *)name buttonType:(int)resourceId;
- (void)handleKeyInputWithInternTokenList:(NSMutableArray<InternToken*>*)keyInputInternTokenList andResourceId:(int)resourceId;
- (NSString *)getExternFormulaString;
- (void)generateExternFormulaStringAndInternExternMapping;
- (void)setCursorAndSelection:(int)externCursorPosition
                    selected:(BOOL)isSelected;
- (InternFormulaState*)getInternFormulaState;
- (void)setExternCursorPositionRightTo:(int)internTokenIndex;
- (void)updateInternCursorPosition;
- (void)selectWholeFormula;
- (BOOL)isEmpty;
- (int)getExternCursorPosition;
- (int)getExternSelectionEndIndex;
- (int)getExternSelectionStartIndex;
- (NSArray<InternToken*>*)getInternTokenList;
- (TokenSelectionType)getExternSelectionType;
- (InternFormulaTokenSelection *)getSelection;
- (void)selectParseErrorTokenAndSetCursor;

@end
