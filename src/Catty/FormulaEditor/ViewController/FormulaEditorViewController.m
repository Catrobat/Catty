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

#import "FormulaEditorViewController.h"
#import "FormulaEditorTextView.h"
#import "UIDefines.h"
#import "Brick.h"
#import "StartScriptCell.h"
#import "BrickFormulaProtocol.h"
#import "UIImage+CatrobatUIImageExtensions.h"
#import "OrderedMapTable.h"
#import "Script.h"
#import "BrickCellFormulaData.h"
#import "VariablePickerData.h"
#import "Brick+UserVariable.h"
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

@interface FormulaEditorViewController ()


@property (weak, nonatomic) Formula *formula;
@property (weak, nonatomic) BrickCellFormulaData *brickCellData;

@property (strong, nonatomic) UITapGestureRecognizer *recognizer;
@property (strong, nonatomic) UITapGestureRecognizer *pickerGesture;
@property (strong, nonatomic) FormulaEditorTextView *formulaEditorTextView;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *orangeTypeButton;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *toolTypeButton;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSMutableArray *normalTypeButton;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *highlightedButtons;

@property (weak, nonatomic) IBOutlet UIScrollView *calcScrollView;
@property (weak, nonatomic) IBOutlet UIScrollView *mathScrollView;
@property (weak, nonatomic) IBOutlet UIScrollView *logicScrollView;
@property (weak, nonatomic) IBOutlet UIScrollView *objectScrollView;
@property (weak, nonatomic) IBOutlet UIScrollView *sensorScrollView;
@property (weak, nonatomic) IBOutlet UIScrollView *variableScrollView;
@property (weak, nonatomic) IBOutlet UIPickerView *variablePicker;
@property (weak, nonatomic) IBOutlet UISegmentedControl *variableSegmentedControl;

@property (weak, nonatomic) IBOutlet UISegmentedControl *varOrListSegmentedControl;


@property (weak, nonatomic) IBOutlet UIButton *calcButton;
@property (weak, nonatomic) IBOutlet UIButton *mathbutton;
@property (weak, nonatomic) IBOutlet UIButton *logicButton;
@property (weak, nonatomic) IBOutlet UIButton *objectButton;
@property (weak, nonatomic) IBOutlet UIButton *sensorButton;
@property (weak, nonatomic) IBOutlet ShapeButton *deleteButton;
@property (weak, nonatomic) IBOutlet UIButton *variableButton;

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
@property (weak, nonatomic) IBOutlet UIButton *deleteVar;

@property (nonatomic) BOOL isProgramVariable;
@property (nonatomic, strong) BDKNotifyHUD *notficicationHud;
@end

@implementation FormulaEditorViewController

@synthesize formulaEditorTextView;

- (id)initWithBrickCellFormulaData:(BrickCellFormulaData *)brickCellData andFormulaManager:(FormulaManager*)formulaManager
{
    self = [super init];
    
    if(self) {
        [self setBrickCellFormulaData:brickCellData];
        NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
        [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
        self.formulaManager = formulaManager;
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:self.formulaEditorTextView];
    self.formulaManager = nil;
}

- (void)setBrickCellFormulaData:(BrickCellFormulaData *)brickCellData
{
    self.brickCellData = brickCellData;
    self.delegate = brickCellData;
    self.formula = brickCellData.formula;
    self.internFormula = [[InternFormula alloc] initWithInternTokenList:[self.formula.formulaTree getInternTokenList]];
    self.history = [[FormulaEditorHistory alloc] initWithInternFormulaState:[self.internFormula getInternFormulaState]];
    
    [self setCursorPositionToEndOfFormula];
    [self update];
    
    [self.formulaEditorTextView highlightSelection:[[self.internFormula getExternFormulaString] length]
                       start:0
                         end:(int)[[self.internFormula getExternFormulaString] length]];
    [self.internFormula selectWholeFormula];
}

- (BOOL)changeBrickCellFormulaData:(BrickCellFormulaData *)brickCellData andForce:(BOOL)forceChange
{
    InternFormulaParser *internFormulaParser = [[InternFormulaParser alloc] initWithTokens:[self.internFormula getInternTokenList] andFormulaManager:(id<FormulaManagerProtocol>)self.formulaManager];
    
    Brick *brick = (Brick*)self.brickCellData.brickCell.scriptOrBrick; // must be a brick!
    [internFormulaParser parseFormulaForSpriteObject:brick.script.object];
    FormulaParserStatus formulaParserStatus = [internFormulaParser getErrorTokenIndex];
    
    if(formulaParserStatus == FORMULA_PARSER_OK) {
        BOOL saved = NO;
        if([self.history undoIsPossible] || [self.history redoIsPossible]) {
            [self saveIfPossible];
            saved = YES;
        }
        [self setBrickCellFormulaData:brickCellData];
        if(saved) {
            [self showChangesSavedView];
        }
        return saved;
    } else if(formulaParserStatus == FORMULA_PARSER_STACK_OVERFLOW) {
        [self showFormulaTooLongView];
    } else {
        if(forceChange) {
            [self setBrickCellFormulaData:brickCellData];
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor backgroundColor];
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    [self showFormulaEditor];
    
    [self.normalTypeButton addObjectsFromArray:[self initMathSectionWithScrollView:self.mathScrollView buttonHeight:self.calcButton.frame.size.height]];
    [self.normalTypeButton addObjectsFromArray:[self initObjectSectionWithScrollView:self.objectScrollView buttonHeight:self.calcButton.frame.size.height]];
    [self.normalTypeButton addObjectsFromArray:[self initSensorSectionWithScrollView:self.sensorScrollView buttonHeight:self.calcButton.frame.size.height]];
    
    [self initSegmentedControls];
    [self colorFormulaEditor];
    [self hideScrollViews];
    self.calcScrollView.hidden = NO;
    [self.calcButton setSelected:YES];
    self.mathScrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    self.logicScrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    self.objectScrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    self.sensorScrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    self.calcScrollView.contentSize = CGSizeMake(self.calcScrollView.frame.size.width,self.calcScrollView.frame.size.height);
    
    [self localizeView];
    
    //Hotfix IOS-559
    CGFloat topInsetNavigationBar = 0.0f;
    if (@available(iOS 11, *)) {
        topInsetNavigationBar = [UIApplication sharedApplication].statusBarFrame.size.height;
        UIView *insetNavBarView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, topInsetNavigationBar)];
        insetNavBarView.backgroundColor = [UIColor globalTintColor];
        [self.view addSubview:insetNavBarView];
    }
    UINavigationBar *myNav = [[UINavigationBar alloc]initWithFrame:CGRectMake(0.0f, topInsetNavigationBar, self.view.frame.size.width, kFormulaEditorTopOffset)];
    [UINavigationBar appearance].barTintColor = [UIColor globalTintColor];
    myNav.translucent = NO;
    [self.view addSubview:myNav];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:kLocalizedCancel
                                                      style:UIBarButtonItemStylePlain
                                                     target:self
                                                            action:@selector(dismissFormulaEditorViewController)];
    
    item.tintColor = [UIColor navTintColor];
    UINavigationItem *navigItem = [[UINavigationItem alloc] initWithTitle:@""];
    navigItem.leftBarButtonItem = item;
    myNav.items = [NSArray arrayWithObjects: navigItem,nil];
    self.deleteButton.shapeStrokeColor = [UIColor navTintColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(formulaTextViewTextDidChangeNotification:) name:UITextViewTextDidChangeNotification object:self.formulaEditorTextView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //self.pickerGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(chosenVariable:)];
    //self.pickerGesture.numberOfTapsRequired = 1;
    //[self.variablePicker addGestureRecognizer:self.pickerGesture];
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

#pragma mark initPickerView

-(void)initSegmentedControls
{
    self.variablePicker.delegate = self;
    self.variablePicker.dataSource = self;
    self.variablePicker.tintColor = [UIColor globalTintColor];
    self.variableSourceProgram = [[NSMutableArray alloc] init];
    self.variableSourceObject = [[NSMutableArray alloc] init];
    self.variableSource = [[NSMutableArray alloc] init];
    self.listSourceProgram = [[NSMutableArray alloc] init];
    self.listSourceObject = [[NSMutableArray alloc] init];
    self.listSource = [[NSMutableArray alloc] init];
    [self updateVariablePickerData];
    [self.variableSegmentedControl setTitle:kLocalizedObject forSegmentAtIndex:1];
    [self.variableSegmentedControl setTitle:kLocalizedProgram forSegmentAtIndex:0];
    self.variableSegmentedControl.tintColor = [UIColor globalTintColor];
    
    
    [self.varOrListSegmentedControl setTitle:kLocalizedVariables forSegmentAtIndex:0];
    [self.varOrListSegmentedControl setTitle:kLocalizedLists forSegmentAtIndex:1];
    self.varOrListSegmentedControl.tintColor = [UIColor globalTintColor];
}

#pragma mark - localizeView
- (void)localizeView
{
    for (UIButton *button in self.normalTypeButton) {
        NSString *name = [Operators getExternName:[Operators getName:(Operator)[button tag]]];
        if([name length] != 0) {
            [button setTitle:name forState:UIControlStateNormal];
        }
    }
    
    [self.calcButton setTitle:kUIFENumbers forState:UIControlStateNormal];
    [self.mathbutton setTitle:kUIFEMath forState:UIControlStateNormal];
    [self.logicButton setTitle:kUIFELogic forState:UIControlStateNormal];
    [self.objectButton setTitle:kUIFEObject forState:UIControlStateNormal];
    [self.sensorButton setTitle:kUIFESensor forState:UIControlStateNormal];
    [self.variableButton setTitle:kUIFEVariableList forState:UIControlStateNormal];
    [self.computeButton setTitle:kUIFECompute forState:UIControlStateNormal];
    [self.doneButton setTitle:kUIFEDone forState:UIControlStateNormal];
    [self.variable setTitle:kUIFEVar forState:UIControlStateNormal];
    [self.takeVar setTitle:kUIFETake forState:UIControlStateNormal];
    [self.deleteVar setTitle:kUIFEDelete forState:UIControlStateNormal];
}


#pragma mark - helper methods
- (void)dismissFormulaEditorViewController
{
    if (! self.presentingViewController.isBeingDismissed) {
        [self.brickCellData drawBorder:NO];
        [self setBrickCellFormulaData:self.brickCellData];
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
    [self.internFormula handleKeyInputWithName:title butttonType:buttonType];
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

- (IBAction)done:(id)sender
{
    if([self saveIfPossible])
    {
        [self dismissFormulaEditorViewController];
    }
}

- (void)updateDeleteButton:(BOOL)enabled
{
    self.deleteButton.shapeStrokeColor = enabled ? [UIColor navTintColor] : [UIColor grayColor];
}

- (IBAction)compute:(id)sender
{
    if (self.internFormula != nil) {
        InternFormulaParser *internFormulaParser = [[InternFormulaParser alloc] initWithTokens:[self.internFormula getInternTokenList] andFormulaManager:(id<FormulaManagerProtocol>)self.formulaManager];
        
        Brick *brick = (Brick*)self.brickCellData.brickCell.scriptOrBrick; // must be a brick!
        Formula *formula = [[Formula alloc] initWithFormulaElement:[internFormulaParser parseFormulaForSpriteObject:brick.script.object]];
        
        switch ([internFormulaParser getErrorTokenIndex]) {
            case FORMULA_PARSER_OK:
                [self showComputeDialog:formula andSpriteObject:brick.script.object];
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
                        [self showComputeDialog:formula andSpriteObject:brick.script.object];
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
        return [formatter stringFromNumber:result];
    }
    
    return @"";
}

#pragma mark - UI
- (void)showFormulaEditor
{
    CGFloat topPadding = 0.0f;
    if (@available(iOS 11.0, *)) {
        UIWindow *window = UIApplication.sharedApplication.keyWindow;
        topPadding = window.safeAreaInsets.top;
    }
    self.formulaEditorTextView = [[FormulaEditorTextView alloc] initWithFrame: CGRectMake(1, topPadding + self.brickCellData.brickCell.frame.size.height + kFormulaEditorTopOffset, self.view.frame.size.width - 2, 0) AndFormulaEditorViewController:self];
    [self.view addSubview:self.formulaEditorTextView];
    
    [self update];
    
    [self.formulaEditorTextView becomeFirstResponder];
}

-(void) colorFormulaEditor
{
    for(UIButton *button in self.orangeTypeButton) {
        [button setTitleColor:[UIColor formulaButtonTextColor] forState:UIControlStateNormal];
        [button setBackgroundColor:[UIColor formulaEditorOperatorColor]];
        [button setBackgroundImage:[UIImage imageWithColor:[UIColor formulaEditorOperandColor]] forState:UIControlStateHighlighted];
        [[button layer] setBorderWidth:1.0f];
        [[button layer] setBorderColor:[UIColor formulaEditorBorderColor].CGColor];
        button.titleLabel.adjustsFontSizeToFitWidth = YES;
        button.titleLabel.minimumScaleFactor = 0.01f;
    }
    
    for(UIButton *button in self.normalTypeButton) {
        [button setTitleColor:[UIColor formulaEditorOperandColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor backgroundColor] forState:UIControlStateHighlighted];
        [button setBackgroundColor:[UIColor backgroundColor]];
        [button setBackgroundImage:[UIImage imageWithColor:[UIColor formulaEditorOperandColor]] forState:UIControlStateHighlighted];
        [[button layer] setBorderWidth:1.0f];
        [[button layer] setBorderColor:[UIColor formulaEditorBorderColor].CGColor];
        button.titleLabel.adjustsFontSizeToFitWidth = YES;
        button.titleLabel.minimumScaleFactor = 0.01f;
        //    if([[self.normalTypeButton objectAtIndex:i] tag] == 3011)
        //    {
        //        if(![self.brickCellData.brickCell.scriptOrBrick isKindOfClass:[SpeakBrick class]])
        //       {
        //            [[self.normalTypeButton objectAtIndex:i] setEnabled:NO];
        //           [[self.normalTypeButton objectAtIndex:i] setTitleColor:[UIColor navTintColor] forState:UIControlStateNormal];
        //            }
        //        }
    }
    //    for(UIButton *button in self.toolTypeButton) {
    //        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    //        [button setTitleColor:[UIColor formulaEditorHighlightColor] forState:UIControlStateHighlighted];
    //        [button setTitleColor:[UIColor utilityTintColor] forState:UIControlStateSelected];
    //        [button setBackgroundColor:[UIColor backgroundColor]];
    //        [[button layer] setBorderWidth:1.0f];
    //        [[button layer] setBorderColor:[UIColor formulaEditorBorderColor].CGColor];
    //        button.titleLabel.adjustsFontSizeToFitWidth = YES;
    //        button.titleLabel.minimumScaleFactor = 0.01f;
    //    }
    
    for(UIButton *button in self.toolTypeButton) {
        [button setTitleColor:[UIColor formulaButtonTextColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor formulaEditorOperatorColor] forState:UIControlStateSelected];
        [button setBackgroundImage:[UIImage imageWithColor:[UIColor formulaEditorOperatorColor]] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageWithColor:[UIColor formulaButtonTextColor]] forState:UIControlStateSelected];
        [[button layer] setBorderWidth:1.0f];
        [[button layer] setBorderColor:[UIColor formulaEditorBorderColor].CGColor];
        button.titleLabel.adjustsFontSizeToFitWidth = YES;
        button.titleLabel.minimumScaleFactor = 0.01f;
    }
    
    for(UIButton *button in self.highlightedButtons) {
        [button setTitleColor:[UIColor formulaButtonTextColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
        [button setBackgroundColor:[UIColor formulaEditorOperatorColor]];
        [button setBackgroundImage:[UIImage imageWithColor:[UIColor formulaEditorOperandColor]] forState:UIControlStateSelected];
        [[button layer] setBorderWidth:1.0f];
        [[button layer] setBorderColor:[UIColor formulaEditorBorderColor].CGColor];
        button.titleLabel.adjustsFontSizeToFitWidth = YES;
        button.titleLabel.minimumScaleFactor = 0.01f;
    }
    self.variableScrollView.backgroundColor = [UIColor backgroundColor];
    
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
            InternFormulaParser *internFormulaParser = [[InternFormulaParser alloc] initWithTokens:[self.internFormula getInternTokenList] andFormulaManager:(id<FormulaManagerProtocol>)self.formulaManager];
            
            Brick *brick = (Brick*)self.brickCellData.brickCell.scriptOrBrick; // must be a brick!
            FormulaElement *formulaElement = [internFormulaParser parseFormulaForSpriteObject:brick.script.object];
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
    [self hideScrollViews];
    self.mathScrollView.hidden = NO;
    [self.mathbutton setSelected:YES];
    [self.mathScrollView scrollsToTop];
    [self.mathScrollView flashScrollIndicators];
}
- (IBAction)showLogic:(UIButton *)sender {
    [self hideScrollViews];
    self.logicScrollView.hidden = NO;
    [self.logicButton setSelected:YES];
    [self.logicScrollView scrollsToTop];
    [self.logicScrollView flashScrollIndicators];
}
- (IBAction)showObject:(UIButton *)sender {
    [self hideScrollViews];
    self.objectScrollView.hidden = NO;
    [self.objectButton setSelected:YES];
    [self.objectScrollView scrollsToTop];
    [self.objectScrollView flashScrollIndicators];
}
- (IBAction)showSensor:(UIButton *)sender {
    [self hideScrollViews];
    self.sensorScrollView.hidden = NO;
    [self.sensorButton setSelected:YES];
    [self.sensorScrollView scrollsToTop];
    [self.sensorScrollView flashScrollIndicators];
}
- (IBAction)showVariable:(UIButton *)sender {
  [self hideScrollViews];
  self.variableScrollView.hidden = NO;
  [self.variableButton setSelected:YES];
  [self.variableScrollView scrollsToTop];
  [self.variableScrollView flashScrollIndicators];
}

- (void)hideScrollViews
{
    self.mathScrollView.hidden = YES;
    self.calcScrollView.hidden = YES;
    self.logicScrollView.hidden = YES;
    self.objectScrollView.hidden = YES;
    self.sensorScrollView.hidden = YES;
    self.variableScrollView.hidden = YES;
    [self.calcButton setSelected:NO];
    [self.mathbutton setSelected:NO];
    [self.objectButton setSelected:NO];
    [self.logicButton setSelected:NO];
    [self.sensorButton setSelected:NO];
    [self.variableButton setSelected:NO];
}

- (void)addNewVarOrList: (BOOL)isProgramVarOrList isList:(BOOL)isList {
    
    NSString* promptTitle = isList ? kUIFENewList : kUIFENewVar;
    NSString* promptMessage = isList ? kUIFEListName : kUIFEVarName;
    self.isProgramVariable = isProgramVarOrList;
    self.variableSegmentedControl.selectedSegmentIndex = isProgramVarOrList ? 0 : 1;
    [self.variableSegmentedControl setNeedsDisplay];

    [Util askUserForVariableNameAndPerformAction:@selector(saveVariable:isList:)
                                          target:self
                                     promptTitle:promptTitle
                                   promptMessage:promptMessage
                                  minInputLength:kMinNumOfVariableNameCharacters
                                  maxInputLength:kMaxNumOfVariableNameCharacters
                                          isList:isList
                             blockedCharacterSet:[self blockedCharacterSet]
                                    andTextField:self.formulaEditorTextView];
}

- (void)askObjectOrProgram:(BOOL)isList {
    NSString* promptTitle = isList ? kUIFEActionList : kUIFEActionVar;
    [[[[[[AlertControllerBuilder actionSheetWithTitle:promptTitle]
         addCancelActionWithTitle:kLocalizedCancel handler:^{
             [self.formulaEditorTextView becomeFirstResponder];
         }]
        addDefaultActionWithTitle:kUIFEActionVarPro handler:^{
            [self addNewVarOrList: YES isList: isList];
        }]
       addDefaultActionWithTitle:kUIFEActionVarObj handler:^{
           [self addNewVarOrList: NO isList: isList];
       }] build]
     showWithController:self];
}

- (IBAction)askVarOrList:(UIButton *)sender {
    [self.formulaEditorTextView resignFirstResponder];
    
    [[[[[[AlertControllerBuilder actionSheetWithTitle:kUIFEVarOrList]
         addCancelActionWithTitle:kLocalizedCancel handler:^{
             [self.formulaEditorTextView becomeFirstResponder];
         }]
        addDefaultActionWithTitle:kUIFENewVar handler:^{
            [self askObjectOrProgram: NO];
        }]
       addDefaultActionWithTitle:kUIFENewList handler:^{
           [self askObjectOrProgram: YES];
       }] build]
     showWithController:self];
}

static NSCharacterSet *blockedCharacterSet = nil;

- (NSCharacterSet*)blockedCharacterSet

{
    if (! blockedCharacterSet) {
        blockedCharacterSet = [[NSCharacterSet characterSetWithCharactersInString:kTextFieldAllowedCharacters]
                               invertedSet];
    }
    return blockedCharacterSet;
}

- (void)updateVariablePickerData
{
    VariablesContainer *variables = self.object.program.variables;
    [self.variableSource removeAllObjects];
    [self.variableSourceProgram  removeAllObjects];
    [self.variableSourceObject  removeAllObjects];
    [self.listSource removeAllObjects];
    [self.listSourceProgram  removeAllObjects];
    [self.listSourceObject  removeAllObjects];
    
    // ------------------
    // Program Variables
    // ------------------
    if([variables.programVariableList count] > 0){
        [self.variableSource addObject:[[VariablePickerData alloc] initWithTitle:kUIFEProgramVars]];
    }
    
    for(UserVariable *userVariable in variables.programVariableList) {
        VariablePickerData *pickerData = [[VariablePickerData alloc] initWithTitle:userVariable.name andVariable:userVariable];
        [pickerData setIsProgramVariable:YES];
        [self.variableSource addObject:pickerData];
        [self.variableSourceProgram addObject:pickerData];
    }
    
    
    // ------------------
    // Program Lists
    // ------------------
    if([variables.programListOfLists count] > 0){
        [self.listSource addObject:[[VariablePickerData alloc] initWithTitle:kUIFEProgramLists]];
    }
    
    for(UserVariable *userVariable in variables.programListOfLists) {
        VariablePickerData *pickerData = [[VariablePickerData alloc] initWithTitle:userVariable.name andVariable:userVariable];
        [pickerData setIsProgramVariable:YES];
        [self.listSource addObject:pickerData];
        [self.listSourceProgram addObject:pickerData];
    }
    
  
    // ------------------
    // Object Variables
    // ------------------
    NSArray *array = [variables.objectVariableList objectForKey:self.object];
    if (array) {
        if([array count] > 0)
            [self.variableSource addObject:[[VariablePickerData alloc] initWithTitle:kUIFEObjectVars]];
        
        for (UserVariable *var in array) {
            VariablePickerData *pickerData = [[VariablePickerData alloc] initWithTitle:var.name andVariable:var];
            [pickerData setIsProgramVariable:NO];
            [self.variableSource addObject:pickerData];
            [self.variableSourceObject addObject:pickerData];
        }
    }
    
    
    // ------------------
    // Object Lists
    // ------------------
    array = [variables.objectListOfLists objectForKey:self.object];
    if (array) {
        if([array count] > 0)
            [self.listSource addObject:[[VariablePickerData alloc] initWithTitle:kUIFEObjectLists]];
        
        for (UserVariable *var in array) {
            VariablePickerData *pickerData = [[VariablePickerData alloc] initWithTitle:var.name andVariable:var];
            [pickerData setIsProgramVariable:NO];
            [self.listSource addObject:pickerData];
            [self.listSourceObject addObject:pickerData];
        }
    }
  
    [self.variablePicker reloadAllComponents];
    if([self.variableSource count] > 0)
        [self.variablePicker selectRow:0 inComponent:0 animated:NO];
}

- (void) askForVariableName:(BOOL)isList
{
    [Util askUserForVariableNameAndPerformAction:@selector(saveVariable:isList:)
                                          target:self
                                     promptTitle:kUIFENewVarExists
                                   promptMessage:kUIFEOtherName
                                  minInputLength:kMinNumOfVariableNameCharacters
                                  maxInputLength:kMaxNumOfVariableNameCharacters
                                          isList:isList
                             blockedCharacterSet:[self blockedCharacterSet]
                                    andTextField:self.formulaEditorTextView];
}

- (void)saveVariable:(NSString*)name isList:(BOOL)isList
{
    if (self.isProgramVariable && !isList){
        for (UserVariable* variable in [self.object.program.variables allVariables]) {
            if ([variable.name isEqualToString:name]) {
                [self askForVariableName: isList];
                return;
            }
        }
    } else if (!self.isProgramVariable && !isList) {
        for (UserVariable* variable in [self.object.program.variables allVariablesForObject:self.object]) {
            if ([variable.name isEqualToString:name]) {
                [self askForVariableName: isList];
                return;
            }
        }
    } else if (self.isProgramVariable && isList){
        for (UserVariable* variable in [self.object.program.variables allLists]) {
            if ([variable.name isEqualToString:name]) {
                [self askForVariableName: isList];
                return;
            }
        }
    } else if (!self.isProgramVariable && isList) {
        for (UserVariable* variable in [self.object.program.variables allListsForObject:self.object]) {
            if ([variable.name isEqualToString:name]) {
                [self askForVariableName: isList];
                return;
            }
        }
    }
    
    [self.formulaEditorTextView becomeFirstResponder];
    UserVariable* var = [UserVariable new];
    var.name = name;
    
    if (isList) {
        var.value = [[NSMutableArray alloc] init];
    } else{
        var.value = [NSNumber numberWithInt:0];
    }
    var.isList = isList;
    
    if (self.isProgramVariable && !isList) {
        [self.object.program.variables.programVariableList addObject:var];
    } else if (self.isProgramVariable && isList){
        [self.object.program.variables.programListOfLists addObject:var];
    } else if (!self.isProgramVariable && !isList) {
        NSMutableArray *array = [self.object.program.variables.objectVariableList objectForKey:self.object];
        if (!array) {
            array = [NSMutableArray new];
        }
        [array addObject:var];
        [self.object.program.variables.objectVariableList setObject:array forKey:self.object];
    } else if (!self.isProgramVariable && isList) {
        NSMutableArray *array = [self.object.program.variables.objectListOfLists objectForKey:self.object];
        if (!array) {
            array = [NSMutableArray new];
        }
        [array addObject:var];
        [self.object.program.variables.objectListOfLists setObject:array forKey:self.object];
    }
    
    [self.object.program saveToDiskWithNotification:YES];
    [self updateVariablePickerData];
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
                                  minInputLength:kMinNumOfProgramNameCharacters
                                  maxInputLength:kMaxNumOfProgramNameCharacters
										  isList:NO
                             blockedCharacterSet:[self blockedCharacterSet]
                                    andTextField:self.formulaEditorTextView];
}

- (void)handleNewTextInput:(NSString*)text
{
    NSDebug(@"Text: %@", text);
    [self handleInputWithTitle:text AndButtonType:TOKEN_TYPE_STRING];
    [self.formulaEditorTextView becomeFirstResponder];
}

#pragma mark - pickerView

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (component == 0 && self.variableSegmentedControl.selectedSegmentIndex == 0 && self.varOrListSegmentedControl.selectedSegmentIndex == 0) {
        return self.variableSourceProgram.count;
    } else if (component == 0 && self.variableSegmentedControl.selectedSegmentIndex == 1 && self.varOrListSegmentedControl.selectedSegmentIndex == 0) {
        return self.variableSourceObject.count;
    } else if (component == 0 && self.variableSegmentedControl.selectedSegmentIndex == 0 && self.varOrListSegmentedControl.selectedSegmentIndex == 1) {
        return self.listSourceProgram.count;
    } else if (component == 0 && self.variableSegmentedControl.selectedSegmentIndex == 1 && self.varOrListSegmentedControl.selectedSegmentIndex == 1) {
        return self.listSourceObject.count;
    }
    return 0;
}

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    BOOL forObjectOnly = self.variableSegmentedControl.selectedSegmentIndex;
    BOOL isList = self.varOrListSegmentedControl.selectedSegmentIndex;
    
    

    if (component == 0 && !forObjectOnly && !isList) {
        if (row < self.variableSourceProgram.count) {
            return [[self.variableSourceProgram objectAtIndex:row] title];
        }
    } else if (component == 0 && forObjectOnly && !isList) {
        if (row < self.variableSourceObject.count) {
            return [[self.variableSourceObject objectAtIndex:row] title];
        }
    } else if (component == 0 && !forObjectOnly && isList) {
        if (row < self.listSourceProgram.count) {
            return [[self.listSourceProgram objectAtIndex:row] title];
        }
    }
    else if (component == 0 && forObjectOnly && isList) {
        if (row < self.listSourceObject.count) {
            return [[self.listSourceObject objectAtIndex:row] title];
        }
    }
    
    return @"";
}

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *title = [self pickerView:pickerView titleForRow:row forComponent:component];
    UIColor *color = [UIColor globalTintColor];
    NSAttributedString *attString = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName:color}];
    return attString;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{

}

- (IBAction)choseVariableOrList:(UIButton *)sender {

 NSInteger row = [self.variablePicker selectedRowInComponent:0];
    if (row >= 0) {
        int buttonType = 0;
        VariablePickerData *pickerData;
        if (self.variableSegmentedControl.selectedSegmentIndex == 0 && self.varOrListSegmentedControl.selectedSegmentIndex == 0) {
            if (row < self.variableSourceProgram.count) {
               pickerData = [self.variableSourceProgram objectAtIndex:row];
            }
        } else if (self.variableSegmentedControl.selectedSegmentIndex == 1 && self.varOrListSegmentedControl.selectedSegmentIndex == 0){
            if (row < self.variableSourceObject.count) {
                pickerData = [self.variableSourceObject objectAtIndex:row];
            }
        } else if (self.variableSegmentedControl.selectedSegmentIndex == 0 && self.varOrListSegmentedControl.selectedSegmentIndex == 1){
            if (row < self.listSourceProgram.count) {
                pickerData = [self.listSourceProgram objectAtIndex:row];
                buttonType = 11;
            }
        } else if (self.variableSegmentedControl.selectedSegmentIndex == 1 && self.varOrListSegmentedControl.selectedSegmentIndex == 1){
            if (row < self.listSourceObject.count) {
                pickerData = [self.listSourceObject objectAtIndex:row];
                buttonType = 11;
            }
        }
        if (pickerData) {
             [self handleInputWithTitle:pickerData.userVariable.name AndButtonType:buttonType];
        }
    }
}


- (IBAction)deleteVariable:(UIButton *)sender {
    NSInteger row = [self.variablePicker selectedRowInComponent:0];
    if (row >= 0) {
        VariablePickerData *pickerData;
        if ((self.variableSegmentedControl.selectedSegmentIndex == 0)
            && (self.varOrListSegmentedControl.selectedSegmentIndex == 0)) {
            if (row < self.variableSourceProgram.count) {
                pickerData = [self.variableSourceProgram objectAtIndex:row];
            }
        } else if ((self.variableSegmentedControl.selectedSegmentIndex == 1)
                   && (self.varOrListSegmentedControl.selectedSegmentIndex == 0)) {
            if (row < self.variableSourceObject.count) {
                pickerData = [self.variableSourceObject objectAtIndex:row];
            }
        } else if ((self.variableSegmentedControl.selectedSegmentIndex == 0)
                   && (self.varOrListSegmentedControl.selectedSegmentIndex == 1)) {
            if (row < self.listSourceProgram.count) {
                pickerData = [self.listSourceProgram objectAtIndex:row];
            }
        } else if ((self.variableSegmentedControl.selectedSegmentIndex == 1)
                   && (self.varOrListSegmentedControl.selectedSegmentIndex == 1)) {
            if (row < self.listSourceObject.count) {
                pickerData = [self.listSourceObject objectAtIndex:row];
            }
        }
        if (pickerData) {
            if(![self isVarOrListBeingUsed:pickerData.userVariable]) {
                
                BOOL removed = NO;
                BOOL isList = pickerData.userVariable.isList;
                if (!isList) {
                    removed = [self.object.program.variables removeUserVariableNamed:pickerData.userVariable.name forSpriteObject:self.object];
                } else {
                    removed = [self.object.program.variables removeUserListNamed:pickerData.userVariable.name forSpriteObject:self.object];
                }
                if (removed) {
                    if (!isList) {
                        [self.variableSource removeObjectAtIndex:row];
                    } else {
                        [self.listSource removeObjectAtIndex:row];
                    }
                    [self.object.program saveToDiskWithNotification:YES];
                    [self updateVariablePickerData];
                }
            } else {
                [self showNotification:kUIFEDeleteVarBeingUsed andDuration:1.5f];
            }
        }
    }
}

- (BOOL)isVarOrListBeingUsed:(UserVariable*)variable
{
    //TODO: Make it work for lists
    if([self.object.program.variables isProgramVariableOrList:variable]) {
        for(SpriteObject *spriteObject in self.object.program.objectList) {
            for(Script *script in spriteObject.scriptList) {
                for(id brick in script.brickList) {
                    if([brick isKindOfClass:[Brick class]] && [brick isVarOrListBeingUsed:variable]) {
                        return YES;
                    }
                }
            }
        }
    } else {
        for(Script *script in self.object.scriptList) {
            for(id brick in script.brickList) {
                if([brick isKindOfClass:[Brick class]] && [brick isVarOrListBeingUsed:variable]) {
                    return YES;
                }
            }
        }
    }
    
    return NO;
}

- (IBAction)changeVariablePickerView:(id)sender {
    [self.variablePicker reloadAllComponents];
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
        self.deleteButton.shapeStrokeColor = containsText ? [UIColor navTintColor] : [UIColor grayColor];
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
