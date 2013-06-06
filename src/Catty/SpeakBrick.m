/**
 *  Copyright (C) 2010-2013 The Catrobat Team
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

#import "SpeakBrick.h"
#import "NSString+CatrobatNSStringExtensions.h"
#import "Sound.h"

#define TTS_SERVICE @"http://www.translate.google.com/translate_tts?tl="
#define TTS_APPENDIX @"&q="
#define USER_AGENT @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10.6; rv:2.0.1) Gecko/20100101 Firefox/4.0.1"

@interface SpeakBrick()

@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) NSString *language;
@property (nonatomic, strong) NSString *fileName;
@property (nonatomic, strong) NSURL* url;

@end


@implementation SpeakBrick


-(void)setText:(NSString *)text
{
    _text = text;
    [self setup];
    [self downloadFileAsynchronous];
}


-(id)init
{
    self = [super init];
    if(self) {
    }
    return self;
}


- (void)performFromScript:(Script*)script;
{
    NSDebug(@"Performing: %@", self.description);
    
    [self speakUsingTTSWebService];
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
    

    self.fileName = [[NSString alloc] initWithFormat:@"%@%@", [name sha1], @".mp3"];
    self.path = [NSTemporaryDirectory() stringByAppendingPathComponent:self.fileName];
    
    NSDebug(@"File Name:%@", self.path);
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@%@", TTS_SERVICE, self.language, TTS_APPENDIX, self.text];
    self.url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSDebug(@"URL: %@", urlString);
}


-(void)speakUsingTTSWebService
{
    [self downloadFileSynchronous];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.path])
    {
        Sound* sound = [[Sound alloc] init];
        sound.name = self.text;
        sound.fileName = self.fileName;
        [self.object speakSound:sound];
    }
    
}


-(void)downloadFileAsynchronous
{
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:self.path])
    {        
        NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:self.url];
        [request setValue:USER_AGENT forHTTPHeaderField:@"User-Agent"];
        
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
        [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
         {
             if ([data length] > 0 && error == nil)
             {
                 NSDebug(@"Download sucess");
                 [data writeToFile:self.path atomically:YES];
             }
             else if ([data length] == 0 && error == nil)
             {
                 NSDebug(@"No Reply");
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
