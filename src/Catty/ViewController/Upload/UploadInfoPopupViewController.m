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

//Warning: TestServer Uploads are restricted in size (about 1MB)!!!

#import "UploadInfoPopupViewController.h"
#import "UIColor+CatrobatUIColorExtensions.h"
#import "LanguageTranslationDefines.h"
#import <QuartzCore/QuartzCore.h>
#import "NetworkDefines.h"
#import "ProgramDefines.h"
#import "SegueDefines.h"
#import "UIColor+CatrobatUIColorExtensions.h"
#import "Util.h"
#import "FileManager.h"
#import "AppDelegate.h"
#import "CatrobatAlertView.h"
#import "LoginPopupViewController.h"

#import "NetworkDefines.h"
#import "ProgramDefines.h"
#import "UIColor+CatrobatUIColorExtensions.h"
#import "UIImage+CatrobatUIImageExtensions.h"
#import "LanguageTranslationDefines.h"
#import "NSData+Hashes.h"
#import "Keychain.h"
#import "KeychainDefines.h"

#define uploadParameterTag @"upload"                 //zip file with program
#define fileChecksumParameterTag @"fileChecksum"     //md5 hash
#define tokenParameterTag @"token"                   //registration token
#define programNameTag @"projectTitle"              //name of the program
#define programDescriptionTag @"projectDescription" //description of the project
#define userEmailTag @"userEmail"
#define userNameTag @"username"
#define deviceLanguageTag @"deviceLanguage"

#define statusCodeTag @"statusCode"
#define answerTag @"answer"
#define projectIDTag @"projectId"
#define statusCodeOK @"200"
#define statusCodeTokenWrong @"601"

//random boundary string
#define httpBoundary @"---------------------------98598263596598246508247098291---------------------------"

//web status codes are on: https://github.com/Catrobat/Catroweb/blob/master/statusCodes.php


@interface UploadInfoPopupViewController ()
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UITextView *bodyTextView;
@property (nonatomic, strong) UITextField *programnameTextField;
@property (nonatomic, strong) UITextField *sizeTextField;
@property (nonatomic, strong) UITextField *descriptionTextField;
@property (nonatomic, strong) UIButton *uploadButton;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) NSData *zipFileData;

@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSMutableData *data;
@property (nonatomic, strong) Keychain *keychain;

@end

@implementation UploadInfoPopupViewController

const CGFloat POPUP_FRAME_HEIGHT = 250.0f;
const CGFloat HEADER_FONT_SIZE = 20.0f;
const CGFloat LABEL_FONT_SIZE = 16.0f;
const CGFloat TEXTFIELD_HEIGHT = 30.0f;
const CGFloat PADDING = 5.0f;
const CGFloat NAME_LABEL_POSITION_Y = 30.0f;
const CGFloat SIZE_LABEL_POSITION_Y = 95.0f;
const CGFloat DESCRIPTION_LABEL_POSITION_Y = 140.0f;
const CGFloat STANDARD_LINEWIDTH = 2.0f;


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
    self.view.frame = CGRectMake(0,0, [Util screenWidth]-10, POPUP_FRAME_HEIGHT);
    self.view.backgroundColor = [UIColor backgroundColor];
    self.keychain = [[Keychain alloc] initWithService:kcServiceName withGroup:nil];
    [self initLoginHeader];
    [self initProgramNameViewElements];
    [self initSizeViewElements];
    [self initDescriptionViewElements];
    [self initActionButtons];
    [self.programnameTextField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Initialization
- (void)initLoginHeader
{
    UILabel *uploadHeader = [self setUpLabelAtPositionX:self.contentView.frame.size.width/2
                                              positionY:PADDING
                                               withText:kUploadSelectedProgram
                                               andColor:[UIColor skyBlueColor]
                                     centeringXPosition:true];
    
    [self addHorizontalBorderLineAtY:(uploadHeader.frame.size.height + 2*PADDING)
                               Width:self.contentView.frame.size.width
                       withLineWidth:STANDARD_LINEWIDTH
                            andColor:[UIColor skyBlueColor]];
}

- (void)initProgramNameViewElements
{
    UILabel *programnameLabel = [self setUpLabelAtPositionX:2*PADDING
                                                  positionY:NAME_LABEL_POSITION_Y
                                                   withText:kLocalizedName
                                                   andColor:[UIColor skyBlueColor]
                                         centeringXPosition:false];
    
    [self addHorizontalBorderLineAtY:(NAME_LABEL_POSITION_Y + programnameLabel.frame.size.height/2 + 2*PADDING)
                               Width:self.contentView.frame.size.width - 4*PADDING
                       withLineWidth:1.5f
                            andColor:[UIColor grayColor]];
    
    self.programnameTextField =
    [self setUpProgramDataTextFieldAtPositionX:2*PADDING
                                     positionY:NAME_LABEL_POSITION_Y + programnameLabel.frame.size.height + 2*PADDING
                                         width:(self.contentView.frame.size.width - 6*PADDING)
                                     andHeight:TEXTFIELD_HEIGHT];
    
    if(self.program.header.programName) {
        self.programnameTextField.text = self.program.header.programName;
    }
}

- (void)initSizeViewElements
{
    UILabel *sizeNameLabel = [self setUpLabelAtPositionX:2*PADDING
                                               positionY:SIZE_LABEL_POSITION_Y
                                                withText:kLocalizedSize
                                                andColor:[UIColor skyBlueColor]
                                      centeringXPosition:false];
    
    [self addHorizontalBorderLineAtY:(SIZE_LABEL_POSITION_Y + sizeNameLabel.frame.size.height/2 + 2*PADDING)
                               Width:self.contentView.frame.size.width - 4*PADDING
                       withLineWidth:1.5f
                            andColor:[UIColor grayColor]];
    
    AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    self.zipFileData = nil;
    self.zipFileData = [appDelegate.fileManager zipProgram:self.program];
    NSString *zipFileSizeString = @"";
    
    if(!self.zipFileData) {
        NSLog(@"ZIPing program files failed");
        [self.delegate dismissPopupWithCode:NO];
    } else {
        zipFileSizeString = [self adaptSizeRepresentationString:self.zipFileData.length];
    }
    
    [self setUpLabelAtPositionX:2*PADDING
                      positionY:SIZE_LABEL_POSITION_Y + sizeNameLabel.frame.size.height + 1*PADDING
                       withText:zipFileSizeString
                       andColor:[UIColor lightOrangeColor]
             centeringXPosition:false];
}

- (void)initDescriptionViewElements
{
    UILabel *descriptionLabel = [self setUpLabelAtPositionX:2*PADDING
                                                  positionY:DESCRIPTION_LABEL_POSITION_Y
                                                   withText:kLocalizedDescription
                                                   andColor:[UIColor skyBlueColor]
                                         centeringXPosition:false];
    
    [self addHorizontalBorderLineAtY:(DESCRIPTION_LABEL_POSITION_Y + descriptionLabel.frame.size.height/2 + 2*PADDING)
                               Width:self.contentView.frame.size.width - 4*PADDING
                       withLineWidth:1.5f
                            andColor:[UIColor grayColor]];
    
    self.descriptionTextField =
    [self setUpProgramDataTextFieldAtPositionX:2*PADDING
                                     positionY:DESCRIPTION_LABEL_POSITION_Y + descriptionLabel.frame.size.height + 2*PADDING
                                         width:(self.contentView.frame.size.width - 6*PADDING)
                                     andHeight:TEXTFIELD_HEIGHT];
    
    if(self.program.header.programDescription) {
        self.descriptionTextField.text = self.program.header.programDescription;
    }
}

- (void)initActionButtons
{
    CGFloat buttonSectionBeginY = self.descriptionTextField.frame.origin.y + self.descriptionTextField.frame.size.height + 2*PADDING;
    
    [self addHorizontalBorderLineAtY:buttonSectionBeginY
                               Width:self.contentView.frame.size.width
                       withLineWidth:STANDARD_LINEWIDTH
                            andColor:[UIColor skyBlueColor]];
    
    CGFloat buttonPositionY = buttonSectionBeginY + ((self.contentView.frame.size.height - buttonSectionBeginY)/2);
    
    
    self.cancelButton = [self setUpButtonWithCenterAtPositionX:self.contentView.frame.size.width/4
                                                     positionY:buttonPositionY
                                                          name:kLocalizedCancel
                                                      selector:@selector(cancel)];
    
    self.uploadButton = [self setUpButtonWithCenterAtPositionX:3*self.contentView.frame.size.width/4
                                                     positionY:buttonPositionY
                                                          name:kLocalizedUpload
                                                      selector:@selector(uploadAction)];
    
    
    //add button separator line
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake([Util screenWidth] / 2, buttonSectionBeginY)];
    [path addLineToPoint:CGPointMake([Util screenWidth] / 2, self.contentView.frame.size.height)];
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = [path CGPath];
    shapeLayer.strokeColor = [[UIColor skyBlueColor] CGColor];
    shapeLayer.lineWidth = 2.0;
    shapeLayer.fillColor = [[UIColor clearColor] CGColor];
    [self.view.layer addSublayer:shapeLayer];
    
}

#pragma mark Helpers
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

-(UILabel*)setUpLabelAtPositionX:(CGFloat)x positionY:(CGFloat)y withText:(NSString*)text andColor:(UIColor*)color centeringXPosition:(BOOL)inCenter
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0,0,0,0)];
    [label setTextColor:color];
    [label setText:text];
    [label setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:LABEL_FONT_SIZE]];
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

- (UITextField*)setUpProgramDataTextFieldAtPositionX:(CGFloat)x positionY:(CGFloat)y width:(CGFloat)width andHeight:(CGFloat)height
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
    [button.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:LABEL_FONT_SIZE]];
    [button.titleLabel setTextColor:[UIColor lightOrangeColor]];
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    [button sizeToFit];
    button.frame = CGRectMake((x - button.frame.size.width/2), (y - button.frame.size.height/2), button.frame.size.width, button.frame.size.height);
    [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    return button;
}

-(void)setFormDataParameter:(NSString*)parameterID withData:(NSData*)data forHTTPBody:(NSMutableData*)body
{
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", httpBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSString *parameterString = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", parameterID];
    [body appendData:[parameterString dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[NSData dataWithData:data]];
    [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
}

-(void)setAttachmentParameter:(NSString*)parameterID withData:(NSData*)data forHTTPBody:(NSMutableData*)body
{
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", httpBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSString *parameterString = [NSString stringWithFormat:@"Content-Disposition: attachment; name=\"%@\"; filename=\".zip\" \r\n", parameterID];
    [body appendData:[parameterString dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    [body appendData:[NSData dataWithData:data]];
    [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
}

-(NSString*)adaptSizeRepresentationString:(NSUInteger)size
{
    CGFloat sizeFloat = (CGFloat)size;
    
    int divisionAmount = 0;
    NSArray *tokens = [NSArray arrayWithObjects:@"bytes",@"KB",@"MB",@"GB",@"TB",nil];
    
    while (sizeFloat > 1024) {
        sizeFloat /= 1024;
        divisionAmount++;
    }
    
    return [NSString stringWithFormat:@"%.2f %@", sizeFloat, [tokens objectAtIndex:divisionAmount]];
}

#pragma mark Actions
-(void)cancel
{
    [self.connection cancel];
    [self.delegate dismissPopupWithCode:NO];
}

-(void)uploadAction
{
    if ([self.programnameTextField.text isEqualToString:@""]) {
        [Util alertWithText:kLocalizedUploadProgramNecessary];
        return;
    }
    
    //reset data
    self.data = nil;
    self.data = [[NSMutableData alloc] init];
    
    NSString *checksum = nil;
    if (self.zipFileData) {
        checksum = [self.zipFileData md5];
    }
    
    if (checksum) {
        NSDebug(@"Upload started for file:%@ with checksum:%@", self.program.header.programName, checksum);
        
        //Upload example URL: https://pocketcode.org/api/upload/upload.json?upload=ZIPFile&fileChecksum=MD5&token=loginToken
        //For testing use: https://catroid-test.catrob.at/api/upload/upload.json?upload=ZIPFile&fileChecksum=MD5&token=loginToken
        
        BOOL useTestServer = [[NSUserDefaults standardUserDefaults] boolForKey:kUseTestServerForUploadAndLogin];
        NSString *uploadUrl = useTestServer ? kTestUploadUrl : kUploadUrl;
        NSString *urlString = [NSString stringWithFormat:@"%@/%@", uploadUrl, (NSString*)kConnectionUpload];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:[NSURL URLWithString:urlString]];
        [request setHTTPMethod:@"POST"];
        
        NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", httpBoundary];
        [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
        
        NSMutableData *body = [NSMutableData data];
        
        //Program Name
        [self setFormDataParameter:programNameTag withData:[self.program.header.programName dataUsingEncoding:NSUTF8StringEncoding] forHTTPBody:body];
        
        //Program Description
        [self setFormDataParameter:programDescriptionTag withData:[self.program.header.programDescription dataUsingEncoding:NSUTF8StringEncoding] forHTTPBody:body];
        
        //User Email
        NSString *userEmail = @"";
        NSData *userEmailData = [self.keychain find:kcEmail];
        if(userEmailData) {
            userEmail = [[NSString alloc] initWithData:userEmailData encoding:NSUTF8StringEncoding];
            NSDebug(@"Email is %@", userEmail);
        } else {
            NSDebug(@"No email address found in keychain!");
        }
        [self setFormDataParameter:userEmailTag withData:[[[NSUserDefaults standardUserDefaults] valueForKey:userEmail] dataUsingEncoding:NSUTF8StringEncoding] forHTTPBody:body];
        
        //checksum
        [self setFormDataParameter:fileChecksumParameterTag withData:[checksum dataUsingEncoding:NSUTF8StringEncoding] forHTTPBody:body];
        
        //token
        [self setFormDataParameter:tokenParameterTag withData:[[[NSUserDefaults standardUserDefaults] valueForKey:kUserLoginToken] dataUsingEncoding:NSUTF8StringEncoding] forHTTPBody:body];
        
        //Username
        NSString *userName = @"";
        NSData *usernameData = [self.keychain find:kcUsername];
        if(usernameData) {
            userName = [[NSString alloc] initWithData:usernameData encoding:NSUTF8StringEncoding];
            NSDebug(@"Username is %@", userName);
        } else {
            NSDebug(@"No username found in keychain!");
        }
        [self setFormDataParameter:userNameTag withData:[[[NSUserDefaults standardUserDefaults] valueForKey:userName] dataUsingEncoding:NSUTF8StringEncoding] forHTTPBody:body];
        
        //Language
        [self setFormDataParameter:deviceLanguageTag withData:[[[NSLocale preferredLanguages] objectAtIndex:0] dataUsingEncoding:NSUTF8StringEncoding] forHTTPBody:body];
        
        //zip file
        [self setAttachmentParameter:uploadParameterTag withData:self.zipFileData forHTTPBody:body];
        
        
        // close form
        [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", httpBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
        // set request body
        [request setHTTPBody:body];
        
        NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[body length]];
        [request addValue:postLength forHTTPHeaderField:@"Content-Length"];
        
        self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        [self.connection start];
        
        if(self.connection) {
            NSDebug(@"Connection Successful");
            [self setEnableActivityIndicator:YES];
            self.uploadButton.enabled = NO;
        } else {
            NSLog(@"Connection could not be established");
            [Util alertWithText:kLocalizedNoInternetConnectionAvailable];
        }
    } else {
        NSLog(@"Could not build checksum");
        [Util alertWithText:kLocalizedUploadProblem];
    }
}

#pragma mark NSURLConnection Delegates
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData*)data
{
    NSDebug(@"Received Data from server");
    if (self.connection == connection) {
        [self.data appendData:data];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if (self.connection == connection) {
        [self setEnableActivityIndicator:NO];
        NSLog(@"NSURLConnection ERROR: %@", error);
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if (self.connection == connection) {
        NSDebug(@"Finished upload");
        [self setEnableActivityIndicator:NO];
        
        NSError *error = nil;
        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:self.data options:kNilOptions error:&error];
        NSString *statusCode = [NSString stringWithFormat:@"%@", [dictionary valueForKey:statusCodeTag]];
        NSDebug(@"StatusCode is %@", statusCode);
        
        if ([statusCode isEqualToString:statusCodeOK]) {
            NSDebug(@"Upload successful");
            
            //Set unique Program-ID received from server
            self.program.header.programID = [NSString stringWithFormat:@"%@", [dictionary valueForKey:projectIDTag]];
            [self.program saveToDisk];
            
            //Set new token
            NSString *newToken = [NSString stringWithFormat:@"%@", [dictionary valueForKey:tokenParameterTag]];
            [[NSUserDefaults standardUserDefaults] setValue:newToken forKey:kUserLoginToken];
            
            [self.delegate dismissPopupWithCode:YES];
            
        } else {
            [self.delegate dismissPopupWithCode:NO];
            NSString *serverResponse = [dictionary valueForKey:answerTag];
            NSDebug(@"Error: %@", serverResponse);
            [Util alertWithText:serverResponse];
            
            if([statusCode isEqualToString:statusCodeTokenWrong]) {
                //Token not valid
                [[NSUserDefaults standardUserDefaults] setBool:false forKey:kUserIsLoggedIn];
                
                NSMutableArray *viewArray = [NSMutableArray arrayWithArray:self.parentViewController.navigationController.viewControllers];
                [viewArray removeLastObject];
                NSArray *newViewArray = [NSArray arrayWithArray:viewArray];
                [self.parentViewController.navigationController setViewControllers:newViewArray animated:YES];
            }
        }
        
        self.data = nil;
        self.connection = nil;
    }
}

- (void)setEnableActivityIndicator:(BOOL)enabled
{
    [UIApplication.sharedApplication setNetworkActivityIndicatorVisible:enabled];
}


@end
