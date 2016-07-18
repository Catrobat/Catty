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
#import "NetworkDefines.h"

@interface MediaLibraryViewController ()
    @property (weak, nonatomic) IBOutlet UIWebView *webView;
    @property (strong, nonatomic) LoadingView *loadingView;
    @property (nonatomic,strong)NSString *filePath;
    @property (nonatomic, strong)NSMutableData * mdata;
    @property (strong, nonatomic)NSURLConnection *connection;
@end

@implementation MediaLibraryViewController

#pragma mark - getters and setters
- (NSMutableData*)mdata
{
    if (! _mdata) {
        _mdata = [[NSMutableData alloc]init];
    }
    return _mdata;
}

-(LoadingView *)loadingView
{
    if (!_loadingView) {
        _loadingView = [[LoadingView alloc] init];
        [self.view addSubview:self.loadingView];
    }
    return _loadingView;
}
	
- (void)viewDidLoad {
  
    [super viewDidLoad];
    NSString *urlString = [NSString stringWithFormat:@"%@/%@", kMediaLibraryUrl, self.urlEnding];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:kConnectionTimeout];
    [_webView loadRequest:urlRequest];
    self.webView.allowsInlineMediaPlayback = YES;
    self.webView.backgroundColor = UIColor.backgroundColor;
    self.view.backgroundColor = [UIColor backgroundColor];
    self.webView.delegate = self;
    self.sound = [[Sound alloc] init];
    self.navigationItem.title = kLocalizedMediaLibrary;
  
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.webView stopLoading];
    [self.loadingView hide];
}

#pragma mark - WebViewDelegate
- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request
                                                navigationType:(UIWebViewNavigationType)navigationType {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.loadingView show];
    });

    if(navigationType == UIWebViewNavigationTypeLinkClicked)
    {
        self.url = [request URL];
        NSURLRequest *datarequest = [NSURLRequest requestWithURL:self.url
                                                     cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                 timeoutInterval:60.0];
        
        self.connection = [[NSURLConnection alloc] initWithRequest:datarequest delegate:self];
        
        return NO;
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
    
    [self.webView setHidden:YES];
}


- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.loadingView hide];
    });
    if ([Util isNetworkError:error]) {
        [Util defaultAlertForNetworkError];
    }
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - NSURLDelegate
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    
    UIImage * image = [UIImage imageWithData:self.mdata];
    NSString *fileName =[[NSString uuid] stringByAppendingString:@".mpga"];
    AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    
    
    if (image)
    {
        NSString *decodedFilename = [(NSString *)[self.url absoluteString] stringByReplacingOccurrencesOfString:@"+" withString:@" "];
        decodedFilename = [decodedFilename stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        // Success use the image
        [self.paintDelegate addMediaLibraryLoadedImage:image withName:[[decodedFilename componentsSeparatedByString:@"="] lastObject]];
    }
    else
    {
        self.filePath = [NSString stringWithFormat:@"%@/%@", delegate.fileManager.documentsDirectory, fileName];
        
        NSString *decodedFilename = [(NSString *)[[[self.url absoluteString] componentsSeparatedByString:@"="] lastObject] stringByReplacingOccurrencesOfString:@"+" withString:@" "];
        decodedFilename = [decodedFilename stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        self.sound.fileName = fileName;
        self.sound.name = decodedFilename;
        [self.mdata writeToFile:self.filePath atomically:YES];
        [self.soundDelegate showDownloadSoundAlert:self.sound];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.loadingView hide];
    });
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.mdata = [[NSMutableData alloc]init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.mdata appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.loadingView hide];
    });
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Util
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
