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

#import "ProgramTVC.h"
#import "TableUtil.h"
#import "ObjectTVC.h"
#import "SegueDefines.h"
#import "Program.h"
#import "Look.h"
#import "Sound.h"
#import "Brick.h"
#import "ObjectTVC.h"
#import "CatrobatImageCell.h"
#import "Util.h"
#import "UIDefines.h"
#import "ProgramDefines.h"
#import "ProgramLoadingInfo.h"
#import "Parser.h"
#import "Script.h"
#import "Brick.h"
#import "SceneViewController.h"
#import "ActionSheetAlertViewTags.h"

// constraints and default values
#define kDefaultProgramName NSLocalizedString(@"New Program",@"Default name for new programs") // XXX: BTW: are there any restrictions or limits for the program name???
#define kBackgroundTitle NSLocalizedString(@"Background",@"Title for Background-Section-Header in program view")
#define kObjectTitleSingular NSLocalizedString(@"Object",@"Title for Object-Section-Header in program view (singular)")
#define kObjectTitlePlural NSLocalizedString(@"Objects",@"Title for Object-Section-Header in program view (plural)")
#define kBackgroundObjectName NSLocalizedString(@"Background",@"Title for Background-Object in program view")
#define kDefaultObjectName NSLocalizedString(@"My Object",@"Title for first (default) object in program view")
#define kProgramNamePlaceholder NSLocalizedString(@"Enter your program name here...",@"Placeholder for rename-program-name input field")

// identifiers
#define kTableHeaderIdentifier @"Header"

@interface ProgramTVC () <UIActionSheetDelegate, UIAlertViewDelegate, UITextFieldDelegate,
                                                                      UINavigationBarDelegate>
@property (strong, nonatomic) Program *program;
@end

@implementation ProgramTVC
# pragma memory for our pointer-properties
@synthesize program = _program;

#pragma getter & setters
- (Program*)program
{
  // lazy instantiation
  if (! _program) {
    _program = [Program createWithProgramName:kDefaultProgramName];
    SpriteObject* backgroundObject = [self createObjectWithName:kBackgroundObjectName];
    SpriteObject* firstObject = [self createObjectWithName:kDefaultObjectName];
    // CAUTION: NEVER change order! BackgroundObject is always first object in list
    _program.objectList = [NSMutableArray arrayWithObjects:backgroundObject, firstObject, nil];

    // automatically update title
    if (self.navigationItem && _program.header)
      self.navigationItem.title = _program.header.programName;

    self.title = _program.header.programName;
    // TODO: uncomment this if XML-Serialization works
    //[Util setLastProgram:_program.header.programName];
  }
  return _program;
}

- (void)setProgram:(Program*)program
{
  // automatically update title name
  if (self.navigationItem && program.header)
    self.navigationItem.title = program.header.programName;

  self.title = self.program.header.programName;
  _program = program;
}

- (SpriteObject*)createObjectWithName:(NSString*)objectName
{
  // TODO: review this...
  SpriteObject* object = [[SpriteObject alloc] init];
  //object.originalSize;
  //object.spriteManagerDelegate;
  //object.broadcastWaitDelegate = self.broadcastWaitHandler;
  // TODO: determine and assign xmlPath...
  //object.projectPath;
  object.lookList = [NSMutableArray array];
  object.soundList = [NSMutableArray array];
  object.scriptList = [NSMutableArray array];
  object.currentLook = nil;
  object.numberOfObjects = 0;
  object.name = objectName;
  object.program = self.program;
  return object;
}

- (BOOL)loadProgram:(ProgramLoadingInfo*)loadingInfo
{
  NSDebug(@"Try to load project '%@'", loadingInfo.visibleName);
  NSDebug(@"Path: %@", loadingInfo.basePath);
  NSString *xmlPath = [NSString stringWithFormat:@"%@", loadingInfo.basePath];
  NSDebug(@"XML-Path: %@", xmlPath);
  Program *program = [[[Parser alloc] init] generateObjectForLevel:[xmlPath stringByAppendingFormat:@"%@", kProgramCodeFileName]];

  if (! program)
    return NO;

  NSDebug(@"ProjectResolution: width/height:  %f / %f", program.header.screenWidth.floatValue, program.header.screenHeight.floatValue);

  // setting effect
  for (SpriteObject *sprite in program.objectList)
  {
    //sprite.spriteManagerDelegate = self;
    //sprite.broadcastWaitDelegate = self.broadcastWaitHandler;
    sprite.projectPath = xmlPath;

    // TODO: change!
    for (Script *script in sprite.scriptList) {
      for (Brick *brick in script.brickList) {
        brick.object = sprite;
      }
    }
  }
  self.program = program;
  [Util setLastProgram:self.program.header.programName];
  return YES;
}

- (id)initWithStyle:(UITableViewStyle)style
{
  self = [super initWithStyle:style];
  if (self) {
    // Custom initialization
  }
  return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
}

- (void)viewDidLoad
{
  [super viewDidLoad];

  // Uncomment the following line to preserve selection between presentations.
  // self.clearsSelectionOnViewWillAppear = NO;

  [self initTableView];
  //[TableUtil initNavigationItem:self.navigationItem withTitle:NSLocalizedString(@"New Programs", nil)];

  // just to ensure
  if (self.navigationItem && self.program.header)
    self.navigationItem.title = self.program.header.programName;
  self.title = self.program.header.programName;

  [self setupToolBar];
}

#pragma marks init
- (void)initTableView
{
  self.tableView.delegate = self;
  self.tableView.dataSource = self;
  [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
  self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"darkblue"]];
  UITableViewHeaderFooterView *headerViewTemplate = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:kTableHeaderIdentifier];
  headerViewTemplate.contentView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"darkblue"]];
  [self.tableView addSubview:headerViewTemplate];
}

#pragma mark - UITableView data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    switch (section) {
        case kBackgroundIndex:
            return kBackgroundObjects;
            break;
        
        case kObjectIndex:
            return ([self.program.objectList count] - kBackgroundObjects);
            break;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProgramCell" forIndexPath:indexPath];
    if ([cell conformsToProtocol:@protocol(CatrobatImageCell)]) {
      UITableViewCell <CatrobatImageCell>* imageCell = (UITableViewCell <CatrobatImageCell>*)cell;
      SpriteObject* object = [self.program.objectList objectAtIndex:(kBackgroundIndex + indexPath.section + indexPath.row)];
      if ([object.lookList count] > 0) {
        Look* look = [object.lookList objectAtIndex:0];
        NSString *imagePath = [NSString stringWithFormat:@"%@/%@", [object.projectPath stringByAppendingString:kProgramImagesDirName], look.fileName];
        imageCell.iconImageView.image = [[UIImage alloc] initWithContentsOfFile: imagePath];
        imageCell.iconImageView.contentMode = UIViewContentModeScaleAspectFit;
      }
      imageCell.titleLabel.text = object.name;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  return [TableUtil getHeightForImageCell];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
  // TODO: MID outsource to TableUtil
  return 40.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
  // TODO: MID outsource to TableUtil
  //UITableViewHeaderFooterView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kTableHeaderIdentifier];
  // FIXME: HACK do not alloc init there. Use ReuseIdentifier instead!! But does lead to several issues...
  UITableViewHeaderFooterView *headerView = [[UITableViewHeaderFooterView alloc] init];
  headerView.contentView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"darkblue"]];

  UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 0.0f, 300.0f, 44.0f)];
  titleLabel.textColor = [UIColor whiteColor];
  titleLabel.tag = 1;
  titleLabel.font = [UIFont systemFontOfSize:18.0f];
  if (section == 0)
    titleLabel.text = kBackgroundTitle;
  else if ([self.program.objectList count] > (kBackgroundObjects + 1))
    titleLabel.text = kObjectTitlePlural;
  else
    titleLabel.text = kObjectTitleSingular;

  [headerView.contentView addSubview:titleLabel];
  return headerView;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
  return ((([self.program.objectList count] - kBackgroundObjects) > kMinNumOfObjects) && (indexPath.section == 1));
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (indexPath.section == 1) {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
      // Delete the row from the data source
      [self.program.objectList removeObjectAtIndex:(kObjectIndex + indexPath.row)];
      [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
  }
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  // Pass the selected object to the new view controller.
  static NSString *toObjectSegueID = kSegueToObject;
  static NSString *toSceneSegueID = kSegueToScene;

  UIViewController *destController = segue.destinationViewController;
  if ([sender isKindOfClass:[UITableViewCell class]]) {
    UITableViewCell *cell = (UITableViewCell*) sender;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    if ([segue.identifier isEqualToString:toObjectSegueID]) {
      if ([destController isKindOfClass:[ObjectTVC class]]) {
        ObjectTVC* tvc = (ObjectTVC*) destController;
        if ([tvc respondsToSelector:@selector(setObject:)]) {
          SpriteObject* object = [self.program.objectList objectAtIndex:(kBackgroundIndex + indexPath.section + indexPath.row)];
          [destController performSelector:@selector(setObject:) withObject:object];
        }
      }
    }
  } else if ([sender isKindOfClass:[UIBarButtonItem class]]) {
    if ([segue.identifier isEqualToString:toSceneSegueID]) {
      if ([destController isKindOfClass:[SceneViewController class]]) {
        SceneViewController* scvc = (SceneViewController*) destController;
        if ([scvc respondsToSelector:@selector(setProgram:)]) {
          [scvc performSelector:@selector(setProgram:) withObject:self.program];
        }
      }
    }
  }
}

#pragma mark - IBActions
- (IBAction)editProgram:(id)sender
{
  [self showSceneActionSheet];
}

#pragma mark - UIActionSheetDelegate Handlers
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
  if (actionSheet.tag == kSceneActionSheetTag) {
    // Rename button
    if (buttonIndex == 1)
      [self showRenameProgramAlertView];
    // Delete button
    if (buttonIndex == actionSheet.destructiveButtonIndex)
    {
      // TODO: implement this. Check if program already stored in filesystem otherwise skip that...
      NSLog(@"Delete button pressed");
      [self.navigationController popViewControllerAnimated:YES];
    }
  }

  // XXX: this is ugly... Why do we use ActionSheets to notify the user? -> Use UIAlertView instead
  if (actionSheet.tag == kInvalidProgramNameWarningActionSheetTag) {
    // OK button
    NSLog(@"Button index was: %d", buttonIndex);
    if (buttonIndex == 0)
    {
      NSLog(@"Show up object alert view again...");
      [self showRenameProgramAlertView];
    }
  }
}

#pragma mark - UIAlertViewDelegate Handlers
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
  if (alertView.tag == kRenameAlertViewTag) {
    // OK button
    if (buttonIndex == 1) {
      // FIXME: check if program name already exists
      NSString* input = [[alertView textFieldAtIndex:0] text];
      if ([input length] && self.program.header) {
        if (self.navigationItem)
          self.navigationItem.title = input;
        self.program.header.programName = self.title = input;
      } else
        [self showWarningInvalidProgramNameActionSheet];
    }
  } else if (alertView.tag == kNewObjectAlertViewTag) {
    // OK button
    if (buttonIndex == 1) {
      NSString* input = [[alertView textFieldAtIndex:0] text];
      if ([input length]) {
        [self.program.objectList addObject:[self createObjectWithName:input]];
        [self.tableView reloadData]; // TODO: only for certain index-path range or use datasource for this
      } else
        [self showWarningInvalidObjectNameActionSheet];
    }
  }
}

//------------------------------------------------------------------------------------------------------------
// TODO: outsource all this view stuff below to UserInterface group
//       and create own helper classes for the helper stuff.
//       This is not part of the controller logic and highly decreases readability!!

#pragma mark - UIAlertView Views
- (void)showRenameProgramAlertView
{
  UIAlertView *renameProgramAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Rename program",nil)
                                                               message:NSLocalizedString(@"Program name:",nil)
                                                              delegate:self
                                                     cancelButtonTitle:kBtnCancelTitle
                                                     otherButtonTitles:kBtnOKTitle, nil];
  [renameProgramAlert setTag:kRenameAlertViewTag];
  renameProgramAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
  UITextField *textField = [renameProgramAlert textFieldAtIndex:0];
  textField.placeholder = kProgramNamePlaceholder;

  // populate with current program name if not default name given
  if (! [self.program.header.programName isEqualToString: kDefaultProgramName])
    textField.text = self.program.header.programName;

  [textField setClearButtonMode:UITextFieldViewModeWhileEditing];
  [renameProgramAlert show];
}

- (void)showNewObjectAlertView
{
  UIAlertView *newObjectAlert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Add Object",nil)
                                                          message:NSLocalizedString(@"Object name:",nil)
                                                         delegate:self
                                                cancelButtonTitle:kBtnCancelTitle
                                                otherButtonTitles:kBtnOKTitle, nil];
  newObjectAlert.tag = kNewObjectAlertViewTag;
  newObjectAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
  [[newObjectAlert textFieldAtIndex:0] setClearButtonMode:UITextFieldViewModeWhileEditing];
  [newObjectAlert show];
}

#pragma mark - UIActionSheet Views
- (void)showSceneActionSheet
{
  UIActionSheet *edit = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Edit Program",nil)
                                                    delegate:self
                                           cancelButtonTitle:kBtnCancelTitle
                                      destructiveButtonTitle:kBtnDeleteTitle
                                           otherButtonTitles:NSLocalizedString(@"Rename",nil), nil];
  edit.tag = kSceneActionSheetTag;
  edit.actionSheetStyle = UIActionSheetStyleDefault;
  [edit showInView:self.view];
}

- (void)showWarningInvalidProgramNameActionSheet
{
  UIActionSheet *warning = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"No or invalid program name entered, try again.",nil)
                                                       delegate:self
                                              cancelButtonTitle:nil
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:kBtnOKTitle, nil];
  warning.tag = kInvalidProgramNameWarningActionSheetTag;
  warning.actionSheetStyle = UIActionSheetStyleDefault;
  [warning showInView:self.view];
}

- (void)showWarningInvalidObjectNameActionSheet
{
  UIActionSheet *warning = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"No or invalid object name entered, aborted.",nil)
                                                       delegate:self
                                              cancelButtonTitle:nil
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:kBtnOKTitle, nil];
  warning.tag = kInvalidObjectNameWarningActionSheetTag;
  warning.actionSheetStyle = UIActionSheetStyleDefault;
  [warning showInView:self.view];
}

#pragma mark - Helper Methods
- (void)addObjectAction:(id)sender
{
  [self showNewObjectAlertView];
}

- (void)playSceneAction:(id)sender
{
  [self performSegueWithIdentifier:kSegueToScene sender:sender];
}

- (void)setupToolBar
{
  [self.navigationController setToolbarHidden:NO];
  self.navigationController.toolbar.barStyle = UIBarStyleBlack;
  self.navigationController.toolbar.tintColor = [UIColor orangeColor];
  self.navigationController.toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
  UIBarButtonItem *flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                            target:nil
                                                                            action:nil];
  UIBarButtonItem *add = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                       target:self
                                                                       action:@selector(addObjectAction:)];
  UIBarButtonItem *play = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay
                                                                        target:self
                                                                        action:@selector(playSceneAction:)];
  self.toolbarItems = [NSArray arrayWithObjects:add, flexItem, play, nil];
}

@end
