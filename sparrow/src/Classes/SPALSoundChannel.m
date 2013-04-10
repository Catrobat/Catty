//
//  SPALSoundChannel.m
//  Sparrow
//
//  Created by Daniel Sperl on 28.05.10.
//  Copyright 2011 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import "SPALSoundChannel.h"
#import "SPALSound.h"
#import "SPAudioEngine.h"
#import "SPMacros.h"

#import <QuartzCore/QuartzCore.h> // for CACurrentMediaTime
#import <OpenAL/al.h>
#import <OpenAL/alc.h>

// --- private interface ---------------------------------------------------------------------------

@interface SPALSoundChannel ()

- (void)scheduleSoundCompletedEvent;
- (void)revokeSoundCompletedEvent;

@end

// --- class implementation ------------------------------------------------------------------------

@implementation SPALSoundChannel
{
    SPALSound *_sound;
    uint _sourceID;
    float _volume;
    BOOL _loop;
    
    double _startMoment;
    double _pauseMoment;
    BOOL _interrupted;
}

@synthesize volume = _volume;
@synthesize loop = _loop;

- (id)init
{
    return nil;
}

- (id)initWithSound:(SPALSound *)sound
{
    if ((self = [super init]))
    {
        _sound = sound;
        _volume = 1.0f;
        _loop = NO;
        _interrupted = NO;
        _startMoment = 0.0;
        _pauseMoment = 0.0;
        
        alGenSources(1, &_sourceID);
        alSourcei(_sourceID, AL_BUFFER, sound.bufferID);
        ALenum errorCode = alGetError();
        if (errorCode != AL_NO_ERROR)
        {
            NSLog(@"Could not create OpenAL source (%x)", errorCode);
            return nil;
        }         
        
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];        
        [nc addObserver:self selector:@selector(onInterruptionBegan:) 
            name:SP_NOTIFICATION_AUDIO_INTERRUPTION_BEGAN object:nil];
        [nc addObserver:self selector:@selector(onInterruptionEnded:) 
            name:SP_NOTIFICATION_AUDIO_INTERRUPTION_ENDED object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];    
    alSourceStop(_sourceID);
    alSourcei(_sourceID, AL_BUFFER, 0);
    alDeleteSources(1, &_sourceID);
    _sourceID = 0;
}

- (void)play
{
    if (!self.isPlaying)
    {
        double now = CACurrentMediaTime();
        
        if (_pauseMoment != 0.0) // paused
        {
            _startMoment += now - _pauseMoment;
            _pauseMoment = 0.0;
        }
        else // stopped 
        {
            _startMoment = now;
        }
        
        [self scheduleSoundCompletedEvent];        
        alSourcePlay(_sourceID);
    }
}

- (void)pause
{
    if (self.isPlaying)
    {    
        [self revokeSoundCompletedEvent];
        _pauseMoment = CACurrentMediaTime();
        alSourcePause(_sourceID);
    }
}

- (void)stop
{
    [self revokeSoundCompletedEvent];
    _startMoment = _pauseMoment = 0.0;
    alSourceStop(_sourceID);
}

- (BOOL)isPlaying
{
    ALint state;
    alGetSourcei(_sourceID, AL_SOURCE_STATE, &state);
    return state == AL_PLAYING;
}

- (BOOL)isPaused
{
    ALint state;
    alGetSourcei(_sourceID, AL_SOURCE_STATE, &state);
    return state == AL_PAUSED;
}

- (BOOL)isStopped
{
    ALint state;
    alGetSourcei(_sourceID, AL_SOURCE_STATE, &state);
    return state == AL_STOPPED;
}

- (void)setLoop:(BOOL)value
{
    if (value != _loop)
    {
        _loop = value;
        alSourcei(_sourceID, AL_LOOPING, _loop);        
    }    
}

- (void)setVolume:(float)value
{
    if (value != _volume)
    {
        _volume = value;
        alSourcef(_sourceID, AL_GAIN, _volume);        
    }
}

- (double)duration
{
    return [_sound duration];
}

- (void)scheduleSoundCompletedEvent
{
    if (_startMoment != 0.0)
    {    
        double remainingTime = _sound.duration - (CACurrentMediaTime() - _startMoment);        
        [self revokeSoundCompletedEvent];
        if (remainingTime >= 0.0)
        {        
            [self performSelector:@selector(dispatchCompletedEvent) withObject:nil
                       afterDelay:remainingTime];   
        }
    }
}

- (void)revokeSoundCompletedEvent
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self 
        selector:@selector(dispatchCompletedEvent) object:nil];
}

- (void)dispatchCompletedEvent
{
    if (!_loop)
        [self dispatchEventWithType:SP_EVENT_TYPE_COMPLETED];
}

- (void)onInterruptionBegan:(NSNotification *)notification
{        
    if (self.isPlaying)
    {
        [self revokeSoundCompletedEvent];
        _interrupted = YES;
        _pauseMoment = CACurrentMediaTime();
    }
}

- (void)onInterruptionEnded:(NSNotification *)notification
{
    if (_interrupted)
    {
        _startMoment += CACurrentMediaTime() - _pauseMoment;
        _pauseMoment = 0.0;
        _interrupted = NO;
        [self scheduleSoundCompletedEvent];
    }
}

@end
