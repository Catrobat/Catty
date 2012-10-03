//
//  SpeakBrick.m
//  Catty
//
//  Created by Dominik Ziegler on 10/3/12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "SpeakBrick.h"

#define TTS_SERVICE @"http://www.translate.google.com/translate_tts?tl=en&q=%@"
#define USER_AGENT @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10.6; rv:2.0.1) Gecko/20100101 Firefox/4.0.1"

@implementation SpeakBrick

-(id)initWithText:(NSString *)text
{
    self = [super init];
    if (self)
    {
        self.text = text;
    }
    return self;
}

- (void)performOnSprite:(Sprite *)sprite fromScript:(Script*)script;
{
    NSLog(@"Performing: %@", self.description);
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"tmp.mp3"];
    
    NSString *urlString = [NSString stringWithFormat:TTS_SERVICE, self.text];
    NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setValue:USER_AGENT forHTTPHeaderField:@"User-Agent"];
    
    NSURLResponse* response = nil;
    NSError* error = nil;
    NSData* data = [NSURLConnection sendSynchronousRequest:request
                                         returningResponse:&response
                                                     error:&error];
    [data writeToFile:path atomically:YES];
    
    AVAudioPlayer  *player;
    NSError        *err;
    if ([[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:
                  [NSURL fileURLWithPath:path] error:&err];
        
        [sprite addSound:player];
    }
    
}

#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"Speak: %@", self.text];
}



@end
