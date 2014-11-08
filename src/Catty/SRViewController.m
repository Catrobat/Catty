/**
 *  Copyright (C) 2010-2014 The Catrobat Team
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

@interface SRViewController ()
@property (nonatomic,strong)Sound *sound;
@property (nonatomic,strong)NSString *filePath;

@end

@implementation SRViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.microphone = [EZMicrophone microphoneWithDelegate:self];
	// Do any additional setup after loading the view, typically from a nib.
    [self.play setEnabled:NO];
    self.audioPlot.frame = CGRectMake(0, 70, self.view.frame.size.width, self.view.frame.size.height * 0.5);
    self.record.frame = CGRectMake(self.view.frame.size.width / 3.0, self.view.frame.size.height * 0.8, self.record.frame.size.width, self.record.frame.size.height);
    self.play.frame = CGRectMake(self.view.frame.size.width * 2.0 / 3.0, self.view.frame.size.height * 0.8, self.play.frame.size.width, self.play.frame.size.height);
    self.framePositionSlider.frame = CGRectMake(self.view.frame.size.width /2.0 - 100, self.view.frame.size.height * 0.7, 200, self.framePositionSlider.frame.size.height);
    self.framePositionSlider.hidden = YES;
    
    self.audioPlot.backgroundColor = [UIColor airForceBlueColor];
    self.audioPlot.color           = [UIColor lightOrangeColor];
    self.audioPlot.plotType        = EZPlotTypeRolling;
    self.audioPlot.shouldFill      = YES;
    self.audioPlot.shouldMirror    = YES;
    
    self.view.backgroundColor = [UIColor airForceBlueColor];

    self.play.hidden = YES;
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


}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.microphone stopFetchingAudio];
    [self.recorder closeAudioFile];
    self.recorder = nil;
    [[EZOutput sharedOutput] stopPlayback];
    [EZOutput sharedOutput].outputDataSource = nil;
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

-(void)recordClicked:(id)sender
{
    if([[EZOutput sharedOutput] isPlaying] ){
        [EZOutput sharedOutput].outputDataSource = nil;
        [[EZOutput sharedOutput] stopPlayback];
    }
    
    if(!self.isRecording)
    {
        [self.microphone startFetchingAudio];
        [self.audioPlot clear];
        NSString * fileName =[[self GetUUID] stringByAppendingString:@".m4a"];
        self.sound = [[Sound alloc] init];
        self.sound.fileName = fileName;
        self.sound.name = NSLocalizedString(@"Recording", nil);
        AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
        self.filePath = [NSString stringWithFormat:@"%@/%@", delegate.fileManager.documentsDirectory, fileName];
        NSURL* outputFileUrl = [NSURL fileURLWithPath:self.filePath isDirectory:NO];

        self.recorder = [EZRecorder recorderWithDestinationURL:outputFileUrl
                                                  sourceFormat:self.microphone.audioStreamBasicDescription
                                           destinationFileType:EZRecorderFileTypeM4A];
        [self.record setTitle:@"Stop" forState:UIControlStateNormal];
        self.isRecording = YES;
    }
    else
    {
        [self.recorder closeAudioFile];
        self.isRecording = NO;
        [self.record setTitle:@"Record" forState:UIControlStateNormal];
        self.play.hidden = NO;
        self.framePositionSlider.hidden = NO;
        [self.play setEnabled:YES];
        self.eof = YES;
        [self openFile];
        [self.microphone stopFetchingAudio];
    }
    

}
- (NSString *)GetUUID
{
  CFUUIDRef theUUID = CFUUIDCreate(NULL);
  CFStringRef string = CFUUIDCreateString(NULL, theUUID);
  CFRelease(theUUID);
  return (__bridge NSString *)string;
}

-(void)playClicked:(id)sender
{
    [self.microphone stopFetchingAudio];
    self.isRecording = NO;
    if( ![[EZOutput sharedOutput] isPlaying] ){
        if( self.eof ){
            [self.audioFile seekToFrame:0];
        }
        [self.audioPlot clear];
        [EZOutput sharedOutput].outputDataSource = self;
        [[EZOutput sharedOutput] startPlayback];
    }
    else {
        [EZOutput sharedOutput].outputDataSource = nil;
        [[EZOutput sharedOutput] stopPlayback];
    }

}

- (IBAction)seekToFrame:(UISlider *)sender {
    [self.audioFile seekToFrame:(SInt64)[sender value]];
}


-(void)openFile {
    
        // Stop playback
    [[EZOutput sharedOutput] stopPlayback];
    
    self.audioFile                        = [EZAudioFile audioFileWithURL:[NSURL URLWithString:self.filePath]];
    self.audioFile.audioFileDelegate      = self;
    self.framePositionSlider.maximumValue = (float)self.audioFile.totalFrames;
    
        // Set the client format from the EZAudioFile on the output
    [[EZOutput sharedOutput] setAudioStreamBasicDescription:self.audioFile.clientFormat];
    
        // Plot the whole waveform

    [self.audioFile getWaveformDataWithCompletionBlock:^(float *waveformData, UInt32 length) {
        [self.audioPlot updateBuffer:waveformData withBufferSize:length];
    }];
    
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
    [self.play setEnabled:YES];
}


-(uint64_t)getFreeDiskspace {
  uint64_t totalSpace = 0;
  uint64_t totalFreeSpace = 0;
  NSError *error = nil;
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];
  
  if (dictionary) {
    NSNumber *fileSystemSizeInBytes = [dictionary objectForKey: NSFileSystemSize];
    NSNumber *freeFileSystemSizeInBytes = [dictionary objectForKey:NSFileSystemFreeSize];
    totalSpace = [fileSystemSizeInBytes unsignedLongLongValue];
    totalFreeSpace = [freeFileSystemSizeInBytes unsignedLongLongValue];
    NSLog(@"Memory Capacity of %llu MiB with %llu MiB Free memory available.", ((totalSpace/1024ll)/1024ll), ((totalFreeSpace/1024ll)/1024ll));
  } else {
    NSLog(@"Error Obtaining System Memory Info: Domain = %@, Code = %ld", [error domain], (long)[error code]);
  }
  
  return totalFreeSpace;
}

-(void)microphone:(EZMicrophone *)microphone
 hasAudioReceived:(float **)buffer
   withBufferSize:(UInt32)bufferSize
withNumberOfChannels:(UInt32)numberOfChannels {

    dispatch_async(dispatch_get_main_queue(),^{

        [self.audioPlot updateBuffer:buffer[0] withBufferSize:bufferSize];
    });
}

-(void)microphone:(EZMicrophone *)microphone
    hasBufferList:(AudioBufferList *)bufferList
   withBufferSize:(UInt32)bufferSize
withNumberOfChannels:(UInt32)numberOfChannels {

    if( self.isRecording ){
        [self.recorder appendDataFromBufferList:bufferList
                                 withBufferSize:bufferSize];
    }
    
}



#pragma mark - EZAudioFileDelegate
-(void)audioFile:(EZAudioFile *)audioFile
       readAudio:(float **)buffer
  withBufferSize:(UInt32)bufferSize
withNumberOfChannels:(UInt32)numberOfChannels {
    dispatch_async(dispatch_get_main_queue(), ^{
        if( [EZOutput sharedOutput].isPlaying ){
            if( self.audioPlot.plotType     == EZPlotTypeBuffer &&
               self.audioPlot.shouldFill    == YES              &&
               self.audioPlot.shouldMirror  == YES ){
                self.audioPlot.shouldFill   = NO;
                self.audioPlot.shouldMirror = NO;
            }
            [self.audioPlot updateBuffer:buffer[0] withBufferSize:bufferSize];
        }
    });
}

-(void)audioFile:(EZAudioFile *)audioFile
 updatedPosition:(SInt64)framePosition {
    dispatch_async(dispatch_get_main_queue(), ^{
        if( !self.framePositionSlider.touchInside ){
            self.framePositionSlider.value = (float)framePosition;
        }
    });
}

#pragma mark - EZOutputDataSource
-(void)output:(EZOutput *)output shouldFillAudioBufferList:(AudioBufferList *)audioBufferList withNumberOfFrames:(UInt32)frames
{
    if( self.audioFile )
    {
        UInt32 bufferSize;
        [self.audioFile readFrames:frames
                   audioBufferList:audioBufferList
                        bufferSize:&bufferSize
                               eof:&_eof];
        if( _eof )
        {
            [self.audioPlot clear];
            [self seekToFrame:0];
        }
    }
}

-(AudioStreamBasicDescription)outputHasAudioStreamBasicDescription:(EZOutput *)output {
    return self.audioFile.clientFormat;
}


@end
