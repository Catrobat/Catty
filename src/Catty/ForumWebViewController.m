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

@interface ForumWebViewController ()

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
    
    //background image

    [TableUtil initNavigationItem:self.navigationItem withTitle:@"Forum" enableBackButton:YES target:self];
    

    
    
    NSString *urlAddress = @"https://groups.google.com/forum/?fromgroups=#!forum/pocketcode";
    NSURL *url = [NSURL URLWithString:urlAddress];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [(UIWebView*)self.view loadRequest:request];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

@end
