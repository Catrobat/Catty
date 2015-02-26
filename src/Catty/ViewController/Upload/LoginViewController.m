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

//web status codes are on: https://github.com/Catrobat/Catroweb/blob/master/statusCodes.php

#import "LoginViewController.h"
#import "NetworkDefines.h"
#import "ProgramDefines.h"
#import "UIColor+CatrobatUIColorExtensions.h"
#import "UIImage+CatrobatUIImageExtensions.h"
#import "LanguageTranslationDefines.h"
#import "SegueDefines.h"
#import "Util.h"

static NSString *const usernameParameterID = @"registrationUsername";
static NSString *const passwordParameterID = @"registrationPassword";
static NSString *const registrationEmailParameterID = @"registrationEmail";
static NSString *const registrationCountryParameterID = @"registrationCountry";

bool useTestUrl = true;

@interface LoginViewController ()
@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSMutableData *data;
@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = kLocalizedUpload;
    self.view.backgroundColor = [UIColor darkBlueColor];
    
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Bold" size:10.0f],
                                                        NSForegroundColorAttributeName : [UIColor lightOrangeColor]
                                                        } forState:UIControlStateSelected];

    //[self.usernameLabel setText:[NSString stringWithFormat:@"%@", kLocalizedUsername]];
    [self.usernameLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:16.0f]];
    self.usernameLabel.textColor = [UIColor lightOrangeColor];
    //[self.passwordLabel setText:kLocalizedPassword];
    [self.passwordLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:16.0f]];
    self.passwordLabel.textColor = [UIColor lightOrangeColor];
    [self.emailLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:16.0f]];
    self.emailLabel.textColor = [UIColor lightOrangeColor];
    
    [self.loginButton setTitle:kLocalizedLogin forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - NSURLConnection Delegates
- (IBAction)loginButtonClicked:(id)sender
{
    if ([self.usernameTextField.text isEqualToString:@""]) {
        [Util alertWithText:@"Username is necessary!"];
        return;
    } else if ([self.passwordTextField.text isEqualToString:@""]) {
        [Util alertWithText:@"Password is necessary!"];
        return;
    } else if ([self.emailTextField.text isEqualToString:@""]) {
        [Util alertWithText:@"Email is necessary!"];
        return;
    }
    
    [self loginAtServerWithUsername:self.usernameTextField.text
                        andPassword:self.passwordTextField.text
                           andEmail:self.emailTextField.text];
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
    
    NSString *uploadUrlBase = useTestUrl ? kTestLoginOrRegisterUrl : kLoginOrRegisterUrl;
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
            //save username, password in keychain and token in nsuserdefaults
            [self performSegueWithIdentifier:kSegueToUpload sender:self];
            
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

- (void)loadingIndicator:(BOOL)value
{
    UIApplication* app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = value;
}


 #pragma mark - Navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
}

@end
