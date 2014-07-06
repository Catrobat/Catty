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

#import "WebViewController.h"
#import "UIDefines.h"
#import "UIColor+CatrobatUIColorExtensions.h"
#import <tgmath.h>

@interface WebViewController ()
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) NSURL *URL;
@property (nonatomic, strong) UILabel *urlTitleLabel;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@property (nonatomic, strong) UIView *touchHelperView;
@property (strong, nonatomic) UITapGestureRecognizer *tapGesture;
@property (strong, nonatomic) UIView *forwardButtonBackGroundView;
@property (strong, nonatomic) UIView *backButtonBackGroundView;

@end

#define kTranslateYNavigationBar 40.0f
#define kScrollDownThreshold 30.0f
#define kURLViewHeight 20.0f
#define kScrollOffset 64.0f

@implementation WebViewController {
    BOOL _errorLoadingURL;
    BOOL _doneLoadingURL;
    BOOL _showActivityIndicator;
    BOOL _controlsHidden;
    UIButton *_forwardButton;
    UIButton *_backButton;
    UIBarButtonItem *_refreshButton;
    UIBarButtonItem *_stopButton;
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
    
    UIImage *forwardButtonImage = [UIImage imageNamed:@"webview_arrow_right"];
    UIImage *backButtonImage = [UIImage imageNamed:@"webview_arrow_left"];
    forwardButtonImage = [forwardButtonImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    backButtonImage = [backButtonImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    _forwardButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_forwardButton setBackgroundImage:forwardButtonImage forState:UIControlStateNormal];
    _forwardButton.tintColor = self.tintColor;
    [_forwardButton addTarget:self action:@selector(goForward:) forControlEvents:UIControlEventTouchUpInside];
    
    _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_backButton setBackgroundImage:backButtonImage forState:UIControlStateNormal];
    _backButton.tintColor = self.tintColor;
    [_backButton addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
    
    _refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh:)];
    _stopButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(stop:)];
    
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    
    self.webView.scrollView.delegate = self;
}

- (void)loadView
{
    if (self.URL) {
        [self.webView loadRequest:[NSURLRequest requestWithURL:self.URL]];
    }
    
    UIView *view = [[UIView alloc] initWithFrame:UIScreen.mainScreen.bounds];
    view.backgroundColor = UIColor.backgroundColor;
    [view addSubview:self.webView];
    self.view = view;
    
    self.touchHelperView = [[UIView alloc] initWithFrame:CGRectZero];
    self.touchHelperView.backgroundColor = UIColor.clearColor;
    
    self.backButtonBackGroundView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 44.0f, 44.0f)];
    self.forwardButtonBackGroundView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 44.0f, 44.0f)];
    self.backButtonBackGroundView.backgroundColor = UIColor.backgroundColor;
    self.forwardButtonBackGroundView.backgroundColor = UIColor.backgroundColor;
    self.backButtonBackGroundView.layer.cornerRadius = 22.0f;
    self.forwardButtonBackGroundView.layer.cornerRadius = 22.0f;
    self.backButtonBackGroundView.alpha = 0.95f;
    self.forwardButtonBackGroundView.alpha = 0.95f;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setupToolbarItems];
    [self.navigationController.navigationBar addSubview:self.progressView];
    [self.view insertSubview:self.urlTitleLabel aboveSubview:self.webView];
    [self.view insertSubview:self.touchHelperView aboveSubview:self.webView];
    
    [self.view insertSubview:self.backButtonBackGroundView aboveSubview:self.touchHelperView];
    [self.view insertSubview:self.forwardButtonBackGroundView aboveSubview:self.touchHelperView];
    
    [self.forwardButtonBackGroundView addSubview:_forwardButton];
    [self.backButtonBackGroundView addSubview:_backButton];

    [self.touchHelperView addGestureRecognizer:self.tapGesture];
    [self.view addSubview:self.spinner];
    [self.spinner startAnimating];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.webView stopLoading];
    
    [self.backButtonBackGroundView removeFromSuperview];
    [self.forwardButtonBackGroundView removeFromSuperview];
    [self.progressView removeFromSuperview];
    
    if ([self.view.window.gestureRecognizers containsObject:self.tapGesture]) {
        [self.view.window removeGestureRecognizer:self.tapGesture];
    }
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.spinner.center = self.view.center;
    self.touchHelperView.frame = CGRectMake(0.0f, CGRectGetHeight(self.view.bounds) - kToolbarHeight, CGRectGetWidth(self.view.bounds), kToolbarHeight);
    
    self.forwardButtonBackGroundView.center = CGPointMake(CGRectGetWidth(self.view.bounds) - CGRectGetMidX(self.backButtonBackGroundView.bounds) - 5.0f, CGRectGetHeight(self.view.bounds) - CGRectGetMidY(self.backButtonBackGroundView.bounds) - 5.0f);
    self.backButtonBackGroundView.center = CGPointMake(5.0f + CGRectGetMidX(self.backButtonBackGroundView.bounds), CGRectGetHeight(self.view.bounds) - CGRectGetMidY(self.forwardButtonBackGroundView.bounds) - 5.0f);
    
    _forwardButton.frame = CGRectMake(CGRectGetMidX(self.forwardButtonBackGroundView.bounds) - 5.0f, CGRectGetMidY(self.forwardButtonBackGroundView.bounds) - 11.0f, 11.5f, 22.0f);
    _backButton.frame = CGRectMake(CGRectGetMidX(self.backButtonBackGroundView.bounds) - 8.0f, CGRectGetMidY(self.backButtonBackGroundView.bounds) - 11.0f, 11.5f, 22.0f);
}

- (void)dealloc
{
    self.URL = nil;
    self.webView.delegate = nil;
    self.webView = nil;
}

#pragma mark - getters
- (UIWebView *)webView
{
    if (!_webView) {
        _webView = [[UIWebView alloc] initWithFrame:UIScreen.mainScreen.bounds];
        _webView.delegate = self;
        _webView.allowsInlineMediaPlayback = YES;
        _webView.scalesPageToFit = YES;
        _webView.backgroundColor = UIColor.backgroundColor;
        _webView.alpha = 0.0f;
    }
    return _webView;
}

- (UIProgressView *)progressView
{
    if (!_progressView) {
        _progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
        CGFloat height = 2.0f;
        _progressView.frame = CGRectMake(0, CGRectGetHeight(self.navigationController.navigationBar.bounds) - height, CGRectGetWidth(self.navigationController.navigationBar.bounds), height);
        _progressView.tintColor = self.tintColor;
        
    }
    return _progressView;
}

- (UILabel *)urlTitleLabel
{
    if (!_urlTitleLabel) {
        _urlTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, CGRectGetHeight(self.navigationController.navigationBar.bounds) + kURLViewHeight, CGRectGetWidth(UIScreen.mainScreen.bounds), kURLViewHeight)];
        _urlTitleLabel.backgroundColor = UIColor.backgroundColor;
        _urlTitleLabel.font = [UIFont systemFontOfSize:13.0f];
        _urlTitleLabel.textColor = UIColor.lightBlueColor;
        _urlTitleLabel.textAlignment = NSTextAlignmentCenter;
        _urlTitleLabel.alpha = 0.6f;
    }
    return _urlTitleLabel;
}

#pragma mark - WebViewDelegate
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self setEnableActivityIndicator:NO];
    [self setupToolbarItems];
    _errorLoadingURL = YES;
    _doneLoadingURL = NO;
    [self setProgress:0.0f];
    
    if (error.code != -999) {
        [[[UIAlertView alloc] initWithTitle:@"Info"
                                    message:error.localizedDescription
                                   delegate:self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
}


- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self setEnableActivityIndicator:NO];
    self.URL = webView.request.URL;
    [self setupToolbarItems];
    _errorLoadingURL = NO;
    _doneLoadingURL = YES;
    
    [self setProgress:1.0f];
    [self showNavigationButtons];
    
    [UIView animateWithDuration:0.25f animations:^{ self.webView.alpha = 1.0f; }];
    
    if (self.spinner.isAnimating) {
        [self.spinner stopAnimating];
    }
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self setEnableActivityIndicator:YES];
    _doneLoadingURL = NO;
    [self setProgress:0.2f];
    [self setupToolbarItems];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    _controlsHidden = self.webView.scrollView.contentOffset.y >= 0.0f ? YES : NO;
    
    if (_controlsHidden) {
        return;
    }
    
    CGFloat offsetY = MAX(0.0f, scrollView.contentOffset.y + kScrollOffset);
    CGFloat translateValueNavBar;
    CGFloat translateUrlTitleLabel;
    CGFloat alphaURLLabel;
    CGFloat alphaNavBar;
    
    if (!_controlsHidden && offsetY < kScrollOffset) {
        translateValueNavBar = MIN(kTranslateYNavigationBar, offsetY);
        translateUrlTitleLabel = MIN(kURLViewHeight * 2.0f, offsetY);
        alphaURLLabel = 0.6f + MIN(0.25f, offsetY * 0.01f);
        alphaNavBar = self.navigationController.navigationBar.alpha - offsetY * 0.08f;
        
        self.urlTitleLabel.alpha = alphaURLLabel;
        self.navigationController.navigationBar.titleTextAttributes = @{ NSForegroundColorAttributeName : [UIColor.skyBlueColor colorWithAlphaComponent:alphaNavBar] };
        self.navigationController.navigationBar.tintColor = [self.navigationController.navigationBar.tintColor colorWithAlphaComponent: alphaNavBar];
        self.navigationController.navigationBar.transform = CGAffineTransformMakeTranslation(0.0f, -translateValueNavBar);
        self.urlTitleLabel.transform = CGAffineTransformMakeTranslation(0.0f, -translateUrlTitleLabel);
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if (velocity.y >= 0.0f) {
        [self hideNavigationButtons];
    } else {
        [self showNavigationButtons];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        [self endScrollingWithOffset:MAX(0.0f, scrollView.contentOffset.y + kScrollOffset)];
        
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self endScrollingWithOffset:MAX(0.0f, scrollView.contentOffset.y + kScrollOffset)];
}


- (void)endScrollingWithOffset:(CGFloat)offsetY
{
    if (offsetY <= kScrollDownThreshold) {
        [self showControls];
    }
}

#pragma mark - Webview Navigation
- (void)goBack:(id)sender
{
    if ([sender isKindOfClass:UIButton.class]) {
        if (self.webView.canGoBack) {
            [self.webView goBack];
        }
    }
}

- (void)goForward:(id)sender
{
    if ([sender isKindOfClass:UIButton.class]) {
        if (self.webView.canGoForward) {
            [self.webView goForward];
        }
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
    
    _forwardButton.enabled = self.webView.canGoForward;
    _backButton.enabled = self.webView.canGoBack;
    _backButtonBackGroundView.alpha = self.webView.canGoBack ? 0.95f : 0.5f;
    _forwardButtonBackGroundView.alpha = self.webView.canGoForward ? 0.95f : 0.5f;
    
    self.navigationItem.rightBarButtonItems = @[refreshOrStopButton];
}

- (void)setProgress:(CGFloat)progress
{
    self.progressView.progress = progress;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.progressView.hidden = _doneLoadingURL;
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
        self.navigationController.navigationBar.titleTextAttributes = @{ NSForegroundColorAttributeName : [UIColor.skyBlueColor colorWithAlphaComponent:1.0f] };
        self.urlTitleLabel.alpha = 0.6f;
    } completion:^(BOOL finished) {
        if (finished)
            [UIView animateWithDuration:0.2f delay:0.0f usingSpringWithDamping:1.0f initialSpringVelocity:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
                self.urlTitleLabel.transform = CGAffineTransformIdentity;
            } completion:NULL];
    }];
}

- (void)hideNavigationButtons
{
    [UIView animateWithDuration:0.4f delay:0.0 usingSpringWithDamping:1.0f initialSpringVelocity:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.forwardButtonBackGroundView.transform = CGAffineTransformMakeTranslation(0.0f, CGRectGetWidth(self.forwardButtonBackGroundView.bounds) * 2.0f);
        self.backButtonBackGroundView.transform = CGAffineTransformMakeTranslation(0.0f, CGRectGetWidth(self.backButtonBackGroundView.bounds) * 2.0f);
    } completion:NULL];
}

- (void)showNavigationButtons
{
    [self setupToolbarItems];
    [UIView animateWithDuration:0.4f delay:0.0 usingSpringWithDamping:0.6f initialSpringVelocity:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.forwardButtonBackGroundView.transform = CGAffineTransformIdentity;
        self.backButtonBackGroundView.transform = CGAffineTransformIdentity;
    } completion:NULL];
}

- (void)handleTap:(UITapGestureRecognizer *)sender
{
    if ([sender isKindOfClass:UITapGestureRecognizer.class]) {
        if (sender.state == UIGestureRecognizerStateEnded) {
            [self showNavigationButtons];
            [self showControls];
        }
    }
}

@end
