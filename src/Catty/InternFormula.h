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

#import <Foundation/Foundation.h>
#import "ExternInternRepresentationMapping.h"
#import "InternFormulaTokenSelection.h"
#import "InternToken.h"
#import "InternFormulaParser.h"
#import "InternFormulaUtils.h"
#import "InternFormulaKeyboardAdapter.h"
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
    PARSER_ERROR_SELECTION
}TokenSelectionType;


@interface InternFormula : NSObject

-(InternFormula *)initWithInternTokenList:(NSMutableArray *)internTokenList;
-(InternFormula *)initWithInternTokenList:(NSMutableArray *)internTokenList
              internFormulaTokenSelection:(InternFormulaTokenSelection *)internFormulaTokenSelection
                     externCursorPosition:(int)externCursorPosition;
-(void)handleKeyInputWithName:(NSString *)name butttonType:(int)resourceId;
-(NSString *)getExternFormulaString;
-(void)generateExternFormulaStringAndInternExternMapping;
-(void)setCursorAndSelection:(int)externCursorPosition
                    selected:(BOOL)isSelected;
-(InternFormulaState*)getInternFormulaState;
-(InternFormulaParser *)getInternFormulaParser;
-(void)setExternCursorPositionRightTo:(int)internTokenIndex;
-(void)updateInternCursorPosition;
-(void)selectWholeFormula;

@end
