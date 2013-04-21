//
//  ForumWebViewController.h
//  Catty
//
//  Created by Mattias Rauter on 21.04.13.
//
//

#import <UIKit/UIKit.h>
#import "BackButtonDelegate.h"
 

@interface ForumWebViewController : UIViewController <BackButtonDelegate, UIWebViewDelegate>
@property (strong, nonatomic) IBOutlet UIWebView *webView;
@end
