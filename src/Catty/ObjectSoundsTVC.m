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

#import "ObjectSoundsTVC.h"
#import "UIDefines.h"
#import "TableUtil.h"
#import "CatrobatImageCell.h"
#import "Sound.h"
#import "SegueDefines.h"
#import "SceneViewController.h"
#import "SpriteObject.h"

#define kTableHeaderIdentifier @"Header"

@interface ObjectSoundsTVC () <UIActionSheetDelegate>

@end

@implementation ObjectSoundsTVC

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

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.object.soundList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SoundCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    // Configure the cell...
    if ([cell conformsToProtocol:@protocol(CatrobatImageCell)]) {
      UITableViewCell <CatrobatImageCell>* imageCell = (UITableViewCell <CatrobatImageCell>*)cell;
      imageCell.iconImageView.image = [UIImage imageNamed:@"programs"];
      imageCell.titleLabel.text = ((Sound*) [self.object.soundList objectAtIndex:indexPath.row]).name;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  return [TableUtil getHeightForImageCell];
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        //[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  static NSString* toSceneSegueID = kSegueToScene;
  UIViewController* destController = segue.destinationViewController;
  if ([sender isKindOfClass:[UIBarButtonItem class]]) {
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

#pragma mark - UIActionSheet Views
- (void)showSceneActionSheet
{
  // TODO: determine whether to show delete button or not
  BOOL showDeleteButton = false;
  //if (self.objectsList && self.background && [self.objectsList count] && [self.background count])
  showDeleteButton = true;

  UIActionSheet *edit = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Edit Sounds",nil)
                                                    delegate:self
                                           cancelButtonTitle:kBtnCancelTitle
                                      destructiveButtonTitle:(showDeleteButton ? kBtnDeleteTitle : nil)
                                           otherButtonTitles:NSLocalizedString(@"Rename",nil), nil];
  //[edit setTag:kSceneActionSheetTag];
  edit.actionSheetStyle = UIActionSheetStyleDefault;
  [edit showInView:self.view];
}

#pragma mark - Helper Methods
- (void)addObjectAction:(id)sender
{
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
