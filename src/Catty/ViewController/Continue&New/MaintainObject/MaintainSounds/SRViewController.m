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

#import "SRViewController.h"
#import "Sound.h"
#import "UIDefines.h"
#import "AppDelegate.h"
#import "UIColor+CatrobatUIColorExtensions.h"
#import "TimerLabel.h"
#import "NSString+CatrobatNSStringExtensions.h"

@interface SRViewController ()
@property (nonatomic,strong)Sound *sound;
@property (nonatomic,strong)NSString *filePath;
@property (nonatomic,strong) TimerLabel* timerLabel;
@property (nonatomic,strong) AVAudioRecorder* recorder;
@property (nonatomic,strong) UIProgressView* timeProgress;
@property (nonatomic,strong) NSTimer* progressTimer;

@end

@implementation SRViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    self.record.frame = CGRectMake(self.view.frame.size.width / 2.0 - 100, self.view.frame.size.height * 0.5, 200, 200);
    
    self.timerLabel = [[TimerLabel alloc] initWithFrame:CGRectMake(0,self.view.frame.size.height * 0.4, self.view.frame.size.width, 40)];
    self.timeProgress = [[UIProgressView alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2.0 - 125 ,self.view.frame.size.height * 0.3, 250, 10)];
    
    self.timerLabel.timerType = TimerLabelTypeStopWatch;
    [self.view addSubview:self.timerLabel];
    [self.view addSubview:self.timeProgress];
    self.timerLabel.timeLabel.backgroundColor = [UIColor clearColor];
    self.timerLabel.timeLabel.font = [UIFont systemFontOfSize:28.0f];
    self.timerLabel.timeLabel.textColor = [UIColor lightOrangeColor];
    self.timerLabel.timeLabel.textAlignment = NSTextAlignmentCenter;
    
    
  UITapGestureRecognizer * recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(recording:)];
    [self.timerLabel addGestureRecognizer:recognizer];
    [self.timeProgress addGestureRecognizer:recognizer];
    
    self.view.backgroundColor = [UIColor airForceBlueColor];

    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *err = NULL;
    [audioSession setActive:YES error:&err];
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&err];
    if( err ){
        NSLog(@"There was an error creating the audio session");
    }
    [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:NULL];
    if( err ){
        NSLog(@"There was an error sending the audio to the speakers");
    }

    self.isRecording = NO;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.recorder stop];
    [self.timerLabel reset];
    [self.record setSelected:NO];
    self.recorder = nil;
    if (self.sound) {
        NSNotificationCenter *dnc = [NSNotificationCenter defaultCenter];
        [dnc postNotificationName:kRecordAddedNotification
                           object:nil
                         userInfo:@{ kUserInfoSound : self.sound}];
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)recording:(id)sender {
  [self recordClicked:nil];
}

-(void)recordClicked:(id)sender
{
    if (!self.isRecording) {
        AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;

        NSString *fileName =[[NSString uuid] stringByAppendingString:@".m4a"];
        self.filePath = [NSString stringWithFormat:@"%@/%@", delegate.fileManager.documentsDirectory, fileName];
        self.sound = [[Sound alloc] init];
        self.sound.fileName = fileName;
        self.sound.name = NSLocalizedString(@"Recording", nil);
        NSURL* outputFileUrl = [NSURL fileURLWithPath:self.filePath isDirectory:NO];
        
        AVAudioSession* session = [AVAudioSession sharedInstance];
        [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        
        NSMutableDictionary* recordSetting = [[NSMutableDictionary alloc]init];
        
        [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
        
        [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
        
        [recordSetting setValue:[NSNumber numberWithInt:2] forKey:AVNumberOfChannelsKey];
        
        self.recorder = [[AVAudioRecorder alloc]initWithURL:outputFileUrl settings:recordSetting error:NULL];
        
        self.recorder.delegate = self;
        self.recorder.meteringEnabled = YES;
        
        [self.recorder prepareToRecord];
        [self.record setSelected:YES];
        [self.timerLabel start];
        self.isRecording = YES;
        [session setActive:YES error:nil];
        [self.recorder recordForDuration:(([delegate.fileManager freeDiskspace]/1024ll)/256.0)];

        self.progressTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateProgressView) userInfo:nil repeats:YES];
    } else {
        [self.recorder stop];
        [self.progressTimer invalidate];
        [self.timerLabel reset];
        [self.record setSelected:NO];
        self.isRecording = NO;
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void) audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{
  if (!flag) {
    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Error"
                                                   message:@"Not enough Memory"
                                                  delegate:nil
                                         cancelButtonTitle:@"OK"
                                         otherButtonTitles:nil];
    [alert show];
  }
    [self.record setTitle:@"Record" forState:UIControlStateNormal];
}

-(void)updateProgressView
{
    CGFloat time = 0;
    float minutes = floor(self.recorder.currentTime/60);
    float seconds = self.recorder.currentTime - (minutes * 60);
    time = (NSInteger)(seconds)% (NSInteger)(5*60);
    time = time / (5*60);
    [self.timeProgress setProgress:time];
    [self.timeProgress setNeedsDisplay];
    
}


@end
