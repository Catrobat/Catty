/**
 *  Copyright (C) 2010-2019 The Catrobat Team
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

#import "ProjectsForUploadViewController.h"
#import "LanguageTranslationDefines.h"
#import "CellTagDefines.h"
#import "UIColor+CatrobatUIColorExtensions.h"
#import "CatrobatImageCell.h"
#import "CatrobatBaseCell.h"
#import "TableUtil.h"
#import "ProjectLoadingInfo.h"
#import "UIDefines.h"
#import "CBFileManager.h"
#import "RuntimeImageCache.h"
#import "AppDelegate.h"
#import "Util.h"
#import "BDKNotifyHUD.h"
#import "Pocket_Code-Swift.h"


@interface ProjectsForUploadViewController ()

@property (nonatomic, strong) Project *lastUsedProject;
@property (nonatomic, strong) NSMutableArray *projectLoadingInfos;
@property (nonatomic, strong) UIBarButtonItem *uploadButton;
@property (nonatomic, strong) NSMutableArray *selectedIndexPaths;
@property (nonatomic, strong) NSMutableArray *uploadingProjectInfos;

@end


@implementation ProjectsForUploadViewController

- (NSMutableArray*)uploadingProjectInfos
{
    if (!_uploadingProjectInfos) {
        _uploadingProjectInfos = [NSMutableArray new];
    }
    return _uploadingProjectInfos;
}

-(id)init
{
    _showLoginFeedback = false;
    return self;
}

#pragma mark - View Events
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.title = self.title = kLocalizedUploadProject;
    self.projectLoadingInfos = [[Project allProjectLoadingInfos] mutableCopy];
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
    self.projectLoadingInfos = nil;
}

#pragma mark - getters and setters
- (Project*)lastUsedProject
{
    if (! _lastUsedProject) {
        _lastUsedProject = [Project lastUsedProject];
    }
    return _lastUsedProject;
}

#pragma mark - table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.projectLoadingInfos count];
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
    ProjectLoadingInfo *info = [self.projectLoadingInfos objectAtIndex:indexPath.row];
    BOOL isSelcted = NO;
    for (ProjectLoadingInfo *checkInfo in self.uploadingProjectInfos) {
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
    
    // check if one of these screenshot files is available in memory
    CBFileManager *fileManager = [CBFileManager sharedManager];
    NSArray *fallbackPaths = @[[[NSString alloc] initWithFormat:@"%@%@", info.basePath, kScreenshotFilename],
                               [[NSString alloc] initWithFormat:@"%@%@", info.basePath, kScreenshotManualFilename],
                               [[NSString alloc] initWithFormat:@"%@%@", info.basePath, kScreenshotAutoFilename]];
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
                                                     thumbnailFrameSize:CGSizeMake(kPreviewThumbnailWidth, kPreviewThumbnailHeight)
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
        
        // no screenshot file available -> last fallback, show standard project icon instead
        [imageCache loadImageWithName:@"projects" onCompletion:^(UIImage *image){
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
        [self.uploadingProjectInfos removeAllObjects];
        for (UITableViewCell * cell in self.tableView.visibleCells) {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        currentCell.accessoryType = UITableViewCellAccessoryCheckmark;
        //
        [self.uploadingProjectInfos addObject:[self.projectLoadingInfos objectAtIndex:indexPath.row]];
    }else{
        currentCell.accessoryType = UITableViewCellAccessoryNone;
        [self.uploadingProjectInfos removeObject:[self.projectLoadingInfos objectAtIndex:indexPath.row]];
    }

}

#pragma mark - Actions
- (void)uploadProjectAction:(id)sender
{
    NSDebug(@"Upload project: %@", self.lastUsedProject.header.programName);
    //NSDebug(@"Attention: Currently not working!");
    
    //[Util alertWithText:kLocalizedThisFeatureIsComingSoon];
    
    /*
     ProjectLoadingInfo *info = self.projectLoadingInfos.firstObject;
     NSDebug(@"%@", info.basePath);
     */
    
    [self showUploadInfoView];  //Currently not working
}

#pragma mark - Helpers
- (void)setupToolBar
{
    [super setupToolBar];

    self.uploadButton = [[UIBarButtonItem alloc] initWithTitle:kLocalizedUpload
                                                         style:UIBarButtonItemStylePlain
                                                        target:self
                                                        action:@selector(uploadProjectAction:)];
    
    [self.uploadButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:18.0f], NSFontAttributeName, nil] forState:UIControlStateNormal];

    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                          target:self
                                                                          action:nil];
    self.toolbarItems = @[flex, self.uploadButton, flex];
}

- (void)showUploadInfoView
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iPhone" bundle: nil];
    UploadInfoViewController * vc = [storyboard instantiateViewControllerWithIdentifier:@"UploadController"];
    if (self.uploadingProjectInfos.count) {
        Project * prog = [Project projectWithLoadingInfo:self.uploadingProjectInfos[0]];
        vc.project = prog;
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        NSDebug(@"Please select a project to upload");
        [Util alertWithText:kLocalizedUploadSelectProject];
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
