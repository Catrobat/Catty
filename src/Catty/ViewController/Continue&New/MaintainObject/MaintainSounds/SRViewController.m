/**
 *  Copyright (C) 2010-2018 The Catrobat Team
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

#import "SRViewController.h"
#import "Sound.h"
#import "UIDefines.h"
#import "AppDelegate.h"
#import "UIColor+CatrobatUIColorExtensions.h"
#import "TimerLabel.h"
#import "NSString+CatrobatNSStringExtensions.h"
#import "Util.h"
#import "Pocket_Code-Swift.h"

@interface SRViewController ()
@property (nonatomic,strong)Sound *sound;
@property (nonatomic,strong)NSString *filePath;
@property (nonatomic,weak) IBOutlet TimerLabel* timerLabel;
@property (nonatomic,strong) AVAudioRecorder* recorder;
@property (nonatomic,strong) AVAudioSession* session;
@property (nonatomic,assign) BOOL isSaved;
    //@property (nonatomic,strong) UIProgressView* timeProgress;
    //@property (nonatomic,strong) NSTimer* progressTimer;

@end

@implementation SRViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
        // Do any additional setup after loading the view, typically from a nib.
//    [self setupToolBar];
    UIBarButtonItem *save = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                          target:self
                                                                          action:@selector(saveSound)];
    self.navigationController.toolbarHidden = YES;

    self.navigationItem.rightBarButtonItem = save;
    self.record.frame = CGRectMake(self.view.frame.size.width / 2.0 - (self.view.frame.size.height * 0.4 / 2.0f), self.view.frame.size.height * 0.4, self.view.frame.size.height * 0.4, self.view.frame.size.height * 0.4);


        //    self.timeProgress = [[UIProgressView alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2.0 - 125 ,self.view.frame.size.height * 0.3, 250, 10)];
    
    self.timerLabel.timerType = TimerLabelTypeStopWatch;
    [self.view addSubview:self.timerLabel];
        //    [self.view addSubview:self.timeProgress];
    self.timerLabel.timeLabel.backgroundColor = [UIColor clearColor];
    self.timerLabel.timeLabel.font = [UIFont systemFontOfSize:28.0f];
    self.timerLabel.timeLabel.textColor = [UIColor globalTintColor];
    self.timerLabel.timeLabel.textAlignment = NSTextAlignmentCenter;
    
    
    UITapGestureRecognizer * recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(recording:)];
    [self.timerLabel addGestureRecognizer:recognizer];
        //    [self.timeProgress addGestureRecognizer:recognizer];
    
    self.view.backgroundColor = [UIColor backgroundColor];
    
    
    self.isRecording = NO;
    self.isSaved = NO;
    [self prepareRecorder];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.recorder stop];
    [self.timerLabel reset];
    [self.record setSelected:NO];
    self.recorder = nil;
    if (self.sound.name && !self.isSaved) {
        [self.delegate showSaveSoundAlert:self.sound];
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
        // Dispose of any resources that can be recreated.
}

- (void)prepareRecorder
{
    CBFileManager *fileManager = [CBFileManager sharedManager];
    NSString *fileName =[[NSString uuid] stringByAppendingString:@".m4a"];
    self.filePath = [NSString stringWithFormat:@"%@/%@", fileManager.documentsDirectory, fileName];
    self.sound = [[Sound alloc] init];
    self.sound.fileName = fileName;
    NSURL* outputFileUrl = [NSURL fileURLWithPath:self.filePath isDirectory:NO];
    self.session = [AVAudioSession sharedInstance];
    NSError *err = NULL;
    [self.session setActive:YES error:&err];
    [self.session setCategory:AVAudioSessionCategoryPlayAndRecord error:&err];
    if( err ){
        NSError(@"There was an error creating the audio session");
    }
    [self.session overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:NULL];
    if( err ){
        NSError(@"There was an error sending the audio to the speakers");
    }
    
    NSMutableDictionary* recordSetting = [[NSMutableDictionary alloc]init];
    
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    
    [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    
    [recordSetting setValue:[NSNumber numberWithInt:2] forKey:AVNumberOfChannelsKey];
    
    self.recorder = [[AVAudioRecorder alloc]initWithURL:outputFileUrl settings:recordSetting error:NULL];
    
    self.recorder.delegate = self;
    self.recorder.meteringEnabled = YES;
    
    [self.recorder prepareToRecord];
}



- (IBAction)recording:(id)sender {
    [self recordClicked];
}

- (void)recordClicked
{
    if (!self.isRecording) {
        
        [self.record setSelected:YES];
        [self.timerLabel start];
            //        [self.recorder record];
        self.isRecording = YES;
        [self.session setActive:YES error:nil];
        CBFileManager *fileManager = [CBFileManager sharedManager];
        [self.recorder recordForDuration:(([fileManager freeDiskspace]/1024ll)/256.0)];
//        [self setupToolBar];
        self.sound.name = kLocalizedRecording;
            //        self.progressTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateProgressView) userInfo:nil repeats:YES];
    } else {
        [self.recorder pause];
            //        [self.progressTimer invalidate];
        [self.timerLabel pause];
        [self.record setSelected:NO];
        self.isRecording = NO;
        [self setupToolBar];
    }
}

- (void) audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{
    if (!flag) {
        [Util alertWithTitle:kLocalizedError andText:kLocalizedMemoryWarning];
    }
    [self.record setTitle:kLocalizedRecording forState:UIControlStateNormal];
}

    //- (void)updateProgressView
    //{
    //    CGFloat time = 0;
    //    float minutes = floor(self.recorder.currentTime/60);
    //    float seconds = self.recorder.currentTime - (minutes * 60);
    //    time = (NSInteger)(seconds)% (NSInteger)(5*60);
    //    time = time / (5*60);
    //    [self.timeProgress setProgress:time];
    //    [self.timeProgress setNeedsDisplay];
    //
    //}

- (void)setupToolBar
{

    UIBarButtonItem *save = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                          target:self
                                                                          action:@selector(saveSound)];
    UIImage* recordPauseImage;
    if (!self.isRecording) {
        recordPauseImage = [UIImage imageNamed:@"record"];
    } else {
        recordPauseImage = [UIImage imageNamed:@"pause"];
    }
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.bounds = CGRectMake( 0, 0, recordPauseImage.size.width, recordPauseImage.size.height );
    [button setImage:recordPauseImage forState:UIControlStateNormal];
    [button addTarget:self action:@selector(recordClicked) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *recordPause = [[UIBarButtonItem alloc] initWithCustomView:button];
        //    UIBarButtonItem* recordPause = [[UIBarButtonItem alloc] initWithImage:recordPauseImage style:nil target:self action:@selector(recordClicked)];
    
        // XXX: workaround for tap area problem:
        // http://stackoverflow.com/questions/5113258/uitoolbar-unexpectedly-registers-taps-on-uibarbuttonitem-instances-even-when-tap
    UIBarButtonItem *(^invisibleItem)(void) = ^UIBarButtonItem *() { return [UIBarButtonItem invisibleItem]; };
    UIBarButtonItem *(^flexItem)(void) = ^UIBarButtonItem *() { return [UIBarButtonItem flexItem]; };
    self.toolbarItems = [NSArray arrayWithObjects:flexItem(), invisibleItem(), recordPause, invisibleItem(), flexItem(),
                         flexItem(), flexItem(), invisibleItem(), save , invisibleItem(), flexItem(), nil];
}

- (void)saveSound
{
    [self.recorder stop];
    [self.timerLabel reset];
    [self.record setSelected:NO];
    self.recorder = nil;
    if (self.sound.name) {
        [self.delegate addSound:self.sound];
    }
    self.isSaved = YES;
    [self.navigationController popViewControllerAnimated:YES];
}


@end
