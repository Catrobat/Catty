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

#import "FormulaEditorViewController.h"
#import "FormulaEditorTextView.h"
#import "UIDefines.h"
#import "Brick.h"
#import "LanguageTranslationDefines.h"
#import "UIColor+CatrobatUIColorExtensions.h"
#import "StartScriptCell.h"
#import "WhenScriptCell.h"
#import "IfLogicElseBrickCell.h"
#import "IfLogicEndBrickCell.h"
#import "ForeverBrickCell.h"
#import "IfLogicBeginBrickCell.h"
#import "RepeatBrickCell.h"
#import "BroadcastScriptCell.h"
#import "CellMotionEffect.h"
#import "BrickCell.h"
#import "FormulaElement.h"
#import "LanguageTranslationDefines.h"
#import "FormulaEditorHistory.h"
#import "AHKActionSheet.h"
#import "FormulaEditorButton.h"
#import "BrickFormulaProtocol.h"
#import "UIImage+CatrobatUIImageExtensions.h"

NS_ENUM(NSInteger, ButtonIndex) {
    kButtonIndexDelete = 0,
    kButtonIndexCopyOrCancel = 1,
    kButtonIndexAnimate = 2,
    kButtonIndexEdit = 3,
    kButtonIndexCancel = 4
};

@interface FormulaEditorViewController ()

@property (strong, nonatomic) FormulaEditorHistory *history;
@property (weak, nonatomic) Formula *formula;
@property (weak, nonatomic) BrickCell *brickCell;

@property (strong, nonatomic) UITapGestureRecognizer *recognizer;
@property (strong, nonatomic) UIMotionEffectGroup *motionEffects;
@property (strong, nonatomic) FormulaEditorTextView *formulaEditorTextView;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *orangeTypeButton;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *toolTypeButton;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *normalTypeButton;

@property (weak, nonatomic) IBOutlet UIScrollView *calcScrollView;
@property (weak, nonatomic) IBOutlet UIScrollView *mathScrollView;
@property (weak, nonatomic) IBOutlet UIScrollView *logicScrollView;
@property (weak, nonatomic) IBOutlet UIScrollView *objectScrollView;
@property (weak, nonatomic) IBOutlet UIScrollView *sensorScrollView;

@property (weak, nonatomic) IBOutlet UIButton *calcButton;
@property (weak, nonatomic) IBOutlet UIButton *mathbutton;
@property (weak, nonatomic) IBOutlet UIButton *logicButton;
@property (weak, nonatomic) IBOutlet UIButton *objectButton;
@property (weak, nonatomic) IBOutlet UIButton *sensorButton;

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *buttons;
@property (weak, nonatomic) IBOutlet UIButton *undoButton;
@property (weak, nonatomic) IBOutlet UIButton *redoButton;
@property (weak, nonatomic) IBOutlet UIButton *computeButton;
@property (weak, nonatomic) IBOutlet UIButton *divisionButton;
@property (weak, nonatomic) IBOutlet UIButton *multiplicationButton;
@property (weak, nonatomic) IBOutlet UIButton *substractionButton;
@property (weak, nonatomic) IBOutlet UIButton *additionButton;

@property (strong, nonatomic) AHKActionSheet *mathFunctionsMenu;
@property (strong, nonatomic) AHKActionSheet *logicalOperatorsMenu;

@end

@implementation FormulaEditorViewController

@synthesize formulaEditorTextView;

- (id)initWithBrickCell:(BrickCell *)brickCell
{
    self = [super init];
    
    if(self) {
        self.brickCell = brickCell;
    }
    
    return self;
}

- (void)setFormula:(Formula*)formula

{
    _formula = formula;
    self.internFormula = [[InternFormula alloc] initWithInternTokenList:[formula.formulaTree getInternTokenList]];
    self.history = [[FormulaEditorHistory alloc] initWithInternFormulaState:[self.internFormula getInternFormulaState]];

    [FormulaEditorButton setActiveFormula:formula];
    [self update];
    [self setCursorPositionToEndOfFormula];
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
    self.view.backgroundColor = UIColor.clearColor;
    [CellMotionEffect addMotionEffectForView:self.brickCell withDepthX:0.0f withDepthY:25.0f withMotionEffectGroup:self.motionEffects];
    
    [self showFormulaEditor];
    [self hideScrollViews];
    self.calcScrollView.hidden = NO;
    [self.calcButton setSelected:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    self.recognizer.numberOfTapsRequired = 1;
    self.recognizer.cancelsTouchesInView = NO;
    [self.view.window addGestureRecognizer:self.recognizer];
    [self update];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [CellMotionEffect removeMotionEffect:self.motionEffects fromView:self.brickCell];
    self.motionEffects = nil;
    if ([self.view.window.gestureRecognizers containsObject:self.recognizer]) {
        [self.view.window removeGestureRecognizer:self.recognizer];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(formulaEditorViewController:withBrickCell:)]) {
        [self.delegate formulaEditorViewController:self withBrickCell:self.brickCell];
    }
}

- (void)handleTap:(UITapGestureRecognizer *)sender
{
    if ([sender isKindOfClass:UITapGestureRecognizer.class]) {
        //[self dismissFormulaEditorViewController];
    }
}

- (UIMotionEffectGroup *)motionEffects {
    if (!_motionEffects) {
        _motionEffects = [UIMotionEffectGroup new];
    }
    return _motionEffects;
}

#pragma mark - helper methods
- (void)dismissFormulaEditorViewController
{
    if (! self.presentingViewController.isBeingDismissed) {
        [FormulaEditorButton setActiveFormula:nil];
        
        [self.formulaEditorTextView removeFromSuperview];
        [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
    }
}

#pragma mark - TextField Actions
- (IBAction)buttonPressed:(id)sender
{
    if([sender isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton *)sender;
        NSString *title = button.titleLabel.text;

        if(PLUS == [sender tag])
        {
            NSLog(@"Plus: %@", title);
        }else{
            NSLog(@"Beschreibung: %ld", (long)[sender tag]);
        }
        
        [self handleInputWithTitle:title AndButtonType:(int)[sender tag]];
    }
}

- (void)handleInputWithTitle:(NSString*)title AndButtonType:(int)buttonType
{
    [self.internFormula handleKeyInputWithName:title butttonType:buttonType];
    NSLog(@"InternFormulaString: %@",[self.internFormula getExternFormulaString]);
    [self.history push:[self.internFormula getInternFormulaState]];
    [self update];
}

- (IBAction)undo:(id)sender
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

- (void)backspace:(id)sender
{
    [self handleInputWithTitle:@"Backspace" AndButtonType:CLEAR];
}

- (IBAction)done:(id)sender
{
    [self dismissFormulaEditorViewController];
}

- (IBAction)compute:(id)sender {
    float result = [[[self.internFormula getInternFormulaParser] parseFormula] interpretRecursiveForSprite:nil];
    NSString *computedString = [NSString stringWithFormat:@"Computed result is %f", result];
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"Result"
                                                   message: computedString
                                                  delegate: self
                                         cancelButtonTitle:@"OK"
                                         otherButtonTitles:nil,nil];
    [alert show];
}

#pragma mark - Getter and setter

- (AHKActionSheet *)mathFunctionsMenu
{
    if (!_mathFunctionsMenu) {
        
        NSArray *mathFunctions = @[
                                  [NSNumber numberWithInt:SIN],
                                  [NSNumber numberWithInt:COS],
                                  [NSNumber numberWithInt:TAN],
                                  [NSNumber numberWithInt:LN],
                                  [NSNumber numberWithInt:LOG],
                                  [NSNumber numberWithInt:PI_F],
                                  [NSNumber numberWithInt:SQRT],
                                  [NSNumber numberWithInt:ABS],
                                  [NSNumber numberWithInt:MAX],
                                  [NSNumber numberWithInt:MIN],
                                  [NSNumber numberWithInt:ARCSIN],
                                  [NSNumber numberWithInt:ARCCOS],
                                  [NSNumber numberWithInt:ARCTAN],
                                  [NSNumber numberWithInt:ROUND],
                                  [NSNumber numberWithInt:MOD],
                                  [NSNumber numberWithInt:POW],
                                  [NSNumber numberWithInt:EXP]
                                  ];
        
        _mathFunctionsMenu = [[AHKActionSheet alloc]initWithTitle:kUIActionSheetTitleSelectMathematicalFunction];
        _mathFunctionsMenu.blurTintColor = [UIColor colorWithWhite:0.0f alpha:0.7f];
        _mathFunctionsMenu.separatorColor = UIColor.skyBlueColor;
        _mathFunctionsMenu.titleTextAttributes = @{NSFontAttributeName : [UIFont systemFontOfSize:14.0f] ,
                                                    NSForegroundColorAttributeName : UIColor.skyBlueColor};
        _mathFunctionsMenu.cancelButtonTextAttributes = @{NSForegroundColorAttributeName : UIColor.lightOrangeColor};
        _mathFunctionsMenu.buttonTextAttributes = @{NSForegroundColorAttributeName : UIColor.whiteColor};
        _mathFunctionsMenu.selectedBackgroundColor = [UIColor colorWithWhite:0.0f alpha:0.3f];
        _mathFunctionsMenu.automaticallyTintButtonImages = NO;
        
        __weak FormulaEditorViewController *weakSelf = self;
        
        for(int i = 0; i < [mathFunctions count]; i++) {
            
            int type = [[mathFunctions objectAtIndex:i] intValue];
            NSString *name = [Functions getExternName:[Functions getName:type]];
            [_mathFunctionsMenu addButtonWithTitle:name
                                           type:AHKActionSheetButtonTypeDefault
                                        handler:^(AHKActionSheet *actionSheet) {
                                            [weakSelf handleInputWithTitle:name AndButtonType:type];
                                            [weakSelf closeMenu];
                                        }];
        }
        
        _mathFunctionsMenu.cancelHandler = ^(AHKActionSheet *actionSheet) {
            [weakSelf closeMenu];
        };
    }
    return _mathFunctionsMenu;
}

- (AHKActionSheet *)logicalOperatorsMenu
{
    if (!_logicalOperatorsMenu) {
        
        NSArray *logicalOperators = @[
                                   [NSNumber numberWithInt:EQUAL],
                                   [NSNumber numberWithInt:NOT_EQUAL],
                                   [NSNumber numberWithInt:SMALLER_THAN],
                                   [NSNumber numberWithInt:SMALLER_OR_EQUAL],
                                   [NSNumber numberWithInt:GREATER_THAN],
                                   [NSNumber numberWithInt:GREATER_OR_EQUAL],
                                   [NSNumber numberWithInt:LOGICAL_AND],
                                   [NSNumber numberWithInt:LOGICAL_OR],
                                   [NSNumber numberWithInt:LOGICAL_NOT],
                                   [NSNumber numberWithInt:TRUE_F],
                                   [NSNumber numberWithInt:FALSE_F]
                                   ];
        
        _logicalOperatorsMenu = [[AHKActionSheet alloc]initWithTitle:kUIActionSheetTitleSelectLogicalOperator];
        _logicalOperatorsMenu.blurTintColor = [UIColor colorWithWhite:0.0f alpha:0.7f];
        _logicalOperatorsMenu.separatorColor = UIColor.skyBlueColor;
        _logicalOperatorsMenu.titleTextAttributes = @{NSFontAttributeName : [UIFont systemFontOfSize:14.0f] ,
                                                   NSForegroundColorAttributeName : UIColor.skyBlueColor};
        _logicalOperatorsMenu.cancelButtonTextAttributes = @{NSForegroundColorAttributeName : UIColor.lightOrangeColor};
        _logicalOperatorsMenu.buttonTextAttributes = @{NSForegroundColorAttributeName : UIColor.whiteColor};
        _logicalOperatorsMenu.selectedBackgroundColor = [UIColor colorWithWhite:0.0f alpha:0.3f];
        _logicalOperatorsMenu.automaticallyTintButtonImages = NO;
        
        __weak FormulaEditorViewController *weakSelf = self;
        
        for(int i = 0; i < [logicalOperators count]; i++) {
            
            int type = [[logicalOperators objectAtIndex:i] intValue];
            NSString *name;
            if([Operators getName:type] == nil)
                name = [Functions getExternName:[Functions getName:type]];
            else
                name = [Operators getExternName:[Operators getName:type]];
            
            [_logicalOperatorsMenu addButtonWithTitle:name
                                              type:AHKActionSheetButtonTypeDefault
                                           handler:^(AHKActionSheet *actionSheet) {
                                               [weakSelf handleInputWithTitle:name AndButtonType:type];
                                               [weakSelf closeMenu];
                                           }];
        }
        
        _logicalOperatorsMenu.cancelHandler = ^(AHKActionSheet *actionSheet) {
            [weakSelf closeMenu];
        };
    }
    return _logicalOperatorsMenu;
}

#pragma mark - UI

- (void)showFormulaEditor
{
    self.formulaEditorTextView = [[FormulaEditorTextView alloc] initWithFrame: CGRectMake(1, self.brickCell.frame.size.height + 41, self.view.frame.size.width - 2, 0) AndFormulaEditorViewController:self];
    [self.view addSubview:self.formulaEditorTextView];
    
    for(int i = 0; i < [self.orangeTypeButton count]; i++) {
        [[self.orangeTypeButton objectAtIndex:i] setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [[self.orangeTypeButton objectAtIndex:i] setBackgroundColor:[UIColor lightOrangeColor]];
      
        [[self.orangeTypeButton objectAtIndex:i] setBackgroundImage:[UIImage imageWithColor:[UIColor orangeColor]] forState:UIControlStateHighlighted];
    }
  for(int i = 0; i < [self.normalTypeButton count]; i++) {
    [[self.normalTypeButton objectAtIndex:i] setTitleColor:[UIColor skyBlueColor] forState:UIControlStateNormal];
    [[self.normalTypeButton objectAtIndex:i] setBackgroundColor:[UIColor airForceBlueColor]];
    [[self.normalTypeButton objectAtIndex:i] setBackgroundImage:[UIImage imageWithColor:[UIColor lightOrangeColor]] forState:UIControlStateHighlighted];
  }
  for(int i = 0; i < [self.toolTypeButton count]; i++) {
    [[self.toolTypeButton objectAtIndex:i] setTitleColor:[UIColor skyBlueColor] forState:UIControlStateNormal];
    [[self.toolTypeButton objectAtIndex:i] setBackgroundColor:[UIColor darkBlueColor]];
    [[self.toolTypeButton objectAtIndex:i] setBackgroundImage:[UIImage imageWithColor:[UIColor lightOrangeColor]] forState:UIControlStateHighlighted];
          [[self.toolTypeButton objectAtIndex:i] setBackgroundImage:[UIImage imageWithColor:[UIColor lightOrangeColor]] forState:UIControlStateSelected];
  }
  
    [self update];
    [self.formulaEditorTextView becomeFirstResponder];
}

- (void)update
{
    [self.formulaEditorTextView update];
    [self updateFormula];
    [self.undoButton setEnabled:[self.history undoIsPossible]];
    [self.redoButton setEnabled:[self.history redoIsPossible]];
}

- (void)updateFormula
{
    if(self.internFormula != nil) {
        InternFormulaParser *internFormulaParser = [self.internFormula getInternFormulaParser];
        Formula *formula = [[Formula alloc] initWithFormulaElement:[internFormulaParser parseFormula]];
        
        if([internFormulaParser getErrorTokenIndex] == FORMULA_PARSER_OK) {
            [self.formula setRoot:formula.formulaTree];
        }
    }

    [self.brickCell setupBrickCell];
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
}
- (IBAction)showLogic:(UIButton *)sender {
    [self hideScrollViews];
    self.logicScrollView.hidden = NO;
    [self.logicButton setSelected:YES];
    [self.logicScrollView scrollsToTop];
}
- (IBAction)showObject:(UIButton *)sender {
    [self hideScrollViews];
    self.objectScrollView.hidden = NO;
    [self.objectButton setSelected:YES];
    [self.objectScrollView scrollsToTop];
}
- (IBAction)showSensor:(UIButton *)sender {
    [self hideScrollViews];
    self.sensorScrollView.hidden = NO;
    [self.sensorButton setSelected:YES];
    [self.sensorScrollView scrollsToTop];
}

-(void)hideScrollViews
{
    self.mathScrollView.hidden = YES;
    self.calcScrollView.hidden = YES;
    self.logicScrollView.hidden = YES;
    self.objectScrollView.hidden = YES;
    self.sensorScrollView.hidden = YES;
    [self.calcButton setSelected:NO];
    [self.mathbutton setSelected:NO];
    [self.objectButton setSelected:NO];
    [self.logicButton setSelected:NO];
    [self.sensorButton setSelected:NO];
}

- (void)closeMenu
{
    [self.formulaEditorTextView becomeFirstResponder];
}

@end
