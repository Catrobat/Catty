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
#import "Util.h"
#import "ScenePresenterViewController.h"
#import "ProgramTVC.h"

#define kIphone5ScreenHeight 568.0f
#define kIphone4ScreenHeight 480.0f

@interface CatrobatTableViewController () <UIAlertViewDelegate,
                                    UIActionSheetDelegate, UITextFieldDelegate>

@property (nonatomic, strong) NSArray* cells;
@property (nonatomic, strong) NSArray* images;

@end

@implementation CatrobatTableViewController


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initTableView];
    [self initNavigationBar];
    
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate.fileManager addDefaultProjectToLeveLDirectory];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self.navigationController setToolbarHidden:YES];
    [self.navigationController setNavigationBarHidden:NO];
     NSIndexPath* indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
    
}

-(void) viewDidAppear:(BOOL)animated {
  NSIndexPath* indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
  [self.tableView beginUpdates];
  [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
  [self.tableView endUpdates];
  self.tableView.alwaysBounceVertical = NO;
    self.tableView.scrollEnabled = NO;// disable scrolling
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma marks init
-(void)initTableView
{
    self.cells = [[NSArray alloc] initWithObjects:kSegueContinue, kSegueNew, kSeguePrograms, kSegueForum, kSegueDownload, kSegueUpload, nil];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"darkblue"]];
}

-(void)initNavigationBar
{

    [TableUtil initNavigationItem:self.navigationItem withTitle:@"Pocket Code"];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeInfoLight];
    [button addTarget:self action:@selector(infoPressed:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *infoItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    [self.navigationItem setLeftBarButtonItem:infoItem];
    
}



#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.cells count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = (indexPath.row == 0) ? kContinueCell : kImageCell;
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        NSError(@"Should Never happen - since iOS5 Storyboard *always* instantiates our cell!");
    }
        
    if([cell conformsToProtocol:@protocol(CatrobatImageCell)]) {
        UITableViewCell <CatrobatImageCell>* imageCell = (UITableViewCell <CatrobatImageCell>*)cell;
        [self configureImageCell:imageCell atIndexPath:indexPath];
    }

    if (indexPath.row == 0) {
        [self configureSubtitleLabelForCell:cell];
    }
    return cell;
}

-(void)infoPressed:(id)sender
{
    NSString *message = [NSString localizedStringWithFormat:NSLocalizedString(@"Pocket Code for iOS",nil)];
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Pocket Code" message: message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}



#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    NSString* identifier = [self.cells objectAtIndex:indexPath.row];
#warning the if statement should be removed once everything has been implemented..
    if ([identifier isEqualToString:kSegueDownload ] || [identifier isEqualToString:kSeguePrograms] ||
        [identifier isEqualToString:kSegueForum] || [identifier isEqualToString:kSegueContinue] ||
        [identifier isEqualToString:kSegueNew]) {
        [self performSegueWithIdentifier:identifier sender:self];
    } else {
        [Util showComingSoonAlertView];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  return [self getHeightForCellAtIndexPath:indexPath];
}

#pragma mark Helper
-(void)configureImageCell:(UITableViewCell <CatrobatImageCell>*)cell atIndexPath:(NSIndexPath*)indexPath
{

    
    cell.titleLabel.text = NSLocalizedString([[self.cells objectAtIndex:indexPath.row] capitalizedString], nil);
    cell.iconImageView.image = [UIImage imageNamed: [self.cells objectAtIndex:indexPath.row]];


}

-(void)configureSubtitleLabelForCell:(UITableViewCell*)cell
{
    UILabel* subtitleLabel = (UILabel*)[cell viewWithTag:kSubtitleLabelTag];
    subtitleLabel.textColor = [UIColor brightGrayColor];
    NSString* lastProject = [Util lastProgram];
    subtitleLabel.text = lastProject;
}

-(CGFloat)getHeightForCellAtIndexPath:(NSIndexPath*) indexPath {
    CGFloat height;
    if (indexPath.row == 0) {
        height= [TableUtil getHeightForContinueCell];
        if ([Util getScreenHeight]==kIphone4ScreenHeight) {
            height = height*kIphone4ScreenHeight/kIphone5ScreenHeight;
        }
    }
    else{
        height= [TableUtil getHeightForImageCell];
        if ([Util getScreenHeight]==kIphone4ScreenHeight) {
            height = height*kIphone4ScreenHeight/kIphone5ScreenHeight;
        }
    }
    return height;

}

#pragma makrk - Segue delegate
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{    
    if ([[segue identifier] isEqualToString:kSegueContinue]) {
        ProgramTVC* programTVC = (ProgramTVC*) segue.destinationViewController;
        ProgramLoadingInfo* loadingInfo = [Util programLoadingInfoForProgramWithName:[Util lastProgram]];
        BOOL success = [programTVC loadProgram:loadingInfo];
        if (! success) {
          NSString *popuperrormessage = [NSString stringWithFormat:@"Program %@ could not be loaded!", loadingInfo.visibleName];
          UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Program"
                                                          message:popuperrormessage
                                                         delegate:self
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
          [alert show];
          // TODO: prevent performing segue here
        }
    }
}


@end
