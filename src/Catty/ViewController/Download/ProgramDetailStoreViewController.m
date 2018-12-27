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

#import "ProgramDetailStoreViewController.h"
#import "AppDelegate.h"
#import "ButtonTags.h"
#import "UIColor+CatrobatUIColorExtensions.h"
#import "SegueDefines.h"
#import "ProgramTableViewController.h"
#import "Util.h"
#import "NetworkDefines.h"
#import "EVCircularProgressView.h"
#import "CreateView.h"
#import "ProgramUpdateDelegate.h"
#import "KeychainUserDefaultsDefines.h"
#import "Pocket_Code-Swift.h"


@interface ProgramDetailStoreViewController () <ProgramUpdateDelegate>

@property (nonatomic, strong) UIView *projectView;
@property (nonatomic, strong) LoadingView *loadingView;
@property (nonatomic, strong) Program *loadedProgram;
@property (strong, nonatomic) NSURLSession *session;
@property (strong, nonatomic) NSURLSessionDataTask *dataTask;
@property (nonatomic, strong) NSString *duplicateName;

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
    CBFileManager *fileManager = [CBFileManager sharedManager];
    fileManager.delegate = self;
    fileManager.projectURL = [NSURL URLWithString:self.project.downloadUrl];
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
    self.loadedProgram = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
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
        [[[[[[AlertControllerBuilder textFieldAlertWithTitle:kLocalizedReportProgram message:kLocalizedEnterReason]
              addCancelActionWithTitle:kLocalizedCancel handler:nil]
             addDefaultActionWithTitle:kLocalizedOK handler:^(NSString *report) {
                 [self sendReportWithMessage:report];
             }]
           valueValidator:^InputValidationResult *(NSString *report) {
               int minInputLength = 1;
               int maxInputLength = 10;
               if (report.length < minInputLength) {
                   return [InputValidationResult invalidInputWithLocalizedMessage:
                           [NSString stringWithFormat:kLocalizedNoOrTooShortInputDescription, minInputLength]];
               } else if (report.length > maxInputLength) {
                   return [InputValidationResult invalidInputWithLocalizedMessage:
                           [NSString stringWithFormat:kLocalizedTooLongInputDescription, maxInputLength]];
               } else {
                   return [InputValidationResult validInput];
               }
           }] build]
         showWithController:self];
    } else {
        [Util alertWithText:kLocalizedLoginToReport];
    }
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
    EVCircularProgressView* button = (EVCircularProgressView*)[self.projectView viewWithTag:kStopLoadingTag];
    [self.projectView viewWithTag:kDownloadButtonTag].hidden = YES;
    button.hidden = NO;
    button.progress = 0;
    [self downloadWithName:self.project.name];
}

- (void)downloadButtonPressed:(id)sender
{
    [self downloadButtonPressed];
}

-(void)downloadAgain
{
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

-(void)downloadWithName:(NSString*)name
{
    NSURL *url = [NSURL URLWithString:self.project.downloadUrl];
    CBFileManager *fileManager = [CBFileManager sharedManager];
    fileManager.delegate = self;
    [fileManager downloadProgramFromURL:url withProgramID:self.project.projectID andName:name];
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
    NSURL *url = [NSURL URLWithString:self.project.downloadUrl];
    CBFileManager *fileManager = [CBFileManager sharedManager];
    [fileManager stopLoading:url];
    fileManager.delegate = self;
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

- (void)maximumFilesizeReached
{
    [self setBackDownloadStatus];
    [Util alertWithText:kLocalizedNotEnoughFreeMemoryDescription];
}

- (void)fileNotFound
{
    [self setBackDownloadStatus];
    [Util alertWithText:kLocalizedProgramNotFound];
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

@end
