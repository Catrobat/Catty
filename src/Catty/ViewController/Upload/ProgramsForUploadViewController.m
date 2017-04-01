/**
 *  Copyright (C) 2010-2017 The Catrobat Team
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

#import "ProgramsForUploadViewController.h"
#import "LanguageTranslationDefines.h"
#import "CellTagDefines.h"
#import "UIColor+CatrobatUIColorExtensions.h"
#import "CatrobatImageCell.h"
#import "CatrobatBaseCell.h"
#import "TableUtil.h"
#import "ProgramLoadingInfo.h"
#import "UIDefines.h"
#import "UIImageView+CatrobatUIImageViewExtensions.h"
#import "FileManager.h"
#import "RuntimeImageCache.h"
#import "AppDelegate.h"
#import "Util.h"
#import "UploadInfoPopupViewController.h"
#import "BDKNotifyHUD.h"


@interface ProgramsForUploadViewController ()

@property (nonatomic, strong) Program *lastUsedProgram;
@property (nonatomic, strong) NSMutableArray *programLoadingInfos;
@property (nonatomic, strong) UIBarButtonItem *uploadButton;
@property (nonatomic, strong) NSMutableArray *selectedIndexPaths;
@property (nonatomic, strong) NSMutableArray *uploadingProgramInfos;

@end


@implementation ProgramsForUploadViewController

- (NSMutableArray*)uploadingProgramInfos
{
    if (!_uploadingProgramInfos) {
        _uploadingProgramInfos = [NSMutableArray new];
    }
    return _uploadingProgramInfos;
}

-(id)init
{
    _showLoginFeedback = false;
    return self;
}

#pragma mark - View Events
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.title = self.title = kLocalizedUploadProgram;
    self.programLoadingInfos = [[Program allProgramLoadingInfos] mutableCopy];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self setupToolBar];
    self.navigationController.toolbarHidden = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController setToolbarHidden:NO];
    [self.tableView reloadData];
    
    if(_showLoginFeedback) {
        [self showLoggedInView];
    }
    
    _showLoginFeedback = false;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - system events
- (void)dealloc
{
    self.tableView.dataSource = nil;
    self.tableView.delegate = nil;
    self.programLoadingInfos = nil;
}

#pragma mark - getters and setters
- (Program*)lastUsedProgram
{
    if (! _lastUsedProgram) {
        _lastUsedProgram = [Program lastUsedProgram];
    }
    return _lastUsedProgram;
}

#pragma mark - table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.programLoadingInfos count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = kImageCell;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (! [cell isKindOfClass:[CatrobatBaseCell class]] || ! [cell conformsToProtocol:@protocol(CatrobatImageCell)]) {
        return cell;
    }
    
    CatrobatBaseCell<CatrobatImageCell> *imageCell = (CatrobatBaseCell<CatrobatImageCell>*)cell;
    [self configureImageCell:imageCell atIndexPath:indexPath];


    return imageCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [TableUtil heightForImageCell];
}

#pragma mark - table view helpers
- (void)configureImageCell:(CatrobatBaseCell<CatrobatImageCell>*)cell atIndexPath:(NSIndexPath*)indexPath
{
    ProgramLoadingInfo *info = [self.programLoadingInfos objectAtIndex:indexPath.row];
    BOOL isSelcted = NO;
    for (ProgramLoadingInfo *checkInfo in self.uploadingProgramInfos) {
        if ([info isEqualToLoadingInfo:checkInfo]) {
            isSelcted = YES;
            break;
        }
    }
    if (isSelcted) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    cell.titleLabel.text = info.visibleName;
    cell.iconImageView.contentMode = UIViewContentModeScaleAspectFit;
    cell.iconImageView.image = nil;
    cell.indexPath = indexPath;
    [cell.iconImageView setBorder:[UIColor globalTintColor] Width:kDefaultImageCellBorderWidth];
    
    // check if one of these screenshot files is available in memory
    FileManager *fileManager = ((AppDelegate*)[UIApplication sharedApplication].delegate).fileManager;
    NSArray *fallbackPaths = @[[[NSString alloc] initWithFormat:@"%@screenshot.png", info.basePath],
                               [[NSString alloc] initWithFormat:@"%@manual_screenshot.png", info.basePath],
                               [[NSString alloc] initWithFormat:@"%@automatic_screenshot.png", info.basePath]];
    RuntimeImageCache *imageCache = [RuntimeImageCache sharedImageCache];
    for (NSString *fallbackPath in fallbackPaths) {
        NSString *fileName = [fallbackPath lastPathComponent];
        NSString *thumbnailPath = [NSString stringWithFormat:@"%@%@%@",
                                   info.basePath, kScreenshotThumbnailPrefix, fileName];
        UIImage *image = [imageCache cachedImageForPath:thumbnailPath];
        if (image) {
            cell.iconImageView.image = image;
            return;
        }
    }
    
    // no screenshot files in memory, check if one of these screenshot files exists on disk
    // if a screenshot file is found, then load it from disk and cache it in memory for future access
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        for (NSString *fallbackPath in fallbackPaths) {
            if ([fileManager fileExists:fallbackPath]) {
                NSString *fileName = [fallbackPath lastPathComponent];
                NSString *thumbnailPath = [NSString stringWithFormat:@"%@%@%@",
                                           info.basePath, kScreenshotThumbnailPrefix, fileName];
                [imageCache loadThumbnailImageFromDiskWithThumbnailPath:thumbnailPath
                                                              imagePath:fallbackPath
                                                     thumbnailFrameSize:CGSizeMake(kPreviewImageWidth, kPreviewImageHeight)
                                                           onCompletion:^(UIImage *image, NSString* path){
                                                               // check if cell still needed
                                                               if ([cell.indexPath isEqual:indexPath]) {
                                                                   cell.iconImageView.image = image;
                                                                   [cell setNeedsLayout];
                                                                   [self.tableView endUpdates];
                                                               }
                                                           }];
                return;
            }
        }
        
        // no screenshot file available -> last fallback, show standard program icon instead
        [imageCache loadImageWithName:@"programs" onCompletion:^(UIImage *image){
            // check if cell still needed
            if ([cell.indexPath isEqual:indexPath]) {
                cell.iconImageView.image = image;
                [cell setNeedsLayout];
                [self.tableView endUpdates];
            }
        }];
    });
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *currentCell = [tableView cellForRowAtIndexPath:indexPath];
    if (currentCell.accessoryType == UITableViewCellAccessoryNone) {
        //ONLY allow 1 selection
        [self.uploadingProgramInfos removeAllObjects];
        for (UITableViewCell * cell in self.tableView.visibleCells) {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        currentCell.accessoryType = UITableViewCellAccessoryCheckmark;
        //
        [self.uploadingProgramInfos addObject:[self.programLoadingInfos objectAtIndex:indexPath.row]];
    }else{
        currentCell.accessoryType = UITableViewCellAccessoryNone;
        [self.uploadingProgramInfos removeObject:[self.programLoadingInfos objectAtIndex:indexPath.row]];
    }

}

#pragma mark - Actions
- (void)uploadProgramAction:(id)sender
{
    NSDebug(@"Upload program: %@", self.lastUsedProgram.header.programName);
    //NSDebug(@"Attention: Currently not working!");
    
    //[Util alertWithText:kLocalizedThisFeatureIsComingSoon];
    
    /*
     ProgramLoadingInfo *info = self.programLoadingInfos.firstObject;
     NSDebug(@"%@", info.basePath);
     */
    
    [self showUploadInfoView];  //Currently not working
}

#pragma mark - Helpers
- (void)setupToolBar
{
    [super setupToolBar];
    UIBarButtonItem *flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                              target:nil
                                                                              action:nil];
    
    self.uploadButton = [[UIBarButtonItem alloc] initWithTitle:kLocalizedUpload
                                                         style:UIBarButtonItemStylePlain
                                                        target:self
                                                        action:@selector(uploadProgramAction:)];
    
    [self.uploadButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"HelveticaNeue-Bold" size:18.0f], NSFontAttributeName, nil] forState:UIControlStateNormal];
    
    self.toolbarItems = @[flexItem, self.uploadButton, flexItem];
}

- (void)showUploadInfoView
{

        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iPhone" bundle: nil];
        UploadInfoViewController * vc = [storyboard instantiateViewControllerWithIdentifier:@"UploadController"];
        if (self.uploadingProgramInfos.count) {
            Program * prog = [Program programWithLoadingInfo:self.uploadingProgramInfos[0]];
            vc.program = prog;
            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:vc];
            self.tableView.scrollEnabled = NO;

            [self.navigationController presentViewController:navController animated:YES completion:^{
                self.tableView.scrollEnabled = YES;
                self.uploadButton.enabled = YES;
                self.navigationItem.leftBarButtonItem.enabled = YES;
                //[self showUploadSuccessfulView];
            }];
            self.navigationItem.leftBarButtonItem.enabled = NO;
            self.uploadButton.enabled = NO;
        } else {
            NSDebug(@"Please select a program to upload");
            [Util alertWithText:kLocalizedUploadSelectProgram];
        }

}

- (void)showLoggedInView
{
    BDKNotifyHUD *hud = [BDKNotifyHUD notifyHUDWithImage:[UIImage imageNamed:kBDKNotifyHUDCheckmarkImageName]
                                                    text:kLocalizedLoginSuccessful];
    hud.destinationOpacity = kBDKNotifyHUDDestinationOpacity;
    hud.center = CGPointMake(self.view.center.x, self.view.center.y + kBDKNotifyHUDCenterOffsetY);
    hud.tag = kLoginViewTag;
    [self.view addSubview:hud];
    [hud presentWithDuration:kBDKNotifyHUDPresentationDuration
                       speed:kBDKNotifyHUDPresentationSpeed
                      inView:self.view
                  completion:^{ [hud removeFromSuperview]; }];
}


@end
