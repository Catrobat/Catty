/**
 *  Copyright (C) 2010-2015 The Catrobat Team
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

#import "LoginViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "UIColor+CatrobatUIColorExtensions.h"
#import "LanguageTranslationDefines.h"
#import "NetworkDefines.h"
#import "ProgramDefines.h"
#import "SegueDefines.h"
#import "Util.h"
#import "JNKeychain.h"
#import "CatrobatTableViewController.h"
#import "BDKNotifyHUD.h"
#import "RegisterViewController.h"

#import "NetworkDefines.h"
#import "ProgramDefines.h"
#import "UIImage+CatrobatUIImageExtensions.h"
#import "LanguageTranslationDefines.h"
#import "KeychainUserDefaultsDefines.h"

#define usernameTag @"registrationUsername"
#define passwordTag @"registrationPassword"
#define registrationEmailTag @"registrationEmail"
#define registrationCountryTag @"registrationCountry"

#define tokenTag @"token"
#define statusCodeTag @"statusCode"
#define answerTag @"answer"
#define statusCodeOK @"200"
#define statusCodeRegistrationOK @"201"

//random boundary string
#define httpBoundary @"---------------------------98598263596598246508247098291---------------------------"

//web status codes are on: https://github.com/Catrobat/Catroweb/blob/master/statusCodes.php

@interface LoginViewController ()
@property (nonatomic, strong) NSString *userEmail;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *password;
@property (strong, nonatomic) NSURLSession *session;
@property (strong, nonatomic) NSURLSessionDataTask *dataTask;
//@property (nonatomic, strong) Keychain *keychain;
@end

@implementation LoginViewController

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
    self.navigationController.title  = self.title = kLocalizedLogin;
    [self initView];
    [self addDoneToTextFields];
    
}


-(void)initView
{
    UIColor* mainColor = [UIColor backgroundColor];
    UIColor* darkColor = [UIColor globalTintColor];
    
    NSString* fontName = @"Avenir-Book";
    NSString* boldFontName = @"Avenir-Black";
    CGFloat currentHeight = 0.0f;
    CGFloat headerHeight;
    if (IS_IPHONE4||IS_IPHONE5) {
        headerHeight = 70.0f;
    } else {
        headerHeight = 160.0f;
    }
    
    self.view.backgroundColor = mainColor;
    self.headerImageView.image = [UIImage imageNamed:@"PocketCode"];
    self.headerImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.headerImageView.frame = CGRectMake(0, 0, self.view.frame.size.width, headerHeight);
    
    self.infoLabel.textColor =  [UIColor globalTintColor];
    self.infoLabel.font =  [UIFont fontWithName:boldFontName size:28.0f];
    self.infoLabel.text = kLocalizedInfoLogin;
    [self.infoLabel sizeToFit];
    self.infoLabel.frame = CGRectMake(0, headerHeight, self.view.frame.size.width, self.infoLabel.frame.size.height);
    
    currentHeight+= self.headerImageView.frame.size.height+20;
    currentHeight = headerHeight+self.infoLabel.frame.size.height;
    [self addHorizontalLineToView:self.view andHeight:currentHeight];
    
    currentHeight += 10;
    self.usernameField.backgroundColor = [UIColor whiteColor];
    self.usernameField.placeholder =kLocalizedUsername;
    self.usernameField.font = [UIFont fontWithName:fontName size:16.0f];
    self.usernameField.layer.borderColor = [UIColor colorWithWhite:0.9 alpha:0.7].CGColor;
    self.usernameField.layer.borderWidth = 1.0f;
    self.usernameField.tag = 1;
    self.usernameField.frame = CGRectMake(0, currentHeight, self.view.frame.size.width, self.usernameField.frame.size.height);
    currentHeight+= self.usernameField.frame.size.height;
    UIImageView* leftView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    leftView.image = [UIImage imageNamed:@"user"];
    self.usernameField.leftViewMode = UITextFieldViewModeAlways;
    self.usernameField.leftView = leftView;
    
    
    self.passwordField.backgroundColor = [UIColor whiteColor];
    self.passwordField.placeholder =kLocalizedPassword;
    [self.passwordField setSecureTextEntry:YES];
    self.passwordField.font = [UIFont fontWithName:fontName size:16.0f];
    self.passwordField.layer.borderColor = [UIColor colorWithWhite:0.9 alpha:0.7].CGColor;
    self.passwordField.layer.borderWidth = 1.0f;
    self.passwordField.tag = 2;
    self.passwordField.frame = CGRectMake(0, currentHeight, self.view.frame.size.width, self.passwordField.frame.size.height);
    currentHeight+= self.passwordField.frame.size.height;
    
    UIImageView* leftView2 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    leftView2.image = [UIImage imageNamed:@"password"];
    self.passwordField.leftViewMode = UITextFieldViewModeAlways;
    self.passwordField.leftView = leftView2;
    
    self.loginButton.backgroundColor = darkColor;
    self.loginButton.titleLabel.font = [UIFont fontWithName:boldFontName size:20.0f];
    [self.loginButton setTitle:kLocalizedLogin forState:UIControlStateNormal];
    [self.loginButton setTitleColor:[UIColor backgroundColor] forState:UIControlStateNormal];
    [self.loginButton setTitleColor:[UIColor colorWithWhite:1.0f alpha:0.5f] forState:UIControlStateHighlighted];
    [self.loginButton addTarget:self action:@selector(loginAction) forControlEvents:UIControlEventTouchUpInside];
    self.loginButton.frame = CGRectMake(20, currentHeight, self.view.frame.size.width-40, self.loginButton.frame.size.height);
    currentHeight+= self.loginButton.frame.size.height+10;
    
    self.forgotButton.backgroundColor = [UIColor clearColor];
    self.forgotButton.titleLabel.font = [UIFont fontWithName:fontName size:15.0f];
    [self.forgotButton setTitle:kLocalizedForgotPassword forState:UIControlStateNormal];
    [self.forgotButton setTitleColor:[UIColor buttonTintColor] forState:UIControlStateNormal];
    [self.forgotButton setTitleColor:[UIColor colorWithWhite:1.0 alpha:0.5] forState:UIControlStateHighlighted];
    [self.forgotButton addTarget:self action:@selector(forgotPassword) forControlEvents:UIControlEventTouchUpInside];
    self.forgotButton.frame = CGRectMake(0, currentHeight, self.view.frame.size.width, self.forgotButton.frame.size.height);
    currentHeight+= self.forgotButton.frame.size.height+20;
    
    [self addHorizontalLineToView:self.view andHeight:currentHeight];
    currentHeight+= 10;
    self.registerButton.backgroundColor = darkColor;
    self.registerButton.titleLabel.font = [UIFont fontWithName:boldFontName size:16.0f];
    [self.registerButton setTitle:kLocalizedRegister forState:UIControlStateNormal];
    [self.registerButton setTitleColor:[UIColor backgroundColor] forState:UIControlStateNormal];
    [self.registerButton setTitleColor:[UIColor colorWithWhite:1.0f alpha:0.5f] forState:UIControlStateHighlighted];
    [self.registerButton addTarget:self action:@selector(registerAction) forControlEvents:UIControlEventTouchUpInside];
    self.registerButton.frame = CGRectMake(20, currentHeight, self.view.frame.size.width-40, self.registerButton.frame.size.height);
}

-(void)addDoneToTextFields
{
    [self.usernameField setReturnKeyType:UIReturnKeyNext];
    [self.usernameField addTarget:self
                           action:@selector(textFieldShouldReturn:)
                 forControlEvents:UIControlEventEditingDidEndOnExit];
    [self.passwordField setReturnKeyType:UIReturnKeyDone];
    [self.passwordField addTarget:self
                           action:@selector(loginAction)
                 forControlEvents:UIControlEventEditingDidEndOnExit];
}

-(void)willMoveToParentViewController:(UIViewController *)parent
{
    if (!parent) {
        [self.catTVC afterSuccessfulLogin];
    }
    
}

- (void)addHorizontalLineToView:(UIView*)view andHeight:(CGFloat)height
{
    UIView *lineView =[[UIView alloc] initWithFrame:CGRectMake(0, height,view.frame.size.width , 1)];
    lineView.backgroundColor = [UIColor utilityTintColor];
    [view addSubview:lineView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(BOOL) NSStringIsValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = NO; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}


-(BOOL)validPassword:(NSString*)password
{
    int numberofCharacters = 6;
    BOOL lowerCaseLetter = NO ,upperCaseLetter = NO,digit = NO,specialCharacter = NO;
    if([password length] >= numberofCharacters)
    {
        for (int i = 0; i < [password length]; i++)
        {
            unichar c = [password characterAtIndex:i];
            if(!lowerCaseLetter)
            {
                lowerCaseLetter = [[NSCharacterSet lowercaseLetterCharacterSet] characterIsMember:c];
            }
            if(!upperCaseLetter)
            {
                upperCaseLetter = [[NSCharacterSet uppercaseLetterCharacterSet] characterIsMember:c];
            }
            if(!digit)
            {
                digit = [[NSCharacterSet decimalDigitCharacterSet] characterIsMember:c];
            }
            if(!specialCharacter)
            {
                specialCharacter = [[NSCharacterSet symbolCharacterSet] characterIsMember:c];
            }
        }
        
        if(specialCharacter && digit && lowerCaseLetter && upperCaseLetter)
        {
            //do what u want
            return YES;
        }
        else
        {
            return YES;
        }
    }
    else
    {
        return NO;
    }
}

-(void)setFormDataParameter:(NSString*)parameterID withData:(NSData*)data forHTTPBody:(NSMutableData*)body
{
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", httpBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSString *parameterString = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", parameterID];
    [body appendData:[parameterString dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[NSData dataWithData:data]];
    [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
}

#pragma mark Actions

-(void)loginAction
{
    if ([self.usernameField.text isEqualToString:@""]) {
        [Util alertWithText:kLocalizedLoginUsernameNecessary];
        return;
    } else if (![self validPassword:self.passwordField.text]) {
        [Util alertWithText:kLocalizedLoginPasswordNotValid];
        return;
    }
    
    [self loginAtServerWithUsername:self.usernameField.text
                        andPassword:self.passwordField.text];
}

-(void)registerAction
{
//TODO present registerViewController
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iPhone" bundle: nil];
    RegisterViewController * vc = [storyboard instantiateViewControllerWithIdentifier:@"RegisterController"];
    vc.catTVC = self.catTVC;
    vc.userName = self.usernameField.text;
    vc.password = self.passwordField.text;
    
    [self.navigationController pushViewController:vc animated:YES];

}

- (void)loginAtServerWithUsername:(NSString*)username andPassword:(NSString*)password
{
    NSDebug(@"Login started with username:%@ and password:%@ ", username, password);
    
    BOOL useTestServer = [[NSUserDefaults standardUserDefaults] boolForKey:kUseTestServerForUploadAndLogin];
    NSString *uploadUrl = useTestServer ? kTestLoginUrl : kLoginUrl;
    NSString *urlString = [NSString stringWithFormat:@"%@/%@", uploadUrl, (NSString*)kConnectionLogin];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", httpBoundary];
    [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
    
    NSMutableData *body = [NSMutableData data];
    
    //username
    self.userName = username;
    [self setFormDataParameter:usernameTag withData:[username dataUsingEncoding:NSUTF8StringEncoding] forHTTPBody:body];
    
    //password
    self.password = password;
    [self setFormDataParameter:passwordTag withData:[password dataUsingEncoding:NSUTF8StringEncoding] forHTTPBody:body];
    
//    //Country
//    NSLocale *currentLocale = [NSLocale currentLocale];
//    NSString *countryCode = [currentLocale objectForKey:NSLocaleCountryCode];
//    NSDebug(@"Current Country is: %@", countryCode);
//    [self setFormDataParameter:registrationCountryTag withData:[countryCode dataUsingEncoding:NSUTF8StringEncoding] forHTTPBody:body];
//    
//    //Language ?! 
    
    // close form
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", httpBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    // set request body
    [request setHTTPBody:body];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[body length]];
    [request addValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    
    self.dataTask = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            if (error.code != -999) {
                NSLog(@"%@", error);
            }
            
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self setEnableActivityIndicator:NO];
                
                NSError *error = nil;
                NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                NSString *statusCode = [NSString stringWithFormat:@"%@", [dictionary valueForKey:statusCodeTag]];
                NSDebug(@"StatusCode is %@", statusCode);
                
                if ([statusCode isEqualToString:statusCodeOK]) {

                    [self showLoginSuccessfulView];
                    NSDebug(@"Login successful");
                    NSString *token = [NSString stringWithFormat:@"%@", [dictionary valueForKey:tokenTag]];
                    NSDebug(@"Token is %@", token);
                    
                    //save username, password and email in keychain and token in nsuserdefaults
                    [[NSUserDefaults standardUserDefaults] setBool:true forKey:kUserIsLoggedIn];
                    [[NSUserDefaults standardUserDefaults] setValue:token forKey:kUserLoginToken];
                    [[NSUserDefaults standardUserDefaults] setValue:self.userName forKey:kcUsername];
                    
                    //TODO email?!
                    [[NSUserDefaults standardUserDefaults] setValue:self.userEmail forKey:kcEmail];
                    [[NSUserDefaults standardUserDefaults] synchronize];
            
                    [JNKeychain saveValue:self.password forKey:kcPassword];
                    [JNKeychain saveValue:token forKey:kUserLoginToken];

                    [self.navigationController popViewControllerAnimated:NO];
                    
                } else {
                    self.loginButton.enabled = YES;
                    
                    NSString *serverResponse = [dictionary valueForKey:answerTag];
                    NSDebug(@"Error: %@", serverResponse);
                    [Util alertWithText:serverResponse];
                }
            });
        }
    }];
    
    if (self.dataTask) {
        [self.dataTask resume];
        NSDebug(@"Connection Successful");
        [self setEnableActivityIndicator:YES];
        self.loginButton.enabled = NO;
    } else {
        NSDebug(@"Connection could not be established");
        [Util alertWithTitle:kLocalizedNoInternetConnection andText:kLocalizedNoInternetConnectionAvailable];
    }
}

- (void)showLoginSuccessfulView
{
    BDKNotifyHUD *hud = [BDKNotifyHUD notifyHUDWithImage:[UIImage imageNamed:kBDKNotifyHUDCheckmarkImageName]
                                                    text:kLocalizedLoginSuccessful];
    hud.destinationOpacity = kBDKNotifyHUDDestinationOpacity;
    hud.center = CGPointMake(self.view.center.x, self.view.center.y + kBDKNotifyHUDCenterOffsetY);
    hud.tag = kLoginViewTag;
    [self.view addSubview:hud];
    [hud presentWithDuration:kBDKNotifyHUDPresentationDuration
                       speed:kBDKNotifyHUDPresentationSpeed
                      inView:self.view
                  completion:^{ [hud removeFromSuperview]; }];
}

- (NSURLSession *)session {
    if (!_session) {
        // Initialize Session Configuration
        NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        
        // Configure Session Configuration
        [sessionConfiguration setHTTPAdditionalHeaders:@{ @"Accept" : @"application/json" }];
        
        // Initialize Session
        _session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    }
    
    return _session;
}

-(void)openTermsOfUse
{
    NSString *url = kTermsOfUseURL;
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

- (void)forgotPassword
{
    NSString *url = kRecoverPassword;
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

- (void)setEnableActivityIndicator:(BOOL)enabled
{
    [UIApplication.sharedApplication setNetworkActivityIndicatorVisible:enabled];
}

-(void)dismissKeyboard {
    [self.usernameField resignFirstResponder];
    [self.passwordField resignFirstResponder];
    [self setViewMovedUp:NO];
}
@end
