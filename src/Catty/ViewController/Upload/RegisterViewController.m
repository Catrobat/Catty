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

#import "RegisterViewController.h"
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


@interface RegisterViewController ()
@property (nonatomic, strong) NSString *userEmail;
@property (strong, nonatomic) NSURLSession *session;
@property (strong, nonatomic) NSURLSessionDataTask *dataTask;
//@property (nonatomic, strong) Keychain *keychain;
@end

@implementation RegisterViewController

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
	self.navigationController.title  = self.title = kLocalizedRegister;
    [self initView];
    [self addDoneToTextFields];
    
}


-(void)initView
{
    UIColor* mainColor = [UIColor backgroundColor];
    UIColor* darkColor = [UIColor globalTintColor];
    
    NSString* fontName = @"Avenir-Book";
    NSString* boldFontName = @"Avenir-Black";
    
    self.view.backgroundColor = mainColor;
    self.headerImageView.image = [UIImage imageNamed:@"PocketCode"];
    self.headerImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    self.titleLabel.textColor =  [UIColor globalTintColor];
    self.titleLabel.font =  [UIFont fontWithName:boldFontName size:28.0f];
    self.titleLabel.text = kLocalizedInfoRegister;
    [self.titleLabel sizeToFit];
    
    self.usernameField.backgroundColor = [UIColor whiteColor];
    self.usernameField.placeholder = kLocalizedUsername;
    if (self.userName) {
        self.usernameField.text = self.userName;
    }
    self.usernameField.font = [UIFont fontWithName:fontName size:16.0f];
    self.usernameField.layer.borderColor = [UIColor colorWithWhite:0.9 alpha:0.7].CGColor;
    self.usernameField.layer.borderWidth = 1.0f;
    self.usernameField.tag = 1;

    
    UIImageView* leftView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    leftView.image = [UIImage imageNamed:@"user"];
    self.usernameField.leftViewMode = UITextFieldViewModeAlways;
    self.usernameField.leftView = leftView;
    UIImageView* leftView2 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    leftView2.image = [UIImage imageNamed:@"password"];
    self.passwordField.leftViewMode = UITextFieldViewModeAlways;
    self.passwordField.leftView = leftView2;
    
    self.emailField.backgroundColor = [UIColor whiteColor];
    self.emailField.placeholder =kLocalizedEmail;
    self.emailField.font = [UIFont fontWithName:fontName size:16.0f];
    self.emailField.layer.borderColor = [UIColor colorWithWhite:0.9 alpha:0.7].CGColor;
    self.emailField.layer.borderWidth = 1.0f;
    self.emailField.tag = 3;

    UIImageView* leftView3 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    leftView3.image = [UIImage imageNamed:@"email"];
    self.emailField.leftViewMode = UITextFieldViewModeAlways;
    self.emailField.leftView = leftView3;

    
    
    self.passwordField.backgroundColor = [UIColor whiteColor];
    self.passwordField.placeholder = kLocalizedPassword;
    if (self.password) {
        self.passwordField.text = self.password;
    }
    [self.passwordField setSecureTextEntry:YES];
    self.passwordField.font = [UIFont fontWithName:fontName size:16.0f];
    self.passwordField.layer.borderColor = [UIColor colorWithWhite:0.9 alpha:0.7].CGColor;
    self.passwordField.layer.borderWidth = 1.0f;
    self.passwordField.tag = 2;

    self.termsOfUseButton.backgroundColor = [UIColor clearColor];
    self.termsOfUseButton.titleLabel.font = [UIFont fontWithName:boldFontName size:14.0f];
    [self.termsOfUseButton setTitle:[NSString stringWithFormat:@"%@ %@",kLocalizedTermsAgreementPart,kLocalizedTermsOfUse] forState:UIControlStateNormal];
    [self.termsOfUseButton setTitleColor:[UIColor buttonTintColor] forState:UIControlStateNormal];
    [self.termsOfUseButton setTitleColor:[UIColor colorWithWhite:1.0f alpha:0.5f] forState:UIControlStateHighlighted];
    [self.termsOfUseButton addTarget:self action:@selector(openTermsOfUse) forControlEvents:UIControlEventTouchUpInside];

    self.registerButton.backgroundColor = darkColor;
    self.registerButton.titleLabel.font = [UIFont fontWithName:boldFontName size:20.0f];
    [self.registerButton setTitle:kUIFEDone forState:UIControlStateNormal];
    [self.registerButton setTitleColor:[UIColor backgroundColor] forState:UIControlStateNormal];
    [self.registerButton setTitleColor:[UIColor colorWithWhite:1.0f alpha:0.5f] forState:UIControlStateHighlighted];
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
                           action:@selector(registerAction)
              forControlEvents:UIControlEventEditingDidEndOnExit];
    [self.emailField setReturnKeyType:UIReturnKeyNext];
    [self.emailField addTarget:self
                        action:@selector(textFieldShouldReturn:)
              forControlEvents:UIControlEventEditingDidEndOnExit];
}

-(void)willMoveToParentViewController:(UIViewController *)parent
{
    // TODO when successful registration -> it pops to CtrobatTableViewController ->
    // make sure it will go back to upload. For now user has to klick again.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)addHorizontalLineToView:(UIView*)view andHeight:(CGFloat)height
{
    UIView *lineView =[[UIView alloc] initWithFrame:CGRectMake(0, height,view.frame.size.width , 1)];
    lineView.backgroundColor = [UIColor utilityTintColor];
    [view addSubview:lineView];
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


-(void)registerAction
{
    if ([self.usernameField.text isEqualToString:@""]) {
        [Util alertWithText:kLocalizedLoginUsernameNecessary];
        return;
    } else if (![self validPassword:self.passwordField.text]) {
        [Util alertWithText:kLocalizedLoginPasswordNotValid];
        return;
    } else if ([self.emailField.text isEqualToString:@""] || ![self NSStringIsValidEmail:self.emailField.text]) {
        [Util alertWithText:kLocalizedLoginEmailNotValid];
        return;
    }
    
    [self registerAtServerWithUsername:self.usernameField.text
                        andPassword:self.passwordField.text
                           andEmail:self.emailField.text];
}

- (void)registerAtServerWithUsername:(NSString*)username andPassword:(NSString*)password andEmail:(NSString*)email
{
    NSDebug(@"Register started with username:%@ and password:%@ and email:%@", username, password, email);
    
    BOOL useTestServer = [[NSUserDefaults standardUserDefaults] boolForKey:kUseTestServerForUploadAndLogin];
    NSString *uploadUrl = useTestServer ? kTestRegisterUrl : kRegisterUrl;
    NSString *urlString = [NSString stringWithFormat:@"%@/%@", uploadUrl, (NSString*)kConnectionRegister];
    
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
    
    //email
    self.userEmail = email;
    [self setFormDataParameter:registrationEmailTag withData:[email dataUsingEncoding:NSUTF8StringEncoding] forHTTPBody:body];
    
    //Country
    NSLocale *currentLocale = [NSLocale currentLocale];
    NSString *countryCode = [currentLocale objectForKey:NSLocaleCountryCode];
    NSDebug(@"Current Country is: %@", countryCode);
    [self setFormDataParameter:registrationCountryTag withData:[countryCode dataUsingEncoding:NSUTF8StringEncoding] forHTTPBody:body];
    
    //Language ?! 
    
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
                
                if ([statusCode isEqualToString:statusCodeOK] || [statusCode  isEqualToString:statusCodeRegistrationOK]) {
                    
                    if ([statusCode isEqualToString:statusCodeRegistrationOK]) {
                        [self showRegistrationSuccessfulView];
                    }
                    
                    NSDebug(@"Login successful");
                    NSString *token = [NSString stringWithFormat:@"%@", [dictionary valueForKey:tokenTag]];
                    NSDebug(@"Token is %@", token);
                    
                    //save username, password and email in keychain and token in nsuserdefaults
                    [[NSUserDefaults standardUserDefaults] setBool:true forKey:kUserIsLoggedIn];
                    [[NSUserDefaults standardUserDefaults] setValue:token forKey:kUserLoginToken];
                    [[NSUserDefaults standardUserDefaults] setValue:self.userName forKey:kcUsername];
                    [[NSUserDefaults standardUserDefaults] setValue:self.userEmail forKey:kcEmail];
                    [[NSUserDefaults standardUserDefaults] synchronize];
            
                    [JNKeychain saveValue:self.password forKey:kcPassword];
                    [JNKeychain saveValue:token forKey:kUserLoginToken];

                    [self.navigationController popToRootViewControllerAnimated:NO];
                    
                } else {
                    self.registerButton.enabled = YES;
                    
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
        self.registerButton.enabled = NO;
    } else {
        NSDebug(@"Connection could not be established");
        [Util alertWithTitle:kLocalizedNoInternetConnection andText:kLocalizedNoInternetConnectionAvailable];
    }
}

- (void)showRegistrationSuccessfulView
{
    BDKNotifyHUD *hud = [BDKNotifyHUD notifyHUDWithImage:[UIImage imageNamed:kBDKNotifyHUDCheckmarkImageName]
                                                    text:kLocalizedRegistrationSuccessful];
    hud.destinationOpacity = kBDKNotifyHUDDestinationOpacity;
    hud.center = CGPointMake(self.view.center.x, self.view.center.y + kBDKNotifyHUDCenterOffsetY);
    hud.tag = kRegistrationViewTag;
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


- (void)setEnableActivityIndicator:(BOOL)enabled
{
    [UIApplication.sharedApplication setNetworkActivityIndicatorVisible:enabled];
}

-(void)dismissKeyboard {
    [self.usernameField resignFirstResponder];
    [self.passwordField resignFirstResponder];
    [self.emailField resignFirstResponder];
}
@end
