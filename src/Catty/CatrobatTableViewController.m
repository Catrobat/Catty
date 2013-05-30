//
//  CatrobatTableViewController.m
//  Catty
//
//  Created by Dominik Ziegler on 2/27/13.
//  Copyright (c) 2013 Graz University of Technology. All rights reserved.
//

#import "CatrobatTableViewController.h"
#import "CellTagDefines.h"
#import "BackgroundLayer.h"
#import "TableUtil.h"
#import "UIColor+CatrobatUIColorExtensions.h"
#import "AppDelegate.h"
#import "Util.h"
#import "CatrobatImageCell.h"
#import "StageViewController.h"
#import "ProgramLoadingInfo.h"
#import "SegueDefines.h"
#import "Util.h"

#import <QuartzCore/QuartzCore.h>




@interface CatrobatTableViewController ()

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
    [TableUtil initNavigationItem:self.navigationItem withTitle:@"Pocket Code" enableBackButton:NO target:nil];
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate.fileManager addDefaultProject];
    [appDelegate.fileManager addAquariumProject];

}

-(void) viewDidAppear:(BOOL)animated {
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
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
        NSLog(@"Should Never happen - since iOS5 Storyboard *always* instantiates our cell!");
        abort();
    }
        
    if([cell conformsToProtocol:@protocol(CatrobatImageCell)]) {
        UITableViewCell <CatrobatImageCell>* imageCell = (UITableViewCell <CatrobatImageCell>*)cell;
        [self configureImageCell:imageCell atIndexPath:indexPath];
    }

    if(indexPath.row == 0) {
        [self configureSubtitleLabelForCell:cell];
    }
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    NSString* identifier = [self.cells objectAtIndex:indexPath.row];
    if ([identifier isEqualToString:kSegueContinue]) {
        StageViewController* viewController = [Util createStageViewControllerWithProgram:[Util lastProgram]];
        [self.navigationController pushViewController:viewController animated:YES];
    }
    else if ([identifier isEqualToString:kSegueForum]) {
        [self performSegueWithIdentifier:identifier sender:self];
    }
#warning the if statement should be removed once everything has been implemented..
    else if ([identifier isEqualToString:kSegueDownload ] || [identifier isEqualToString:kSeguePrograms]) {
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
    return (indexPath.row == 0) ? [TableUtil getHeightForContinueCell] : [TableUtil getHeightForImageCell];
}

#pragma makrk - Segue delegate

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:kSegueDownload] ||
       [[segue identifier] isEqualToString:kSegueForum]) {
        CATransition* transition = [Util getPushCATransition];
        [self.view.window.layer addAnimation:transition forKey:nil];
    }
    
}





@end
