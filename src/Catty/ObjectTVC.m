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

#import "ObjectTVC.h"
#import "ObjectScriptsCVC.h"
#import "ObjectLooksTVC.h"
#import "ObjectSoundsTVC.h"
#import "SpriteObject.h"
#import "ProgramDefines.h"
#import "UIDefines.h"
#import "SegueDefines.h"
#import "TableUtil.h"
#import "CatrobatImageCell.h"
#import "SceneViewController.h"

// identifiers
#define kTableHeaderIdentifier @"Header"

@interface ObjectTVC () <UIActionSheetDelegate>

@end

@implementation ObjectTVC

- (id)initWithStyle:(UITableViewStyle)style
{
  self = [super initWithStyle:style];
  if (self) {
      // Custom initialization
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];

  // Uncomment the following line to preserve selection between presentations.
  // self.clearsSelectionOnViewWillAppear = NO;

  [self initTableView];
  //[TableUtil initNavigationItem:self.navigationItem withTitle:NSLocalizedString(@"New Programs", nil)];

  self.title = self.object.name;
  self.navigationItem.title = self.object.name;
  [self setupToolBar];
  self.tableView.alwaysBounceVertical = NO;
}

#pragma marks init
- (void)initTableView
{
  [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
  self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"darkblue"]];
  UITableViewHeaderFooterView *headerViewTemplate = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:kTableHeaderIdentifier];
  headerViewTemplate.contentView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"darkblue"]];
  [self.tableView addSubview:headerViewTemplate];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *CellIdentifier = @"MenuCell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

  if ([cell conformsToProtocol:@protocol(CatrobatImageCell)]) {
    UITableViewCell <CatrobatImageCell>* imageCell = (UITableViewCell <CatrobatImageCell>*)cell;
    switch (indexPath.row) {
      case 0:
        imageCell.iconImageView.image = [UIImage imageNamed:@"ic_scripts"];
        imageCell.titleLabel.text = kScriptsTitle;
        break;
      case 1:
        imageCell.iconImageView.image = [UIImage imageNamed:@"ic_looks"];
        imageCell.titleLabel.text = (self.object.isBackground ? kBackgroundsTitle : kLooksTitle);
        break;
      case 2:
        imageCell.iconImageView.image = [UIImage imageNamed:@"ic_sounds"];
        imageCell.titleLabel.text = kSoundsTitle;
        break;
    }
  }
  return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  return [TableUtil getHeightForImageCell];
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  // Pass the selected object to the new view controller.
  static NSString *toScriptsSegueID = kSegueToScripts;
  static NSString *toLooksSegueID = kSegueToLooks;
  static NSString *toSoundsSegueID = kSegueToSounds;
  static NSString *toSceneSegueID = kSegueToScene;

  UIViewController* destController = segue.destinationViewController;
  if ([sender isKindOfClass:[UITableViewCell class]]) {
    if (([segue.identifier isEqualToString:toScriptsSegueID] ||
        [segue.identifier isEqualToString:toLooksSegueID] ||
        [segue.identifier isEqualToString:toSoundsSegueID]) &&
        [destController respondsToSelector:@selector(setObject:)]) {
      [destController performSelector:@selector(setObject:) withObject:self.object];
    }
  } else if ([sender isKindOfClass:[UIBarButtonItem class]]) {
    if ([segue.identifier isEqualToString:toSceneSegueID]) {
      if ([destController isKindOfClass:[SceneViewController class]]) {
        SceneViewController* scvc = (SceneViewController*) destController;
        if ([scvc respondsToSelector:@selector(setProgram:)]) {
          [scvc performSelector:@selector(setProgram:) withObject:self.object.program];
        }
      }
    }
  }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  // Pass the selected object to the new view controller.
  static NSString *toScriptsSegueID = kSegueToScripts;
  static NSString *toLooksSegueID = kSegueToLooks;
  static NSString *toSoundsSegueID = kSegueToSounds;

  UITableViewCell* sender = [tableView cellForRowAtIndexPath:indexPath];
  if (indexPath.row == 0)
    [self performSegueWithIdentifier:toScriptsSegueID sender:sender];
  else if (indexPath.row == 1)
    [self performSegueWithIdentifier:toLooksSegueID sender:sender];
  else if (indexPath.row == 2)
    [self performSegueWithIdentifier:toSoundsSegueID sender:sender];
}

#pragma mark - UIActionSheetDelegate Handlers
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
  // TODO: implement this
}

- (IBAction)editObject:(id)sender
{
  [self showSceneActionSheet];
}

#pragma mark - UIActionSheet Views
- (void)showSceneActionSheet
{
  // TODO: determine whether to show delete button or not
  BOOL showDeleteButton = false;
  //if (self.objectsList && self.background && [self.objectsList count] && [self.background count])
  showDeleteButton = true;
  
  UIActionSheet *edit = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Edit Object",nil)
                                                    delegate:self
                                           cancelButtonTitle:kBtnCancelTitle
                                      destructiveButtonTitle:nil
                                           otherButtonTitles:NSLocalizedString(@"Einstellungen",nil), nil];
  //[edit setTag:kSceneActionSheetTag];
  edit.actionSheetStyle = UIActionSheetStyleDefault;
  [edit showInView:self.view];
}

#pragma mark - Helper Methods
- (void)playSceneAction:(id)sender
{
    [self.navigationController setToolbarHidden:YES];
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
  UIBarButtonItem *play = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay
                                                                        target:self
                                                                        action:@selector(playSceneAction:)];
  self.toolbarItems = [NSArray arrayWithObjects:flexItem, play, flexItem, nil];
}

@end
