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

@interface WebViewController ()
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) NSURL *URL;
@property (nonatomic, strong) UILabel *urlTitleLabel;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;

@end

#define kScrollDownThreshold 44.0f

@implementation WebViewController {
    BOOL _errorLoadingURL;
    BOOL _doneLoadingURL;
    BOOL _showActivityIndicator;
    BOOL _stopUpdateTransalation;
    BOOL _decelerateBackToZero;
    BOOL _updateAnimations;
    CGFloat _tempTranslateValue;
    CGPoint _originToolBar;
    CGFloat _tempYOffset;
    CGFloat _URLViewHeight;
    UIBarButtonItem *_forwardButton;
    UIBarButtonItem *_backButton;
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
    
    _forwardButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"webview_arrow_right"] style:0 target:self action:@selector(goForward:)];
    _backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"webview_arrow_left"] style:0 target:self action:@selector(goBack:)];
    _refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh:)];
    _stopButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(stop:)];
    _URLViewHeight = UIApplication.sharedApplication.statusBarFrame.size.height;
    
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    
    self.navigationController.toolbar.barStyle = UIBarStyleBlack;
    self.navigationController.toolbar.hidden = NO;
    
    self.webView.scrollView.delegate = self;
    _updateAnimations = YES;
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
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setToolbarHidden:NO];
    [self setupToolbarItems];
    [self.navigationController.navigationBar addSubview:self.progressView];
    [self.view insertSubview:self.urlTitleLabel aboveSubview:self.webView];
    [self.view addSubview:self.spinner];
    [self.spinner startAnimating];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.toolbar.transform = CGAffineTransformIdentity;
    [self.webView stopLoading];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.spinner.center = self.view.center;
    _originToolBar = self.navigationController.toolbar.frame.origin;
}

- (void)dealloc
{
    [self.progressView removeFromSuperview];
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
        _progressView.tintColor = UIColor.lightOrangeColor;
        
    }
    return _progressView;
}

- (UILabel *)urlTitleLabel
{
    if (!_urlTitleLabel) {
        _urlTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, CGRectGetHeight(self.navigationController.navigationBar.bounds) + _URLViewHeight, CGRectGetWidth(UIScreen.mainScreen.bounds), _URLViewHeight)];
        _urlTitleLabel.backgroundColor = UIColor.backgroundColor;
        _urlTitleLabel.font = [UIFont systemFontOfSize:13.0f];
        _urlTitleLabel.textColor = UIColor.lightBlueColor;
        _urlTitleLabel.textAlignment = NSTextAlignmentCenter;
        _urlTitleLabel.layer.opacity = 0.7f;
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
    if (self.spinner.isAnimating) [self.spinner stopAnimating];
    
//    self.URLView.transform = CGAffineTransformMakeTranslation(0.0f, -_URLViewHeight);
    [UIView animateWithDuration:0.25f animations:^{
        self.webView.alpha = 1.0f;
    }];
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self setEnableActivityIndicator:YES];
    _doneLoadingURL = NO;
//   [UIView animateWithDuration:0.2f animations:^{ self.URLView.alpha = 0.0f; }];
    [self setProgress:0.2f];
    [self setupToolbarItems];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat offsetY = MAX(0.0f, scrollView.contentOffset.y + kNavigationbarHeight);    
    CGFloat translateValueToolBar = MIN(kToolbarHeight, offsetY);
    CGFloat translateValueNavBar = MIN(kNavigationbarHeight - 2.0f, offsetY);
    CGFloat translateUrlTitleLabel = MIN(_URLViewHeight * 2.0f, offsetY);
    
    self.navigationController.navigationBar.transform = CGAffineTransformMakeTranslation(0.0f, -translateValueNavBar);
    self.webView.transform = CGAffineTransformMakeTranslation(0.0f, translateValueToolBar);
    self.navigationController.toolbar.transform = CGAffineTransformMakeTranslation(0.0f, translateValueToolBar);
    self.urlTitleLabel.transform = CGAffineTransformMakeTranslation(0.0f, -translateUrlTitleLabel);
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView
                     withVelocity:(CGPoint)velocity
              targetContentOffset:(inout CGPoint *)targetContentOffset
{
    
    if ((*targetContentOffset).y + kNavigationbarHeight >= _tempYOffset) {
        _decelerateBackToZero = NO;
    } else {
        _decelerateBackToZero = YES;
    }
    
    _tempYOffset = MAX(0.0f, scrollView.contentOffset.y + kNavigationbarHeight);
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        [self endScrollingWithOffset:MAX(0.0f, scrollView.contentOffset.y + kNavigationbarHeight)];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self endScrollingWithOffset:MAX(0.0f, scrollView.contentOffset.y + kNavigationbarHeight)];
}


- (void)endScrollingWithOffset:(CGFloat)offsetY
{
    if (offsetY < kScrollDownThreshold && offsetY != 0.0f) {
        [UIView animateWithDuration:0.15f animations:^{
            self.navigationController.navigationBar.transform = CGAffineTransformIdentity;
            self.webView.transform = CGAffineTransformIdentity;
            self.navigationController.toolbar.transform = CGAffineTransformIdentity;
            self.urlTitleLabel.transform = CGAffineTransformIdentity;
            self.webView.scrollView.contentOffset = CGPointMake(0.0f, -CGRectGetHeight(self.navigationController.navigationBar.bounds) - _URLViewHeight);
        }];
    }
}

#pragma mark - Webview Navigation
- (void)goBack:(id)sender
{
    if ([sender isKindOfClass:UIBarButtonItem.class]) {
        if (self.webView.canGoBack) {
            [self.webView goBack];
        }
    }
}

- (void)goForward:(id)sender
{
    if ([sender isKindOfClass:UIBarButtonItem.class]) {
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
    UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixedSpace.width = 50.0f;
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    self.urlTitleLabel.text = [NSString stringWithFormat:@"%@%@", [self.URL host], [self.URL relativePath]];
    
    _forwardButton.enabled = self.webView.canGoForward;
    _backButton.enabled = self.webView.canGoBack;
    
    self.toolbarItems = @[_backButton, fixedSpace, _forwardButton, flexibleSpace, refreshOrStopButton];
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


@end
