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

@interface SRViewController ()
{
    AVAudioRecorder* recorder;
    AVAudioPlayer* player;
}

@property (nonatomic,strong)Sound *sound;

@end

@implementation SRViewController

@synthesize record = _record;
@synthesize play = _play;
@synthesize stop = _stop;
@synthesize soundName = _soundName;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self.stop setEnabled:NO];
    [self.play setEnabled:NO];
    _soundName.text  = @"Aufnahme";
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (self.sound) {
        self.sound.name = _soundName.text;
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

-(void)stopClicked:(id)sender
{
    [recorder stop];
    
    
    AVAudioSession* audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:NO error:nil];
    
}
-(void)recordClicked:(id)sender
{
    if (player.playing) {
        [player stop];
    }
    
    if (!recorder.recording) {
        
        NSString * fileName =[[self GetUUID] stringByAppendingString:@".m4a"];
//        NSString * fileName =[self GetUUID];
      AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
      NSString *filePath = [NSString stringWithFormat:@"%@/%@", delegate.fileManager.documentsDirectory, fileName];
      NSURL* outputFileUrl = [NSURL fileURLWithPath:filePath isDirectory:NO];
      
        self.sound = [[Sound alloc] init];
        self.sound.fileName = fileName;
        
      AVAudioSession* session = [AVAudioSession sharedInstance];
      [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
      
      NSMutableDictionary* recordSetting = [[NSMutableDictionary alloc]init];
      
      [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
      
      [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
      
      [recordSetting setValue:[NSNumber numberWithInt:2] forKey:AVNumberOfChannelsKey];
      
      recorder = [[AVAudioRecorder alloc]initWithURL:outputFileUrl settings:recordSetting error:NULL];
      
      recorder.delegate = self;
      recorder.meteringEnabled = YES;
      
      [recorder prepareToRecord];
      
      
      [session setActive:YES error:nil];
      [recorder recordForDuration:(([self getFreeDiskspace]/1024ll)/256.0)];
      [self.record setTitle:@"Pause" forState:UIControlStateNormal];
      
      [self performSelector:@selector(fadeOutDialog) withObject:nil afterDelay:0];

    }
    else{
        [recorder pause];
        [self.record setTitle:@"Record" forState:UIControlStateNormal];
    }
    [self.stop setEnabled:YES];
    [self.play setEnabled:NO];
}
- (NSString *)GetUUID
{
  CFUUIDRef theUUID = CFUUIDCreate(NULL);
  CFStringRef string = CFUUIDCreateString(NULL, theUUID);
  CFRelease(theUUID);
  return (__bridge NSString *)string;
}

-(void)fadeOutDialog
{
  [recorder updateMeters];
  NSLog(@"%f",[recorder averagePowerForChannel:0]);
}
-(void)playClicked:(id)sender
{
    if (!recorder.recording) {
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:recorder.url error:nil];
        
        [player setDelegate:self];
        [player play];
        
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
    [self.stop setEnabled:NO];
    [self.play setEnabled:YES];
}
-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Done"
                                                   message:@"Finished playing audio file"
                                                  delegate:nil
                                         cancelButtonTitle:@"OK"
                                         otherButtonTitles:nil];
    [alert show];
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

@end
