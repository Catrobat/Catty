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

#import "LoginPopupViewController.h"
#import "UIColor+CatrobatUIColorExtensions.h"
#import "LanguageTranslationDefines.h"
#import <QuartzCore/QuartzCore.h>
#import "NetworkDefines.h"
#import "ProgramDefines.h"
#import "SegueDefines.h"
#import "UIColor+CatrobatUIColorExtensions.h"
#import "Util.h"

#import "NetworkDefines.h"
#import "ProgramDefines.h"
#import "UIColor+CatrobatUIColorExtensions.h"
#import "UIImage+CatrobatUIImageExtensions.h"
#import "LanguageTranslationDefines.h"

#define usernameParameterID @"registrationUsername"
#define passwordParameterID @"registrationPassword"
#define registrationEmailParameterID @"registrationEmail"
#define registrationCountryParameterID @"registrationCountry"


@interface LoginPopupViewController ()
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UITextView *bodyTextView;
@property (nonatomic, strong) UITextField *usernameTextField;
@property (nonatomic, strong) UITextField *passwordTextField;
@property (nonatomic, strong) UITextField *emailTextField;

@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSMutableData *data;
@property (nonatomic, assign) BOOL useTestUrl;

@end

@implementation LoginPopupViewController

const int VIEW_FRAME_PADDING_HORIZONTAL = 20;
const CGFloat VIEW_FRAME_HEIGHT = 260.0f;
const CGFloat VIEW_FRAME_CONTENT_HEIGHT = 300.0f;
const CGFloat VIEW_FRAME_WIDTH = 280.0f;

const int VIEW_HEADER_PADDING_TOP = 10;
const int VIEW_HEADER_LABEL_HEIGHT = 40;

const int VIEW_BODY_PADDING_TOP = 5;
const int VIEW_BODY_PADDING_BOTTOM = 5;

const int VIEW_MENU_BUTTON_MARGIN_HORIZONTAL = 11;
const int VIEW_BUTTON_HEIGHT = 30;
const int VIEW_BUTTON_MARGIN_BOTTOM = 15;


- (UITextView *)bodyTextView
{
    if(!_bodyTextView) _bodyTextView = [[UITextView alloc] init];
    return _bodyTextView;
}

- (UIView *)contentView
{
    if(!_contentView) _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    return _contentView;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.frame = CGRectMake(0,0, [Util screenWidth]-10, VIEW_FRAME_HEIGHT);
    self.view.backgroundColor = [UIColor backgroundColor];
    [self initUsernameTextfield];
    [self initPasswordTextfield];
    [self initEmailTextfield];
    [self initTermsOfUse];
    [self initCancelButton];
    [self initLoginButton];
    [self initForgotPasswordButton];
    self.useTestUrl = YES;
    [self.usernameTextField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Initialization

- (void)initUsernameTextfield
{

    UILabel *usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, VIEW_MENU_BUTTON_MARGIN_HORIZONTAL, 100, 30)];
    usernameLabel.text = @"username";
    usernameLabel.textColor = [UIColor skyBlueColor];
    
    self.usernameTextField = [[UITextField alloc] initWithFrame:CGRectMake(usernameLabel.frame.origin.x+usernameLabel.frame.size.width + 5, VIEW_MENU_BUTTON_MARGIN_HORIZONTAL, [Util screenWidth] - usernameLabel.frame.origin.x - usernameLabel.frame.size.width -25, 30)];
    
    self.usernameTextField.textColor = [UIColor lightOrangeColor];
    self.usernameTextField.backgroundColor = [UIColor whiteColor];
    [self.usernameTextField setBorderStyle:UITextBorderStyleRoundedRect];
    [self.usernameTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
    [self.usernameTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    
    [self.view addSubview:usernameLabel];
    [self.view addSubview:self.usernameTextField];
}


- (void)initPasswordTextfield
{
    
    UILabel *passwordLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 3 * VIEW_MENU_BUTTON_MARGIN_HORIZONTAL + VIEW_BUTTON_HEIGHT, 100, 30)];
    passwordLabel.text = @"password";
    passwordLabel.textColor = [UIColor skyBlueColor];
    
    self.passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(passwordLabel.frame.origin.x + passwordLabel.frame.size.width + 5, passwordLabel.frame.origin.y, [Util screenWidth] - passwordLabel.frame.origin.x - passwordLabel.frame.size.width -25, 30)];
    
    self.passwordTextField.textColor = [UIColor lightOrangeColor];
    self.passwordTextField.backgroundColor = [UIColor whiteColor];
    [self.passwordTextField setBorderStyle:UITextBorderStyleRoundedRect];
    [self.passwordTextField setSecureTextEntry:YES];
    [self.passwordTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
    [self.passwordTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [self.view addSubview:passwordLabel];
    [self.view addSubview:self.passwordTextField];
}


- (void)initEmailTextfield
{
    
    UILabel *emailLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5 * VIEW_MENU_BUTTON_MARGIN_HORIZONTAL + 2 * VIEW_BUTTON_HEIGHT, 100, 30)];
    emailLabel.text = @"email";
    emailLabel.textColor = [UIColor skyBlueColor];
    
    self.emailTextField = [[UITextField alloc] initWithFrame:CGRectMake(emailLabel.frame.origin.x + emailLabel.frame.size.width + 5, emailLabel.frame.origin.y, [Util screenWidth] - emailLabel.frame.origin.x - emailLabel.frame.size.width -25, 30)];
    
    self.emailTextField.textColor = [UIColor lightOrangeColor];
    self.emailTextField.backgroundColor = [UIColor whiteColor];
    [self.emailTextField setBorderStyle:UITextBorderStyleRoundedRect];
    [self.emailTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
    [self.emailTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [self.view addSubview:emailLabel];
    [self.view addSubview:self.emailTextField];
}


- (void)initTermsOfUse
{
    UIButton *termsOfUseButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [termsOfUseButton setTitle:kLocalizedTermsOfUse forState:UIControlStateNormal];
    [termsOfUseButton sizeToFit];
    termsOfUseButton.frame = CGRectMake(0, self.view.frame.size.height - termsOfUseButton.frame.size.height - VIEW_BODY_PADDING_BOTTOM * 1.5, self.view.frame.size.width, termsOfUseButton.frame.size.height);

    [self addLinkButton:termsOfUseButton];
    
    [self.view addSubview:termsOfUseButton];
}
- (void)initForgotPasswordButton
{
    UIButton *forgotButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [forgotButton setTitle:kLocalizedForgotPassword forState:UIControlStateNormal];
    [forgotButton sizeToFit];
    forgotButton.frame = CGRectMake(0, self.view.frame.size.height - forgotButton.frame.size.height - VIEW_BODY_PADDING_BOTTOM * 5, self.view.frame.size.width, forgotButton.frame.size.height);
    
    [self addLinkButton:forgotButton];
    
    [self.view addSubview:forgotButton];
}

- (void)initCancelButton
{
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancelButton sizeToFit];
    cancelButton.frame = CGRectMake(50, self.view.frame.size.height - cancelButton.frame.size.height - VIEW_BODY_PADDING_BOTTOM * 12, cancelButton.frame.size.width, cancelButton.frame.size.height);
    
    [cancelButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cancelButton];
}

- (void)initLoginButton
{
    UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [loginButton setTitle:@"Login" forState:UIControlStateNormal];
    [loginButton sizeToFit];
    loginButton.frame = CGRectMake(self.view.frame.size.width - loginButton.frame.size.width - 50, self.view.frame.size.height - loginButton.frame.size.height - VIEW_BODY_PADDING_BOTTOM * 12, loginButton.frame.size.width, loginButton.frame.size.height);
    
    [loginButton addTarget:self action:@selector(loginAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loginButton];
}

- (void)addMenuButton:(UIButton *)button
{
    [self.view addSubview:button];
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0.0, button.frame.origin.y + button.frame.size.height + VIEW_MENU_BUTTON_MARGIN_HORIZONTAL)];
    [path addLineToPoint:CGPointMake(self.view.frame.size.width, button.frame.origin.y + button.frame.size.height + VIEW_MENU_BUTTON_MARGIN_HORIZONTAL)];
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = [path CGPath];
    shapeLayer.strokeColor = [[UIColor skyBlueColor] CGColor];
    shapeLayer.lineWidth = 2.0;
    shapeLayer.fillColor = [[UIColor clearColor] CGColor];
    [self.view.layer addSublayer:shapeLayer];
}

- (void)addLinkButton:(UIButton *)button
{
    [button setTitleColor:[UIColor lightOrangeColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(openURLAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView insertSubview:button belowSubview:self.bodyTextView];
}

- (void)initContentView:(NSString *)headerTitle withText:(NSString *)bodyText
{
    self.contentView.backgroundColor = [UIColor backgroundColor];
    self.contentView.layer.cornerRadius = 15;
    self.contentView.layer.masksToBounds = YES;
    
    //init header
    UILabel *aboutPocketCodeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2, VIEW_HEADER_PADDING_TOP, self.view.frame.size.width, VIEW_HEADER_LABEL_HEIGHT)];
    [aboutPocketCodeLabel setTextColor:[UIColor skyBlueColor]];
    [aboutPocketCodeLabel setText:headerTitle];
    [aboutPocketCodeLabel sizeToFit];
    aboutPocketCodeLabel.frame = CGRectMake(self.view.frame.size.width / 2 - aboutPocketCodeLabel.frame.size.width / 2, VIEW_HEADER_PADDING_TOP, aboutPocketCodeLabel.frame.size.width, aboutPocketCodeLabel.frame.size.height);
    aboutPocketCodeLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:aboutPocketCodeLabel];
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0.0, VIEW_HEADER_LABEL_HEIGHT)];
    [path addLineToPoint:CGPointMake(self.contentView.frame.size.width, VIEW_HEADER_LABEL_HEIGHT)];
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = [path CGPath];
    shapeLayer.strokeColor = [[UIColor skyBlueColor] CGColor];
    shapeLayer.lineWidth = 2.0;
    shapeLayer.fillColor = [[UIColor clearColor] CGColor];
    [self.contentView.layer addSublayer:shapeLayer];
    
    //init body
    self.bodyTextView.frame = CGRectMake(VIEW_FRAME_PADDING_HORIZONTAL, VIEW_HEADER_LABEL_HEIGHT + VIEW_BODY_PADDING_TOP, self.view.frame.size.width - 2 * VIEW_FRAME_PADDING_HORIZONTAL, 50);
    self.bodyTextView.text = bodyText;
    self.bodyTextView.textAlignment = NSTextAlignmentCenter;
    [self.bodyTextView sizeToFit];
    self.bodyTextView.frame = CGRectMake(VIEW_FRAME_PADDING_HORIZONTAL, VIEW_HEADER_LABEL_HEIGHT + VIEW_BODY_PADDING_TOP, self.view.frame.size.width - 2 * VIEW_FRAME_PADDING_HORIZONTAL, self.bodyTextView.frame.size.height);
    self.bodyTextView.textColor = [UIColor skyBlueColor];
    self.bodyTextView.backgroundColor = [UIColor backgroundColor];
    self.bodyTextView.editable = NO;
    [self.contentView addSubview:self.bodyTextView];
    
    //initBackbutton
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [backButton setTitle:kLocalizedBack forState:UIControlStateNormal];
    [backButton addTarget:self
                   action:@selector(backAction)
         forControlEvents:UIControlEventTouchUpInside];
    [backButton sizeToFit];
    backButton.frame = CGRectMake(self.contentView.frame.size.width / 2 - backButton.frame.size.width / 2, self.contentView.frame.size.height - backButton.frame.size.height - VIEW_BODY_PADDING_BOTTOM+102.0f, backButton.frame.size.width, backButton.frame.size.height);
    [self.contentView addSubview:backButton];
    
    UIBezierPath *backPath = [UIBezierPath bezierPath];
    [backPath moveToPoint:CGPointMake(0.0, backButton.frame.origin.y - VIEW_BODY_PADDING_BOTTOM / 2)];
    [backPath addLineToPoint:CGPointMake(self.contentView.frame.size.width, backButton.frame.origin.y - VIEW_BODY_PADDING_BOTTOM / 2)];
    CAShapeLayer *backShapeLayer = [CAShapeLayer layer];
    backShapeLayer.path = [backPath CGPath];
    backShapeLayer.fillColor = [[UIColor skyBlueColor] CGColor];
    backShapeLayer.strokeColor = [[UIColor skyBlueColor] CGColor];
    backShapeLayer.lineWidth = 2.0f;
    backShapeLayer.fillColor = [[UIColor clearColor] CGColor];
    [self.contentView.layer addSublayer:backShapeLayer];
}

-(void)cancel
{
    [self.delegate dismissPopupWithLoginCode:NO];
}

-(void)loginAction
{
    if ([self.usernameTextField.text isEqualToString:@""]) {
        [Util alertWithText:@"Username is necessary!"];
        return;
    } else if (![self validPassword:self.passwordTextField.text]) {
        [Util alertWithText:@"Password is not vaild!"];
        return;
    } else if ([self.emailTextField.text isEqualToString:@""] || ![self NSStringIsValidEmail:self.emailTextField.text]) {
        [Util alertWithText:@"Email is not valid!"];
        return;
    }
    
    [self loginAtServerWithUsername:self.usernameTextField.text
                        andPassword:self.passwordTextField.text
                           andEmail:self.emailTextField.text];
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
    BOOL lowerCaseLetter=0,upperCaseLetter=0,digit=0,specialCharacter = 0;
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

#pragma mark - Helpers
- (void)loginAtServerWithUsername:(NSString*)username andPassword:(NSString*)password andEmail:(NSString*)email
{
    NSDebug(@"Login started with username:%@ and password:%@ and email:%@", username, password, email);
        // reset data
    self.data = nil;
    self.data = [[NSMutableData alloc] init];
    
        //Example URL: https://pocketcode.org/api/loginOrRegister/loginOrRegister.json?registrationUsername=MaxMuster&registrationPassword=MyPassword
        //For testing use: https://catroid-test.catrob.at/api/loginOrRegister/loginOrRegister.json?registrationUsername=MaxMuster&registrationPassword=MyPassword
    
    NSString *uploadUrlBase = self.useTestUrl ? kTestLoginOrRegisterUrl : kLoginOrRegisterUrl;
    /*
     NSString *urlString = [NSString stringWithFormat:@"%@/%@?%@=%@&%@=%@", uploadUrlBase, kConnectionLoginOrRegister, usernameParameterID, username, passwordParameterID, password];
     NSDebug(@"URL string: %@", urlString);
     */
    NSLocale *currentLocale = [NSLocale currentLocale];
    NSString *countryCode = [currentLocale objectForKey:NSLocaleCountryCode];
    NSDebug(@"Current Country is: %@", countryCode);
    
        //NSString *testEmail = @"test1@gmx.at";
    
    NSString *post = [NSString stringWithFormat:@"%@=%@&%@=%@&%@=%@&%@=%@",usernameParameterID, username, passwordParameterID, password, registrationEmailParameterID, email, registrationCountryParameterID, countryCode];
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", uploadUrlBase, kConnectionLoginOrRegister]]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:postData];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    self.connection = connection;
    
    [self.connection start];
    
    if(self.connection) {
        NSLog(@"Connection Successful");
    } else {
        NSLog(@"Connection could not be made");
    }
}


#pragma mark - NSURLConnection Delegates
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData*)data
{
    NSDebug(@"Received Data from server");
    if (self.connection == connection) {
        [self.data appendData:data];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSDebug(@"NSURLConnection ERROR: %@", error);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if (self.connection == connection) {
        NSDebug(@"Finished loading");
        
        NSError *error = nil;
        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:self.data options:kNilOptions error:&error];
        NSString *statusCode = [NSString stringWithFormat:@"%@", [dictionary valueForKey:@"statusCode"]];
            //int statusCode = [dictionary valueForKey:@"statusCode"];
        NSDebug(@"StatusCode is %@", statusCode);
        
            //some ugly code just to get logic working
        if ([statusCode isEqualToString:@"200"] || [statusCode  isEqualToString:@"201"]) {
            
            NSDebug(@"Login successful");
            NSString *token = [NSString stringWithFormat:@"%@", [dictionary valueForKey:@"token"]];
            NSDebug(@"Token is %@", token);
            [[NSUserDefaults standardUserDefaults] setBool:true forKey:kUserIsLoggedIn];
            [[NSUserDefaults standardUserDefaults] setValue:token forKey:kUserLoginToken];
            [[NSUserDefaults standardUserDefaults] synchronize];
//                //save username, password in keychain and token in nsuserdefaults
            [self.delegate dismissPopupWithLoginCode:YES];
            
        } else {
            NSDebug(@"Error: %@", [dictionary valueForKey:@"answer"]);
            [Util alertWithText:[dictionary valueForKey:@"answer"]];
                //TODO: translate answer message
                //maybe clear password field?
        }
        
        self.data = nil;
        self.connection = nil;
    }
}

-(void)loadingIndicator:(BOOL)value
{
    UIApplication* app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = value;
}

- (void)openURLAction:(id)sender
{
    NSString *url = nil;
    UIButton *button = (UIButton *)sender;

    if([button.currentTitle isEqualToString:kLocalizedTermsOfUse])
        url = kTermsOfUseURL;
    if([button.currentTitle isEqualToString:kLocalizedForgotPassword])
        url = kRecoverPassword;
    
    if (url) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    }

}


@end
