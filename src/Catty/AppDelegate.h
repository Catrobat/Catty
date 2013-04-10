//
//  AppDelegate.h
//  AppScaffold
//

#import <UIKit/UIKit.h>
#import "FileManager.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) FileManager *fileManager;

@end
