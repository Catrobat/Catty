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

#import "NewProgramTVC.h"
#import "TableUtil.h"
#import "BackgroundObjectTVC.h"
#import "SegueDefines.h"
#import "Program.h"
#import "Look.h"
#import "Sound.h"
#import "Brick.h"
#import "BackgroundObjectTVC.h"
#import "CatrobatImageCell.h"

enum NewProgramTVCSections
{
    kBackground_Section = 0,
    kObjects_Section
};

// Action sheet & Alert view tags
#define kSceneActionSheetTag 1
#define kInvalidProgramNameWarningActionSheetTag 2
#define kInvalidObjectNameWarningActionSheetTag 3
#define kRenameAlertViewTag 1
#define kNewObjectAlertViewTag 2

// constraints and default values
#define kDefaultProgramName @"New Program"
#define kDefaultObjectName @"My Object"
#define kProgramNamePlaceholder @"Enter your program name here..."
#define kMinNumOfObjects 1

// identifiers
#define kTableHeaderIdentifier @"Header"
#define kSegueProgramBackground @"BackgroundSegue"
#define kSegueProgramObject @"ObjectSegue"

// keys
#define kBackgroundKey @"backgroundKey"
#define kBackgroundTitleKey @"Background"
#define kBackgroundScriptsKey @"backgroundScriptsKey"
#define kBackgroundLooksKey @"backgroundLooksKey"
#define kBackgroundSoundsKey @"backgroundSoundsKey"
#define kObjectKey @"objectKey"
#define kObjectTitleSingularKey @"Object"
#define kObjectTitlePluralKey @"Objects"
#define kObjectScriptsKey @"objectScriptsKey"
#define kObjectTitleKey @"object"
#define kObjectsLooksKey @"objectLooksKey"
#define kObjectSoundsKey @"objectSoundsKey"
#define kObjectName @"objectName"

// indexes
#define kBackgroundIndex 0
#define kObjectIndex 1

@interface NewProgramTVC () <UIActionSheetDelegate, UIAlertViewDelegate, UITextFieldDelegate,
                                                                        UINavigationBarDelegate>
@property (strong, nonatomic)NSMutableArray *background;
@property (strong, nonatomic)NSMutableArray *objectsList;
@property (strong, nonatomic)NSString *programName; // XXX: BTW: are there any restrictions or limits for the program name???
@property (strong, nonatomic)Program *program;

@end

@implementation NewProgramTVC

- (id)initWithStyle:(UITableViewStyle)style
{
  self = [super initWithStyle:style];
  if (self) {
    // Custom initialization
  }
  return self;
}

#pragma getter & setters
- (void)setProgramName:(NSString*)programName
{
  // automatically update title name
  if (self.navigationItem)
    self.navigationItem.title = programName;
  _programName = programName;
}

- (NSMutableArray *)getObjectList
{
    if (self.dataSourceArray)
        return [self.dataSourceArray objectAtIndex:kObjectIndex];
    else return nil;
}

- (NSMutableArray *)getBackground
{
  return (self.dataSourceArray ? [self.dataSourceArray objectAtIndex:kBackgroundIndex] : nil);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    self.programName = kDefaultProgramName;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;

    [self initTableView];
    //[TableUtil initNavigationItem:self.navigationItem withTitle:NSLocalizedString(@"New Programs", nil)];

    [self.navigationController setToolbarHidden:NO];
    [self setupToolBar];

    // XXX: @Luca: What about lazy instantiation???
    self.dataSourceArray = [[NSMutableArray alloc]initWithCapacity:2];
    self.background = [[NSMutableArray alloc]initWithCapacity:1];
    self.objectsList = [[NSMutableArray alloc]initWithCapacity:5];
    self.background = [self createBackground];
    [self addObjectToObjectList:[self createNewObject:kDefaultObjectName]];
    [self.dataSourceArray addObject:self.background];
    [self.dataSourceArray addObject:self.objectsList];
}

#pragma marks init
-(void)initTableView
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
    return [self.dataSourceArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    switch (section) {
        case kBackgroundIndex:
            return 1;
            break;
        
        case kObjectIndex:
            return [self.objectsList count];
            break;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProgramCell" forIndexPath:indexPath];
    if ([cell conformsToProtocol:@protocol(CatrobatImageCell)]) {
      UITableViewCell <CatrobatImageCell>* imageCell = (UITableViewCell <CatrobatImageCell>*)cell;
      imageCell.iconImageView.image = [UIImage imageNamed:@"programs"];

      if (indexPath.section == 0)
        imageCell.titleLabel.text = [[self.background objectAtIndex:indexPath.row] valueForKey:kBackgroundTitleKey];
      else if (indexPath.section == 1)
        imageCell.titleLabel.text = [[self.objectsList objectAtIndex:indexPath.row] valueForKey:kObjectName];
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
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
  titleLabel.text = ((section == 0) ? kBackgroundTitleKey
                                    : (([self.objectsList count] > 1) ? kObjectTitlePluralKey
                                                                      : kObjectTitleSingularKey));
  [headerView.contentView addSubview:titleLabel];
  return headerView;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
  return (([self.objectsList count] > kMinNumOfObjects) && (indexPath.section == 1));
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (indexPath.section == 1) {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
      // Delete the row from the data source
      [self.objectsList removeObjectAtIndex:indexPath.row];
      [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
  }
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  // Pass the selected object to the new view controller.
  static NSString* backgroundSegueID = kSegueProgramBackground;
  static NSString* objectSegueID = kSegueProgramObject;
  static NSString* toSceneSegueID = kSegueToScene;

  if ([sender isKindOfClass:[UITableViewCell class]]) {
    UIViewController* destController = segue.destinationViewController;
    if ([segue.identifier isEqualToString:backgroundSegueID]) {
      // background segue
      if ([destController respondsToSelector:@selector(setBackgroundScripts:)]) {
        NSDictionary* bgObject = self.dataSourceArray[kBackgroundIndex];
        [destController performSelector:@selector(setBackgroundScripts:) withObject:[bgObject valueForKey:kBackgroundScriptsKey]];
        /*
        [destController performSelector:@selector(setBackgroundBackgrounds:) withObject:[bgObject valueForKey:kBackgroundLooksKey]];
        [destController performSelector:@selector(setBackgroundSounds:) withObject:[bgObject valueForKey:kBackgroundSoundsKey]];
         */
        if(true);
      }
    } else if ([segue.identifier isEqualToString:objectSegueID]) {
      // object segue
      // TODO: implement this...
//      if ([destController respondsToSelector:INSERT_YOUR_SELECTOR_HERE]) {
//          ...
//      }
    } else if ([segue.identifier isEqualToString:toSceneSegueID]) {
      // TODO: implement this...
      /*
      if ([destController respondsToSelector:@selector(setProgramLoadingInfo:)]) {
        [destController performSelector:@selector(setProgramLoadingInfo:) withObject:[Util programLoadingInfoForProgramWithName:self.programName]];
      }
      */
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

  // XXX: this is really ugly... Why do we use ActionSheets to notify the user? -> Use UIAlertView instead
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
      if ([input length])
        self.programName = input;
      else
        [self showWarningInvalidProgramNameActionSheet];
    }
  } else if (alertView.tag == kNewObjectAlertViewTag) {
    // OK button
    if (buttonIndex == 1) {
      NSString* input = [[alertView textFieldAtIndex:0] text];
      if ([input length]) {
        [self addObjectToObjectList:[self createNewObject:input]];
      } else
        [self showWarningInvalidObjectNameActionSheet];
    }
  }
}

//------------------------------------------------------------------------------------------------------------
// TODO: refactor and outsource all this view stuff below to UserInterface group
//       and create own helper classes for the helper stuff.
//       This is not part of the controller logic and highly decreases readability!!

#pragma mark - UIAlertView Views
- (void)showRenameProgramAlertView
{
  UIAlertView *renameProgramAlert = [[UIAlertView alloc] initWithTitle:@"Rename program"
                                                               message:@"Program name:"
                                                              delegate:self
                                                     cancelButtonTitle:@"Cancel"
                                                     otherButtonTitles:@"Ok", nil];
  [renameProgramAlert setTag:kRenameAlertViewTag];
  renameProgramAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
  UITextField *textField = [renameProgramAlert textFieldAtIndex:0];
  textField.placeholder = kProgramNamePlaceholder;

  // populate with current program name if not default name given
  if (! [self.programName isEqualToString: kDefaultProgramName])
    textField.text = self.programName;

  [textField setClearButtonMode:UITextFieldViewModeWhileEditing];
  [renameProgramAlert show];
}

- (void)showNewObjectAlertView
{
  UIAlertView *newObjectAlert = [[UIAlertView alloc]initWithTitle:@"Add Object"
                                                          message:@"Object name:"
                                                         delegate:self
                                                cancelButtonTitle:@"Cancel"
                                                otherButtonTitles:@"OK", nil];
  [newObjectAlert setTag:kNewObjectAlertViewTag];
  newObjectAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
  [[newObjectAlert textFieldAtIndex:0] setClearButtonMode:UITextFieldViewModeWhileEditing];
  [newObjectAlert show];
}

#pragma mark - UIActionSheet Views
- (void)showSceneActionSheet
{
  // TODO: determine whether to show delete button or not
  BOOL showDeleteButton = false;
  //if (self.objectsList && self.background && [self.objectsList count] && [self.background count])
    showDeleteButton = true;

  UIActionSheet *edit = [[UIActionSheet alloc] initWithTitle:@"Edit Program"
                                                    delegate:self
                                           cancelButtonTitle:@"Cancel"
                                      destructiveButtonTitle:(showDeleteButton ? @"Delete" : nil)
                                           otherButtonTitles:@"Rename", nil];
  [edit setTag:kSceneActionSheetTag];
  edit.actionSheetStyle = UIActionSheetStyleDefault;
  [edit showInView:self.view];
}

- (void)showWarningInvalidProgramNameActionSheet
{
  UIActionSheet *warning = [[UIActionSheet alloc]initWithTitle:@"No or invalid program name entered, try again."
                                                      delegate:self
                                             cancelButtonTitle:nil
                                        destructiveButtonTitle:nil
                                             otherButtonTitles:@"OK", nil];
  [warning setTag:kInvalidProgramNameWarningActionSheetTag];
  warning.actionSheetStyle = UIActionSheetStyleDefault;
  [warning showInView:self.view];
}

- (void)showWarningInvalidObjectNameActionSheet
{
  UIActionSheet *warning = [[UIActionSheet alloc]initWithTitle:@"No or invalid object name entered, aborted."
                                                      delegate:self
                                             cancelButtonTitle:nil
                                        destructiveButtonTitle:nil
                                             otherButtonTitles:@"OK", nil];
  [warning setTag:kInvalidObjectNameWarningActionSheetTag];
  warning.actionSheetStyle = UIActionSheetStyleDefault;
  [warning showInView:self.view];
}

#pragma mark - Helper Methods
- (void)addObjectToObjectList:(NSDictionary *)object
{
    if (self.objectsList) {
        [self.objectsList addObject:object];
    }
    [self.tableView reloadData];
}


- (void)removeObjectFromObjectsListAtIndex:(NSUInteger)index
{
    if (self.objectsList) {
        [self.objectsList removeObjectAtIndex:index];
    }
}


- (void)replaceObject:(NSMutableArray *)object inDataSourceArrayAtIndex:(NSUInteger)index
{
    if ([self.dataSourceArray count])
        [self.dataSourceArray replaceObjectAtIndex:index withObject:object];
    [self.tableView reloadData];
}


- (void)addObjectAction:(id)sender
{
  [self showNewObjectAlertView];
}

- (void)playScene:(id)sender
{
}

- (void)setupToolBar
{
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
                                                                        action:@selector(playScene:)];
  self.toolbarItems = [NSArray arrayWithObjects:add, flexItem, play, nil];
}

// TODO: solve this github-issue
- (NSDictionary *) createNewObject:(NSString*)objectName
{
    NSDictionary *object = @{
      kObjectTitleKey   : @"Objects",
      kObjectName       : objectName,
      kObjectScriptsKey : [NSMutableArray array],
      kObjectsLooksKey  : [NSMutableArray array],
      kObjectSoundsKey  : [NSMutableArray array]
    };
    return object;
}

- (NSMutableArray *)createBackground
{
    NSArray *initArrayBG = @[@{
      kBackgroundTitleKey   : @"Background",
      kBackgroundScriptsKey : [NSMutableArray array],
      kBackgroundLooksKey   : [NSMutableArray array],
      kBackgroundSoundsKey  : [NSMutableArray array]
    }];
    return [initArrayBG mutableCopy];
}

@end
