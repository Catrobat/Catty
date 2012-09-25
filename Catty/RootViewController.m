//
//  RootViewController.m
//  Catty
//
//  Created by Christof Stromberger on 19.09.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "RootViewController.h"
#import "Util.h"
#import "SSZipArchive.h"
#import "FileManager.h"
#import "CattyAppDelegate.h"

@interface RootViewController ()

@end

@implementation RootViewController

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

    //background image
    UIColor *background = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"startBackground"]];
    self.view.backgroundColor = background;    
    
    
    //load/init sample projects
    [self loadSampleProjects];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Load Sample Projects
- (void)loadSampleProjects {
    NSString *documentsDirectory = [Util applicationDocumentsDirectory];
    NSError *error;

    
    //temp
    [self deleteAllFilesFromDirectory:documentsDirectory];
    
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectory error:&error];
    [Util log:error];
    
    NSLog(@"Contents: %@", contents);
    
    //no entries found, init default
    if ([self isEmpty:contents]) {
        [self downloadSampleProjects];
    }
}

- (void)loadRocketProject {
//    NSString *linkToRocketProject = @"http://catroid.org/catroid/download/291.catrobat";
    NSString *linkToRocketProject = @"http://catroid.org/catroid/download/305.catrobat";


    //rocket project
    NSURL *rocketProjectURL = [NSURL URLWithString:linkToRocketProject];
    NSError *error;
    NSData *rocketProject = [NSData dataWithContentsOfURL:rocketProjectURL options:NSDataReadingMapped error:&error];
    [Util log:error];

    
    //path for temp file
    NSString *documentsDirectory = [Util applicationDocumentsDirectory];
    NSString *tempPath = [NSString stringWithFormat:@"%@/temp.zip", documentsDirectory];

    //writing to file
    [rocketProject writeToFile:tempPath atomically:YES];
    
    //path for storing file
//    NSString *storePath = [NSString stringWithFormat:@"%@/levels/RocketProject", documentsDirectory];
    NSString *storePath = [NSString stringWithFormat:@"%@/levels/Hunter", documentsDirectory];

    
    NSLog(@"Starting unzip");
    
    //unzip file
    [SSZipArchive unzipFileAtPath:tempPath toDestination:storePath];
    
    NSLog(@"Unzip finished");
    
    NSLog(@"Removing temp zip file");
    [[NSFileManager defaultManager] removeItemAtPath:tempPath error:&error];
    [Util log:error];
    
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectory error:&error];
    [Util log:error];
    NSLog(@"Contents: %@", contents);
}

- (void)loadCounterProject {
    NSString *linkToSecondProject = @"http://catroid.org/catroid/download/247.catrobat";
    
    
    //second project
    NSURL *counterProjectURL = [NSURL URLWithString:linkToSecondProject];
    NSError *error;
    NSData *counterProject = [NSData dataWithContentsOfURL:counterProjectURL options:NSDataReadingMapped error:&error];
    [Util log:error];
    
    
    //path for temp file
    NSString *documentsDirectory = [Util applicationDocumentsDirectory];
    NSString *tempPath = [NSString stringWithFormat:@"%@/temp.zip", documentsDirectory];
    
    //writing to file
    [counterProject writeToFile:tempPath atomically:YES];
    
    //path for storing file
    NSString *storePath = [NSString stringWithFormat:@"%@/levels/HandTallyCounter", documentsDirectory];
    
    NSLog(@"Starting unzip");
    
    //unzip file
    [SSZipArchive unzipFileAtPath:tempPath toDestination:storePath];
    
    NSLog(@"Unzip finished");
    
    NSLog(@"Removing temp zip file");
    [[NSFileManager defaultManager] removeItemAtPath:tempPath error:&error];
    [Util log:error];
    
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectory error:&error];
    [Util log:error];
    NSLog(@"Contents: %@", contents);
}



- (void)loadDefaultProject {
    NSString *linkToSecondProject = @"http://catroid.org/catroid/download/575.catrobat";
    
    
    //second project
    NSURL *counterProjectURL = [NSURL URLWithString:linkToSecondProject];
    NSError *error;
    NSData *counterProject = [NSData dataWithContentsOfURL:counterProjectURL options:NSDataReadingMapped error:&error];
    [Util log:error];
    
    
    //path for temp file
    NSString *documentsDirectory = [Util applicationDocumentsDirectory];
    NSString *tempPath = [NSString stringWithFormat:@"%@/temp.zip", documentsDirectory];
    
    //writing to file
    [counterProject writeToFile:tempPath atomically:YES];
    
    //path for storing file
    NSString *storePath = [NSString stringWithFormat:@"%@/levels/DefaultProject", documentsDirectory];
    
    NSLog(@"Starting unzip");
    
    //unzip file
    [SSZipArchive unzipFileAtPath:tempPath toDestination:storePath];
    
    NSLog(@"Unzip finished");
    
    NSLog(@"Removing temp zip file");
    [[NSFileManager defaultManager] removeItemAtPath:tempPath error:&error];
    [Util log:error];
    
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectory error:&error];
    [Util log:error];
    NSLog(@"Contents: %@", contents);
}

- (void)downloadSampleProjects {
   
    [self loadRocketProject];
    [self loadCounterProject];
    [self loadDefaultProject];
    
}

- (void)deleteAllFilesFromDirectory:(NSString*)directoryPath {
    CattyAppDelegate *appDelegate = (CattyAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.fileManager deleteAllFillesOfDirectory:directoryPath];
}

- (BOOL)isEmpty:(NSArray*)arr {
    if ([arr count] > 0) {
        return NO;
    }
    else {
        return YES;
    }
}

- (IBAction)forumButtonClicked:(UIButton *)sender {
    [Util showComingSoonAlertView];
}

- (IBAction)infoButtonClicked:(UIButton*)sender {
    [Util showComingSoonAlertView];
}
@end
