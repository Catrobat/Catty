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

#import "ForumWebViewController.h"
#import "TableUtil.h"
#import "Util.h"
#import "LoadingView.h"
#import "UIColor+CatrobatUIColorExtensions.h"

#define kForumURL @"https://groups.google.com/forum/?fromgroups=#!forum/pocketcode"

@interface ForumWebViewController ()
@property (nonatomic, strong) LoadingView *loadingView;
@property (nonatomic, strong) UIBarButtonItem *back;
@property (nonatomic, strong) UIBarButtonItem *forward;
@property (nonatomic) float scrollIndicator;
@end

@implementation ForumWebViewController

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
	// Do any additional setup after loading the view.
    
    self.webView.delegate = self;
    self.webView.scrollView.delegate = self;
    self.webView.backgroundColor = [UIColor darkBlueColor];
    
    [TableUtil initNavigationItem:self.navigationItem withTitle:NSLocalizedString(@"Programs", nil)];
    
    NSURL *url = [NSURL URLWithString:kForumURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
    [self setupToolBar];
   
    
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.translucent = YES;
}

- (void)viewDidUnload
{
    self.webView = nil;
}

- (void)dealloc
{
    [self.loadingView removeFromSuperview];
    self.loadingView = nil;
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
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self showLoadingView];
    [self initButtons];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self hideLoadingView];
    [self initButtons];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self hideLoadingView];
    [self initButtons];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
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
    
    self.back = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"backbutton.png"]
                                                            style:UIBarButtonItemStylePlain
                                                           target:self
                                                           action:@selector(previousPage:)];
    
    self.forward = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"forwardbutton.png"]
                                                               style:UIBarButtonItemStylePlain
                                                              target:self
                                                              action:@selector(nextPage:)];
    [self initButtons];

    // XXX: workaround for tap area problem:
    // http://stackoverflow.com/questions/5113258/uitoolbar-unexpectedly-registers-taps-on-uibarbuttonitem-instances-even-when-tap
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"transparent1x1.png"]];
    UIBarButtonItem *invisibleButton = [[UIBarButtonItem alloc] initWithCustomView:imageView];
    self.toolbarItems = [NSArray arrayWithObjects:flexItem,  self.back,invisibleButton, invisibleButton, flexItem,
                         flexItem, flexItem, invisibleButton, invisibleButton, self.forward, flexItem, nil];
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.scrollIndicator > scrollView.contentOffset.y) {
        self.navigationController.toolbar.hidden = NO;
        self.navigationController.navigationBar.hidden = NO;
    }

    else {
        
        if(scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height)){
            NSDebug(@"BOTTOM REACHED");
            self.navigationController.toolbar.hidden = NO;
            self.navigationController.navigationBar.hidden = NO;
        }
        else if(scrollView.contentOffset.y <= 0.0){
            NSDebug(@"TOP REACHED");
            self.navigationController.toolbar.hidden = NO;
            self.navigationController.navigationBar.hidden = NO;
        }
        else{
            self.navigationController.toolbar.hidden = YES;
            self.navigationController.navigationBar.hidden = YES;
        }
        
    }
    self.scrollIndicator = scrollView.contentOffset.y;
}



@end
