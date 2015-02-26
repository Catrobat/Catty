/**
 *  Copyright (C) 2010-2015 The Catrobat Team
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

#import "FormulaEditorHistory.h"

@interface FormulaEditorHistory()

@property (strong, nonatomic) NSMutableArray *undoStack; // of InternFormulaState*
@property (strong, nonatomic) NSMutableArray *redoStack;
@property (strong, nonatomic) InternFormulaState *current;
@property (nonatomic) BOOL hasUnsavedChanges;

@end

@implementation FormulaEditorHistory

- (id)initWithInternFormulaState:(InternFormulaState*)internFormulaState
{
    self = [super init];
    if(self) {
        self.current = internFormulaState;
        self.undoStack = [[NSMutableArray alloc] init];
        self.redoStack = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)init:(InternFormulaState*)internFormulaState
{
    self.current = internFormulaState;
}

#define MAXIMUM_HISTORY_LENGTH 32
- (void)push:(InternFormulaState*)internFormulaState
{
    if (self.current != nil && [self.current isEqual:internFormulaState]) {
        return;
    }
    if (self.current != nil) {
        [self.undoStack addObject:self.current];
    }
    self.current = internFormulaState;
    [self.redoStack removeAllObjects];
    self.hasUnsavedChanges = YES;
    
    if ([self.undoStack count] > MAXIMUM_HISTORY_LENGTH) {
        [self.undoStack removeObjectAtIndex:0];
    }
}

- (InternFormulaState*)backward
{
    [self.redoStack addObject:self.current];
    self.hasUnsavedChanges = YES;
    if ([self.undoStack count] > 0) {
        self.current = [self.undoStack lastObject];
        [self.undoStack removeLastObject];
    }
    return self.current;
}

- (InternFormulaState*)forward
{
    [self.undoStack addObject:self.current];
    self.hasUnsavedChanges = YES;
    if ([self.redoStack count] > 0) {
        self.current = [self.redoStack lastObject];
        [self.redoStack removeLastObject];
    }
    return self.current;
}

- (InternFormulaState*)getCurrentState
{
    return self.current;
}

- (void)updateCurrentSelection:(InternFormulaTokenSelection*)internFormulaTokenSelection
{
    self.current.tokenSelection = internFormulaTokenSelection;
}

- (void)clear
{
    [self.undoStack removeAllObjects];
    [self.redoStack removeAllObjects];
    self.current = nil;
    self.hasUnsavedChanges = NO;
}

- (void)updateCurrentCursor:(int)cursorPosition
{
    self.current.externCursorPosition = cursorPosition;
}

- (BOOL)undoIsPossible
{
    return [self.undoStack count] > 0;
}

- (BOOL)redoIsPossible
{
    return [self.redoStack count] > 0;
}

- (BOOL)hasUnsavedChanges
{
    return self.hasUnsavedChanges;
}

- (void)changesSaved
{
    self.hasUnsavedChanges = false;
}

@end
