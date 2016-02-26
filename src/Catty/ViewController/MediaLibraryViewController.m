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

#import "MediaLibraryViewController.h"
#import "LoadingView.h"
#import "Util.h"
#import "AppDelegate.h"
#import "NSString+CatrobatNSStringExtensions.h"
#import "Sound.h"
#import "UIColor+CatrobatUIColorExtensions.h"

@interface MediaLibraryViewController ()
    @property (weak, nonatomic) IBOutlet UIWebView *webView;
    @property (strong, nonatomic) LoadingView *loadingView;
    @property (nonatomic,strong)NSString *filePath;
@end

@implementation MediaLibraryViewController


- (void)viewDidLoad {
  
    [super viewDidLoad];
    NSString *urlString = @"https://share.catrob.at/pocketcode/pocket-library/";
    urlString = [urlString stringByAppendingString:self.urlEnding];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    [_webView loadRequest:urlRequest];
    self.webView.allowsInlineMediaPlayback = YES;
    self.webView.backgroundColor = UIColor.backgroundColor;
    self.view.backgroundColor = [UIColor backgroundColor];
    self.webView.delegate = self;
    self.sound = [[Sound alloc] init];
  
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!_loadingView) {
        _loadingView = [[LoadingView alloc] init];
        [self.view addSubview:self.loadingView];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.webView stopLoading];
    [self.loadingView hide];
}

- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request
                                                navigationType:(UIWebViewNavigationType)navigationType {

//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self.loadingView show];
//    });
            if(navigationType == UIWebViewNavigationTypeLinkClicked)
            {
//                dispatch_async(dispatch_get_main_queue(), ^{
                    self.url = [request URL];
                    [self loadAndPrepareData];
                    [self.navigationController popViewControllerAnimated:YES];
                    
//                });
            }
    

    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    NSString *cssString = [NSString stringWithFormat:@"body { background-color: %@; } header { display: none; } #footer-menu-bottom { display: none; } article img { background-color: %@; }",
                           [self hexStringFromColor:[UIColor backgroundColor]],
                           [self hexStringFromColor:[UIColor navTintColor]]];
    
    NSString *javascriptString = @"var style = document.createElement('style'); style.innerHTML = '%@'; document.head.appendChild(style)";
    
    NSString *javascriptWithCSSString = [NSString stringWithFormat:javascriptString, cssString];
    [webView stringByEvaluatingJavaScriptFromString:javascriptWithCSSString];
    [self.webView setHidden:NO];
    [self.loadingView hide];
}

-(void)webViewDidStartLoad:(UIWebView *)webView{
    [self.loadingView show];
    [self.webView setHidden:YES];
}


#pragma mark - WebViewDelegate
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.loadingView hide];
    });
//    if (error.code != -999) {
//        if ([[Util networkErrorCodes] containsObject:[NSNumber
//                                                      numberWithInteger:error.code]]){
//            [Util alertWithTitle:kLocalizedNoInternetConnection andText:kLocalizedNoInternetConnectionAvailable];
//        } else {
//            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Info" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
//            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:kLocalizedOK style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
//            }];
//            [alert addAction:cancelAction];
//            [self presentViewController:alert animated:YES completion:nil];
//        }
//    }
}

- (void)loadAndPrepareData
{
    NSData * data = [NSData dataWithContentsOfURL:self.url];
    UIImage * image = [UIImage imageWithData:data];
    AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    NSString *fileName =[[NSString uuid] stringByAppendingString:@".mpga"];

    if (image)
    {
        // Success use the image
        [self.paintDelegate addMediaLibraryLoadedImage:image withName:[[[self.url absoluteString] componentsSeparatedByString:@"="] lastObject]];
    }
    else
    {
        self.filePath = [NSString stringWithFormat:@"%@/%@", delegate.fileManager.documentsDirectory, fileName];
        
        self.sound.fileName = fileName;
        self.sound.name = [[[self.url absoluteString] componentsSeparatedByString:@"="] lastObject];
        [data writeToFile:self.filePath atomically:YES];
        [self.soundDelegate showDownloadSoundAlert:self.sound];
    }
}

- (NSString *)hexStringFromColor:(UIColor *)color
{
    const CGFloat *components = CGColorGetComponents(color.CGColor);
    
    CGFloat r, g, b;
    
    {
        r = components[0];
        g = components[0];
        b = components[0];
    }
    
    return [NSString stringWithFormat:@"#%02lX%02lX%02lX",
            lroundf(r * 255),
            lroundf(g * 255),
            lroundf(b * 255)];
}

@end
