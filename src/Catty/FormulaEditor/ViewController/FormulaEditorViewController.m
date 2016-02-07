/**
 *  Copyright (C) 2010-2016 The Catrobat Team
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
#import "BrickCell.h"
#import "FormulaElement.h"
#import "LanguageTranslationDefines.h"
#import "BrickFormulaProtocol.h"
#import "UIImage+CatrobatUIImageExtensions.h"
#import "VariablesContainer.h"
#import "UserVariable.h"
#import "OrderedMapTable.h"
#import "ActionSheetAlertViewTags.h"
#import "BrickProtocol.h"
#import "Script.h"
#import "InternToken.h"
#import "SpriteObject.h"
#import "BrickCellFormulaData.h"
#import "VariablePickerData.h"
#import "Brick+UserVariable.h"
#import "BDKNotifyHUD.h"
#import "Speakbrick.h"
#import "KeychainUserDefaultsDefines.h"
#import "ProgramVariablesManager.h"
#import "CatrobatAlertController.h"

NS_ENUM(NSInteger, ButtonIndex) {
    kButtonIndexDelete = 0,
    kButtonIndexCopyOrCancel = 1,
    kButtonIndexAnimate = 2,
    kButtonIndexEdit = 3,
    kButtonIndexCancel = 4
};

@interface FormulaEditorViewController () <CatrobatActionSheetDelegate>


@property (weak, nonatomic) Formula *formula;
@property (weak, nonatomic) BrickCellFormulaData *brickCellData;

@property (strong, nonatomic) UITapGestureRecognizer *recognizer;
@property (strong, nonatomic) UITapGestureRecognizer *pickerGesture;
@property (strong, nonatomic) FormulaEditorTextView *formulaEditorTextView;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *orangeTypeButton;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *toolTypeButton;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSMutableArray *normalTypeButton;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *highlightedButtons;
@property (strong, nonatomic) NSMutableArray *sensorTypeButton;

@property (weak, nonatomic) IBOutlet UIScrollView *calcScrollView;
@property (weak, nonatomic) IBOutlet UIScrollView *mathScrollView;
@property (weak, nonatomic) IBOutlet UIScrollView *logicScrollView;
@property (weak, nonatomic) IBOutlet UIScrollView *objectScrollView;
@property (weak, nonatomic)IBOutlet  UIScrollView *sensorScrollView;
@property (strong, nonatomic)        UIScrollView *sensorScrollHelperView;
@property (weak, nonatomic) IBOutlet UIScrollView *variableScrollView;
@property (weak, nonatomic) IBOutlet UIPickerView *variablePicker;
@property (weak, nonatomic) IBOutlet UISegmentedControl *variableSegmentedControl;


@property (weak, nonatomic) IBOutlet UIButton *calcButton;
@property (weak, nonatomic) IBOutlet UIButton *mathbutton;
@property (weak, nonatomic) IBOutlet UIButton *logicButton;
@property (weak, nonatomic) IBOutlet UIButton *objectButton;
@property (weak, nonatomic) IBOutlet UIButton *sensorButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
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

@property (nonatomic) BOOL isProgramVariable;
@property (nonatomic, strong) BDKNotifyHUD *notficicationHud;
@end



@implementation FormulaEditorViewController

@synthesize formulaEditorTextView;

- (id)initWithBrickCellFormulaData:(BrickCellFormulaData *)brickCellData
{
    self = [super init];
    
    if(self) {
        [self setBrickCellFormulaData:brickCellData];
        NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
        [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    }
    
    return self;
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
    InternFormulaParser *internFormulaParser = [self.internFormula getInternFormulaParser];
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
    [[ProgramVariablesManager sharedProgramVariablesManager] setVariables:self.object.program.variables];
    self.view.backgroundColor = [UIColor backgroundColor];
    [self showFormulaEditor];
    [self initSensorView];
    [self initVariablePicker];
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
    
    UINavigationBar *myNav = [[UINavigationBar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    [UINavigationBar appearance].barTintColor = [UIColor globalTintColor];
    [self.view addSubview:myNav];
    

    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:kLocalizedCancel
                                                      style:UIBarButtonItemStylePlain
                                                     target:self
                                                            action:@selector(dismissFormulaEditorViewController)];
    
    item.tintColor = [UIColor navTintColor];
    UINavigationItem *navigItem = [[UINavigationItem alloc] initWithTitle:@""];
    navigItem.leftBarButtonItem = item;
    myNav.items = [NSArray arrayWithObjects: navigItem,nil];
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
    [self updateSensorButtonWidth];
   
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
        
        UIAlertController *undoAlert = [UIAlertController alertControllerWithTitle:nil
                                                                           message:kLocalizedUndoTypingDescription
                                                                    preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:kLocalizedCancel
                                                               style:UIAlertActionStyleCancel
                                                             handler:^(UIAlertAction *action) { }];
        [undoAlert addAction:cancelAction];
        
        UIAlertAction *undoAction = [UIAlertAction actionWithTitle:kLocalizedUndo
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction *action) { [self undo]; }];
        [undoAlert addAction:undoAction];
        [self presentViewController:undoAlert animated:YES completion:nil];
    }
}

#pragma mark initPickerView

-(void)initVariablePicker
{
    self.variablePicker.delegate = self;
    self.variablePicker.dataSource = self;
    self.variablePicker.tintColor = [UIColor globalTintColor];
    self.variableSourceProgram = [[NSMutableArray alloc] init];
    self.variableSourceObject = [[NSMutableArray alloc] init];
    self.variableSource = [[NSMutableArray alloc] init];
    [self updateVariablePickerData];
    [self.variableSegmentedControl setTitle:kLocalizedObject forSegmentAtIndex:1];
    [self.variableSegmentedControl setTitle:kLocalizedPrograms forSegmentAtIndex:0];
    self.variableSegmentedControl.tintColor = [UIColor globalTintColor];
}

#pragma mark initSensorView

-(void)initSensorView
{
    for (UIView* view in [self.formulaEditorTextView.inputView subviews]){
        if (view.tag == 9000) {
            self.sensorScrollHelperView = (UIScrollView*)view;
            break;
        }
    }
    self.sensorTypeButton = [NSMutableArray new];
    NSArray *standardSensorArray = [[NSArray alloc] initWithObjects:@"acceleration_x", @"acceleration_y",@"acceleration_z",@"compass", @"inclination_x", @"inclination_y",@"loudness", nil];
    NSInteger buttonCount = standardSensorArray.count;
    self.sensorScrollHelperView.frame = CGRectMake(self.sensorScrollHelperView.frame.origin.x, self.sensorScrollHelperView.frame.origin.y, self.sensorScrollView.frame.size.width, buttonCount *self.calcButton.frame.size.height);
    //standard Sensors
    for (NSInteger count = 0; count < standardSensorArray.count; count++) {
        [self addStandardSensorViewButton:count];
    }
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kUseFaceDetectionSensors]) {
        NSArray *faceDetectionSensorArray = [NSArray arrayWithObjects:@"FACE_DETECTED",
                                             @"FACE_SIZE",
                                             @"FACE_POSITION_X",
                                             @"FACE_POSITION_Y", nil];
        for (NSInteger count = 0; count < faceDetectionSensorArray.count; count++) {
            [self addFaceDetectionSensorViewButton:count and:buttonCount+count];
        }
        buttonCount += faceDetectionSensorArray.count;
    }
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kUsePhiroBricks]) {
        NSArray *phiroSensorArray = [NSArray arrayWithObjects:@"front_left", @"front_right",@"side_left", @"side_right", @"bottom_left", @"bottom_right", nil];
        for (NSInteger count = 0; count < phiroSensorArray.count; count++) {
            [self addPhiroSensorViewButton:count and:buttonCount+count];
        }
        buttonCount += phiroSensorArray.count;
    }

    if ([[NSUserDefaults standardUserDefaults] boolForKey:kUseArduinoBricks]) {
        NSArray *arduinoSensorArray = [NSArray arrayWithObjects:@"analogPin",@"digitalPin", nil];
        for (NSInteger count = 0; count < arduinoSensorArray.count; count++) {
            [self addArduinoSensorViewButton:count and:buttonCount+count];
        }
        buttonCount += arduinoSensorArray.count;
    }

    
    [self.normalTypeButton addObjectsFromArray:self.sensorTypeButton];
    self.sensorScrollHelperView.frame = CGRectMake(self.sensorScrollHelperView.frame.origin.x, self.sensorScrollHelperView.frame.origin.y, self.sensorScrollHelperView.frame.size.width, buttonCount *self.calcButton.frame.size.height);
    self.sensorScrollView.contentSize = CGSizeMake(self.sensorScrollHelperView.frame.size.width, buttonCount *self.calcButton.frame.size.height);
}

-(void)addStandardSensorViewButton:(NSInteger)tag
{
    UIButton *button = [self getSensorButton:tag];
    if (tag >5) {
        button.tag = 900+tag+7;
    } else {
        button.tag = 900+tag;
    }
}
-(void)addFaceDetectionSensorViewButton:(NSInteger)tag and:(NSInteger)buttonCount
{
    UIButton *button = [self getSensorButton:buttonCount];
    button.tag = 914+tag;

}
-(void)addPhiroSensorViewButton:(NSInteger)tag and:(NSInteger)buttonCount
{
    UIButton *button = [self getSensorButton:buttonCount];
    button.tag = 918+tag;
    
}

-(void)addArduinoSensorViewButton:(NSInteger)tag and:(NSInteger)buttonCount
{
    UIButton *button = [self getSensorButton:buttonCount];
    button.tag = 523+tag;
}

-(UIButton*)getSensorButton:(NSInteger)buttonCount
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button addTarget:self
               action:@selector(buttonPressed:)
     forControlEvents:UIControlEventTouchUpInside];
    button.frame = CGRectMake(0, buttonCount*self.calcButton.frame.size.height, self.sensorScrollHelperView.frame.size.width, self.calcButton.frame.size.height);
    button.titleLabel.font = [UIFont systemFontOfSize:18.0f];
    [self.sensorScrollHelperView addSubview:button];
    [self.sensorTypeButton addObject:button];
    return button;
}

-(void)updateSensorButtonWidth
{
    for(UIButton* button in self.sensorTypeButton){
        button.frame = CGRectMake(button.frame.origin.x, button.frame.origin.y, self.sensorScrollView.frame.size.width, button.frame.size.height);
    }
    
}

#pragma mark - localizeView

- (void)localizeView
{
    for (UIButton *button in self.normalTypeButton) {
        
        NSString *name = [Functions getExternName:[Functions getName:(Function)[button tag]]];
        if([name length] != 0)
        {
            [button setTitle:name forState:UIControlStateNormal];
        }else
        {
            name = [Operators getExternName:[Operators getName:(Operator)[button tag]]];
            if([name length] != 0)
            {
                [button setTitle:name forState:UIControlStateNormal];
            }else{
                name = [SensorManager getExternName:[SensorManager stringForSensor:(Sensor)[button tag]]];
                if([name length] != 0)
                {
                    [button setTitle:name forState:UIControlStateNormal];
                }

            }
        }
    }
    
    [self.calcButton setTitle:kUIFENumbers forState:UIControlStateNormal];
    [self.mathbutton setTitle:kUIFEMath forState:UIControlStateNormal];
    [self.logicButton setTitle:kUIFELogic forState:UIControlStateNormal];
    [self.objectButton setTitle:kUIFEObject forState:UIControlStateNormal];
    [self.sensorButton setTitle:kUIFESensor forState:UIControlStateNormal];
    [self.variableButton setTitle:kUIFEVariable forState:UIControlStateNormal];
    [self.computeButton setTitle:kUIFECompute forState:UIControlStateNormal];
    [self.doneButton setTitle:kUIFEDone forState:UIControlStateNormal];
    [self.variable setTitle:kUIFEVar forState:UIControlStateNormal];
    [self.takeVar setTitle:kUIFETake forState:UIControlStateNormal];
    
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

//        if(PLUS == [sender tag])
//        {
//            NSDebug(@"Plus: %@", title);
//        }else{
//            NSDebug(@"Beschreibung: %ld", (long)[sender tag]);
//        }
        
        [self handleInputWithTitle:title AndButtonType:(int)[sender tag]];
    }
}

//3011 for string

- (void)handleInputWithTitle:(NSString*)title AndButtonType:(int)buttonType
{
    [self.internFormula handleKeyInputWithName:title butttonType:buttonType];
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
- (IBAction)backspaceButtonAction:(id)sender {
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
    [self.deleteButton setEnabled:enabled];
}

- (IBAction)compute:(id)sender
{
    UIAlertController *alert;
    UIAlertAction *cancelAction;
    if (self.internFormula != nil) {
        InternFormulaParser *internFormulaParser = [self.internFormula getInternFormulaParser];
        Brick *brick = (Brick*)self.brickCellData.brickCell.scriptOrBrick; // must be a brick!
        Formula *formula = [[Formula alloc] initWithFormulaElement:[internFormulaParser parseFormulaForSpriteObject:brick.script.object]];
        NSString *computedString;

        switch ([internFormulaParser getErrorTokenIndex]) {
            case FORMULA_PARSER_OK:
                
                computedString = [formula getResultForComputeDialog:brick.script.object];
                
                alert = [UIAlertController alertControllerWithTitle:kUIFEResult message:computedString preferredStyle:UIAlertControllerStyleAlert];
                cancelAction = [UIAlertAction actionWithTitle:kLocalizedOK style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                }];
                [alert addAction:cancelAction];
                [self presentViewController:alert animated:YES completion:nil];

                break;
            case FORMULA_PARSER_STACK_OVERFLOW:
                [self showFormulaTooLongView];
                break;
            case FORMULA_PARSER_STRING:
                if(!self.brickCellData.brickCell.isScriptBrick){
                    Brick* brick = (Brick*)self.brickCellData.brickCell.scriptOrBrick;
                    if(![brick requiresStringFormula]){
                        [self showSyntaxErrorView];
                    }else{
                        computedString = [formula getResultForComputeDialog:brick.script.object];
                        
                        alert = [UIAlertController alertControllerWithTitle:kUIFEResult message:computedString preferredStyle:UIAlertControllerStyleAlert];
                        cancelAction = [UIAlertAction actionWithTitle:kLocalizedOK style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                        }];
                        [alert addAction:cancelAction];
                        [self presentViewController:alert animated:YES completion:nil];
                    }
                }
                
                break;

            default:
                [self showSyntaxErrorView];
                break;
        }
    }
    
}


#pragma mark - UI

- (void)showFormulaEditor
{
    self.formulaEditorTextView = [[FormulaEditorTextView alloc] initWithFrame: CGRectMake(1, self.brickCellData.brickCell.frame.size.height + 50, self.view.frame.size.width - 2, 0) AndFormulaEditorViewController:self];
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
    [self.brickCellData.brickCell setupBrickCell];
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
            InternFormulaParser *internFormulaParser = [self.internFormula getInternFormulaParser];
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
                        Brick* brick = (Brick*)self.brickCellData.brickCell.scriptOrBrick;
                        if(![brick requiresStringFormula]){
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
- (IBAction)addNewVariable:(UIButton *)sender {
    //TODO alert with text
    [self.formulaEditorTextView resignFirstResponder];
    
    [Util actionSheetWithTitle:kUIFEActionVar delegate:self destructiveButtonTitle:nil otherButtonTitles:@[kUIFEActionVarObj,kUIFEActionVarPro] tag:kAddNewVarActionSheetTag view:self.view];

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
    if([variables.programVariableList count] > 0)
        [self.variableSource addObject:[[VariablePickerData alloc] initWithTitle:kUIFEProgramVars]];
    
    for(UserVariable *userVariable in variables.programVariableList) {
        VariablePickerData *pickerData = [[VariablePickerData alloc] initWithTitle:userVariable.name andVariable:userVariable];
        [pickerData setIsProgramVariable:YES];
        [self.variableSource addObject:pickerData];
        [self.variableSourceProgram addObject:pickerData];
    }
    
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
  
    [self.variablePicker reloadAllComponents];
    if([self.variableSource count] > 0)
        [self.variablePicker selectRow:0 inComponent:0 animated:NO];
}

- (void)saveVariable:(NSString*)name
{
    if (self.isProgramVariable){
        for (UserVariable* variable in [self.object.program.variables allVariables]) {
            if ([variable.name isEqualToString:name]) {
                [Util askUserForVariableNameAndPerformAction:@selector(saveVariable:) target:self promptTitle:kUIFENewVarExists promptMessage:kUIFEVarName minInputLength:kMinNumOfVariableNameCharacters maxInputLength:kMaxNumOfVariableNameCharacters blockedCharacterSet:[self blockedCharacterSet] invalidInputAlertMessage:kUIFEonly15Char andTextField:self.formulaEditorTextView];
                return;
            }
        }
    } else {
        for (UserVariable* variable in [self.object.program.variables allVariablesForObject:self.object]) {
            if ([variable.name isEqualToString:name]) {
                [Util askUserForVariableNameAndPerformAction:@selector(saveVariable:) target:self promptTitle:kUIFENewVarExists promptMessage:kUIFEVarName minInputLength:kMinNumOfVariableNameCharacters maxInputLength:kMaxNumOfVariableNameCharacters blockedCharacterSet:[self blockedCharacterSet] invalidInputAlertMessage:kUIFEonly15Char andTextField:self.formulaEditorTextView];
                return;
            }
        }
        
    }
    
    [self.formulaEditorTextView becomeFirstResponder];
    UserVariable* var = [UserVariable new];
    var.name = name;
    var.value = [NSNumber numberWithInt:0];
    if (self.isProgramVariable) {
        [self.object.program.variables.programVariableList addObject:var];
    } else {
        NSMutableArray *array = [self.object.program.variables.objectVariableList objectForKey:self.object];
        if (!array) {
            array = [NSMutableArray new];
        }
        [array addObject:var];
        [self.object.program.variables.objectVariableList setObject:array forKey:self.object];
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
    
    [Util askUserForVariableNameAndPerformAction:@selector(handleNewTextInput:) target:self promptTitle:kUIFENewText promptMessage:kUIFETextMessage minInputLength:1 maxInputLength:kMaxNumOfProgramNameCharacters blockedCharacterSet:[self blockedCharacterSet] invalidInputAlertMessage:kUIFEonly15Char andTextField:self.formulaEditorTextView];
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
    if (component == 0 && self.variableSegmentedControl.selectedSegmentIndex == 0) {
        return self.variableSourceProgram.count;
    } else if (component == 0 && self.variableSegmentedControl.selectedSegmentIndex == 1) {
        return self.variableSourceObject.count;
    }
    return 0;
}

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (component == 0 && self.variableSegmentedControl.selectedSegmentIndex == 0) {
        if (row < self.variableSourceProgram.count) {
            return [[self.variableSourceProgram objectAtIndex:row] title];
        }
    } else if (component == 0 && self.variableSegmentedControl.selectedSegmentIndex == 1) {
        if (row < self.variableSourceObject.count) {
            return [[self.variableSourceObject objectAtIndex:row] title];
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

- (IBAction)choseVariable:(UIButton *)sender {

 NSInteger row = [self.variablePicker selectedRowInComponent:0];
    if (row >= 0) {
        VariablePickerData *pickerData;
        if (self.variableSegmentedControl.selectedSegmentIndex == 0) {
            if (row < self.variableSourceProgram.count) {
               pickerData = [self.variableSourceProgram objectAtIndex:row];
            }
        } else {
            if (row < self.variableSourceObject.count) {
                pickerData = [self.variableSourceObject objectAtIndex:row];
            }
        }
        if (pickerData) {
             [self handleInputWithTitle:pickerData.userVariable.name AndButtonType:0];
        }
    }
   
}


- (IBAction)deleteVariable:(UIButton *)sender {
    NSInteger row = [self.variablePicker selectedRowInComponent:0];
    if (row >= 0) {
        VariablePickerData *pickerData;
        if (self.variableSegmentedControl.selectedSegmentIndex == 0) {
            if (row < self.variableSourceProgram.count) {
                pickerData = [self.variableSourceProgram objectAtIndex:row];
            }
        } else {
            if (row < self.variableSourceObject.count) {
                pickerData = [self.variableSourceObject objectAtIndex:row];
            }
        }
        if (pickerData) {
            if(![self isVariableBeingUsed:pickerData.userVariable]) {
                BOOL removed = [self.object.program.variables removeUserVariableNamed:pickerData.userVariable.name forSpriteObject:self.object];
                if (removed) {
                    [self.variableSource removeObjectAtIndex:row];
                    [self.object.program saveToDiskWithNotification:YES];
                    [self updateVariablePickerData];
                }
            } else {
                [self showNotification:kUIFEDeleteVarBeingUsed andDuration:1.5f];
            }
        }
    }
}

- (BOOL)isVariableBeingUsed:(UserVariable*)variable
{
    if([self.object.program.variables isProgramVariable:variable]) {
        for(SpriteObject *spriteObject in self.object.program.objectList) {
            for(Script *script in spriteObject.scriptList) {
                for(id brick in script.brickList) {
                    if([brick isKindOfClass:[Brick class]] && [brick isVariableBeingUsed:variable]) {
                        return YES;
                    }
                }
            }
        }
    } else {
        for(Script *script in self.object.scriptList) {
            for(id brick in script.brickList) {
                if([brick isKindOfClass:[Brick class]] && [brick isVariableBeingUsed:variable]) {
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


#pragma mark - action sheet delegates
- (void)actionSheet:(CatrobatAlertController*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    self.isProgramVariable = NO;
    //    if (actionSheet.tag == 444) {
    if (buttonIndex == 2) {
        self.isProgramVariable = YES;
    }
    [Util askUserForVariableNameAndPerformAction:@selector(saveVariable:) target:self promptTitle:kUIFENewVar promptMessage:kUIFEVarName minInputLength:1 maxInputLength:15 blockedCharacterSet:[self blockedCharacterSet] invalidInputAlertMessage:kUIFEonly15Char andTextField:self.formulaEditorTextView];
    //    }
    
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
    [self showNotification:kUIFESyntaxError andDuration:kBDKNotifyHUDPresentationDuration];
    [self.formulaEditorTextView setParseErrorCursorAndSelection];
}

- (void)showFormulaTooLongView
{
    [self showNotification:kUIFEtooLongFormula andDuration:kBDKNotifyHUDPresentationDuration];
}

@end
