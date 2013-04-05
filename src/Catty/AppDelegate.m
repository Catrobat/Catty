//
//  AppDelegate.m
//  AppScaffold
//

#import "AppDelegate.h"
#import "Stage.h"
#import "StageViewController.h"

// --- c functions ---

void onUncaughtException(NSException *exception)
{
    NSLog(@"uncaught exception: %@", exception.description);
}

// ---

@implementation AppDelegate
{
    SPViewController *_viewController;
    UIWindow *_window;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSSetUncaughtExceptionHandler(&onUncaughtException);
    
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    _window = [[UIWindow alloc] initWithFrame:screenBounds];
    
    _viewController = [[StageViewController alloc] init];
    [_viewController startWithRoot:[Stage class] supportHighResolutions:YES doubleOnPad:YES];
    
//    _viewController.view.frame = CGRectMake(50, 50, 300, 300);
//    
//    _viewController.stage.width = 2000;
//    _viewController.stage.height = 1000;
    
    [_window setRootViewController:_viewController];
    [_window makeKeyAndVisible];
    
    return YES;
}

@end
