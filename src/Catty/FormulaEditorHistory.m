//
//  FormulaEditorHistory.m
//  Catty
//
//  Created by Michael Herold on 11/09/14.
//
//

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
    [self.current setSelection:internFormulaTokenSelection];
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
    [self.current setExternCursorPosition:cursorPosition];
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
