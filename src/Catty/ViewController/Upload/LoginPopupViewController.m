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
#import "Keychain.h"

#import "NetworkDefines.h"
#import "ProgramDefines.h"
#import "UIColor+CatrobatUIColorExtensions.h"
#import "UIImage+CatrobatUIImageExtensions.h"
#import "LanguageTranslationDefines.h"
#import "KeychainDefines.h"

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


@interface LoginPopupViewController ()
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UITextView *bodyTextView;
@property (nonatomic, strong) UITextField *usernameTextField;
@property (nonatomic, strong) UITextField *passwordTextField;
@property (nonatomic, strong) UITextField *emailTextField;
@property (nonatomic, strong) UIButton *loginButton;

@property (nonatomic, strong) NSString *userEmail;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSMutableData *data;
@property (nonatomic, strong) Keychain *keychain;

@end

@implementation LoginPopupViewController


const CGFloat LOGIN_VIEW_FRAME_HEIGHT = 260.0f;
const CGFloat LOGIN_VIEW_HEADER_FONT_SIZE = 20.0f;
const CGFloat LOGIN_VIEW_LABEL_FONT_SIZE = 16.0f;
const CGFloat LOGIN_VIEW_TEXTFIELD_HEIGHT = 30.0f;
const CGFloat LOGIN_VIEW_PADDING = 5.0f;
const CGFloat LOGIN_VIEW_USERNAME_LABEL_POSITION_Y = 45.0f;
const CGFloat LOGIN_VIEW_PASSWORD_LABEL_POSITION_Y = 80.0f;
const CGFloat LOGIN_VIEW_EMAIL_LABEL_POSITION_Y = 115.0f;
const CGFloat LOGIN_VIEW_FORGOTTEN_PWD_POSITION_Y = 198.0f;
const CGFloat LOGIN_VIEW_TEXTFIELD_POSITION_X = 100.0f;
const CGFloat LOGIN_VIEW_STANDARD_LINEWIDTH = 2.0f;


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
    self.view.frame = CGRectMake(0,0, [Util screenWidth]-10, LOGIN_VIEW_FRAME_HEIGHT);
    self.view.backgroundColor = [UIColor backgroundColor];
    self.keychain = [[Keychain alloc] initWithService:kcServiceName withGroup:nil];
    [self initLoginHeader];
    [self initUsernameViewElements];
    [self initPasswordViewElements];
    [self initEmailViewElements];
    [self initActionButtons];
    [self initForgotPasswordButton];
    [self initTermsOfUse];
    [self.usernameTextField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Initialization
- (void)initLoginHeader
{
    UILabel *loginHeader = [self setUpLabelAtPositionX:self.contentView.frame.size.width/2
                                             positionY:LOGIN_VIEW_PADDING
                                              withText:kLocalizedLogin
                                              fontSize:LOGIN_VIEW_HEADER_FONT_SIZE
                                              andColor:[UIColor skyBlueColor]
                                       centerXPosition:true];
    
    [self addHorizontalBorderLineAtY:loginHeader.frame.size.height + 2*LOGIN_VIEW_PADDING
                               Width:self.contentView.frame.size.width
                       withLineWidth:LOGIN_VIEW_STANDARD_LINEWIDTH
                            andColor:[UIColor skyBlueColor]];
}

- (void)initUsernameViewElements
{
    UILabel *usernameLabel = [self setUpLabelAtPositionX:2*LOGIN_VIEW_PADDING
                                               positionY:LOGIN_VIEW_USERNAME_LABEL_POSITION_Y
                                                withText:[NSString stringWithFormat:@"%@:", (NSString*)kLocalizedUsername]
                                                fontSize:LOGIN_VIEW_LABEL_FONT_SIZE
                                                andColor:[UIColor skyBlueColor]
                                         centerXPosition:false];
    
    self.usernameTextField = [self setUpUserDataTextFieldAtPositionX:LOGIN_VIEW_TEXTFIELD_POSITION_X
                                                           positionY:[self calculateTextFieldPositionYFromLabel:usernameLabel]
                                                               width:self.contentView.frame.size.width - LOGIN_VIEW_TEXTFIELD_POSITION_X - 2*LOGIN_VIEW_PADDING
                                                           andHeight:LOGIN_VIEW_TEXTFIELD_HEIGHT];
    
    NSString *userName = @"";
    NSData *usernameData = [self.keychain find:kcUsername];
    if(usernameData) {
        userName = [[NSString alloc] initWithData:usernameData encoding:NSUTF8StringEncoding];
    }
    [self.usernameTextField setText:userName];
}

- (void)initPasswordViewElements
{
    UILabel *passwordLabel = [self setUpLabelAtPositionX:2*LOGIN_VIEW_PADDING
                                               positionY:LOGIN_VIEW_PASSWORD_LABEL_POSITION_Y
                                                withText:[NSString stringWithFormat:@"%@:", (NSString*)kLocalizedPassword]
                                                fontSize:LOGIN_VIEW_LABEL_FONT_SIZE
                                                andColor:[UIColor skyBlueColor]
                                         centerXPosition:false];
    
    self.passwordTextField = [self setUpUserDataTextFieldAtPositionX:LOGIN_VIEW_TEXTFIELD_POSITION_X
                                                           positionY:[self calculateTextFieldPositionYFromLabel:passwordLabel]
                                                               width:self.contentView.frame.size.width - LOGIN_VIEW_TEXTFIELD_POSITION_X - 2*LOGIN_VIEW_PADDING
                                                           andHeight:LOGIN_VIEW_TEXTFIELD_HEIGHT];
    [self.passwordTextField setSecureTextEntry:YES];
    
    NSString *password = @"";
    NSData *passwordData = [self.keychain find:kcPassword];
    if(passwordData) {
        password = [[NSString alloc] initWithData:passwordData encoding:NSUTF8StringEncoding];
    }
    [self.passwordTextField setText:password];
}

- (void)initEmailViewElements
{
    UILabel *emailLabel = [self setUpLabelAtPositionX:2*LOGIN_VIEW_PADDING
                                            positionY:LOGIN_VIEW_EMAIL_LABEL_POSITION_Y
                                             withText:[NSString stringWithFormat:@"%@:", (NSString*)kLocalizedEmail]
                                             fontSize:LOGIN_VIEW_LABEL_FONT_SIZE
                                             andColor:[UIColor skyBlueColor]
                                      centerXPosition:false];
    
    self.emailTextField = [self setUpUserDataTextFieldAtPositionX:LOGIN_VIEW_TEXTFIELD_POSITION_X
                                                        positionY:[self calculateTextFieldPositionYFromLabel:emailLabel]
                                                            width:self.contentView.frame.size.width - LOGIN_VIEW_TEXTFIELD_POSITION_X - 2*LOGIN_VIEW_PADDING
                                                        andHeight:LOGIN_VIEW_TEXTFIELD_HEIGHT];
    
    [self.emailTextField setKeyboardType:UIKeyboardTypeEmailAddress];
    
    NSString *userEmail = @"";
    NSData *emailData = [self.keychain find:kcEmail];
    if(emailData) {
        userEmail = [[NSString alloc] initWithData:emailData encoding:NSUTF8StringEncoding];
    }
    [self.emailTextField setText:userEmail];
}

- (void)initActionButtons
{
    CGFloat beginPositionY = self.emailTextField.frame.origin.y + self.emailTextField.frame.size.height + 2*LOGIN_VIEW_PADDING;
    CGFloat endPositionY = beginPositionY + 2*LOGIN_VIEW_LABEL_FONT_SIZE;
    
    [self addHorizontalBorderLineAtY:beginPositionY
                               Width:self.contentView.frame.size.width
                       withLineWidth:LOGIN_VIEW_STANDARD_LINEWIDTH
                            andColor:[UIColor skyBlueColor]];
    
    [self setUpButtonWithCenterAtPositionX:self.contentView.frame.size.width/4
                                 positionY:beginPositionY + (endPositionY - beginPositionY)/2
                                      name:kLocalizedCancel
                                  selector:@selector(cancel)];
    
    self.loginButton = [self setUpButtonWithCenterAtPositionX:3*self.contentView.frame.size.width/4
                                 positionY:beginPositionY + (endPositionY - beginPositionY)/2
                                      name:kLocalizedLogin
                                  selector:@selector(loginAction)];
    
    [self addHorizontalBorderLineAtY:endPositionY
                               Width:self.contentView.frame.size.width
                       withLineWidth:LOGIN_VIEW_STANDARD_LINEWIDTH
                            andColor:[UIColor skyBlueColor]];
    
    //add button separator line
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake([Util screenWidth] / 2, beginPositionY)];
    [path addLineToPoint:CGPointMake([Util screenWidth] / 2, endPositionY)];
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = [path CGPath];
    shapeLayer.strokeColor = [[UIColor skyBlueColor] CGColor];
    shapeLayer.lineWidth = LOGIN_VIEW_STANDARD_LINEWIDTH;
    shapeLayer.fillColor = [[UIColor clearColor] CGColor];
    [self.view.layer addSublayer:shapeLayer];
    
}

- (void)initForgotPasswordButton
{
    UIButton *forgotButton = [self setUpButtonWithCenterAtPositionX:self.contentView.frame.size.width/2
                                                          positionY:LOGIN_VIEW_FORGOTTEN_PWD_POSITION_Y
                                                               name:kLocalizedForgotPassword
                                                           selector:nil];
    
    [self addLinkButton:forgotButton];
    [self.view addSubview:forgotButton];
    
    [self addHorizontalBorderLineAtY:LOGIN_VIEW_FORGOTTEN_PWD_POSITION_Y + LOGIN_VIEW_LABEL_FONT_SIZE
                               Width:self.contentView.frame.size.width
                       withLineWidth:LOGIN_VIEW_STANDARD_LINEWIDTH
                            andColor:[UIColor skyBlueColor]];
}

- (void)initTermsOfUse
{
    CGFloat beginPositionY = LOGIN_VIEW_FORGOTTEN_PWD_POSITION_Y + LOGIN_VIEW_LABEL_FONT_SIZE + LOGIN_VIEW_PADDING;
    
    UILabel *termsOfUseLabel = [self setUpLabelAtPositionX:self.contentView.frame.size.width/2
                                                 positionY:beginPositionY
                                                  withText:kLocalizedTermsAgreementPart
                                                  fontSize:3*LOGIN_VIEW_LABEL_FONT_SIZE/4
                                                  andColor:[UIColor skyBlueColor]
                                           centerXPosition:true];
    
    UIButton *termsOfUseButton = [self setUpButtonWithCenterAtPositionX:self.contentView.frame.size.width/2
                                                              positionY:beginPositionY + termsOfUseLabel.frame.size.height + 2*LOGIN_VIEW_PADDING
                                                                   name:kLocalizedTermsOfUse
                                                               selector:nil];
    
    [self addLinkButton:termsOfUseButton];
    [self.view addSubview:termsOfUseButton];
}


#pragma mark Helper
- (CGFloat)calculateTextFieldPositionYFromLabel:(UILabel*)label
{
    //Calculate the position y for textfield such that the middle of the textfield is the same as the middle of the label
    return label.frame.origin.y + label.frame.size.height/2 - LOGIN_VIEW_TEXTFIELD_HEIGHT/2;
}

- (void)addHorizontalBorderLineAtY:(CGFloat)positionX Width:(CGFloat)width withLineWidth:(CGFloat)lineWidth andColor:(UIColor*)color
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake((self.contentView.frame.size.width/2 - width/2), positionX)];
    [path addLineToPoint:CGPointMake(width, positionX)];
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = [path CGPath];
    shapeLayer.strokeColor = [color CGColor];
    shapeLayer.lineWidth = lineWidth;
    shapeLayer.fillColor = [[UIColor clearColor] CGColor];
    [self.view.layer addSublayer:shapeLayer];
}

-(UILabel*)setUpLabelAtPositionX:(CGFloat)x positionY:(CGFloat)y withText:(NSString*)text fontSize:(CGFloat)fontSize andColor:(UIColor*)color centerXPosition:(BOOL)inCenter
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0,0,0,0)];
    [label setTextColor:color];
    [label setText:text];
    [label setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:fontSize]];
    [label sizeToFit];
    
    if(inCenter)
    {
        x = x - label.frame.size.width/2;
    }
    
    label.frame = CGRectMake(x,y,label.frame.size.width,label.frame.size.height);
    label.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label];
    
    return label;
}

- (UITextField*)setUpUserDataTextFieldAtPositionX:(CGFloat)x positionY:(CGFloat)y width:(CGFloat)width andHeight:(CGFloat)height
{
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(x,y,width,height)];
    textField.textColor = [UIColor lightOrangeColor];
    textField.backgroundColor = [UIColor whiteColor];
    [textField setBorderStyle:UITextBorderStyleRoundedRect];
    [textField setAutocorrectionType:UITextAutocorrectionTypeNo];
    [textField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [textField setKeyboardType:UIKeyboardTypeDefault];
    [self.view addSubview:textField];
    
    return textField;
}

-(UIButton*)setUpButtonWithCenterAtPositionX:(CGFloat)x positionY:(CGFloat)y name:(NSString*)name selector:(SEL)selector
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setTitle:name forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:LOGIN_VIEW_LABEL_FONT_SIZE]];
    [button.titleLabel setTextColor:[UIColor orangeColor]];
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    [button sizeToFit];
    button.frame = CGRectMake((x - button.frame.size.width/2), (y - button.frame.size.height/2), button.frame.size.width, button.frame.size.height);
    [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    return button;
}

- (void)addLinkButton:(UIButton *)button
{
    [button setTitleColor:[UIColor lightOrangeColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(openURLAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView insertSubview:button belowSubview:self.bodyTextView];
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

-(void)addOrUpdateKeychainItem:(NSString*)key withData:(NSString*)dataString
{
    NSData * value = [dataString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSData *existingData = [self.keychain find:key];
    if (existingData == nil) {
        [self.keychain insert:key :value];
        NSDebug(@"No existing entry in keychain for %@", key);
        
    } else {
        [self.keychain update:key :value];
        NSDebug(@"Updated entry in keychain for %@", key);
    }
}


#pragma mark Actions
-(void)cancel
{
    [self.delegate dismissPopupWithCode:NO];
}

-(void)loginAction
{
    if ([self.usernameTextField.text isEqualToString:@""]) {
        [Util alertWithText:kLocalizedLoginUsernameNecessary];
        return;
    } else if (![self validPassword:self.passwordTextField.text]) {
        [Util alertWithText:kLocalizedLoginPasswordNotValid];
        return;
    } else if ([self.emailTextField.text isEqualToString:@""] || ![self NSStringIsValidEmail:self.emailTextField.text]) {
        [Util alertWithText:kLocalizedLoginEmailNotValid];
        return;
    }
    
    [self loginAtServerWithUsername:self.usernameTextField.text
                        andPassword:self.passwordTextField.text
                           andEmail:self.emailTextField.text];
}

- (void)loginAtServerWithUsername:(NSString*)username andPassword:(NSString*)password andEmail:(NSString*)email
{
    NSDebug(@"Login started with username:%@ and password:%@ and email:%@", username, password, email);
    // reset data
    self.data = nil;
    self.data = [[NSMutableData alloc] init];
    
    //Example URL: https://pocketcode.org/api/loginOrRegister/loginOrRegister.json?registrationUsername=MaxMuster&registrationPassword=MyPassword
    //For testing use: https://catroid-test.catrob.at/api/loginOrRegister/loginOrRegister.json?registrationUsername=MaxMuster&registrationPassword=MyPassword
    
    BOOL useTestServer = [[NSUserDefaults standardUserDefaults] boolForKey:kUseTestServerForUploadAndLogin];
    NSString *uploadUrl = useTestServer ? kTestLoginOrRegisterUrl : kLoginOrRegisterUrl;
    NSString *urlString = [NSString stringWithFormat:@"%@/%@", uploadUrl, (NSString*)kConnectionLoginOrRegister];
    
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
    
    // close form
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", httpBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    // set request body
    [request setHTTPBody:body];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[body length]];
    [request addValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    self.connection = connection;
    
    [self.connection start];
    
    if(self.connection) {
        NSDebug(@"Connection Successful");
        [self setEnableActivityIndicator:YES];
        self.loginButton.enabled = NO;
    } else {
        NSDebug(@"Connection could not be established");
        [Util alertWithText:kLocalizedNoInternetConnectionAvailable];
    }
}


#pragma mark - NSURLConnection Delegates
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData*)data
{
    if (self.connection == connection) {
        NSDebug(@"Received Data from server");
        [self.data appendData:data];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if(connection == self.connection) {
        [self setEnableActivityIndicator:NO];
        NSDebug(@"NSURLConnection ERROR: %@", error);
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if (self.connection == connection) {
        NSDebug(@"Finished loading");
        [self setEnableActivityIndicator:NO];
        
        NSError *error = nil;
        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:self.data options:kNilOptions error:&error];
        NSString *statusCode = [NSString stringWithFormat:@"%@", [dictionary valueForKey:statusCodeTag]];
        NSDebug(@"StatusCode is %@", statusCode);
        
        if ([statusCode isEqualToString:statusCodeOK] || [statusCode  isEqualToString:statusCodeRegistrationOK]) {
            
            if ([statusCode isEqualToString:statusCodeRegistrationOK]) {
                [Util alertWithText:kLocalizedRegistrationSuccessfull];
            }
            
            NSDebug(@"Login successful");
            NSString *token = [NSString stringWithFormat:@"%@", [dictionary valueForKey:tokenTag]];
            NSDebug(@"Token is %@", token);
            
            //save username, password and email in keychain and token in nsuserdefaults
            [[NSUserDefaults standardUserDefaults] setBool:true forKey:kUserIsLoggedIn];
            [[NSUserDefaults standardUserDefaults] setValue:token forKey:kUserLoginToken];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [self addOrUpdateKeychainItem:kcUsername withData:self.userName];
            [self addOrUpdateKeychainItem:kcPassword withData:self.password];
            [self addOrUpdateKeychainItem:kcEmail withData:self.userEmail];
            
            [self.delegate dismissPopupWithCode:YES];
            
        } else {
            self.loginButton.enabled = YES;
            
            NSString *serverResponse = [dictionary valueForKey:answerTag];
            NSDebug(@"Error: %@", serverResponse);
            [Util alertWithText:serverResponse];
        }
        
        self.data = nil;
        self.connection = nil;
    }
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

- (void)setEnableActivityIndicator:(BOOL)enabled
{
    [UIApplication.sharedApplication setNetworkActivityIndicatorVisible:enabled];
}


@end
