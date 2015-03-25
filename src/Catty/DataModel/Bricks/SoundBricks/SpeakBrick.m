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

#import "SpeakBrick.h"
#import "NSString+CatrobatNSStringExtensions.h"
#import "Sound.h"
#import <AVFoundation/AVSpeechSynthesis.h>

@implementation SpeakBrick

- (id)init
{
    self = [super init];
    if(self) {
    }
    return self;
}

- (NSString*)brickTitle
{
    return kLocalizedSpeak;
}

- (void)setupEmptyBrick
{
    self.text = kLocalizedDefaultSpeakText;
}

- (SKAction*)action
{
    NSDebug(@"Adding: %@", self.description);
    
    return [SKAction runBlock:^{
        NSDebug(@"Performing: %@", self.description);
        AVSpeechSynthesizer *synthesizer = [[AVSpeechSynthesizer alloc] init];
        AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc] initWithString:self.text];
        [synthesizer speakUtterance:utterance];

    }];
}

#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"Speak: %@", self.text];
}

- (void)setText:(NSString *)text forLineNumber:(NSInteger)lineNumber andParameterNumber:(NSInteger)paramNumber
{
    if(text)
        self.text = text;
}

- (NSString*)textForLineNumber:(NSInteger)lineNumber andParameterNumber:(NSInteger)paramNumber
{
    return self.text;
}

@end
