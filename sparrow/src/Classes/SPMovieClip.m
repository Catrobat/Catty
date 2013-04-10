//
//  SPMovieClip.m
//  Sparrow
//
//  Created by Daniel Sperl on 01.05.10.
//  Copyright 2011 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import "SPMovieClip.h"
#import "SPMacros.h"

// --- class implementation ------------------------------------------------------------------------

@implementation SPMovieClip
{
    NSMutableArray *_textures;
    NSMutableArray *_sounds;
    NSMutableArray *_durations;
    
    double _defaultFrameDuration;
    double _totalTime;
    double _currentTime;
    BOOL _loop;
    BOOL _playing;
    int _currentFrame;
}

@synthesize loop = _loop;
@synthesize isPlaying = _playing;
@synthesize currentFrame = _currentFrame;
@synthesize totalTime = _totalTime;
@synthesize currentTime = _currentTime;

- (id)initWithFrame:(SPTexture *)texture fps:(float)fps
{
    if ((self = [super initWithTexture:texture]))
    {
        _defaultFrameDuration = 1.0f / fps;
        _loop = YES;
        _playing = YES;
        _totalTime = 0.0;
        _currentTime = 0.0;
        _currentFrame = 0;
        _textures = [[NSMutableArray alloc] init];
        _sounds = [[NSMutableArray alloc] init];
        _durations = [[NSMutableArray alloc] init];        
        [self addFrameWithTexture:texture];
    }
    return self;
}

- (id)initWithFrames:(NSArray *)textures fps:(float)fps
{
    if (textures.count == 0)
        [NSException raise:SP_EXC_INVALID_OPERATION format:@"empty texture array"];
        
    self = [self initWithFrame:textures[0] fps:fps];
        
    if (self && textures.count > 1)
        for (int i=1; i<textures.count; ++i)
            [self addFrameWithTexture:textures[i] atIndex:i];
    
    return self;
}

- (id)initWithTexture:(SPTexture *)texture
{
    return [self initWithFrame:texture fps:10];
}

- (void)addFrameWithTexture:(SPTexture *)texture
{
    [self addFrameWithTexture:texture atIndex:self.numFrames];
}

- (void)addFrameWithTexture:(SPTexture *)texture duration:(double)duration
{
    [self addFrameWithTexture:texture duration:duration atIndex:self.numFrames];
}

- (void)addFrameWithTexture:(SPTexture *)texture duration:(double)duration sound:(SPSoundChannel *)sound
{
    [self addFrameWithTexture:texture duration:duration sound:sound atIndex:self.numFrames];
}

- (void)addFrameWithTexture:(SPTexture *)texture atIndex:(int)frameID
{
    [self addFrameWithTexture:texture duration:_defaultFrameDuration atIndex:frameID];
}

- (void)addFrameWithTexture:(SPTexture *)texture duration:(double)duration atIndex:(int)frameID
{
    [self addFrameWithTexture:texture duration:duration sound:nil atIndex:frameID];
}

- (void)addFrameWithTexture:(SPTexture *)texture duration:(double)duration
                      sound:(SPSoundChannel *)sound atIndex:(int)frameID
{
    _totalTime += duration;
    [_textures insertObject:texture atIndex:frameID];
    [_durations insertObject:@(duration) atIndex:frameID];
    [_sounds insertObject:(sound ? sound : [NSNull null]) atIndex:frameID];
}

- (void)removeFrameAtIndex:(int)frameID
{
    _totalTime -= [self durationAtIndex:frameID];
    [_textures removeObjectAtIndex:frameID];
    [_durations removeObjectAtIndex:frameID];
    [_sounds removeObjectAtIndex:frameID];
}

- (void)setTexture:(SPTexture *)texture atIndex:(int)frameID
{
    _textures[frameID] = texture;
}

- (void)setSound:(SPSoundChannel *)sound atIndex:(int)frameID
{
    _sounds[frameID] = sound ? sound : [NSNull null];
}

- (void)setDuration:(double)duration atIndex:(int)frameID
{
    _totalTime -= [self durationAtIndex:frameID];
    _durations[frameID] = @(duration);
    _totalTime += duration;
}

- (SPTexture *)textureAtIndex:(int)frameID
{
    return _textures[frameID];    
}

- (SPSoundChannel *)soundAtIndex:(int)frameID
{
    id sound = _sounds[frameID];
    if ([NSNull class] != [sound class]) return sound;
    else return nil;
}

- (double)durationAtIndex:(int)frameID
{
    return [_durations[frameID] doubleValue];
}

- (void)setFps:(float)fps
{
    float newFrameDuration = (fps == 0.0f ? INT_MAX : 1.0 / fps);
	float acceleration = newFrameDuration / _defaultFrameDuration;
    _currentTime *= acceleration;
    _defaultFrameDuration = newFrameDuration;
    
	for (int i=0; i<self.numFrames; ++i)
		[self setDuration:[self durationAtIndex:i] * acceleration atIndex:i];
}

- (float)fps
{
	return (float)(1.0 / _defaultFrameDuration);
}

- (int)numFrames
{        
    return _textures.count;
}

- (void)play
{
    _playing = YES;    
}

- (void)pause
{
    _playing = NO;
}

- (void)stop
{
    _playing = NO;
    self.currentFrame = 0;
}

- (void)updateCurrentFrame
{
    self.texture = _textures[_currentFrame];
}

- (void)playCurrentSound
{
    id sound = _sounds[_currentFrame];
    if ([NSNull class] != [sound class])                    
        [sound play];
}

- (void)setCurrentFrame:(int)frameID
{
    _currentFrame = frameID;
    _currentTime = 0.0;
    
    for (int i=0; i<frameID; ++i)
        _currentTime += [_durations[i] doubleValue];
    
    [self updateCurrentFrame];
}

- (BOOL)isPlaying
{
    if (_playing)
        return _loop || _currentTime < _totalTime;
    else
        return NO;
}

- (BOOL)isComplete
{
    return !_loop && _currentTime >= _totalTime;
}

+ (id)movieWithFrame:(SPTexture *)texture fps:(float)fps
{
    return [[self alloc] initWithFrame:texture fps:fps];
}

+ (id)movieWithFrames:(NSArray *)textures fps:(float)fps
{
    return [[self alloc] initWithFrames:textures fps:fps];
}

#pragma mark SPAnimatable

- (void)advanceTime:(double)seconds
{    
    if (_loop && _currentTime == _totalTime) _currentTime = 0.0;    
    if (!_playing || seconds == 0.0 || _currentTime == _totalTime) return;    
    
    int i = 0;
    double durationSum = 0.0;
    double previousTime = _currentTime;
    double restTime = _totalTime - _currentTime;
    double carryOverTime = seconds > restTime ? seconds - restTime : 0.0;
    _currentTime = MIN(_totalTime, _currentTime + seconds);            
       
    for (NSNumber *frameDuration in _durations)
    {
        double fd = [frameDuration doubleValue];
        if (durationSum + fd >= _currentTime)            
        {
            if (_currentFrame != i)
            {
                _currentFrame = i;
                [self updateCurrentFrame];
                [self playCurrentSound];
            }
            break;
        }
        
        ++i;
        durationSum += fd;
    }
    
    if (previousTime < _totalTime && _currentTime == _totalTime)
        [self dispatchEventWithType:SP_EVENT_TYPE_COMPLETED];
    
    [self advanceTime:carryOverTime];
}

@end