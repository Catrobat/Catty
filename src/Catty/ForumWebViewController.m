//
//  ForumWebViewController.m
//  Catty
//
//  Created by Mattias Rauter on 21.04.13.
//
//

#import "ForumWebViewController.h"
#import "TableUtil.h"
#import "Util.h"
#import "LoadingView.h"

@interface ForumWebViewController ()
@property (nonatomic, strong) LoadingView *loadingView;
@end

@implementation ForumWebViewController


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
	// Do any additional setup after loading the view.
    
    self.webView.delegate = self;
    
    //background image

    [TableUtil initNavigationItem:self.navigationItem withTitle:@"Forum" enableBackButton:YES target:self];
    
    
    NSString *urlAddress = @"https://groups.google.com/forum/?fromgroups=#!forum/pocketcode";
    NSURL *url = [NSURL URLWithString:urlAddress];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidUnload
{
    self.webView = nil;
}
-(void)dealloc
{
    [self.loadingView removeFromSuperview];
    self.loadingView = nil;
}

//#pragma mark - Segue
//
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//    
//}


#pragma mark - BackButtonDelegate
-(void)back {
//    [self.navigationController popViewControllerAnimated:YES];
    CATransition *transition = [CATransition animation];
    transition.duration = 0.3;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromLeft;
    [self.view.window.layer addAnimation:transition forKey:nil];
    [self dismissModalViewControllerAnimated:NO];
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

#pragma mark - UIWebViewDelegate

-(void)webViewDidStartLoad:(UIWebView *)webView
{
    [self showLoadingView];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self hideLoadingView];
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self hideLoadingView];
}

#pragma mark - Toolbar

- (IBAction)nextPage:(id)sender
{
    [self.webView goForward];
}

- (IBAction)previousPage:(id)sender
{
    [self.webView goBack];
}
@end
