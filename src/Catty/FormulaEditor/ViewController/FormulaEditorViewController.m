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

#import "FormulaEditorViewController.h"
#import "FormulaEditorTextView.h"
#import "UIDefines.h"
#import "Brick.h"
#import "BrickCell.h"
#import "StartScriptCell.h"
#import "BrickFormulaProtocol.h"
#import "UIImage+CatrobatUIImageExtensions.h"
#import "OrderedMapTable.h"
#import "Script.h"
#import "BrickCellFormulaData.h"
#import "BDKNotifyHUD.h"
#import "KeychainUserDefaultsDefines.h"
#import "Pocket_Code-Swift.h"

NS_ENUM(NSInteger, ButtonIndex) {
    kButtonIndexDelete = 0,
    kButtonIndexCopyOrCancel = 1,
    kButtonIndexAnimate = 2,
    kButtonIndexEdit = 3,
    kButtonIndexCancel = 4
};

@interface FormulaEditorViewController () <BrickCellDelegate>


@property (weak, nonatomic) Formula *formula;
@property (strong, nonatomic) BrickCellFormulaData *brickCellData;
@property (strong, nonatomic) BrickCell *brickCell;
@property (strong, nonatomic) FormulaEditorKeyboardView* keyboard;
@property (strong, nonatomic) FormulaEditorKeyboardAccessoryView* keyboardAccessory;

@property (strong, nonatomic) UITapGestureRecognizer *recognizer;
@property (strong, nonatomic) UITapGestureRecognizer *pickerGesture;
@property (strong, nonatomic) FormulaEditorTextView *formulaEditorTextView;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *orangeTypeButton;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *toolTypeButton;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSMutableArray *normalTypeButton;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *highlightedButtons;

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *buttons;
@property (strong, nonatomic) UIBarButtonItem* undoButton;
@property (strong, nonatomic) UIBarButtonItem* redoButton;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;

@property (nonatomic) BOOL isProjectVariable;
@property (nonatomic, strong) BDKNotifyHUD *notficicationHud;
@property (strong, nonatomic) FormulaEditorSectionViewController *formulaEditorSectionViewController;

@property (nonatomic) BOOL isScrolling;

@end

@implementation FormulaEditorViewController

#define TEXT_FIELD_MARGIN_BOTTOM 2

@synthesize formulaEditorTextView;

- (id)initWithBrickCellFormulaData:(BrickCellFormulaData*)brickCellData andFormulaManager:(FormulaManager*)formulaManager
{
    self = [super init];
    
    if(self) {
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInt:UIInterfaceOrientationPortrait] forKey:@"orientation"];

        self.formulaManager = formulaManager;
        [self initBrickCell:brickCellData.brickCell];
        [self initFormulaData:brickCellData];
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:self.formulaEditorTextView];
    self.formulaManager = nil;
}

- (void)initBrickCell:(BrickCell*)originalbrickCell
{
    id<BrickProtocol> brick = originalbrickCell.scriptOrBrick;
    self.brickCell = [[(Class)[brick brickCell] alloc] init];
    self.brickCell.scriptOrBrick = brick;
    self.brickCell.dataDelegate = originalbrickCell.dataDelegate;
    self.brickCell.delegate = self;
    
    CGSize brickCellSize = originalbrickCell.frame.size;
    
    self.brickCell.frame = CGRectMake(0, UIDefines.brickCategorySectionInset, brickCellSize.width, brickCellSize.height);
    [self.brickCell setupBrickCellinSelectionView:false inBackground:self.object.isBackground];
}

- (void)initFormulaData:(BrickCellFormulaData*)originalBrickCellData
{
    BrickCellFormulaData *newFormulaData = (BrickCellFormulaData*)([self.brickCell dataSubviewForLineNumber:originalBrickCellData.lineNumber andParameterNumber:originalBrickCellData.parameterNumber]);
    
    self.brickCellData = newFormulaData;
    self.delegate = newFormulaData;
    self.formula = newFormulaData.formula;
    self.internFormula = [[InternFormula alloc] initWithInternTokenList:[self.formula.formulaTree getInternTokenList]];
    self.history = [[FormulaEditorHistory alloc] initWithInternFormulaState:[self.internFormula getInternFormulaState]];
    
    [self setCursorPositionToEndOfFormula];
    [self update];
    
    [self.formulaEditorTextView highlightSelection:[[self.internFormula getExternFormulaString] length]
                                             start:0
                                               end:(int)[[self.internFormula getExternFormulaString] length]];
    [self.internFormula selectWholeFormula];
}

# pragma mark BrickCellDelegate
- (void)openFormulaEditor:(BrickCellFormulaData*)formulaData withEvent:(UIEvent*)event {
    [self changeBrickCellFormulaData:formulaData];
    [self.brickCell setNeedsDisplay];
}

- (BOOL)changeBrickCellFormulaData:(BrickCellFormulaData *)brickCellData
{
    InternFormulaParser *internFormulaParser = [[InternFormulaParser alloc] initWithTokens:[self.internFormula getInternTokenList] andFormulaManager:self.formulaManager];
    
    Brick *brick = (Brick*)self.brickCellData.brickCell.scriptOrBrick;
    SpriteObject *object;
    
    if ([brick isKindOfClass:[Script class]]) {
        Script *script = (Script*)brick;
        object = script.object;
    } else {
        object = brick.script.object;
    }
    
    [internFormulaParser parseFormulaForSpriteObject:object];
    FormulaParserStatus formulaParserStatus = [internFormulaParser getErrorTokenIndex];
    
    if(formulaParserStatus == FORMULA_PARSER_OK) {
        BOOL saved = NO;
        if([self.history undoIsPossible] || [self.history redoIsPossible]) {
            [self saveIfPossible];
            saved = YES;
        }
        [self initFormulaData:brickCellData];
        return saved;
    } else if(formulaParserStatus == FORMULA_PARSER_STACK_OVERFLOW) {
        [self showFormulaTooLongView];
    } else {
            [self showSyntaxErrorView];
    }
    
    return NO;
}

- (void)setCursorPositionToEndOfFormula
{
    [self.internFormula setCursorAndSelection:0 selected:NO];
    [self.internFormula generateExternFormulaStringAndInternExternMapping];
    [self.internFormula setExternCursorPositionRightTo:INT_MAX];
    [self.internFormula updateInternCursorPosition];
}

- (InternFormula *)internFormula
{
    if(!_internFormula) {
        _internFormula = [[InternFormula alloc]init];
    }
    return _internFormula;
}

#pragma mark ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = UIColor.background;
    
    [self.view addSubview:self.brickCell];
    
    [self showFormulaEditorTextView];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(formulaTextViewTextDidChangeNotification:) name:UITextViewTextDidChangeNotification object:self.formulaEditorTextView];
    
    
    UITapGestureRecognizer *tapToSelect = [[UITapGestureRecognizer alloc]initWithTarget:self
                                                                                 action:@selector(tappedToSelectRow:)];
    tapToSelect.delegate = self;
    
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self
                                                                                   action:@selector(pickerViewGotScrolled:)];
    
    panRecognizer.delegate = self;
    
    [self setupNavigationBar];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self update];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationName.formulaEditorControllerDidAppear object:self];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if ([self.view.window.gestureRecognizers containsObject:self.recognizer]) {
        [self.view.window removeGestureRecognizer:self.recognizer];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    // enable userinteraction for all subviews
    for (id subview in [self.brickCellData.brickCell dataSubviews]) {
        if([subview isKindOfClass:[UIView class]])
            [(UIView*)subview setUserInteractionEnabled:YES];
    }
}

- (void) setupNavigationBar {

    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:kLocalizedBack
                                                                 style:UIBarButtonItemStylePlain
                                                                target:nil
                                                                action:nil];
    [self.navigationItem setBackBarButtonItem:backItem];
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:kLocalizedCancel
                                                             style:UIBarButtonItemStylePlain
                                                            target:self
                                                            action:@selector(dismissFormulaEditorViewController)];
    
    cancelButton.tintColor = UIColor.navTint;
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:kLocalizedDone
                                                             style:UIBarButtonItemStylePlain
                                                            target:self
                                                            action:@selector(doneTapped)];
    
    doneButton.tintColor = UIColor.navTint;
    
    UIImage* undoButtonImage = [UIImage imageNamed:@"undoButton"];
    self.undoButton = [[UIBarButtonItem alloc] initWithImage: undoButtonImage
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(undo)];
    
    [self.undoButton setEnabled:false];
    
    UIImage* redoButtonImage = [UIImage imageNamed:@"redoButton"];
    self.redoButton = [[UIBarButtonItem alloc] initWithImage: redoButtonImage
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(redo)];
    
    [self.redoButton setEnabled:false];
    
    self.navigationItem.rightBarButtonItems = @[doneButton, self.redoButton, self.undoButton];
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (UIEventSubtypeMotionShake && [self.history undoIsPossible]) {
        [self.formulaEditorTextView resignFirstResponder];
        
        [[[[[AlertControllerBuilder alertWithTitle:nil message:kLocalizedUndoTypingDescription]
         addCancelActionWithTitle:kLocalizedCancel handler:nil]
         addDefaultActionWithTitle:kLocalizedUndo handler:^{
             [self undo];
         }] build]
         showWithController:self];
    }
}

#pragma mark - helper methods
- (void)dismissFormulaEditorViewController
{
    if (! self.presentingViewController.isBeingDismissed) {
        [self.formula setDisplayString:nil];
        [self.formulaEditorTextView removeFromSuperview];
        [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

#pragma mark - TextField Actions
- (void)buttonPressed:(id)sender
{
    if([sender isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton *)sender;
        NSString *title = button.titleLabel.text;
        
        [self handleInputWithTitle:title AndButtonType:(int)[sender tag]];
    }
}

- (void)handleInputWithTitle:(NSString*)title AndButtonType:(int)buttonType
{
    [self.internFormula handleKeyInputWithName:title buttonType:buttonType];
    [self handleInput];
}

- (void)handleInput
{
    NSDebug(@"InternFormulaString: %@",[self.internFormula getExternFormulaString]);
    [self.history push:[self.internFormula getInternFormulaState]];
    [self update];
}

- (void)undo
{
    if (![self.history undoIsPossible]) {
        return;
    }
    
    InternFormulaState *lastStep = [self.history backward];
    if (lastStep != nil) {
        self.internFormula = [lastStep createInternFormulaFromState];
        [self update];
        [self setCursorPositionToEndOfFormula];
    }
}

- (void)redo
{
    if (![self.history redoIsPossible]) {
        return;
    }
    
    InternFormulaState *nextStep = [self.history forward];
    if (nextStep != nil) {
        self.internFormula = [nextStep createInternFormulaFromState];
        [self update];
        [self setCursorPositionToEndOfFormula];
    }
}
- (void)backspaceButtonAction
{
    [self backspace:nil];
}

- (void)backspace:(id)sender
{
    [self.formula setDisplayString:nil];
    [self handleInputWithTitle:@"Backspace" AndButtonType:CLEAR];
}

- (void)doneTapped {
    if([self saveIfPossible])
    {
        [self dismissFormulaEditorViewController];
    }
}

- (IBAction)done:(id)sender
{
    [self doneTapped];
}

- (void)updateDeleteButton:(BOOL)enabled
{
    self.keyboard.backspaceButton.enabled = enabled;
}

- (void)computeTapped
{
    if (self.internFormula != nil) {
        InternFormulaParser *internFormulaParser = [[InternFormulaParser alloc] initWithTokens:[self.internFormula getInternTokenList] andFormulaManager:self.formulaManager];
        
        Brick *brick = (Brick*)self.brickCellData.brickCell.scriptOrBrick;
        SpriteObject *object;
        
        if ([brick isKindOfClass:[Script class]]) {
            Script *script = (Script*)brick;
            object = script.object;
        } else {
            object = brick.script.object;
        }
        
        Formula *formula = [[Formula alloc] initWithFormulaElement:[internFormulaParser parseFormulaForSpriteObject:object]];
        
        switch ([internFormulaParser getErrorTokenIndex]) {
            case FORMULA_PARSER_OK:
                [self showComputeDialog:formula andSpriteObject:object];
                break;
            case FORMULA_PARSER_STACK_OVERFLOW:
                [self showFormulaTooLongView];
                break;
            case FORMULA_PARSER_STRING:
                if(!self.brickCellData.brickCell.isScriptBrick){
                    Brick<BrickFormulaProtocol>* brick = (Brick<BrickFormulaProtocol>*)self.brickCellData.brickCell.scriptOrBrick;
                    if (![brick allowsStringFormula]) {
                        [self showSyntaxErrorView];
                    } else {
                        [self showComputeDialog:formula andSpriteObject:object];
                    }
                }
                
                break;

            default:
                [self showSyntaxErrorView];
                break;
        }
    }
}

- (NSString*)interpretFormula:(Formula*)formula forSpriteObject:(SpriteObject*)spriteObject {
    id result = [self.formulaManager interpret:formula forSpriteObject:spriteObject];
    
    if ([result isKindOfClass:[NSString class]]) {
        return result;
    }
    if ([result isKindOfClass:[NSNumber class]]) {
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        formatter.usesGroupingSeparator = NO;
        return [formatter stringFromNumber:result];
    }
    
    return @"";
}

- (void)setParseErrorCursorAndSelection
{
    [self.internFormula selectParseErrorTokenAndSetCursor];
    int startIndex = [self.internFormula getExternSelectionStartIndex];
    int endIndex = [self.internFormula getExternSelectionEndIndex];
    NSUInteger cursorPostionIndex = [self.internFormula getExternCursorPosition];
    [self.formulaEditorTextView highlightSelection:cursorPostionIndex start:startIndex end:endIndex];
}

#pragma mark - UI
- (void)showFormulaEditorTextView
{
    [self setupFormulaEditorKeyboard];
    
    CGFloat marginTop = self.brickCell.frame.origin.y + self.brickCell.frame.size.height;
    
    self.formulaEditorTextView = [[FormulaEditorTextView alloc] initWithFrame: CGRectMake(0, marginTop, self.view.frame.size.width, 120) AndFormulaEditorViewController:self];
    self.formulaEditorTextView.inputView = _keyboard;
    self.formulaEditorTextView.inputAccessoryView = _keyboardAccessory;
    
    [self.view addSubview:self.formulaEditorTextView];
    [self.formulaEditorTextView becomeFirstResponder];
        
    [self update];
    
}

- (void)setupFormulaEditorKeyboard
{
    _keyboard = [[FormulaEditorKeyboardView alloc] initWithKeyboardWidth:CGRectGetWidth(self.view.bounds)];
    _keyboardAccessory = [[FormulaEditorKeyboardAccessoryView alloc] initWithKeyboardWidth:CGRectGetWidth(self.view.bounds)];

    _keyboardAccessory.accessibilityIdentifier = @"keyboardAccessoryView";
    [_keyboardAccessory.functionsButton addTarget:self action:@selector(showFunctionSection) forControlEvents:UIControlEventTouchUpInside];
    [_keyboardAccessory.propertiesButton addTarget:self action:@selector(showObjectSection) forControlEvents:UIControlEventTouchUpInside];
    [_keyboardAccessory.sensorsButton addTarget:self action:@selector(showSensorSection) forControlEvents:UIControlEventTouchUpInside];
    [_keyboardAccessory.logicButton addTarget:self action:@selector(showLogicSection) forControlEvents:UIControlEventTouchUpInside];
    [_keyboardAccessory.dataButton addTarget:self action:@selector(showDataSection) forControlEvents:UIControlEventTouchUpInside];
    [_keyboard.arrowButton addTarget:self action:@selector(arrowKeyTapped) forControlEvents:UIControlEventTouchUpInside];
    [_keyboard.computeButton addTarget:self action:@selector(computeTapped) forControlEvents:UIControlEventTouchDown];
    [_keyboard.textButton addTarget:self action:@selector(textButtonTapped) forControlEvents:UIControlEventTouchDown];
    [_keyboard.additionButton addTarget:self action:@selector(additionButtonPressed) forControlEvents:UIControlEventTouchDown];
    [_keyboard.subtractionButton addTarget:self action:@selector(substractionButtonPressed) forControlEvents:UIControlEventTouchDown];
    [_keyboard.multiplicationButton addTarget:self action:@selector(multiplicationButtonPressed) forControlEvents:UIControlEventTouchDown];
    [_keyboard.divisionButton addTarget:self action:@selector(divisionButtonPressed) forControlEvents:UIControlEventTouchDown];
    [_keyboard.equalsButton addTarget:self action:@selector(equalsButtonPressed) forControlEvents:UIControlEventTouchDown];
    [_keyboard.backspaceButton addTarget:self action:@selector(backspaceButtonAction) forControlEvents:UIControlEventTouchDown];
    [_keyboard.decimalPointButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchDown];
    [_keyboard.openingBracketButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchDown];
    [_keyboard.closingBracketButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchDown];
    
    for (UIButton* numericButton in _keyboard.numericButtons) {
        [numericButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchDown];
    }
}

- (void)update
{
    [self.formulaEditorTextView update];
    [self updateFormula];
    [self.undoButton setEnabled:[self.history undoIsPossible]];
    [self.redoButton setEnabled:[self.history redoIsPossible]];
    if (self.internFormula != nil) {
        [self.doneButton setEnabled:!self.internFormula.isEmpty];
    }
}

- (void)updateFormula
{

    if(self.formula != nil && self.internFormula != nil)
    {
        [self.formula setDisplayString:[self.internFormula getExternFormulaString]];
    }
    
    BrickCell *brickCell = self.brickCellData.brickCell;
    NSInteger line = self.brickCellData.lineNumber;
    NSInteger parameter = self.brickCellData.parameterNumber;
    [self.brickCellData.brickCell setupBrickCellinSelectionView:false inBackground:self.object.isBackground];
    self.brickCellData = (BrickCellFormulaData*)([brickCell dataSubviewForLineNumber:line andParameterNumber:parameter]);
    [self.brickCellData drawBorder:YES];
    
    // disable userinteraction for all subviews different than BrickCellFormulaData
    for (id subview in [self.brickCellData.brickCell dataSubviews]) {
        if ([subview isKindOfClass:[UIView class]] && ![subview isKindOfClass:[BrickCellFormulaData class]]) {
            [(UIView*)subview setUserInteractionEnabled:NO];
        }
    }
}

- (BOOL)saveIfPossible
{
        if(self.internFormula != nil) {
            InternFormulaParser *internFormulaParser = [[InternFormulaParser alloc] initWithTokens:[self.internFormula getInternTokenList] andFormulaManager:self.formulaManager];
            
            Brick *brick = (Brick*)self.brickCellData.brickCell.scriptOrBrick;
            FormulaElement *formulaElement = nil;
            if ([brick isKindOfClass:[Script class]]) {
                Script *script = (Script*)brick;
                formulaElement = [internFormulaParser parseFormulaForSpriteObject:script.object];
            } else {
                formulaElement = [internFormulaParser parseFormulaForSpriteObject:brick.script.object];
            }
            
            Formula *formula = [[Formula alloc] initWithFormulaElement:formulaElement];
            switch ([internFormulaParser getErrorTokenIndex]) {
                case FORMULA_PARSER_OK:
                    if(self.delegate) {
                        [self.delegate saveFormula:formula];
                    }
                    return YES;
                    break;
                case FORMULA_PARSER_STACK_OVERFLOW:
                    [self showFormulaTooLongView];
                    break;
                case FORMULA_PARSER_STRING:
                    if(!self.brickCellData.brickCell.isScriptBrick){
                        Brick<BrickFormulaProtocol>* brick = (Brick<BrickFormulaProtocol>*)self.brickCellData.brickCell.scriptOrBrick;
                        if(![brick allowsStringFormula]){
                            [self showSyntaxErrorView];
                        }else{
                            if(self.delegate) {
                                [self.delegate saveFormula:formula];
                            }
                            return YES;
                        }
                    }
                    
                    break;
                default:
                    [self showSyntaxErrorView];
                    break;
            }
        }
    
    return NO;
}

- (void)showFunctionSection {
    self.formulaEditorSectionViewController = [[FormulaEditorSectionViewController alloc] initWithType:FormulaEditorSectionTypeFunctions formulaManager:_formulaManager spriteObject:_object formulaEditorViewController:self];
    self.formulaEditorSectionViewController.title = kUIFEFunctions;
    [self.navigationController pushViewController:self.formulaEditorSectionViewController animated:true];
}
- (void)showLogicSection {
    self.formulaEditorSectionViewController = [[FormulaEditorSectionViewController alloc] initWithType:FormulaEditorSectionTypeLogic formulaManager:_formulaManager spriteObject:_object formulaEditorViewController:self];
    self.formulaEditorSectionViewController.title = kUIFELogic;
    [self.navigationController pushViewController:self.formulaEditorSectionViewController animated:true];
}
- (void)showObjectSection {
    self.formulaEditorSectionViewController = [[FormulaEditorSectionViewController alloc] initWithType:FormulaEditorSectionTypeObject formulaManager:_formulaManager spriteObject:_object formulaEditorViewController:self];
    self.formulaEditorSectionViewController.title = kUIFEProperties;
    [self.navigationController pushViewController:self.formulaEditorSectionViewController animated:true];
}
- (void)showSensorSection {
    self.formulaEditorSectionViewController = [[FormulaEditorSectionViewController alloc] initWithType:FormulaEditorSectionTypeSensors formulaManager:_formulaManager spriteObject:_object formulaEditorViewController:self];
    self.formulaEditorSectionViewController.title = kUIFESensor;
    [self.navigationController pushViewController:self.formulaEditorSectionViewController animated:true];
}
- (void)showDataSection {
    FormulaEditorDataSectionViewController* vc = [[FormulaEditorDataSectionViewController alloc] initWithFormulaManager:_formulaManager spriteObject:_object formulaEditorViewController:self];
    vc.title = kUIFEData;
    [self.navigationController pushViewController:vc animated:true];
}

- (void)arrowKeyTapped {
    [_keyboard animateArrowButton];
    
    BOOL hide = true;
    
    if (self->formulaEditorTextView.inputAccessoryView.hidden) {
        [self->formulaEditorTextView.inputAccessoryView setHidden:false];
        hide = false;
    }
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        CGFloat alpha = (hide) ? 0.0 : 1.0 ;
        CGFloat translation = (hide) ? 4.0 : 0;
        
        self->formulaEditorTextView.inputAccessoryView.alpha = alpha;
        self->formulaEditorTextView.inputAccessoryView.transform = CGAffineTransformMakeTranslation(0, translation);
        
    } completion:^(BOOL finished) {
        
        if (finished) {
            if (hide) {
                [self->formulaEditorTextView.inputAccessoryView setHidden:true];
            }
        }
        [self.formulaEditorTextView update];
    }];
}

- (void)textButtonTapped {
    
    [self.formulaEditorTextView resignFirstResponder];    
    [Util askUserForVariableNameAndPerformAction:@selector(handleNewTextInput:)
                                          target:self
                                     promptTitle:kUIFENewText
                                   promptMessage:kUIFETextMessage
                                  minInputLength:0
                                  maxInputLength:0
                                          isList:NO
                                    andTextField:self.formulaEditorTextView
                                     initialText:[self.formulaEditorTextView getHighlightedText]];
}

- (void)handleNewTextInput:(NSString*)text
{
    NSDebug(@"Text: %@", text);
    [self handleInputWithTitle:text AndButtonType:TOKEN_TYPE_STRING];
    [self.formulaEditorTextView becomeFirstResponder];
}

#pragma mark NotificationCenter

- (void)formulaTextViewTextDidChangeNotification:(NSNotification *)note
{
    if (note.object) {
        FormulaEditorTextView *textView = (FormulaEditorTextView *)note.object;
        BOOL containsText = textView.text.length > 0;
        self.keyboard.backspaceButton.tintColor = containsText ? UIColor.navTint : UIColor.grayColor;
        self.keyboard.backspaceButton.enabled = containsText;
    }
}

@end
