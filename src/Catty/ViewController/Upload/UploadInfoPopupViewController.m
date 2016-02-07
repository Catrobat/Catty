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

//Warning: TestServer Uploads are restricted in size (about 1MB)!!!

#import "UploadInfoPopupViewController.h"
#import "UIColor+CatrobatUIColorExtensions.h"
#import "LanguageTranslationDefines.h"
#import <QuartzCore/QuartzCore.h>
#import "NetworkDefines.h"
#import "ProgramDefines.h"
#import "SegueDefines.h"
#import "Util.h"
#import "FileManager.h"
#import "AppDelegate.h"
#import "CatrobatAlertController.h"
#import "NetworkDefines.h"
#import "ProgramDefines.h"
#import "UIImage+CatrobatUIImageExtensions.h"
#import "LanguageTranslationDefines.h"
#import "NSData+Hashes.h"
#import "KeychainUserDefaultsDefines.h"
#import "JNKeychain.h"
#import "BDKNotifyHUD.h"
#import "LoadingView.h"

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

const CGFloat LABEL_FONT_SIZE = 16.0f;
const CGFloat TEXTFIELD_HEIGHT = 30.0f;
const CGFloat PADDING = 5.0f;

@interface UploadInfoViewController ()
@property (nonatomic, strong) NSData *zipFileData;
@property (nonatomic) CGFloat currentHeight;
@property (strong, nonatomic) NSURLSession *session;
@property (strong, nonatomic) NSURLSessionDataTask *dataTask;
@property (strong, nonatomic) LoadingView *loadingView;

@end

@implementation UploadInfoViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
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


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor backgroundColor];
    self.currentHeight = 100;
    [self initProgramNameViewElements];
    [self initSizeViewElements];
    [self initDescriptionViewElements];
    [self initActionButtons];
    self.navigationController.toolbarHidden = NO;
    self.navigationController.title = self.title = kLocalizedUpload;
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissView)];
    self.navigationItem.rightBarButtonItem = rightButton;
    self.navigationController.toolbarHidden = YES;
    [self.programNameTextField becomeFirstResponder];
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self
                           selector:@selector(uploadAction)
                               name:kReadyToUpload
                             object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Initialization

- (void)initProgramNameViewElements
{
    self.programNamelabel.frame = CGRectMake(2*PADDING, self.currentHeight, 100, self.programNamelabel.frame.size.height);
    [self.programNamelabel setTextColor:[UIColor globalTintColor]];
    [self.programNamelabel setText:kLocalizedName];
    [self.programNamelabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:LABEL_FONT_SIZE]];
    [self.programNamelabel sizeToFit];


    
    self.programNameTextField.frame = CGRectMake(self.view.frame.size.width/3.0f, self.currentHeight, 2*self.view.frame.size.width/3.0f -20, TEXTFIELD_HEIGHT);
    
    self.programNameTextField.textColor = [UIColor textTintColor];
    self.programNameTextField.backgroundColor = [UIColor whiteColor];
    [self.programNameTextField setBorderStyle:UITextBorderStyleRoundedRect];
    [self.programNameTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
    [self.programNameTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [self.programNameTextField setKeyboardType:UIKeyboardTypeDefault];

    
    if(self.program.header.programName) {
        self.programNameTextField.text = self.program.header.programName;
    }
    self.currentHeight += self.programNameTextField.frame.size.height+4*PADDING;
    
}

- (void)initSizeViewElements
{
    self.sizeLabel.frame = CGRectMake(2*PADDING, self.currentHeight, 100, self.sizeLabel.frame.size.height);
    [self.sizeLabel setTextColor:[UIColor globalTintColor]];
    [self.sizeLabel setText:kLocalizedSize];
    [self.sizeLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:LABEL_FONT_SIZE]];
    [self.sizeLabel sizeToFit];
    
    AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    self.zipFileData = nil;
    self.zipFileData = [appDelegate.fileManager zipProgram:self.program];
    NSString *zipFileSizeString = @"";
    
    if(!self.zipFileData) {
        NSDebug(@"ZIPing program files failed");
        [self.delegate dismissPopupWithCode:NO];
    } else {
        zipFileSizeString = [self adaptSizeRepresentationString:self.zipFileData.length];
    }
    
    self.sizeValueLabel.frame = CGRectMake(self.view.frame.size.width/3.0f, self.currentHeight, 100, self.sizeValueLabel.frame.size.height);
    [self.sizeValueLabel setTextColor:[UIColor textTintColor]];
    [self.sizeValueLabel setText:zipFileSizeString];
    [self.sizeValueLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:LABEL_FONT_SIZE]];
    [self.sizeValueLabel sizeToFit];
    self.currentHeight += 4*PADDING +self.sizeLabel.frame.size.height;
}

- (void)initDescriptionViewElements
{

    self.descriptionLabel.frame = CGRectMake(2*PADDING, self.currentHeight, 100, self.descriptionLabel.frame.size.height);
    [self.descriptionLabel setTextColor:[UIColor globalTintColor]];
    [self.descriptionLabel setText:kLocalizedDescription];
    [self.descriptionLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:LABEL_FONT_SIZE]];
    [self.descriptionLabel sizeToFit];
    
    self.descriptionTextView.frame = CGRectMake(self.view.frame.size.width/3.0f,self.currentHeight,2*self.view.frame.size.width/3.0f -20,100);
    
    self.descriptionTextView.textColor = [UIColor textTintColor];
    self.descriptionTextView.keyboardAppearance  = UIKeyboardAppearanceDefault;
    self.descriptionTextView.backgroundColor = [UIColor whiteColor];
    [self.descriptionTextView setAutocorrectionType:UITextAutocorrectionTypeNo];
    [self.descriptionTextView setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [self.descriptionTextView setKeyboardType:UIKeyboardTypeDefault];
    
    if(self.program.header.programDescription) {
        self.descriptionTextView.text = self.program.header.programDescription;
    }
    self.currentHeight += self.descriptionTextView.frame.size.height + 4*PADDING;
}

- (void)initActionButtons
{
    [self.uploadButton setTitle:kLocalizedUpload forState:UIControlStateNormal];
    [self.uploadButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:LABEL_FONT_SIZE+4]];
    [self.uploadButton.titleLabel setTextColor:[UIColor buttonHighlightedTintColor]];
    [self.uploadButton setBackgroundColor:[UIColor globalTintColor]];
    self.uploadButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.uploadButton sizeToFit];
    self.uploadButton.frame = CGRectMake(0, self.currentHeight, self.view.frame.size.width, self.uploadButton.frame.size.height);
    [self.uploadButton addTarget:self action:@selector(checkProgramAction) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark Helpers


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
    [self.dataTask cancel];
    [self.delegate dismissPopupWithCode:NO];
}

-(void)checkProgramAction
{
    if ([self.programNameTextField.text isEqualToString:@""]) {
        [Util alertWithText:kLocalizedUploadProgramNecessary];
        return;
    }
    //RemixOF
    if(self.program.header.url && self.program.header.userHandle){
        self.program.header.remixOf = self.program.header.url;
        self.program.header.url = nil;
        self.program.header.userHandle = nil;
    }
    [self.program renameToProgramName:self.programNameTextField.text];
    self.program.header.programDescription = self.descriptionTextView.text;
    [self.program saveToDiskWithNotification:YES];
    if (!self.loadingView) {
        self.loadingView = [[LoadingView alloc] init];
        //        _loadingView.backgroundColor = [UIColor globalTintColor];
        [self.view addSubview:self.loadingView];
    }
    [self.loadingView show];
    for (UIView *view in self.view.subviews) {
        if (![view isKindOfClass:[LoadingView class]]) {
            view.alpha = 0.3f;
        }
    }
    self.view.userInteractionEnabled = NO;
    self.navigationItem.rightBarButtonItem.enabled = NO;
}

-(void)uploadAction
{

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
        [self setFormDataParameter:userEmailTag withData:[[[NSUserDefaults standardUserDefaults] valueForKey:kcEmail] dataUsingEncoding:NSUTF8StringEncoding] forHTTPBody:body];
        
        //checksum
        [self setFormDataParameter:fileChecksumParameterTag withData:[checksum dataUsingEncoding:NSUTF8StringEncoding] forHTTPBody:body];
        
        
        NSString*token = [JNKeychain loadValueForKey:kUserLoginToken];
        //token
        [self setFormDataParameter:tokenParameterTag withData:[token dataUsingEncoding:NSUTF8StringEncoding] forHTTPBody:body];
        
        //Username
        [self setFormDataParameter:userNameTag withData:[[[NSUserDefaults standardUserDefaults] valueForKey:kcUsername] dataUsingEncoding:NSUTF8StringEncoding] forHTTPBody:body];
        
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
        
        self.dataTask = [self.session dataTaskWithRequest:request  completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            [self enableUploadView];
            if (error) {
                if (error.code != -999) {
                    NSLog(@"%@", error);
                }
                [self setEnableActivityIndicator:NO];
                
            } else {
                [self setEnableActivityIndicator:NO];
                
                NSError *error = nil;
                NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                NSString *statusCode = [NSString stringWithFormat:@"%@", [dictionary valueForKey:statusCodeTag]];
                NSDebug(@"StatusCode is %@", statusCode);
                
                if ([statusCode isEqualToString:statusCodeOK]) {
                    NSDebug(@"Upload successful");
                    
                        //Set unique Program-ID received from server
                    NSString* projectId = [NSString stringWithFormat:@"%@", [dictionary valueForKey:projectIDTag]];
                    self.program.header.programID = projectId;
                    [self.program saveToDiskWithNotification:YES];
                    
                        //Set new token but when? everytime is wrong
//                    NSString *newToken = [NSString stringWithFormat:@"%@", [dictionary valueForKey:tokenParameterTag]];
//                    [JNKeychain saveValue:newToken forKey:kUserLoginToken];
                    
                    [self showUploadSuccessfulView];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self dismissView];
                    });
                    
                    
                } else {
                    
                    NSString *serverResponse = [dictionary valueForKey:answerTag];
                    NSDebug(@"Error: %@", serverResponse);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [Util alertWithText:serverResponse];
                        [self.delegate dismissPopupWithCode:NO];
                    });
                    
                    if([statusCode isEqualToString:statusCodeTokenWrong]) {
                            //Token not valid
                        [[NSUserDefaults standardUserDefaults] setBool:false forKey:kUserIsLoggedIn];
                        
                        NSMutableArray *viewArray = [NSMutableArray arrayWithArray:self.parentViewController.navigationController.viewControllers];
                        [viewArray removeLastObject];
                        NSArray *newViewArray = [NSArray arrayWithArray:viewArray];
                        [self.parentViewController.navigationController setViewControllers:newViewArray animated:YES];
                    }
                    
                }
                

            }
        }];
        
        if (self.dataTask) {
            [self.dataTask resume];
        }

        
        if(self.dataTask) {
            NSDebug(@"Connection Successful");
            [self setEnableActivityIndicator:YES];
            self.uploadButton.enabled = NO;
        } else {
            NSDebug(@"Connection could not be established");
            [self enableUploadView];
            [Util alertWithTitle:kLocalizedNoInternetConnection andText:kLocalizedNoInternetConnectionAvailable];
        }
    } else {
        NSDebug(@"Could not build checksum");
        [self enableUploadView];
        [Util alertWithText:kLocalizedUploadProblem];
    }
}


- (void)setEnableActivityIndicator:(BOOL)enabled
{
    [UIApplication.sharedApplication setNetworkActivityIndicatorVisible:enabled];
}

-(void)dismissView
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)showUploadSuccessfulView
{
    BDKNotifyHUD *hud = [BDKNotifyHUD notifyHUDWithImage:[UIImage imageNamed:kBDKNotifyHUDCheckmarkImageName]
                                                    text:kLocalizedUploadSuccessful];
    hud.destinationOpacity = kBDKNotifyHUDDestinationOpacity;
    hud.center = CGPointMake(self.view.center.x, self.view.center.y + kBDKNotifyHUDCenterOffsetY);
    hud.tag = kUploadViewTag;
    [self.view addSubview:hud];
    [hud presentWithDuration:kBDKNotifyHUDPresentationDuration
                       speed:kBDKNotifyHUDPresentationSpeed
                      inView:self.view
                  completion:^{ [hud removeFromSuperview]; }];
}

-(void)enableUploadView
{
    [self.loadingView hide];
    self.view.alpha = 1.0f;
    self.view.userInteractionEnabled = YES;
    self.navigationItem.rightBarButtonItem.enabled = YES;
}


@end
