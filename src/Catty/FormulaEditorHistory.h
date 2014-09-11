//
//  FormulaEditorHistory.h
//  Catty
//
//  Created by Michael Herold on 11/09/14.
//
//

#import <Foundation/Foundation.h>
#import "InternFormulaState.h"
#import "InternFormulaTokenSelection.h"

@interface FormulaEditorHistory : NSObject

- (id)initWithInternFormulaState:(InternFormulaState*)internFormulaState;
- (void)init:(InternFormulaState*)internFormulaState;
- (void)push:(InternFormulaState*)internFormulaState;
- (InternFormulaState*)backward;
- (InternFormulaState*)forward;
- (InternFormulaState*)getCurrentState;
- (void)updateCurrentSelection:(InternFormulaTokenSelection*)internFormulaTokenSelection;
- (void)clear;
- (void)updateCurrentCursor:(int)cursorPosition;
- (BOOL)undoIsPossible;
- (BOOL)redoIsPossible;
- (BOOL)hasUnsavedChanges;
- (void)changesSaved;

@end
