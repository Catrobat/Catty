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
#import "ShapeButton.h"
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

@property (strong, nonatomic) UITapGestureRecognizer *recognizer;
@property (strong, nonatomic) UITapGestureRecognizer *pickerGesture;
@property (strong, nonatomic) FormulaEditorTextView *formulaEditorTextView;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *orangeTypeButton;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *toolTypeButton;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSMutableArray *normalTypeButton;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *highlightedButtons;

@property (weak, nonatomic) IBOutlet UIScrollView *calcScrollView;

@property (weak, nonatomic) IBOutlet UIButton *calcButton;
@property (weak, nonatomic) IBOutlet UIButton *functionsButton;
@property (weak, nonatomic) IBOutlet UIButton *logicButton;
@property (weak, nonatomic) IBOutlet UIButton *objectButton;
@property (weak, nonatomic) IBOutlet UIButton *sensorButton;
@property (weak, nonatomic) IBOutlet ShapeButton *deleteButton;
@property (weak, nonatomic) IBOutlet UIButton *dataButton;

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *buttons;
@property (weak, nonatomic) IBOutlet UIButton *undoButton;
@property (weak, nonatomic) IBOutlet UIButton *redoButton;
@property (weak, nonatomic) IBOutlet UIButton *computeButton;
@property (weak, nonatomic) IBOutlet UIButton *divisionButton;
@property (weak, nonatomic) IBOutlet UIButton *multiplicationButton;
@property (weak, nonatomic) IBOutlet UIButton *substractionButton;
@property (weak, nonatomic) IBOutlet UIButton *additionButton;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UIButton *variable;
@property (weak, nonatomic) IBOutlet UIButton *takeVar;
@property (weak, nonatomic) IBOutlet UIButton *deleteUserData;
@property (weak, nonatomic) IBOutlet UIButton *addNewTextButton;

@property (nonatomic) BOOL isProjectVariable;
@property (nonatomic, strong) BDKNotifyHUD *notficicationHud;
@property (strong, nonatomic) FormulaEditorSectionViewController *formulaEditorSectionViewController;

@property (nonatomic) BOOL isScrolling;

@end

@implementation FormulaEditorViewController

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
    BOOL forceChange = event != nil && ((UITouch*)[[event allTouches] anyObject]).tapCount == 2;
    [self changeBrickCellFormulaData:formulaData andForce:forceChange];
    [self.brickCell setNeedsDisplay];
}

- (BOOL)changeBrickCellFormulaData:(BrickCellFormulaData *)brickCellData andForce:(BOOL)forceChange
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
        if(saved) {
            [self showChangesSavedView];
        }
        return saved;
    } else if(formulaParserStatus == FORMULA_PARSER_STACK_OVERFLOW) {
        [self showFormulaTooLongView];
    } else {
        if(forceChange) {
            [self initFormulaData:brickCellData];
            [self showChangesDiscardedView];
            return YES;
        } else {
            [self showSyntaxErrorView];
        }
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

    [self colorFormulaEditor];
    [self hideScrollViews];
    self.calcScrollView.hidden = NO;
    [self.calcButton setSelected:YES];
    self.calcScrollView.contentSize = CGSizeMake(self.calcScrollView.frame.size.width,self.calcScrollView.frame.size.height);
    
    [self localizeView];
    
    self.deleteButton.shapeStrokeColor = UIColor.navTint;
    
    [self setupButtons];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(formulaTextViewTextDidChangeNotification:) name:UITextViewTextDidChangeNotification object:self.formulaEditorTextView];
    
    
    UITapGestureRecognizer *tapToSelect = [[UITapGestureRecognizer alloc]initWithTarget:self
                                                                                 action:@selector(tappedToSelectRow:)];
    tapToSelect.delegate = self;
    
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self
                                                                                   action:@selector(pickerViewGotScrolled:)];
    
    panRecognizer.delegate = self;
    
    self.formulaEditorSectionViewController = [[FormulaEditorSectionViewController alloc] init];
    self.formulaEditorSectionViewController.formulaManager = _formulaManager;
    self.formulaEditorSectionViewController.spriteObject = _object;
    self.formulaEditorSectionViewController.formulaEditorVC = self;
    self.formulaEditorSectionViewController.modalPresentationStyle = UIModalPresentationPopover;
    [self presentViewController:self.formulaEditorSectionViewController animated:YES completion:NULL];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationName.formulaEditorControllerDidAppear object:self];
    [self update];
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
    self.navigationItem.title = kUIFormulaEditorTitle;
    
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
    self.navigationItem.rightBarButtonItem = doneButton;
}

- (void)setupButtons {
    [self.divisionButton addTarget:self action:@selector(divisionButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.multiplicationButton addTarget:self action:@selector(multiplicationButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.substractionButton addTarget:self action:@selector(substractionButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.additionButton addTarget:self action:@selector(additionButtonPressed) forControlEvents:UIControlEventTouchUpInside];
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (UIEventSubtypeMotionShake && [self.history undoIsPossible]) {
        [self.formulaEditorTextView resignFirstResponder];
        
        [[[[[AlertControllerBuilder alertWithTitle:nil message:kLocalizedUndoTypingDescription]
         addCancelActionWithTitle:kLocalizedCancel handler:^{
             [self.formulaEditorTextView becomeFirstResponder];
         }]
         addDefaultActionWithTitle:kLocalizedUndo handler:^{
             [self undo];
             [self.formulaEditorTextView becomeFirstResponder];
         }] build]
         showWithController:self];
    }
}

#pragma mark - localizeView
- (void)localizeView
{
    [self.calcButton setTitle:kUIFENumbers forState:UIControlStateNormal];
    [self.functionsButton setTitle:kUIFEFunctions forState:UIControlStateNormal];
    [self.logicButton setTitle:kUIFELogic forState:UIControlStateNormal];
    [self.objectButton setTitle:kUIFEObject forState:UIControlStateNormal];
    [self.sensorButton setTitle:kUIFESensor forState:UIControlStateNormal];
    [self.dataButton setTitle:kUIFEData forState:UIControlStateNormal];
    [self.computeButton setTitle:kUIFECompute forState:UIControlStateNormal];
    [self.doneButton setTitle:kUIFEDone forState:UIControlStateNormal];
    [self.variable setTitle:kUIFEVar forState:UIControlStateNormal];
    [self.takeVar setTitle:kUIFETake forState:UIControlStateNormal];
    [self.deleteUserData setTitle:kUIFEDelete forState:UIControlStateNormal];
    [self.addNewTextButton setTitle:kUIFEAddNewText forState:UIControlStateNormal];
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
- (IBAction)buttonPressed:(id)sender
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
    [self switchBack];
}

-(void)switchBack
{
    if (self.calcScrollView.hidden == YES) {
        [self showCalc:nil];
    }
}

- (IBAction)undo
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

- (IBAction)redo:(id)sender
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
- (IBAction)backspaceButtonAction:(id)sender
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
    self.deleteButton.shapeStrokeColor = enabled ? UIColor.navTint : UIColor.grayColor;
}

- (IBAction)compute:(id)sender
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

- (void)showComputeDialog:(Formula*)formula andSpriteObject:(SpriteObject*)spriteObject
{
    [self.formulaManager setupForFormula:formula];
    
    NSString *computedString = [self interpretFormula:formula forSpriteObject:spriteObject];
    [self showNotification:computedString andDuration:kFormulaEditorShowResultDuration];
    
    [self.formulaManager stop];
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

#pragma mark - UI
- (void)showFormulaEditorTextView
{
    CGFloat marginTop = self.brickCell.frame.origin.y + self.brickCell.frame.size.height;
    
    self.formulaEditorTextView = [[FormulaEditorTextView alloc] initWithFrame: CGRectMake(0, marginTop, self.view.frame.size.width - 2, 120) AndFormulaEditorViewController:self];
    
    [self.view addSubview:self.formulaEditorTextView];
    
    [self update];
    [self.formulaEditorTextView becomeFirstResponder];
}

-(void) colorFormulaEditor
{
    for(UIButton *button in self.orangeTypeButton) {
        [button setTitleColor:UIColor.formulaButtonText forState:UIControlStateNormal];
        [button setBackgroundColor:UIColor.formulaEditorOperator];
        [button setBackgroundImage:[UIImage imageWithColor:UIColor.formulaEditorOperand] forState:UIControlStateHighlighted];
        [[button layer] setBorderWidth:1.0f];
        [[button layer] setBorderColor:UIColor.formulaEditorBorder.CGColor];
        button.titleLabel.adjustsFontSizeToFitWidth = YES;
        button.titleLabel.minimumScaleFactor = 0.01f;
    }
    
    for(UIButton *button in self.normalTypeButton) {
        [button setTitleColor:UIColor.formulaEditorOperand forState:UIControlStateNormal];
        [button setTitleColor:UIColor.background forState:UIControlStateHighlighted];
        [button setBackgroundColor:UIColor.background];
        [button setBackgroundImage:[UIImage imageWithColor:UIColor.formulaEditorOperand] forState:UIControlStateHighlighted];
        [[button layer] setBorderWidth:1.0f];
        [[button layer] setBorderColor:UIColor.formulaEditorBorder.CGColor];
        button.titleLabel.adjustsFontSizeToFitWidth = YES;
        button.titleLabel.minimumScaleFactor = 0.01f;
        //    if([[self.normalTypeButton objectAtIndex:i] tag] == 3011)
        //    {
        //        if(![self.brickCellData.brickCell.scriptOrBrick isKindOfClass:[SpeakBrick class]])
        //       {
        //            [[self.normalTypeButton objectAtIndex:i] setEnabled:NO];
        //           [[self.normalTypeButton objectAtIndex:i] setTitleColor:UIColor.navTint forState:UIControlStateNormal];
        //            }
        //        }
    }
    //    for(UIButton *button in self.toolTypeButton) {
    //        [button setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    //        [button setTitleColor:[UIColor formulaEditorHighlightColor] forState:UIControlStateHighlighted];
    //        [button setTitleColor:UIColor.utilityTint forState:UIControlStateSelected];
    //        [button setBackgroundColor:UIColor.background];
    //        [[button layer] setBorderWidth:1.0f];
    //        [[button layer] setBorderColor:[UIColor formulaEditorBorderColor].CGColor];
    //        button.titleLabel.adjustsFontSizeToFitWidth = YES;
    //        button.titleLabel.minimumScaleFactor = 0.01f;
    //    }
    
    for(UIButton *button in self.toolTypeButton) {
        [button setTitleColor:UIColor.formulaButtonText forState:UIControlStateNormal];
        [button setTitleColor:UIColor.formulaEditorOperator forState:UIControlStateSelected];
        [button setBackgroundImage:[UIImage imageWithColor:UIColor.formulaEditorOperator] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageWithColor:UIColor.formulaButtonText] forState:UIControlStateSelected];
        [[button layer] setBorderWidth:1.0f];
        [[button layer] setBorderColor:UIColor.formulaEditorBorder.CGColor];
        button.titleLabel.adjustsFontSizeToFitWidth = YES;
        button.titleLabel.minimumScaleFactor = 0.01f;
    }
    
    for(UIButton *button in self.highlightedButtons) {
        [button setTitleColor:UIColor.formulaButtonText forState:UIControlStateNormal];
        [button setTitleColor:UIColor.grayColor forState:UIControlStateDisabled];
        [button setBackgroundColor:UIColor.formulaEditorOperator];
        [button setBackgroundImage:[UIImage imageWithColor:UIColor.formulaEditorOperand] forState:UIControlStateSelected];
        [[button layer] setBorderWidth:1.0f];
        [[button layer] setBorderColor:UIColor.formulaEditorBorder.CGColor];
        button.titleLabel.adjustsFontSizeToFitWidth = YES;
        button.titleLabel.minimumScaleFactor = 0.01f;
    }
    
}

- (void)update
{
    [self.formulaEditorTextView update];
    [self updateFormula];
    [self.undoButton setEnabled:[self.history undoIsPossible]];
    [self.redoButton setEnabled:[self.history redoIsPossible]];
    if (self.internFormula != nil) {
        [self.computeButton setEnabled:!self.internFormula.isEmpty];
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

//- (IBAction)showMathFunctionsMenu:(id)sender
//{
//    [self.formulaEditorTextView resignFirstResponder];
//    [self.mathFunctionsMenu show];
//    [self.mathFunctionsMenu becomeFirstResponder];
//}
//
//- (IBAction)showLogicalOperatorsMenu:(id)sender
//{
//    [self.formulaEditorTextView resignFirstResponder];
//    [self.logicalOperatorsMenu show];
//    [self.logicalOperatorsMenu becomeFirstResponder];
//}
- (IBAction)showCalc:(UIButton *)sender {
    [self hideScrollViews];
    self.calcScrollView.hidden = NO;
    [self.calcButton setSelected:YES];
    [self.calcScrollView scrollsToTop];
}
- (IBAction)showFunction:(UIButton *)sender {
    self.formulaEditorSectionViewController.formulaEditorSectionType = FormulaEditorSectionTypeFunctions;
    [self presentViewController:self.formulaEditorSectionViewController animated:true completion:nil];
}
- (IBAction)showLogic:(UIButton *)sender {
    self.formulaEditorSectionViewController.formulaEditorSectionType = FormulaEditorSectionTypeLogic;
    [self presentViewController:self.formulaEditorSectionViewController animated:true completion:nil];
}
- (IBAction)showObject:(UIButton *)sender {
    self.formulaEditorSectionViewController.formulaEditorSectionType = FormulaEditorSectionTypeObject;
    [self presentViewController:self.formulaEditorSectionViewController animated:true completion:nil];
}
- (IBAction)showSensor:(UIButton *)sender {
    self.formulaEditorSectionViewController.formulaEditorSectionType = FormulaEditorSectionTypeSensors;
    [self presentViewController:self.formulaEditorSectionViewController animated:true completion:nil];
}
- (IBAction)showVariable:(UIButton *)sender {
    self.formulaEditorSectionViewController.formulaEditorSectionType = FormulaEditorSectionTypeData;
    [self presentViewController:self.formulaEditorSectionViewController animated:true completion:nil];
}

- (void)hideScrollViews
{
    [self.calcButton setSelected:NO];
    [self.functionsButton setSelected:NO];
    [self.objectButton setSelected:NO];
    [self.logicButton setSelected:NO];
    [self.sensorButton setSelected:NO];
    [self.dataButton setSelected:NO];
}

- (void)closeMenu
{
    [self.formulaEditorTextView becomeFirstResponder];
}

- (IBAction)addNewText:(id)sender {
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

- (void)showNotification:(NSString*)text andDuration:(CGFloat)duration
{
    if(self.notficicationHud)
        [self.notficicationHud removeFromSuperview];
    
    CGFloat brickAndInputHeight = self.navigationController.navigationBar.frame.size.height + self.brickCellData.brickCell.frame.size.height + self.formulaEditorTextView.frame.size.height + [[UIApplication sharedApplication] statusBarFrame].size.height + 10;
    CGFloat keyboardHeight = self.formulaEditorTextView.inputView.frame.size.height;
    CGFloat spacerHeight = self.view.frame.size.height - brickAndInputHeight - keyboardHeight;
    CGFloat offset;
    
    self.notficicationHud = [BDKNotifyHUD notifyHUDWithImage:nil text:text];
    self.notficicationHud.destinationOpacity = kBDKNotifyHUDDestinationOpacity;
    
    if(spacerHeight < self.notficicationHud.frame.size.height)
        offset = brickAndInputHeight / 2 + self.notficicationHud.frame.size.height / 2;
    else
        offset = brickAndInputHeight + self.notficicationHud.frame.size.height / 2 + kBDKNotifyHUDPaddingTop;
    
    self.notficicationHud.center = CGPointMake(self.view.center.x, offset);
    
    [self.view addSubview:self.notficicationHud];
    [self.notficicationHud presentWithDuration:duration
                                         speed:kBDKNotifyHUDPresentationSpeed
                                        inView:self.view completion:^{ [self.notficicationHud removeFromSuperview]; }];
}

- (void)showChangesSavedView
{
    [self showNotification:kUIFEChangesSaved andDuration:kBDKNotifyHUDPresentationDuration];
}

- (void)showChangesDiscardedView
{
    [self showNotification:kUIFEChangesDiscarded andDuration:kBDKNotifyHUDPresentationDuration];
}

- (void)showSyntaxErrorView
{
    if (self.internFormula != nil && self.internFormula.isEmpty) {
        [self showNotification:kUIFEEmptyInput andDuration:kBDKNotifyHUDPresentationDuration];
    } else {
        [self showNotification:kUIFESyntaxError andDuration:kBDKNotifyHUDPresentationDuration];
        [self.formulaEditorTextView setParseErrorCursorAndSelection];
    }
}

- (void)showFormulaTooLongView
{
    [self showNotification:kUIFEtooLongFormula andDuration:kBDKNotifyHUDPresentationDuration];
}

#pragma mark NotificationCenter

- (void)formulaTextViewTextDidChangeNotification:(NSNotification *)note
{
    if (note.object) {
        FormulaEditorTextView *textView = (FormulaEditorTextView *)note.object;
        BOOL containsText = textView.text.length > 0;
        self.deleteButton.shapeStrokeColor = containsText ? UIColor.navTint : UIColor.grayColor;
        self.deleteButton.enabled = containsText;
    }
}

#pragma mark Orientation

-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

@end

