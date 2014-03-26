/**
 *  Copyright (C) 2010-2013 The Catrobat Team
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


#import "CatrobatTableViewController.h"
#import "CellTagDefines.h"
#import "BackgroundLayer.h"
#import "TableUtil.h"
#import "UIColor+CatrobatUIColorExtensions.h"
#import "AppDelegate.h"
#import "Util.h"
#import "CatrobatImageCell.h"
#import "ProgramLoadingInfo.h"
#import "SegueDefines.h"
#import "Parser.h"
#import "SpriteObject.h"
#import "Script.h"
#import "Brick.h"
#import "Util.h"
#import "ScenePresenterViewController.h"
#import "ProgramTableViewController.h"
#import "ProgramDefines.h"
#import "UIDefines.h"
#import "ActionSheetAlertViewTags.h"

@interface CatrobatTableViewController () <UIAlertViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) NSArray *cells;
@property (nonatomic, strong) NSArray *imageNames;
@property (nonatomic, strong) NSArray *identifiers;
@property (nonatomic, strong) Program *lastProgram;
@property (nonatomic, strong) Program *defaultProgram;

@end

@implementation CatrobatTableViewController

#pragma mark - getters and setters
- (Program*)lastProgram
{
    if (! _lastProgram) {
        _lastProgram = [Program lastProgram];
    }
    return _lastProgram;
}

#pragma mark - view events
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initTableView];
    [self initNavigationBar];

    self.lastProgram = nil;
    self.defaultProgram = nil;
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate.fileManager addDefaultProjectsToProgramsRootDirectory];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    self.lastProgram = nil;
    self.defaultProgram = nil;
    [self.navigationController setToolbarHidden:YES];
    [self.navigationController setNavigationBarHidden:NO];
     NSIndexPath* indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
    BOOL lockIphoneEnabeled = [self shouldLockIphoneInAppWithoutScenePresenter];
    [[UIApplication sharedApplication] setIdleTimerDisabled:(lockIphoneEnabeled)];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (BOOL)shouldLockIphoneInAppWithoutScenePresenter
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return (! [defaults boolForKey:@"lockiphone"]);
}

- (void)viewDidAppear:(BOOL)animated
{
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
    self.tableView.alwaysBounceVertical = NO;
    self.tableView.scrollEnabled = YES;
}

#pragma mark init
- (void)initTableView
{
    self.cells = [[NSArray alloc] initWithObjects:kMenuTitleContinue, kMenuTitleNew, kMenuTitlePrograms, kMenuTitleHelp, kMenuTitleExplore, kMenuTitleUpload, nil];
    self.imageNames = [[NSArray alloc] initWithObjects:kMenuImageNameContinue, kMenuImageNameNew, kMenuImageNamePrograms, kMenuImageNameHelp, kMenuImageNameExplore, kMenuImageNameUpload, nil];
    self.identifiers = [[NSArray alloc] initWithObjects:kSegueToContinue, kSegueToNewProgram, kSegueToPrograms, kSegueToHelp, kSegueToExplore, kSegueToUpload, nil];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"darkblue"]];
}

- (void)initNavigationBar
{
    [TableUtil initNavigationItem:self.navigationItem withTitle:@"Pocket Code"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeInfoLight];
    [button addTarget:self action:@selector(infoPressed:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *infoItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    [self.navigationItem setLeftBarButtonItem:infoItem];
}

#pragma mark - actions
- (void)infoPressed:(id)sender
{
    [Util alertWithText:NSLocalizedString(@"Pocket Code for iOS",nil)];
}

#pragma mark - table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.cells count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    NSString *CellIdentifier = (indexPath.row == 0) ? kContinueCell : kImageCell;
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (! cell) {
        NSError(@"Should Never happen - since iOS5 Storyboard *always* instantiates our cell!");
    }
    if ([cell conformsToProtocol:@protocol(CatrobatImageCell)]) {
        UITableViewCell<CatrobatImageCell> *imageCell = (UITableViewCell<CatrobatImageCell>*)cell;
        [self configureImageCell:imageCell atIndexPath:indexPath];
    }
    if (indexPath.row == 0) {
        [self configureSubtitleLabelForCell:cell];
    }
    return cell;
}

#pragma mark - table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    NSString* identifier = [self.identifiers objectAtIndex:indexPath.row];
    // TODO: the if statement should be removed once everything has been implemented...
    if ([identifier isEqualToString:kSegueToExplore] || [identifier isEqualToString:kSegueToPrograms] ||
        [identifier isEqualToString:kSegueToHelp] || [identifier isEqualToString:kSegueToContinue] ||
        [identifier isEqualToString:kSegueToNewProgram]) {
        if ([self shouldPerformSegueWithIdentifier:identifier sender:self]) {
            [self performSegueWithIdentifier:identifier sender:self];
        }
    } else {
        [Util showComingSoonAlertView];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  return [self getHeightForCellAtIndexPath:indexPath];
}

#pragma mark - table view helpers
- (void)configureImageCell:(UITableViewCell <CatrobatImageCell>*)cell atIndexPath:(NSIndexPath*)indexPath
{
    cell.titleLabel.text = [self.cells objectAtIndex:indexPath.row];
    cell.iconImageView.image = [UIImage imageNamed:[self.imageNames objectAtIndex:indexPath.row]];
}

- (void)configureSubtitleLabelForCell:(UITableViewCell*)cell
{
    UILabel* subtitleLabel = (UILabel*)[cell viewWithTag:kSubtitleLabelTag];
    subtitleLabel.textColor = [UIColor brightGrayColor];
    NSString* lastProject = [Util lastProgram];
    subtitleLabel.text = lastProject;
}

- (CGFloat)getHeightForCellAtIndexPath:(NSIndexPath*)indexPath
{
    CGFloat height;
    if (indexPath.row == 0) {
        height= [TableUtil getHeightForContinueCell];
        if ([Util getScreenHeight] == kIphone4ScreenHeight) {
            height = height*kIphone4ScreenHeight/kIphone5ScreenHeight;
        }
    }
    else {
        height = [TableUtil getHeightForImageCell];
        if ([Util getScreenHeight] == kIphone4ScreenHeight) {
            height = height*kIphone4ScreenHeight/kIphone5ScreenHeight;
        }
    }
    if ([Util getScreenHeight] == kIphone5ScreenHeight){
    }
    return height; // for scrolling reasons
}

#pragma mark - segue handling
- (BOOL)shouldPerformSegueWithIdentifier:(NSString*)identifier sender:(id)sender
{
    if ([identifier isEqualToString:kSegueToContinue]) {
        // check if program loaded successfully -> not nil
        if (self.lastProgram) {
            return YES;
        }

        // program failed loading...
        // update continue cell
        [Util setLastProgram:nil];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        [Util alertWithText:kMsgUnableToLoadProgram];
        return NO;
    } else if ([identifier isEqualToString:kSegueToNewProgram]) {
        // if there is no program name, abort performing this segue and ask user for program name
        // after user entered a valid program name this segue will be called again and accepted
        if (! self.defaultProgram) {
            [Util promptWithTitle:kTitleNewProgram
                          message:kMsgPromptProgramName
                         delegate:self
                      placeholder:kProgramNamePlaceholder
                              tag:kNewProgramAlertViewTag];
            return NO;
        }
        return YES;
    }
    return [super shouldPerformSegueWithIdentifier:identifier sender:sender];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:kSegueToContinue]) {
        if ([segue.destinationViewController isKindOfClass:[ProgramTableViewController class]]) {
            ProgramTableViewController *programTableViewController = (ProgramTableViewController*)segue.destinationViewController;
            programTableViewController.program = self.lastProgram;

            // TODO: remove this after persisting programs feature is fully implemented...
            programTableViewController.isNewProgram = NO;
        }
    } else if ([segue.identifier isEqualToString:kSegueToNewProgram]) {
        if ([segue.destinationViewController isKindOfClass:[ProgramTableViewController class]]) {
            ProgramTableViewController *programTableViewController = (ProgramTableViewController*)segue.destinationViewController;
            programTableViewController.program = self.defaultProgram;

            // TODO: remove this after persisting programs feature is fully implemented...
            programTableViewController.isNewProgram = YES;
        }
    }
}

#pragma mark - alert view handlers
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    static NSString *segueToNewProgramIdentifier = kSegueToNewProgram;
    if (alertView.tag == kNewProgramAlertViewTag) {
        NSString *input = [alertView textFieldAtIndex:0].text;
        if ((buttonIndex == alertView.cancelButtonIndex) || (buttonIndex != kAlertViewButtonOK)) {
            return;
        }
        kProgramNameValidationResult validationResult = [Program validateProgramName:input];
        if (validationResult == kProgramNameValidationResultInvalid) {
            [Util alertWithText:kMsgInvalidProgramName delegate:self tag:kInvalidProgramNameWarningAlertViewTag];
        } else if (validationResult == kProgramNameValidationResultAlreadyExists) {
            [Util alertWithText:kMsgInvalidProgramNameAlreadyExists delegate:self tag:kInvalidProgramNameWarningAlertViewTag];
        } else if (validationResult == kProgramNameValidationResultOK) {
            self.defaultProgram = [Program defaultProgramWithName:input];
            if ([self shouldPerformSegueWithIdentifier:segueToNewProgramIdentifier sender:self]) {
                [self performSegueWithIdentifier:segueToNewProgramIdentifier sender:self];
            }
        }
    } else if (alertView.tag == kInvalidProgramNameWarningAlertViewTag) {
        // title of cancel button is "OK"
        if (buttonIndex == alertView.cancelButtonIndex) {
            [Util promptWithTitle:kTitleNewProgram
                          message:kMsgPromptProgramName
                         delegate:self
                      placeholder:kProgramNamePlaceholder
                              tag:kNewProgramAlertViewTag];
        }
    }
}

@end
