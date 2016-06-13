/**
 *  Copyright (C) 2010-2016 The Catrobat Team
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
#import "CatrobatProgram.h"
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
#import "UIDefines.h"
#import "KeychainUserDefaultsDefines.h"


@interface ProgramDetailStoreViewController () <ProgramUpdateDelegate>

@property (nonatomic, strong) UIView *projectView;
@property (nonatomic, strong) LoadingView *loadingView;
@property (nonatomic, strong) Program *loadedProgram;
@property (strong, nonatomic) NSURLSession *session;
@property (strong, nonatomic) NSURLSessionDataTask *dataTask;
@property (nonatomic, strong) NSString *duplicateName;
@property (nonatomic, strong) Reachability *reachability;

@end

@implementation ProgramDetailStoreViewController

- (NSMutableDictionary*)projects
{
    if (!_projects) {
        _projects = [[NSMutableDictionary alloc] init];
    }
    return _projects;
}

- (NSURLSession *)session {
    if (!_session) {
            // Initialize Session Configuration
        NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        
            // Configure Session Configuration
        [sessionConfiguration setHTTPAdditionalHeaders:@{ @"Accept" : @"application/json" }];
        
            // Initialize Session
        _session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    }
    
    return _session;
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
    self.duplicateName = self.project.name;
    [self initNavigationBar];
    self.hidesBottomBarWhenPushed = YES;
    self.view.backgroundColor = [UIColor backgroundColor];
    NSDebug(@"%@",self.project.author);
    [self loadProject:self.project];
//    self.scrollViewOutlet.exclusiveTouch = YES;
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadFinishedWithURL:) name:@"finishedloading" object:nil];
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    appDelegate.fileManager.delegate = self;
    appDelegate.fileManager.projectURL = [NSURL URLWithString:self.project.downloadUrl];
    self.reachability = [Reachability reachabilityForInternetConnection];
}


-(void)loadProject:(CatrobatProgram*)project {
    [self.projectView removeFromSuperview];
    self.projectView = [self createViewForProject:project];
    if(!self.project.author){
        [self showLoadingView];
        UIButton * button =(UIButton*)[self.projectView viewWithTag:kDownloadButtonTag];
        button.enabled = NO;
    }
    CGFloat minHeight = self.view.frame.size.height;
    [self.scrollViewOutlet addSubview:self.projectView];
    self.scrollViewOutlet.delegate = self;
    CGSize contentSize = self.projectView.bounds.size;
    
    if (contentSize.height < minHeight) {
        contentSize.height = minHeight;
    }
    contentSize.height += 30.0f;
    [self.scrollViewOutlet setContentSize:contentSize];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.scrollViewOutlet.userInteractionEnabled = YES;
}
- (void)initNavigationBar
{
    self.title = self.navigationItem.title = kLocalizedDetails;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.hidesBottomBarWhenPushed = NO;
    [self.reachability stopNotifier];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (UIView*)createViewForProject:(CatrobatProgram*)project
{
    UIView *view = [CreateView createProgramDetailView:project target:self];
    if ([Program programExistsWithProgramID:project.projectID]) {
        [view viewWithTag:kDownloadButtonTag].hidden = YES;
        [view viewWithTag:kPlayButtonTag].hidden = NO;
        [view viewWithTag:kStopLoadingTag].hidden = YES;
        [view viewWithTag:kDownloadAgainButtonTag].hidden = NO;
    } else if (self.project.isdownloading) {
        [view viewWithTag:kDownloadButtonTag].hidden = YES;
        [view viewWithTag:kPlayButtonTag].hidden = YES;
        [view viewWithTag:kStopLoadingTag].hidden = NO;
        [view viewWithTag:kDownloadAgainButtonTag].hidden = YES;
    }
    return view;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setToolbarHidden:YES];
    self.searchStoreController.checkSearch = NO;
    self.loadedProgram = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:kReachabilityChangedNotification
                                                        object:self];
}

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dealloc
{
    [self setScrollViewOutlet:nil];
}

#pragma mark - segue handling
- (BOOL)shouldPerformSegueWithIdentifier:(NSString*)identifier sender:(id)sender
{
    static NSString *segueToContinue = kSegueToContinue;
    if ([identifier isEqualToString:segueToContinue]) {
        // The local program name with same program ID could differ from the original program name.
        // That's because the user could have renamed the downloaded program.
        NSString *localProgramName = [Program programNameForProgramID:self.project.projectID];

        // check if program loaded successfully -> not nil
        self.loadedProgram = [Program programWithLoadingInfo:[ProgramLoadingInfo programLoadingInfoForProgramWithName:localProgramName programID:self.project.projectID]];

        if (self.loadedProgram) {
            return YES;
        }
        // program failed loading...
        [Util alertWithText:kLocalizedUnableToLoadProgram];
        return NO;
    }
    return [super shouldPerformSegueWithIdentifier:identifier sender:sender];
}

- (void)prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender
{
    static NSString *segueToContinue = kSegueToContinue;
    if ([[segue identifier] isEqualToString:segueToContinue]) {
        if ([segue.destinationViewController isKindOfClass:[ProgramTableViewController class]]) {
            self.hidesBottomBarWhenPushed = YES;
            ProgramTableViewController *programTableViewController = (ProgramTableViewController*)segue.destinationViewController;
            programTableViewController.program = self.loadedProgram;
            programTableViewController.delegate = self;
        }
    }
}

#pragma mark - program update delegates
- (void)removeProgramWithName:(NSString*)programName programID:(NSString*)programID
{
    [self showPlayButton];
}

- (void)renameOldProgramWithName:(NSString*)oldProgramName
                       programID:(NSString*)programID
                toNewProgramName:(NSString*)newProgramName
{
    return; // IMPORTANT: this method does nothing but has to be implemented!!
}

#pragma mark - ProgramStore Delegate
- (void)playButtonPressed
{
    static NSString* segueToContinue = kSegueToContinue;
    NSDebug(@"Play Button");
    if ([self shouldPerformSegueWithIdentifier:segueToContinue sender:self]) {
        [self performSegueWithIdentifier:segueToContinue sender:self];
    }
}
- (void)reportProgram
{
    NSDebug(@"report");
    BOOL isLoggedIn = [[NSUserDefaults standardUserDefaults] boolForKey:kUserIsLoggedIn];
    if (isLoggedIn) {
    
        [Util askUserForReportMessageAndPerformAction:@selector(sendReportWithMessage:) target:self promptTitle:kLocalizedReportProgram promptMessage:kLocalizedEnterReason minInputLength:1 maxInputLength:10 blockedCharacterSet:[self blockedCharacterSet] invalidInputAlertMessage:kLocalizedBlockedCharInputDescription];
        

    } else {
        [Util alertWithText:kLocalizedLoginToReport];
    }
}



static NSCharacterSet *blockedCharacterSet = nil;

- (NSCharacterSet*)blockedCharacterSet
{
    if (! blockedCharacterSet) {
        blockedCharacterSet = [[NSCharacterSet characterSetWithCharactersInString:kTextFieldAllowedCharacters]
                               invertedSet];
    }
    return blockedCharacterSet;
}


- (void)sendReportWithMessage:(NSString*)message
{
    NSDebug(@"ReportMessage::::::%@",message);
    
    NSString *reportUrl = [Util isProductionServerActivated] ? kReportProgramUrl : kTestReportProgramUrl;

    NSString *post = [NSString stringWithFormat:@"%@=%@&%@=%@",@"program",self.project.projectID,@"note",message];
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", reportUrl]]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:postData];
    

    self.dataTask = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            if ([Util isNetworkError:error]) {
                [Util defaultAlertForNetworkError];
                [self hideLoadingView];
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSError *error = nil;
                NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                NSString *statusCode = [NSString stringWithFormat:@"%@", [dictionary valueForKey:@"statusCode"]];
                    
                NSDebug(@"StatusCode is %@", statusCode);
                
                [Util alertWithText:[dictionary valueForKey:@"answer"]];

            });
        }
    }];
    
    if (self.dataTask) {
        [self.dataTask resume];
        NSDebug(@"Connection Successful");
    } else {
         NSDebug(@"Connection could not be made");
    }
}

- (void)playButtonPressed:(id)sender
{
    [self playButtonPressed];
}

- (void)downloadButtonPressed
{
    NSDebug(@"Download Button!");
    if ([self isConnectedToWifiWithSettingEnabled]) {
        EVCircularProgressView* button = (EVCircularProgressView*)[self.projectView viewWithTag:kStopLoadingTag];
        [self.projectView viewWithTag:kDownloadButtonTag].hidden = YES;
        button.hidden = NO;
        button.progress = 0;
        [self downloadWithName:self.project.name];
    }
    
}

- (void)downloadButtonPressed:(id)sender
{
    [self downloadButtonPressed];
}

-(BOOL)isConnectedToWifiWithSettingEnabled
{
    if (![[NSUserDefaults standardUserDefaults] boolForKey:kUseWiFiDownload]) {
        return YES;
    } else {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkStatusChanged:) name:kReachabilityChangedNotification object:nil];
        [self.reachability startNotifier];
        NetworkStatus status = [self.reachability currentReachabilityStatus];
        [self.reachability stopNotifier];
        if (status == ReachableViaWiFi)
        {
            return YES;
        }else{
            [Util alertWithText:kLocalizedNoWifiConnection];
            return NO;
        }
    }
    return NO;
}


-(void)downloadAgain
{
    if ([self isConnectedToWifiWithSettingEnabled]) {
        EVCircularProgressView* button = (EVCircularProgressView*)[self.projectView viewWithTag:kStopLoadingTag];
        [self.projectView viewWithTag:kPlayButtonTag].hidden = YES;
        UIButton* downloadAgainButton = (UIButton*)[self.projectView viewWithTag:kDownloadAgainButtonTag];
        downloadAgainButton.enabled = NO;
        button.hidden = NO;
        button.progress = 0;
        self.duplicateName = [Util uniqueName:self.project.name existingNames:[Program allProgramNames]];
        NSDebug(@"%@",[Program allProgramNames]);
        [self downloadWithName:self.duplicateName];
    }
}

-(void)downloadWithName:(NSString*)name
{
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSURL *url = [NSURL URLWithString:self.project.downloadUrl];
    appDelegate.fileManager.delegate = self;
    [appDelegate.fileManager downloadFileFromURL:url withProgramID:self.project.projectID withName:name];
    NSDebug(@"url screenshot is %@", self.project.screenshotSmall);
    NSString *urlString = self.project.screenshotSmall;
    NSDebug(@"screenshot url is: %@", urlString);
    NSURL *screenshotSmallUrl = [NSURL URLWithString:urlString];
    [appDelegate.fileManager downloadScreenshotFromURL:screenshotSmallUrl andBaseUrl:url andName:name];
    self.project.isdownloading = YES;
    [self.projects setObject:self.project forKey:url];
    [self reloadInputViews];
}

#pragma mark - File Manager Delegate
- (void) downloadFinishedWithURL:(NSURL*)url andProgramLoadingInfo:(ProgramLoadingInfo *)info
{
    NSDebug(@"Download Finished!!!!!!");
    self.project.isdownloading = NO;
    [self.projects removeObjectForKey:url];
    EVCircularProgressView* button = (EVCircularProgressView*)[self.view viewWithTag:kStopLoadingTag];
    button.hidden = YES;
    button.progress = 0;
    [self.view viewWithTag:kPlayButtonTag].hidden = NO;
    UIButton* downloadAgainButton = (UIButton*)[self.projectView viewWithTag:kDownloadAgainButtonTag];
    downloadAgainButton.enabled = YES;
    downloadAgainButton.hidden = NO;
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
        NSString *escapedPhoneNumber = [phoneNumber stringByAddingPercentEncodingWithAllowedCharacters:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789-+()"] invertedSet]];
        NSString *phoneURLString = [NSString stringWithFormat:@"telprompt:%@", escapedPhoneNumber];
        NSURL *url = [NSURL URLWithString:phoneURLString];
        [[UIApplication sharedApplication] openURL:url];
    }
}

- (void)reloadWithProject:(CatrobatProgram *)loadedProject
{
    [self loadProject:loadedProject];
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
//        [self.loadingView setBackgroundColor:[UIColor globalTintColor]];
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
    [self.projectView viewWithTag:kDownloadAgainButtonTag].hidden = YES;
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
    UIButton* downloadAgainButton = (UIButton*)[self.projectView viewWithTag:kDownloadAgainButtonTag];
    if(downloadAgainButton.enabled){
        [self.view viewWithTag:kDownloadButtonTag].hidden = NO;
    } else {
        [self.view viewWithTag:kPlayButtonTag].hidden = NO;
        downloadAgainButton.enabled = YES;
    }
    [self loadingIndicator:NO];
    
}
- (void)updateProgress:(double)progress
{
    NSDebug(@"updateProgress:%f",((float)progress));
    EVCircularProgressView* button = (EVCircularProgressView*)[self.view viewWithTag:kStopLoadingTag];
    [button setProgress:progress animated:YES];
}

- (void)timeoutReached
{
    [self setBackDownloadStatus];
    [Util defaultAlertForNetworkError];
}

- (void)setBackDownloadStatus
{
    [self.view viewWithTag:kDownloadButtonTag].hidden = NO;
    [self.view viewWithTag:kPlayButtonTag].hidden = YES;
    [self.view viewWithTag:kStopLoadingTag].hidden = YES;
    [self.view viewWithTag:kDownloadAgainButtonTag].hidden = YES;
    [self loadingIndicator:NO];
}

- (void)loadingIndicator:(BOOL)value
{
    UIApplication* app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = value;
}


#pragma mark - popup delegate
- (BOOL)dismissPopupWithCode:(BOOL)successLogin
{
    if (self.popupViewController != nil) {
        [self dismissPopupViewController];
        self.navigationItem.leftBarButtonItem.enabled = YES;
        if (successLogin) {
                // TODO no trigger because popup is visible
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [self reportProgram];
            });
        }
        return YES;
    }
    return NO;
}

#pragma mark Rotation

-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self loadProject:self.project];
        [self.view setNeedsDisplay];
    });

}



#pragma mark NetworkStatus
- (void)networkStatusChanged:(NSNotification *)notification
{
    NetworkStatus remoteHostStatus = [self.reachability currentReachabilityStatus];
    if(remoteHostStatus == ReachableViaWWAN && [[NSUserDefaults standardUserDefaults] boolForKey:kUseWiFiDownload]) {
        [self stopLoading];
    }
}

@end
