/**
 *  Copyright (C) 2010-2014 The Catrobat Team
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

#import "ProgramDetailStoreViewController.h"
#import "CatrobatProject.h"
#import "AppDelegate.h"
#import "TableUtil.h"
#import "ButtonTags.h"
#import "UIColor+CatrobatUIColorExtensions.h"
#import "SegueDefines.h"
#import "ProgramTableViewController.h"
#import "ProgramLoadingInfo.h"
#import "Util.h"
#import "NetworkDefines.h"
#import "Program.h"
#import "LoadingView.h"
#import "EVCircularProgressView.h"
#import "LanguageTranslationDefines.h"
#import "CreateView.h"
#import "Reachability.h"
#import "ProgramUpdateDelegate.h"

#define kUIBarHeight 49
#define kNavBarHeight 44

#define kScrollViewOffset 0.0f

#define kIphone5ScreenHeight 568.0f
#define kIphone4ScreenHeight 480.0f

@interface ProgramDetailStoreViewController () <ProgramUpdateDelegate>

@property (nonatomic, strong) UIView* projectView;
@property (nonatomic, strong) LoadingView* loadingView;

@end


@implementation ProgramDetailStoreViewController


- (NSMutableDictionary*)projects
{
    if (!_projects) {
        _projects = [[NSMutableDictionary alloc] init];
    }
    return _projects;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initNavigationBar];
    self.hidesBottomBarWhenPushed = YES;
    
    self.view.backgroundColor = UIColor.backgroundColor;
    self.navigationItem.title = @"";//kUIViewControllerTitleInfo;
    NSDebug(@"%@",self.project.author);
    self.projectView = [self createViewForProject:self.project];
    if(!self.project.author){
        [self showLoadingView];
        UIButton * button =(UIButton*)[self.projectView viewWithTag:kDownloadButtonTag];
        button.enabled = NO;
    }
    [self.scrollViewOutlet addSubview:self.projectView];
    self.scrollViewOutlet.delegate = self;
    CGFloat screenHeight =[Util getScreenHeight];
    CGSize contentSize = self.projectView.bounds.size;
    CGFloat minHeight = self.view.frame.size.height-kUIBarHeight-kNavBarHeight;
    if (contentSize.height < minHeight) {
        contentSize.height = minHeight;
    }
    contentSize.height += kScrollViewOffset;
    
    if (screenHeight == kIphone4ScreenHeight){
        contentSize.height = contentSize.height - kIphone4ScreenHeight +kIphone5ScreenHeight;
    }
    [self.scrollViewOutlet setContentSize:contentSize];
    self.scrollViewOutlet.userInteractionEnabled = YES;
//    self.scrollViewOutlet.exclusiveTouch = YES;
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadFinishedWithURL:) name:@"finishedloading" object:nil];
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    appDelegate.fileManager.delegate = self;
    appDelegate.fileManager.projectURL = [NSURL URLWithString:self.project.downloadUrl];

}

- (void)initNavigationBar
{
    self.title = self.navigationItem.title = kUIViewControllerTitleInfo;
}

- (void) viewWillDisappear:(BOOL)animated
{
    self.hidesBottomBarWhenPushed = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (UIView*)createViewForProject:(CatrobatProject*)project {
    
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    UIView *view = [CreateView createProgramDetailView:project target:self];
    if ([appDelegate.fileManager getFullPathForProgram:project.projectName]) {
        [view viewWithTag:kDownloadButtonTag].hidden = YES;
        [view viewWithTag:kPlayButtonTag].hidden = NO;
        [view viewWithTag:kStopLoadingTag].hidden = YES;
    } else if (self.project.isdownloading) {
    [view viewWithTag:kDownloadButtonTag].hidden = YES;
    [view viewWithTag:kPlayButtonTag].hidden = YES;
    [view viewWithTag:kStopLoadingTag].hidden = NO;
  }


    return view;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setToolbarHidden:YES];
    self.searchStoreController.checkSearch = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kReachabilityChangedNotification
                                                        object:self];
}

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidUnload
{
    [self setScrollViewOutlet:nil];
    [super viewDidUnload];
}

#pragma mark - Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    static NSString* segueToContinue = kSegueToContinue;
    if ([[segue identifier] isEqualToString:segueToContinue]) {
        if ([segue.destinationViewController isKindOfClass:[ProgramTableViewController class]]) {
            self.hidesBottomBarWhenPushed = YES;
            ProgramTableViewController *programTableViewController = (ProgramTableViewController*)segue.destinationViewController;
            programTableViewController.program = [Program programWithLoadingInfo:[Util programLoadingInfoForProgramWithName:self.project.name]];
            programTableViewController.delegate = self;

            // TODO: remove this after persisting programs feature is fully implemented...
            programTableViewController.isNewProgram = NO;
        }
    }
}

#pragma mark - program update delegates
- (void)removeProgram:(NSString *)programName
{
    [self showPlayButton];
}

- (void)renameOldProgramName:(NSString *)oldProgramName toNewProgramName:(NSString *)newProgramName
{
    [self showPlayButton];
}

#pragma mark - ProgramStore Delegate
- (void)playButtonPressed
{
    static NSString* segueToContinue = kSegueToContinue;
    NSDebug(@"Play Button");
    [self performSegueWithIdentifier:segueToContinue sender:self];
}

- (void)playButtonPressed:(id)sender
{
    [self playButtonPressed];
}

- (void)downloadButtonPressed
{
    NSDebug(@"Download Button!");
    EVCircularProgressView* button = (EVCircularProgressView*)[self.projectView viewWithTag:kStopLoadingTag];
    [self.projectView viewWithTag:kDownloadButtonTag].hidden = YES;
    button.hidden = NO;
    button.progress = 0;
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSURL *url = [NSURL URLWithString:self.project.downloadUrl];
    appDelegate.fileManager.delegate = self;
    [appDelegate.fileManager downloadFileFromURL:url withName:self.project.projectName];
   
    
    NSDebug(@"url screenshot is %@", self.project.screenshotSmall)
    NSString *urlString = self.project.screenshotSmall;
    
    NSDebug(@"screenshot url is: %@", urlString);
    
    NSURL *screenshotSmallUrl = [NSURL URLWithString:urlString];
    [appDelegate.fileManager downloadScreenshotFromURL:screenshotSmallUrl andBaseUrl:url andName:self.project.name];
    self.project.isdownloading = YES;
    [self.projects setObject:self.project forKey:url];
}

- (void)downloadButtonPressed:(id)sender
{
    [self downloadButtonPressed];
}

#pragma mark - File Manager Delegate
- (void) downloadFinishedWithURL:(NSURL*)url
{
    NSLog(@"Download Finished!!!!!!");
    self.project.isdownloading = NO;
    [self.projects removeObjectForKey:url];
    EVCircularProgressView* button = (EVCircularProgressView*)[self.view viewWithTag:kStopLoadingTag];
    button.hidden = YES;
    button.progress = 0;
    [self.view viewWithTag:kPlayButtonTag].hidden = NO;
    [self loadingIndicator:NO];
  
}

#pragma mark - TTTAttributedLabelDelegate
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url
{
    [[UIApplication sharedApplication] openURL:url];
}

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithPhoneNumber:(NSString *)phoneNumber
{
    UIDevice *device = [UIDevice currentDevice];
    if ([[device model] isEqualToString:@"iPhone"] ) {
        //NSString* telpromt = [phoneNumber stringByReplacingOccurrencesOfString:@"tel:" withString:@""];
        NSString *cleanedString = [[phoneNumber componentsSeparatedByCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789-+()"] invertedSet]] componentsJoinedByString:@""];
        NSString *escapedPhoneNumber = [cleanedString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *phoneURLString = [NSString stringWithFormat:@"telprompt:%@", escapedPhoneNumber];
        NSURL *url = [NSURL URLWithString:phoneURLString];
        [[UIApplication sharedApplication] openURL:url];
    }
}

-(void)reloadWithProject:(CatrobatProject *)loadedProject
{
    [self.projectView removeFromSuperview];
    self.projectView = [self createViewForProject:loadedProject];
    [self.view addSubview:self.projectView];
    self.project = loadedProject;
    [self.scrollViewOutlet addSubview:self.projectView];
    self.scrollViewOutlet.delegate = self;
    CGFloat screenHeight =[Util getScreenHeight];
    CGSize contentSize = self.projectView.bounds.size;
    CGFloat minHeight = self.view.frame.size.height-kUIBarHeight-kNavBarHeight;
    if (contentSize.height < minHeight) {
        contentSize.height = minHeight;
    }
    contentSize.height += kScrollViewOffset;
    
    if (screenHeight == kIphone4ScreenHeight){
        contentSize.height = contentSize.height - kIphone4ScreenHeight +kIphone5ScreenHeight;
    }
    [self.scrollViewOutlet setContentSize:contentSize];
    self.scrollViewOutlet.userInteractionEnabled = YES;
    self.scrollViewOutlet.exclusiveTouch = YES;
    UIButton * button =(UIButton*)[self.projectView viewWithTag:kDownloadButtonTag];
    button.enabled = YES;
    [self hideLoadingView];
    [self.view setNeedsDisplay];
}

#pragma mark - loading view
- (void)showLoadingView
{
    if(!self.loadingView) {
        self.loadingView = [[LoadingView alloc] init];
        [self.view addSubview:self.loadingView];
    }
    [self.loadingView show];
}

- (void) hideLoadingView
{
    [self.loadingView hide];
}

#pragma mark - play button
- (void)showPlayButton
{
    [self.projectView viewWithTag:kDownloadButtonTag].hidden = NO;
    [self.projectView viewWithTag:kStopLoadingTag].hidden = YES;
    [self.projectView viewWithTag:kPlayButtonTag].hidden = YES;
}

#pragma mark - actions
- (void)stopLoading
{
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSURL *url = [NSURL URLWithString:self.project.downloadUrl];
    NSString *urlString = self.project.screenshotSmall;
    NSURL *screenshotSmallUrl = [NSURL URLWithString:urlString];
    [appDelegate.fileManager stopLoading:url andImageURL:screenshotSmallUrl];
    appDelegate.fileManager.delegate = self;
    EVCircularProgressView* button = (EVCircularProgressView*)[self.view viewWithTag:kStopLoadingTag];
    button.hidden = YES;
    button.progress = 0;
    [self.view viewWithTag:kDownloadButtonTag].hidden = NO;
    [self loadingIndicator:NO];
    
}
-(void)updateProgress:(double)progress
{
    NSDebug(@"updateProgress:%f",((float)progress));
    EVCircularProgressView* button = (EVCircularProgressView*)[self.view viewWithTag:kStopLoadingTag];
    [button setProgress:progress animated:YES];
}

-(void)setBackDownloadStatus
{
    [self.view viewWithTag:kDownloadButtonTag].hidden = NO;
    [self.view viewWithTag:kPlayButtonTag].hidden = YES;
    [self.view viewWithTag:kStopLoadingTag].hidden = YES;
    [self loadingIndicator:NO];
}

-(void)loadingIndicator:(BOOL)value
{
    UIApplication* app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = value;
}



@end
