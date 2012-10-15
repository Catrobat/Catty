//
//  SpeakBrick.m
//  Catty
//
//  Created by Dominik Ziegler on 10/3/12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "SpeakBrick.h"
#import "CustomExtensions.h"

#define TTS_SERVICE @"http://www.translate.google.com/translate_tts?tl="
#define TTS_APPENDIX @"&q="
#define USER_AGENT @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10.6; rv:2.0.1) Gecko/20100101 Firefox/4.0.1"

@interface SpeakBrick()

@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) NSString *language;
@property (nonatomic, strong) NSURL* url;


@end


@implementation SpeakBrick


@synthesize text = _text;
@synthesize path = _path;
@synthesize language = _language;

-(id)init
{
    self = [super init];
    if(self)
    {
        [self setup];
        [self downloadFileAsynchronous];
    }
    return self;
}


-(id)initWithText:(NSString *)text
{
    self = [super init];
    if (self)
    {
        self.text = text;
        [self setup];
        [self downloadFileAsynchronous];
    }
    
    return self;
}


- (void)performOnSprite:(Sprite *)sprite fromScript:(Script*)script;
{
    NSLog(@"Performing: %@", self.description);
    
    [self speakUsingTTSWebServiceOnSprite:sprite];
}

#pragma mark - Description

- (NSString*)description
{
    return [NSString stringWithFormat:@"Speak: %@", self.text];
}




#pragma mark Helper

-(void)setup
{
    self.language = [[NSLocale preferredLanguages] objectAtIndex:0];
    NSString* name = [[NSString alloc] initWithFormat:@"%@(%@)", self.text, self.language];
    

    NSString* fileName = [[NSString alloc] initWithFormat:@"%@%@", [name sha1], @".mp3"];
    self.path = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
    
    NSLog(@"File Name:%@", self.path);
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@%@", TTS_SERVICE, self.language, TTS_APPENDIX, self.text];
    self.url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSLog(@"URL: %@", urlString);
}


-(void)speakUsingTTSWebServiceOnSprite:(Sprite*)sprite
{
    [self downloadFileSynchronous];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:_path])
    {
        AVAudioPlayer  *player;
        NSError        *err;
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:
                  [NSURL fileURLWithPath:_path] error:&err];
        
        [sprite addSound:player];
    }
    
}


-(void)downloadFileAsynchronous
{
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:_path])
    {        
        NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:self.url];
        [request setValue:USER_AGENT forHTTPHeaderField:@"User-Agent"];
        
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
        [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
         {
             if ([data length] > 0 && error == nil)
             {
                 NSLog(@"Download sucess");
                 [data writeToFile:_path atomically:YES];
             }
             else if ([data length] == 0 && error == nil)
             {
                 NSLog(@"No Reply");
             }
             else if (error != nil)
             {
                 NSLog(@"Error: %@", error);
             }
         }];
    }
}

-(void)downloadFileSynchronous
{

    if (![[NSFileManager defaultManager] fileExistsAtPath:self.path])
    {
        NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:self.url];
        [request setValue:USER_AGENT forHTTPHeaderField:@"User-Agent"];
        
        NSURLResponse* response = nil;
        NSError* error = nil;
        NSData* data = [NSURLConnection sendSynchronousRequest:request
                                             returningResponse:&response
                                                         error:&error];
        
        
        [data writeToFile:self.path atomically:YES];
        
    }
    
}


@end
