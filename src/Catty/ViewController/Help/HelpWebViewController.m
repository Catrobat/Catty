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

#import "HelpWebViewController.h"
#import "UIDefines.h"
#import "UIColor+CatrobatUIColorExtensions.h"
#import <tgmath.h>
#import "AppDelegate.h"
#import "Util.h"
#import "ProgramDefines.h"
#import "LoadingView.h"
#import "Program.h"
#import "LanguageTranslationDefines.h"
#import "NetworkDefines.h"
#import "BDKNotifyHUD.h"

@interface HelpWebViewController ()
@property (nonatomic, strong) NSURL *URL;
@property (weak, nonatomic) IBOutlet UILabel *urlTitleLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (nonatomic, strong) UIView *touchHelperView;
@property (strong, nonatomic) UITapGestureRecognizer *tapGesture;
@property (strong, nonatomic) LoadingView *loadingView;

@end

#define kTranslateYNavigationBar 40.0f
#define kScrollDownThreshold 30.0f
#define kURLViewHeight 20.0f
#define kScrollOffset 24.0f

@implementation HelpWebViewController {
    BOOL _errorLoadingURL;
    BOOL _doneLoadingURL;
    BOOL _showActivityIndicator;
    BOOL _controlsHidden;
    UIBarButtonItem *_refreshButton;
    UIBarButtonItem *_stopButton;
    UIViewController *_topViewController;
}

- (id)initWithURL:(NSURL *)URL
{
    if (self = [super init]) {
        _URL = URL;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupToolBar];
    
    self.title = kLocalizedHelp;
    self.tintColor = UIColor.globalTintColor;
    
    _refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh:)];
    _stopButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(stop:)];

    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    self.URL = [NSURL URLWithString:kForumURL];
    self.webView.scrollView.delegate = self;
    self.webView.delegate = self;
    self.webView.allowsInlineMediaPlayback = YES;
    self.webView.scalesPageToFit = YES;
    self.webView.backgroundColor = UIColor.backgroundColor;
    self.webView.alpha = 0.0f;
    [self initUrlTitleLabel];
    if (self.URL) {
        [self.webView loadRequest:[NSURLRequest requestWithURL:self.URL]];
    }
    
    self.touchHelperView = [[UIView alloc] initWithFrame:CGRectZero];
    self.touchHelperView.backgroundColor = UIColor.clearColor;
     _progressView.tintColor = [UIColor navTintColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)initUrlTitleLabel
{
    _urlTitleLabel.backgroundColor = UIColor.backgroundColor;
    _urlTitleLabel.font = [UIFont systemFontOfSize:13.0f];
    _urlTitleLabel.textColor = [UIColor globalTintColor];
    _urlTitleLabel.textAlignment = NSTextAlignmentCenter;
    _urlTitleLabel.alpha = 0.6f;
    
    
}

- (void)setupToolBar
{
    [self.navigationController setToolbarHidden:NO];
    self.navigationController.toolbar.barStyle = UIBarStyleDefault;
    self.navigationController.toolbar.tintColor = [UIColor toolTintColor];
    self.navigationController.toolbar.barTintColor = [UIColor toolBarColor];
    self.navigationController.toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;

    UIBarButtonItem *flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                              target:nil
                                                                              action:nil];
    
    UIBarButtonItem *forward = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"webview_arrow_right"] style:UIBarButtonItemStylePlain target:self action:@selector(goForward:)];
    forward.enabled = self.webView.canGoForward;

    UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"webview_arrow_left"] style:UIBarButtonItemStylePlain target:self action:@selector(goBack:)];
    back.enabled = self.webView.canGoBack;
    UIBarButtonItem *share = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(openInSafari)];
        // XXX: workaround for tap area problem:
        // http://stackoverflow.com/questions/5113258/uitoolbar-unexpectedly-registers-taps-on-uibarbuttonitem-instances-even-when-tap
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"transparent1x1"]];
    UIBarButtonItem *invisibleButton = [[UIBarButtonItem alloc] initWithCustomView:imageView];
    self.toolbarItems = [NSArray arrayWithObjects:invisibleButton, back, invisibleButton, flexItem,
                          invisibleButton, forward, invisibleButton, flexItem, flexItem, share,flexItem, nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setupToolbarItems];
    [self.view insertSubview:self.touchHelperView aboveSubview:self.webView];
    
    [self.touchHelperView addGestureRecognizer:self.tapGesture];
    
    if (!_loadingView) {
        _loadingView = [[LoadingView alloc] init];
//        _loadingView.backgroundColor = [UIColor globalTintColor];
        [self.view addSubview:self.loadingView];
    }
    [self.loadingView show];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.webView stopLoading];
    
    if ([self.view.window.gestureRecognizers containsObject:self.tapGesture]) {
        [self.view.window removeGestureRecognizer:self.tapGesture];
    }
    
     _topViewController = self.navigationController.topViewController;
    self.navigationController.hidesBarsOnSwipe = NO;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    _topViewController.navigationController.navigationBar.titleTextAttributes = @{ NSForegroundColorAttributeName : [UIColor navTintColor] };
    _topViewController.navigationController.navigationBar.tintColor = [UIColor navTintColor];
    _topViewController.navigationController.navigationBar.transform = CGAffineTransformIdentity;
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    self.touchHelperView.frame = CGRectMake(0.0f, CGRectGetHeight(self.view.bounds) - kToolbarHeight, CGRectGetWidth(self.view.bounds), kToolbarHeight);
    

}

- (void)dealloc
{
    self.URL = nil;
    self.webView.delegate = nil;
    self.webView = nil;
}

#pragma mark - WebViewDelegate
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self setEnableActivityIndicator:NO];
    [self setupToolbarItems];
    _errorLoadingURL = YES;
    _doneLoadingURL = NO;
    [self setProgress:0.0f];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.loadingView hide];
    });
    if ([Util isNetworkError:error]) {
        [Util defaultAlertForNetworkError];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self setEnableActivityIndicator:NO];
    self.URL = webView.request.URL;
    [self setupToolbarItems];
    _errorLoadingURL = NO;
    _doneLoadingURL = YES;
    [self.loadingView hide];
    [self setProgress:1.0f];
//    [self showNavigationButtons];
    
    [UIView animateWithDuration:0.25f animations:^{ self.webView.alpha = 1.0f; }];
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self setEnableActivityIndicator:YES];
    _doneLoadingURL = NO;
    [self setProgress:0.2f];
    [self setupToolbarItems];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    
    if ([request.URL.absoluteString rangeOfString:kDownloadUrl].location == NSNotFound) {
        return YES;
    }
    NSDebug(@"Download");
    NSString *param = nil;
    NSArray *myArray = [request.URL.absoluteString componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"?"]];
    param = myArray[0];
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    // extract project ID from URL => example: https://pocketcode.org/download/959.catrobat
    NSArray *urlParts = [param componentsSeparatedByString:@"/"];
    if (! [urlParts count]) {
        [Util alertWithText:kLocalizedInvalidURLGiven];
        return NO;
    }
    // get last part of url and split by using separator "." => 959.catrobat
    urlParts = [[urlParts lastObject] componentsSeparatedByString:@"."];
    if ([urlParts count] != 2) {
        [Util alertWithText:kLocalizedInvalidURLGiven];
        return NO;
    }
    NSString *programID = [urlParts firstObject];
    NSString *compareProgramIDString = [NSString stringWithFormat:@"%lu",
                                        (unsigned long)[programID integerValue]];
    if (! programID || ! [programID integerValue] || ! [programID isEqualToString:compareProgramIDString]) {
        [Util alertWithText:kLocalizedInvalidURLGiven];
        return NO;
    }
    NSURL *url = [NSURL URLWithString:param];
    appDelegate.fileManager.delegate = self;
    param = nil;
    NSRange start = [request.URL.absoluteString rangeOfString:@"="];
    if (start.location != NSNotFound) {
        param = [request.URL.absoluteString substringFromIndex:start.location + start.length];
        param = [param stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    }
    if ([Program programExistsWithProgramName:param programID:programID]) {
        [Util alertWithText:kLocalizedProgramAlreadyDownloadedDescription];
        return NO;
    }
    FileManager *fileManager = appDelegate.fileManager;
    [fileManager downloadFileFromURL:url withProgramID:programID withName:param];
    param = nil;
    start = [request.URL.absoluteString rangeOfString:@"download/"];
    if (start.location != NSNotFound) {
        param = [request.URL.absoluteString substringFromIndex:start.location + start.length];
        NSRange end = [param rangeOfString:@"."];
        if (end.location != NSNotFound) {
            param = [param substringToIndex:end.location];
        }
    }
    NSString *urlString = [NSString stringWithFormat:@"https://pocketcode.org/resources/thumbnails/%@_small.png",param];
    NSDebug(@"screenshot url is: %@", urlString);
    NSURL *screenshotSmallUrl = [NSURL URLWithString:urlString];
    [fileManager downloadScreenshotFromURL:screenshotSmallUrl andBaseUrl:url andName:param];
    [self.loadingView show];
    return NO;
}


#pragma mark - Webview Navigation
- (void)goBack:(id)sender
{
    if (self.webView.canGoBack) {
        [self.webView goBack];
    }
}

- (void)goForward:(id)sender
{
    if (self.webView.canGoForward) {
        [self.webView goForward];
    }
}

- (void)refresh:(id)sender
{
    if ([sender isKindOfClass:UIBarButtonItem.class]) {
        if (!_errorLoadingURL) {
            [self.webView reload];
        } else {
            [self.webView loadRequest:[NSURLRequest requestWithURL:self.URL]];
        }
    }
}

- (void)stop:(id)sender
{
    if ([sender isKindOfClass:UIBarButtonItem.class]) {
        [self.webView stopLoading];
    }
}

#pragma mark - Private
- (void)setupToolbarItems
{
    UIBarButtonItem *refreshOrStopButton = self.webView.loading ? _stopButton : _refreshButton;
    self.urlTitleLabel.text = [NSString stringWithFormat:@"%@%@", [self.URL host], [self.URL relativePath]];

    [self setupToolBar];
    
    self.navigationItem.rightBarButtonItems = @[refreshOrStopButton];
}

- (void)openInSafari
{
   [[UIApplication sharedApplication] openURL:self.URL];
}

- (void)setProgress:(CGFloat)progress
{
    self.progressView.progress = progress;
    BOOL doneLoadingURL = _doneLoadingURL;
    
    __weak HelpWebViewController *weakself = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        weakself.progressView.hidden = doneLoadingURL;
        weakself.urlTitleLabel.hidden = doneLoadingURL;
    });
}

- (void)setEnableActivityIndicator:(BOOL)enabled
{
    if (!_showActivityIndicator) {
        [UIApplication.sharedApplication setNetworkActivityIndicatorVisible:enabled];
        _showActivityIndicator = NO;
    } else {
        [UIApplication.sharedApplication setNetworkActivityIndicatorVisible:enabled];
        _showActivityIndicator = YES;
    }
}

- (void)showControls
{
    [UIView animateWithDuration:0.2f animations:^{
        self.navigationController.navigationBar.transform = CGAffineTransformIdentity;
        self.navigationController.toolbar.transform = CGAffineTransformIdentity;
        self.navigationController.navigationBar.tintColor = [self.navigationController.navigationBar.tintColor colorWithAlphaComponent:1.0f];
        self.navigationController.navigationBar.titleTextAttributes = @{ NSForegroundColorAttributeName : [UIColor.navTintColor colorWithAlphaComponent:1.0f] };
        self.urlTitleLabel.alpha = 0.6f;
    } completion:^(BOOL finished) {
        if (finished)
            [UIView animateWithDuration:0.2f delay:0.0f usingSpringWithDamping:1.0f initialSpringVelocity:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
                self.urlTitleLabel.transform = CGAffineTransformIdentity;
            } completion:NULL];
    }];
}


- (void)handleTap:(UITapGestureRecognizer *)sender
{
    if ([sender isKindOfClass:UITapGestureRecognizer.class]) {
        if (sender.state == UIGestureRecognizerStateEnded) {
            [self showControls];
        }
    }
}


- (void)downloadFinishedWithURL:(NSURL *)url andProgramLoadingInfo:(ProgramLoadingInfo *)info
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.loadingView hide];
        [self showDownloadedView];
    });
}

- (void)showDownloadedView
{
    BDKNotifyHUD *hud = [BDKNotifyHUD notifyHUDWithImage:[UIImage imageNamed:@"checkmark.png"]
                                                    text:kLocalizedDownloaded];
    hud.destinationOpacity = kBDKNotifyHUDDestinationOpacity;
    hud.center = CGPointMake(self.view.center.x, self.view.center.y + kBDKNotifyHUDCenterOffsetY);
    hud.tag = kSavedViewTag;
    [self.view addSubview:hud];
    [hud presentWithDuration:kBDKNotifyHUDPresentationDuration
                       speed:kBDKNotifyHUDPresentationSpeed
                       inView:self.view
                       completion:^{ [hud removeFromSuperview]; }];
}

- (void)timeoutReached
{
    [self setBackDownloadStatus];
    [Util defaultAlertForNetworkError];
}

- (void)setBackDownloadStatus
{
    
}

- (void)updateProgress:(double)progress
{
    if (progress < 1.0f) {
        _doneLoadingURL = NO;
    }else{
        _doneLoadingURL = YES;
    }
    [self setProgress:(CGFloat)progress];
    
}


#pragma mark Rotation

-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.view setNeedsDisplay];
    });
    
}
@end
