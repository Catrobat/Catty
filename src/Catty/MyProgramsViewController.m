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

#import "MyProgramsViewController.h"
#import "Util.h"
#import "ProgramLoadingInfo.h"
#import "Program.h"
#import "ProgramTVC.h"
#import "AppDelegate.h"
#import "TableUtil.h"
#import "CellTagDefines.h"
#import "UIColor+CatrobatUIColorExtensions.h"
#import "CatrobatImageCell.h"
#import "Logger.h"
#import "SegueDefines.h"


@interface MyProgramsViewController ()
@property (nonatomic, strong) NSMutableArray *levelLoadingInfos;
@end

@implementation MyProgramsViewController

@synthesize levelLoadingInfos = _levelLoadingInfos;

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

    [self initTableView];

    [TableUtil initNavigationItem:self.navigationItem withTitle:NSLocalizedString(@"Programs", nil)];

    [self setupToolBar];
    [self loadLevels];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController setToolbarHidden:NO];
}

#pragma marks init
-(void)initTableView
{
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"darkblue"]];
    
}

-(void)dealloc
{
    self.tableView.dataSource = nil;
    self.tableView.delegate = nil;
    self.levelLoadingInfos = nil;
    
}

-(void)loadLevels
{
    NSString *basePath = [Program basePath];
    NSError *error;
    NSArray *levels = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:basePath error:&error];
    NSLogError(error);

    self.levelLoadingInfos = [[NSMutableArray alloc] initWithCapacity:[levels count]];
    for (NSString *level in levels) {
        // exclude .DS_Store folder on MACOSX simulator
        if ([level isEqualToString:@".DS_Store"])
          continue;

        ProgramLoadingInfo *info = [[ProgramLoadingInfo alloc] init];
        info.basePath = [NSString stringWithFormat:@"%@%@/", basePath, level];
        info.visibleName = level;
        NSDebug(@"Adding level: %@", info.basePath);
        [self.levelLoadingInfos addObject:info];
    }
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.levelLoadingInfos count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = kImageCell;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (! cell) {
        NSLog(@"This should not happen - since ios5 - storyboards manages allocation of cells");
        abort();
    }

    if ([cell conformsToProtocol:@protocol(CatrobatImageCell)]) {
        UITableViewCell <CatrobatImageCell>* imageCell = (UITableViewCell <CatrobatImageCell>*)cell;
        [self configureImageCell:imageCell atIndexPath:indexPath];
    }

    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [TableUtil getHeightForImageCell];
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        ProgramLoadingInfo *level = [self.levelLoadingInfos objectAtIndex:indexPath.row];
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        [appDelegate.fileManager deleteDirectory:level.basePath];
        [self.levelLoadingInfos removeObject:level];
        [Util setLastProgram:nil];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

#pragma mark - Table view delegate
/*
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* segueToNew = kSegueToNew;
    [self performSegueWithIdentifier:segueToNew sender:self];
}
*/

#pragma mark - Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    static NSString* segueToNew = kSegueToNew;
    if ([[segue identifier] isEqualToString:segueToNew]) {
      if ([sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *path = [self.tableView indexPathForSelectedRow];
        NSString* programName = [[self.levelLoadingInfos objectAtIndex:path.row] visibleName];
        if ([segue.destinationViewController isKindOfClass:[ProgramTVC class]]) {
          ProgramTVC* programTVC = (ProgramTVC*) segue.destinationViewController;
          [programTVC loadProgram:[Util programLoadingInfoForProgramWithName:programName]];
        }
      } else if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        // no preparation needed
      }
    }
}

#pragma mark - Cell Helper
-(void)configureImageCell:(UITableViewCell <CatrobatImageCell>*)cell atIndexPath:(NSIndexPath*)indexPath
{
    ProgramLoadingInfo *info = [self.levelLoadingInfos objectAtIndex:indexPath.row];
    cell.titleLabel.text = info.visibleName;
    
//    cell.iconImageView.image = [UIImage imageNamed:@"programs"];
    
    NSString* imagePath = [[NSString alloc] initWithFormat:@"%@/screenshot.png", info.basePath];
    
    UIImage* image = [UIImage imageWithContentsOfFile:imagePath];
    if(!image) {
        imagePath = [[NSString alloc] initWithFormat:@"%@/manual_screenshot.png", info.basePath];
        image = [UIImage imageWithContentsOfFile:imagePath];
    }
    
    if(!image) {
        imagePath = [[NSString alloc] initWithFormat:@"%@/automatic_screenshot.png", info.basePath];
        image = [UIImage imageWithContentsOfFile:imagePath];
    }
    if(!image) {
        image = [UIImage imageNamed:@"programs"];
    }
    
//    CGSize imageSize = image.size;
//    UIGraphicsBeginImageContext(imageSize);
//    [image drawInRect:CGRectMake(0, 0, imageSize.width, imageSize.height)];
//    image = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
    
    cell.iconImageView.image = image;
    
    
//    dispatch_queue_t imageQueue = dispatch_queue_create("at.tugraz.ist.catrobat.ImageLoadingQueue", NULL);
//    dispatch_async(imageQueue, ^{
//        
//        NSString* imagePath = [[NSString alloc] initWithFormat:@"%@/screenshot.png", info.basePath];
//        
//        UIImage* image = [UIImage imageWithContentsOfFile:imagePath];
//        if(!image) {
//            imagePath = [[NSString alloc] initWithFormat:@"%@/manual_screenshot.png", info.basePath];
//            image = [UIImage imageWithContentsOfFile:imagePath];
//        }
//        if(!image) {
//            image = [UIImage imageNamed:@"programs"];
//        }
//        
//        
//        CGSize imageSize = image.size;
//        UIGraphicsBeginImageContext(imageSize);
//        [image drawInRect:CGRectMake(0, 0, imageSize.width, imageSize.height)];
//        image = UIGraphicsGetImageFromCurrentImageContext();
//        UIGraphicsEndImageContext();
//        
//
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self.tableView beginUpdates];
//            UITableViewCell <CatrobatImageCell>* cell = (UITableViewCell <CatrobatImageCell>*)[self.tableView cellForRowAtIndexPath:indexPath];
//            if(cell) {
//                cell.iconImageView.image = image;
//            }
//            [self.tableView endUpdates];
//        });
//        
//    });

}

#pragma mark - Helper Methods
- (void)addProgramAction:(id)sender
{
  [self performSegueWithIdentifier:kSegueToNew sender:sender];
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
                                                                       action:@selector(addProgramAction:)];
  self.toolbarItems = [NSArray arrayWithObjects:flexItem, add, flexItem, nil];
}

@end
