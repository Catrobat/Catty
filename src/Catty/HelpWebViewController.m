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

#import "HelpWebViewController.h"
#import "TableUtil.h"
#import "Util.h"
#import "LoadingView.h"
#import "UIColor+CatrobatUIColorExtensions.h"
#import "LanguageTranslationDefines.h"

#define kForumURL @"https://pocketcode.org/tutorial"
#define kBarsHeight 44

@interface HelpWebViewController ()
@property (nonatomic, strong) LoadingView *loadingView;
@property (nonatomic, strong) UIBarButtonItem *back;
@property (nonatomic, strong) UIBarButtonItem *forward;
@property (nonatomic) float scrollIndicator;
@property (nonatomic) NSInteger originalNavigationYPos;
@property (nonatomic) NSInteger originalToolbarFrameYPos;
@property (nonatomic) BOOL  WebviewFinishedLoading;
@property (nonatomic, strong) NSTimer *progressTimer;
@end

@implementation HelpWebViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil
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
    self.webView.backgroundColor = [UIColor darkBlueColor];
    self.view.backgroundColor = [UIColor darkBlueColor];
    [self.webView setOpaque:NO];
    [self.view setOpaque:NO];
    
    self.webView.delegate = self;
    self.webView.scrollView.delegate = self;
    self.WebviewFinishedLoading = NO;
    self.navigationItem.title = kUIViewControllerTitleHelp;
    [self showLoadingView];

    NSURL *url = [NSURL URLWithString:kForumURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
    [self setupToolBar];

    self.originalNavigationYPos = self.navigationController.navigationBar.frame.origin.y;
    self.originalToolbarFrameYPos = ([Util getScreenHeight] - kBarsHeight);
    NSDebug(@"%i & %i", self.originalNavigationYPos,self.originalToolbarFrameYPos);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.translucent = YES;
    self.webView.scalesPageToFit = YES;
    self.webView.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.navigationController.toolbar.frame = CGRectMake(self.navigationController.toolbar.frame.origin.x,self.originalToolbarFrameYPos,self.navigationController.toolbar.frame.size.width,self.navigationController.toolbar.frame.size.height);
    self.navigationController.navigationBar.frame = CGRectMake(self.navigationController.navigationBar.frame.origin.x,self.originalNavigationYPos,self.navigationController.navigationBar.frame.size.width,self.navigationController.navigationBar.frame.size.height);

}

- (void)viewDidUnload
{
    self.webView = nil;
}

- (void)dealloc
{
    [self.loadingView removeFromSuperview];
    self.loadingView = nil;
    [self.webView removeFromSuperview];
    self.webView.delegate = nil;
    self.webView = nil;
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

- (void)hideLoadingView
{
    [self.loadingView hide];
}

#pragma mark - UIWebViewDelegate
- (void)webViewDidStartLoad:(UIWebView*)webView
{
    [self initButtons];
    UIApplication* app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = YES;
    if (self.navigationController.navigationBar.frame.origin.y == self.originalNavigationYPos) {
        self.progressView.progress = 0;
        self.progressView.hidden = NO;
        self.progressTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(timerCallback) userInfo:nil repeats:YES];
    }
    self.WebviewFinishedLoading = NO;
    
}

- (void)webViewDidFinishLoad:(UIWebView*)webView
{
    [self hideLoadingView];
    [self initButtons];
    self.WebviewFinishedLoading = YES;
    UIApplication* app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = NO;
    self.navigationController.toolbar.frame = CGRectMake(self.navigationController.toolbar.frame.origin.x,self.originalToolbarFrameYPos,self.navigationController.toolbar.frame.size.width,self.navigationController.toolbar.frame.size.height);
    self.navigationController.navigationBar.frame = CGRectMake(self.navigationController.navigationBar.frame.origin.x,self.originalNavigationYPos,self.navigationController.navigationBar.frame.size.width,self.navigationController.navigationBar.frame.size.height);
}

- (void)webView:(UIWebView*)webView didFailLoadWithError:(NSError*)error
{
    [self hideLoadingView];
    [self initButtons];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    self.back.enabled = true;
    return YES;
}

#pragma mark - Buttons
- (void)initButtons
{
    self.back.enabled = self.webView.canGoBack;
    self.forward.enabled = self.webView.canGoForward;
}

#pragma mark - toolbar
- (void)nextPage:(id)sender
{
    [self.webView goForward];
    self.back.enabled = true;
    self.forward.enabled = self.webView.canGoForward;
}

- (void)previousPage:(id)sender
{
    [self.webView goBack];
    self.back.enabled = self.webView.canGoBack;
    self.forward.enabled = true;
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

    self.back = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"backbutton"]
                                                            style:UIBarButtonItemStylePlain
                                                           target:self
                                                           action:@selector(previousPage:)];

    self.forward = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"forwardbutton"]
                                                               style:UIBarButtonItemStylePlain
                                                              target:self
                                                              action:@selector(nextPage:)];
    [self initButtons];

    // XXX: workaround for tap area problem:
    // http://stackoverflow.com/questions/5113258/uitoolbar-unexpectedly-registers-taps-on-uibarbuttonitem-instances-even-when-tap
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"transparent1x1"]];
    UIBarButtonItem *invisibleButton = [[UIBarButtonItem alloc] initWithCustomView:imageView];
    self.toolbarItems = [NSArray arrayWithObjects:flexItem,  self.back, invisibleButton, invisibleButton, flexItem,
                         flexItem, flexItem, invisibleButton, invisibleButton, self.forward, flexItem, nil];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat yOffset = scrollView.contentOffset.y+kBarsHeight;
    if (self.WebviewFinishedLoading == YES) {
        if (yOffset <= 0) {
            self.navigationController.toolbar.frame = CGRectMake(self.navigationController.toolbar.frame.origin.x,self.originalToolbarFrameYPos,self.navigationController.toolbar.frame.size.width,self.navigationController.toolbar.frame.size.height);
            self.navigationController.navigationBar.frame = CGRectMake(self.navigationController.navigationBar.frame.origin.x,self.originalNavigationYPos,self.navigationController.navigationBar.frame.size.width,self.navigationController.navigationBar.frame.size.height);
            
            
        }
        
        else if (scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height)){
            self.navigationController.toolbar.frame = CGRectMake(self.navigationController.toolbar.frame.origin.x,self.originalToolbarFrameYPos,self.navigationController.toolbar.frame.size.width,self.navigationController.toolbar.frame.size.height);
            self.navigationController.navigationBar.frame = CGRectMake(self.navigationController.navigationBar.frame.origin.x,self.originalNavigationYPos,self.navigationController.navigationBar.frame.size.width,self.navigationController.navigationBar.frame.size.height);
            
        }
        else if (yOffset > 0) {
            
            if (yOffset <= self.scrollIndicator) {
                self.navigationController.toolbar.frame = CGRectMake(self.navigationController.toolbar.frame.origin.x,self.originalToolbarFrameYPos,self.navigationController.toolbar.frame.size.width,self.navigationController.toolbar.frame.size.height);
                self.navigationController.navigationBar.frame = CGRectMake(self.navigationController.navigationBar.frame.origin.x,self.originalNavigationYPos,self.navigationController.navigationBar.frame.size.width,self.navigationController.navigationBar.frame.size.height);
                
            }
            else{
                self.navigationController.toolbar.frame = CGRectMake(self.navigationController.toolbar.frame.origin.x, self.originalToolbarFrameYPos + yOffset, self.navigationController.toolbar.frame.size.width, self.navigationController.toolbar.frame.size.height);
                self.navigationController.navigationBar.frame = CGRectMake(self.navigationController.navigationBar.frame.origin.x, self.originalNavigationYPos - yOffset, self.navigationController.navigationBar.frame.size.width, self.navigationController.navigationBar.frame.size.height);
                self.progressView.hidden=YES;
                
            }
            
        }
        self.scrollIndicator = yOffset;
    }
}

-(void)timerCallback {
    if (self.WebviewFinishedLoading) {
        if (self.progressView.progress >= 1) {
            self.progressView.hidden = YES;
        }
        else {
            self.progressView.progress += 0.1;
        }
    }
    else {
        self.progressView.progress += 0.05;
        if (self.progressView.progress >= 0.95) {
            self.progressView.progress = 0.95;
        }
    }
}



@end
