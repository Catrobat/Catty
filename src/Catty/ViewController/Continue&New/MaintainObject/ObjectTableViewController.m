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

#import "ObjectTableViewController.h"
#import "ScriptCollectionViewController.h"
#import "LooksTableViewController.h"
#import "SoundsTableViewController.h"
#import "SegueDefines.h"
#import "TableUtil.h"
#import "CatrobatImageCell.h"
#import "Util.h"

@interface ObjectTableViewController ()

@end

@implementation ObjectTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = self.object.name;
    self.navigationItem.title = self.object.name;
    [self setupToolBar];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    static NSString *CellIdentifier = @"MenuCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    if ([cell conformsToProtocol:@protocol(CatrobatImageCell)]) {
        UITableViewCell <CatrobatImageCell> *imageCell = (UITableViewCell<CatrobatImageCell>*)cell;
        switch (indexPath.row) {
            case 0:
                imageCell.iconImageView.image = [UIImage imageNamed:@"ic_scripts"];
                imageCell.titleLabel.text = kLocalizedScripts;
                break;
            case 1:
                imageCell.iconImageView.image = [UIImage imageNamed:@"ic_looks"];
                imageCell.titleLabel.text = (self.object.isBackground
                                          ? kLocalizedBackgrounds
                                          : kLocalizedLooks);
                break;
            case 2:
                imageCell.iconImageView.image = [UIImage imageNamed:@"ic_sounds"];
                imageCell.titleLabel.text = kLocalizedSounds;
                break;
        }
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [TableUtil heightForImageCell];
}

#pragma mark - table view delegates
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Pass the selected object to the new view controller
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

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - segue handlers
- (void)prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender
{
    // Pass the selected object to the new view controller.
    static NSString *toScriptsSegueID = kSegueToScripts;
    static NSString *toLooksSegueID = kSegueToLooks;
    static NSString *toSoundsSegueID = kSegueToSounds;

    UIViewController* destController = segue.destinationViewController;
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        if (([segue.identifier isEqualToString:toScriptsSegueID] ||
             [segue.identifier isEqualToString:toLooksSegueID] ||
             [segue.identifier isEqualToString:toSoundsSegueID]) &&
            [destController respondsToSelector:@selector(setObject:)]) {
            [destController performSelector:@selector(setObject:) withObject:self.object];
        }
    }
}

#pragma mark - helpers
- (void)setupToolBar
{
    [super setupToolBar];
    UIBarButtonItem *flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                              target:nil
                                                                              action:nil];
    UIBarButtonItem *play = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay
                                                                          target:self
                                                                          action:@selector(playSceneAction:)];
    self.toolbarItems = [NSArray arrayWithObjects:flexItem, play, flexItem, nil];
}

@end
