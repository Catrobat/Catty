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
#import "UIColor+CatrobatUIColorExtensions.h"

@interface WebViewController ()
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) NSString *toolbarTitle;
@property (nonatomic, strong) UILabel *toolBarTitleLabel;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;

@end

@implementation WebViewController {
    BOOL _errorLoadingURL;
    BOOL _doneLoadingURL;
    UIBarButtonItem *_forwardButton;
    UIBarButtonItem *_backButton;
    UIBarButtonItem *_refreshButton;
    UIBarButtonItem *_stopButton;
}

- (id)initWithURL:(NSURL *)url
{
    if (self = [super init]) {
        _url = url;
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
    
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    
    self.navigationController.toolbar.barStyle = UIBarStyleBlack;
    self.navigationController.toolbar.hidden = NO;
}

- (void)loadView
{
    if (self.url) {
        [self.webView loadRequest:[NSURLRequest requestWithURL:self.url]];
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
    [self.navigationController.toolbar addSubview:self.toolBarTitleLabel];
    [self.view addSubview:self.spinner];
    [self.spinner startAnimating];
    [self setProgress:0.2f];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
//    [self setupToolbarItems];
    self.toolBarTitleLabel.text = self.toolbarTitle;
    self.spinner.center = self.view.center;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
}

- (void)dealloc
{
    [self.webView stopLoading];
    [self.progressView removeFromSuperview];
    self.url = nil;
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

- (UILabel *)toolBarTitleLabel
{
    if (!_toolBarTitleLabel) {
        _toolBarTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMidX(UIScreen.mainScreen.bounds) - 65.0f, 0.0f, 130.0f, 44.0f)];
        _toolBarTitleLabel.backgroundColor = UIColor.clearColor;
        _toolBarTitleLabel.font = [UIFont systemFontOfSize:13.0f];
        _toolBarTitleLabel.textColor = UIColor.skyBlueColor;
        _toolBarTitleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _toolBarTitleLabel;
}

- (NSString *)toolbarTitle
{
    if (self.url) {
        _toolbarTitle = [self.url host];
    }
    return _toolbarTitle;
}

#pragma mark - WebViewDelegate
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self setupToolbarItems];
    _errorLoadingURL = YES;
    _doneLoadingURL = NO;
    [self setProgress:0.0f];
    
    if (error.code != -999) {
        [[[UIAlertView alloc] initWithTitle:@"Loading Help Info"
                                    message:error.localizedDescription
                                   delegate:self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
}

//- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
//{
//    
//}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
   [self setupToolbarItems];
    _errorLoadingURL = NO;
    _doneLoadingURL = YES;
    
    [self setProgress:1.0f];
    if (self.spinner.isAnimating) [self.spinner stopAnimating];
    [UIView animateWithDuration:0.25f animations:^{ self.webView.alpha = 1.0f; }];
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    _doneLoadingURL = NO;
    
    [self setProgress:0.2f];
    [self setupToolbarItems];
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
            [self.webView loadRequest:[NSURLRequest requestWithURL:self.url]];
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
    fixedSpace.width = 40.0f;
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    self.toolBarTitleLabel.text = self.toolbarTitle;
    
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

@end
