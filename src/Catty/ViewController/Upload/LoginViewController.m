/**
 *  Copyright (C) 2010-2022 The Catrobat Team
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
#import "LanguageTranslationDefines.h"
#import "Util.h"
#import "RegisterViewController.h"
#import "Pocket_Code-Swift.h"

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
#define statusAuthenticationFailed @"601"
#define statusUserDoesNotExist @"803"


//web status codes are on: https://github.com/Catrobat/Catroweb/blob/master/statusCodes.php

@interface LoginViewController ()
@property (nonatomic, strong) NSString *userEmail;
@property (nonatomic, strong) LoadingView* loadingView;
@property (nonatomic) BOOL shouldShowAlert;
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
    self.shouldShowAlert = YES;
    self.usernameField.delegate=self;
    self.passwordField.delegate=self;
}

- (void)dealloc
{
    [self.loadingView removeFromSuperview];
    self.loadingView = nil;
}

-(void)initView
{
    NSString* fontName = @"Avenir-Book";
    NSString* boldFontName = @"Avenir-Black";

    self.view.backgroundColor = UIColor.background;
    self.headerImageView.image = [UIImage imageNamed:@"PocketCode"];
    self.headerImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    self.infoLabel.textColor = UIColor.globalTint;
    self.infoLabel.font =  [UIFont fontWithName:boldFontName size:28.0f];
    self.infoLabel.text = kLocalizedInfoLogin;
    [self.infoLabel sizeToFit];

    self.usernameField.placeholder =kLocalizedUsername;
    self.usernameField.font = [UIFont fontWithName:fontName size:16.0f];
    self.usernameField.layer.borderColor = [UIColor colorWithWhite:0.9 alpha:0.7].CGColor;
    self.usernameField.layer.borderWidth = 1.0f;
    self.usernameField.tag = 1;
    [self.usernameField setIcon:[UIImage imageNamed:@"user"]];

    self.passwordField.placeholder = kLocalizedPassword;
    [self.passwordField setSecureTextEntry:YES];
    self.passwordField.font = [UIFont fontWithName:fontName size:16.0f];
    self.passwordField.layer.borderColor = [UIColor colorWithWhite:0.9 alpha:0.7].CGColor;
    self.passwordField.layer.borderWidth = 1.0f;
    self.passwordField.tag = 2;
    [self.passwordField setIcon:[UIImage imageNamed:@"password"]];
    
    self.loginButton.backgroundColor = UIColor.globalTint;
    self.loginButton.titleLabel.font = [UIFont fontWithName:boldFontName size:20.0f];
    [self.loginButton setTitle:kLocalizedLogin forState:UIControlStateNormal];
    [self.loginButton setTitleColor:UIColor.navTint forState:UIControlStateNormal];
    [self.loginButton setTitleColor:[UIColor colorWithWhite:1.0f alpha:0.5f] forState:UIControlStateHighlighted];
    [self.loginButton addTarget:self action:@selector(loginAction) forControlEvents:UIControlEventTouchUpInside];
    
    self.forgotButton.backgroundColor = UIColor.clearColor;
    self.forgotButton.titleLabel.font = [UIFont fontWithName:fontName size:15.0f];
    [self.forgotButton setTitle:kLocalizedForgotPassword forState:UIControlStateNormal];
    [self.forgotButton setTitleColor:UIColor.buttonTint forState:UIControlStateNormal];
    [self.forgotButton setTitleColor:[UIColor colorWithWhite:1.0 alpha:0.5] forState:UIControlStateHighlighted];
    [self.forgotButton addTarget:self action:@selector(forgotPassword) forControlEvents:UIControlEventTouchUpInside];

    self.registerButton.backgroundColor = UIColor.globalTint;
    self.registerButton.titleLabel.font = [UIFont fontWithName:boldFontName size:20.0f];
    [self.registerButton setTitle:kLocalizedRegister forState:UIControlStateNormal];
    [self.registerButton setTitleColor:UIColor.navTint forState:UIControlStateNormal];
    [self.registerButton setTitleColor:[UIColor colorWithWhite:1.0f alpha:0.5f] forState:UIControlStateHighlighted];
    UIEdgeInsets insets = { .left = 15, .right = 15, .top = 10, .bottom = 10 };
    self.registerButton.contentEdgeInsets = insets;
    [self.registerButton addTarget:self action:@selector(registerAction) forControlEvents:UIControlEventTouchUpInside];
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

- (void)viewWillDisappear:(BOOL)animated
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.dataTask cancel];
    });
    
    [super viewWillDisappear:animated];
}


-(void)textFieldDidBeginEditing:(UITextField *)sender {
    self.activeField = sender;
}

-(void)textFieldDidEndEditing:(UITextField *)sender {
    self.activeField = nil;
}

-(void)willMoveToParentViewController:(UIViewController *)parent
{
    if (!parent) {
        if (self.delegate != nil) {
            [self.delegate afterSuccessfulLogin];
        }
    }
}

- (void)addHorizontalLineToView:(UIView*)view andHeight:(CGFloat)height
{
    UIView *lineView =[[UIView alloc] initWithFrame:CGRectMake(0, height,view.frame.size.width , 1)];
    lineView.backgroundColor = UIColor.utilityTint;
    [view addSubview:lineView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(BOOL)stringContainsSpace:(NSString *)checkString
{
    NSRange whiteSpaceRange = [checkString rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet]];
    if (whiteSpaceRange.location != NSNotFound) {
        return true;
    }
    return false;
}

-(BOOL)NSStringIsValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = NO; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

-(void)registerAction
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iPhone" bundle: nil];
    RegisterViewController * vc = [storyboard instantiateViewControllerWithIdentifier:@"RegisterController"];
    vc.delegate = self.delegate;
    vc.userName = self.usernameField.text;
    vc.password = self.passwordField.text;
    
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)handleLoginResponseWithData:(NSData *)data andResponse:(NSURLResponse *)response
{
    if (data == nil) {

        if (self.shouldShowAlert) {
            self.shouldShowAlert = NO;
            [self hideLoadingView];
            [Util defaultAlertForNetworkError];
        }
        return;
    }

    NSError *error = nil;
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    NSString *statusCode = [NSString stringWithFormat:@"%@", [dictionary valueForKey:statusCodeTag]];
    NSDebug(@"StatusCode is %@", statusCode);
    
    if ([statusCode isEqualToString:statusCodeOK]) {
        
        NSDebug(@"Login successful");
        NSString *token = [NSString stringWithFormat:@"%@", [dictionary valueForKey:tokenTag]];
        NSDebug(@"Token is %@", token);
        
        //save username, password and email in keychain and token in nsuserdefaults
        [[NSUserDefaults standardUserDefaults] setBool:true forKey: NetworkDefines.kUserIsLoggedIn];
        [[NSUserDefaults standardUserDefaults] setValue:self.userName forKey:kcUsername];
        [[NSUserDefaults standardUserDefaults] setValue:self.userEmail forKey:kcEmail];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [Keychain saveValue:token forKey: NetworkDefines.kUserLoginToken];
        
        [self hideLoadingView];
        [self.navigationController popViewControllerAnimated:NO];
        
    } else if ([statusCode isEqualToString:statusAuthenticationFailed] ||
               [statusCode isEqualToString:statusUserDoesNotExist]) {
        self.loginButton.enabled = YES;
        [self hideLoadingView];
        NSDebug(@"Error: %@", kLocalizedAuthenticationFailed);
        [self showError:kLocalizedAuthenticationFailed];
    } else {
        self.loginButton.enabled = YES;
        [self hideLoadingView];
        
        NSString *serverResponse = [dictionary valueForKey:answerTag];
        NSDebug(@"Error: %@", serverResponse);
        [self showError:kLocalizedServerTimeoutIssueMessage];
    }
}

-(void)showError:(NSString *)message {
    [Util alertWithText:message];
}

-(void)openTermsOfUse
{
    NSString *url = NetworkDefines.termsOfUseUrl;
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url] options:@{} completionHandler:nil];
}

- (void)forgotPassword
{
    NSString *url = NetworkDefines.recoverPassword;
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url] options:@{} completionHandler:nil];
}

#pragma mark Helpers

-(void)dismissKeyboard {
    [self.usernameField resignFirstResponder];
    [self.passwordField resignFirstResponder];
    [self setViewMovedUp:NO];
}

- (void)showLoadingView
{
    if(!self.loadingView) {
        self.loadingView = [[LoadingView alloc] init];
        //[self.loadingView setBackgroundColor:UIColor.globalTint];
        [self.view addSubview:self.loadingView];
    }
    [self.loadingView show];
    [Util setNetworkActivityIndicator:YES];
}

- (void) hideLoadingView
{
    [self.loadingView hide];
    [Util setNetworkActivityIndicator:NO];
    NSString *url = NetworkDefines.recoverPassword;
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url] options:@{} completionHandler:nil];
}

@end
