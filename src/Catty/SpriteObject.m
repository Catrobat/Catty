//
//  CattyAppDelegate.m
//  Catty
//
//  Created by Christof Stromberger on 07.07.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "SpriteManagerDelegate.h"
#import "Brick.h"
#import "SpriteObject.h"
#import "Look.h"
#import "Sound.h"
#import "Script.h"
#import "Util.h"
#import "enums.h"
#import "BroadcastWaitDelegate.h"
#import "Startscript.h"
#import "Whenscript.h"
#import "Broadcastscript.h"


// need CattyViewController to access FRAMES_PER_SECOND    TODO: change
//#import "CattyViewController.h"

//test
//#import "CattyAppDelegate.h"



typedef struct {
    CGPoint geometryVertex;
    CGPoint textureVertex;
} TexturedVertex;

typedef struct {
    TexturedVertex bottomLeftCorner;
    TexturedVertex bottomRightCorner;
    TexturedVertex topLeftCorner;
    TexturedVertex topRightCorner;
} TexturedQuad;



//////////////////////////////////////////////////////////////////////////////////////////

// TODO: change this to struct????? Maybe??!?!?!?

@implementation PositionAtTime
@synthesize position = _position;
@synthesize timestamp = _timestamp;

// new

+(PositionAtTime*)positionAtTimeWithPosition:(GLKVector3)position andTimestamp:(double)timestamp
{
    PositionAtTime *obj = [[PositionAtTime alloc]init];
    obj.position = position;
    obj.timestamp = timestamp;
    return obj;
}
@end

//////////////////////////////////////////////////////////////////////////////////////////



@interface SpriteObject()

@property (assign, nonatomic) GLKVector3 position;        // position - origin is bottom-left

@property (assign, nonatomic) float scaleWidth;     // scale width  of image according to bricks (e.g. SetSizeTo-brick)
@property (assign, nonatomic) float scaleHeight;    // scale height of image according to bricks (e.g. SetSizeTo-brick)

@property (assign, nonatomic) float xOffset;        // black border, if proportions are different (project-xml-resolution vs. screen-resolution)
@property (assign, nonatomic) float yOffset;


@property (nonatomic, strong) NSMutableArray *activeScripts;
@property (strong, nonatomic) NSMutableDictionary *nextPositions;       //key=script   value=positionAtTime

@property (strong, nonatomic) NSNumber *indexOfCurrentCostumeInArray;

@property (strong, nonatomic) NSArray *lookList;    // tell the compiler: "I want a private setter"
@property (strong, nonatomic) NSMutableArray *soundList;
@property (strong, nonatomic) NSMutableArray *audioPlayerList;

@end

@implementation SpriteObject

// public synthesizes
@synthesize spriteManagerDelegate = _spriteManagerDelegate;
@synthesize broadcastWaitDelegate = _broadcastWaitDelegate;
@synthesize projectPath = _projectPath;
@synthesize lookList = _lookList;
@synthesize soundList = _soundsArray;


// new
@synthesize scriptList = _scriptList;
#warning added this line... (just a note for mattias)

// private synthesizes
@synthesize position = _position;
@synthesize scaleWidth  = _scaleWidth;
@synthesize scaleHeight = _scaleHeight;
@synthesize xOffset = _xOffset;
@synthesize yOffset = _yOffset;
@synthesize activeScripts = _activeScripts;
@synthesize nextPositions = _nextPositions;
@synthesize indexOfCurrentCostumeInArray = _indexOfCurrentCostumeInArray;

#pragma mark Custom getter and setter
- (NSArray*)costumesArray
{
    if (_lookList == nil)
        _lookList = [[NSArray alloc] init];

    return _lookList;
}

- (NSMutableArray*)soundList
{
    if (_soundsArray == nil)
        _soundsArray = [[NSMutableArray alloc] init];
    
    return _soundsArray;
}

- (NSMutableArray*)audioPlayerList
{
    if (_audioPlayerList == nil)
        _audioPlayerList = [[NSMutableArray alloc] init];
    
    return _audioPlayerList;
}

- (NSMutableDictionary*)nextPositions
{
    if (!_nextPositions)
        _nextPositions = [[NSMutableDictionary alloc]init];
    
    return _nextPositions;
}


#pragma mark - init methods
- (id)init
{
    if (self = [super init]) 
    {
        [self setInitValues];
    }
    return self;
}

- (id)initWithEffect:(GLKBaseEffect*)effect
{
    self = [super init];
    if (self)
    {
        self.effect = effect;
        [self setInitValues];
    }
    return self;
}

-(void)setInitValues
{
    self.position = GLKVector3Make(0.0f, 0.0f, 0.0f);
    self.scaleWidth  = 1.0f;
    self.scaleHeight = 1.0f;
    self.activeScripts = [[NSMutableArray alloc]init];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

-(void)setProjectResolution:(CGSize)projectResolution
{
    if (projectResolution.width > 0 && projectResolution.height > 0) {
        float scaleX = [UIScreen mainScreen].bounds.size.width  / projectResolution.width;
        float scaleY = [UIScreen mainScreen].bounds.size.height / projectResolution.height;
        if (scaleY < scaleX)
            self.scaleFactor = scaleY;
        else
            self.scaleFactor = scaleX;
    }
    
    self.xOffset = ([UIScreen mainScreen].bounds.size.width  - (projectResolution.width  * self.scaleFactor)) / 2.0f;
    self.yOffset = ([UIScreen mainScreen].bounds.size.height - (projectResolution.height * self.scaleFactor)) / 2.0f;
    
    if (projectResolution.width == 0)
        self.xOffset = -1;
    if (projectResolution.height == 0)
        self.yOffset = -1;
    
    NSLog(@"Scale screen size:");
    NSLog(@"  Device:    %f / %f", [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    NSLog(@"  Project:   %f / %f", projectResolution.width, projectResolution.height);
    NSLog(@"  Scale-Factor: %f", self.scaleFactor);
}

- (void)addCostume:(Costume *)costume
{
    self.lookList = [self.lookList arrayByAddingObject:costume];
}

- (void)addCostumes:(NSArray *)costumesArray
{
    self.lookList = [self.lookList arrayByAddingObjectsFromArray:costumesArray];
}


- (float)getZIndex
{
    // TODO: change this - z-coord is not valid
    return self.position.z;
}

-(void)setZIndex:(float)newZIndex
{
    self.position = GLKVector3Make(self.position.x, self.position.y, newZIndex);
}

-(void)decrementZIndexByOne
{
    [self setZIndex:self.position.z-1];
}


#pragma mark - costume index SETTER
- (void)setIndexOfCurrentCostumeInArray:(NSNumber*)indexOfCurrentCostumeInArray
{
    _indexOfCurrentCostumeInArray = indexOfCurrentCostumeInArray;
    
    if (_indexOfCurrentCostumeInArray.intValue < 0)
        return;
    
    NSLog(@"Try to load costume %d / %d", indexOfCurrentCostumeInArray.intValue, [self.costumesArray count]);
    
    if ([self.costumesArray count] - 1 < indexOfCurrentCostumeInArray.intValue) {
        NSLog(@"Index %d is invalid! Array-size: %d", indexOfCurrentCostumeInArray.intValue, [self.costumesArray count]);
    }
    
    NSString *fileName = ((Look*)[self.costumesArray objectAtIndex:[self.indexOfCurrentCostumeInArray intValue]]).fileName;
    
    NSLog(@"Filename: %@", fileName);
    
    NSString *pathToImage = [NSString stringWithFormat:@"%@images/%@", self.projectPath, fileName]; // TODO: change const string
    
    [self loadImageWithPath:pathToImage]; //call method implemented in super-class
    [self setSpriteSizeWithWidth:self.scaleWidth*self.originalImageSize.width andHeight:self.scaleHeight*self.originalImageSize.height];
}


#pragma mark - graphics
- (void)update:(float)dt
{
    NSTimeInterval now = [[NSDate date]timeIntervalSince1970];
    
    for (PositionAtTime *nextPosition in [self.nextPositions allValues]) {
        
        if (now >= nextPosition.timestamp) {
            Script *script = [[self.nextPositions allKeysForObject:nextPosition] lastObject];
            NSLog(@"remove nextPosition");            
            [self.nextPositions removeObjectForKey:script.description];
        
        } else {
        
            // calculate position
            double timeLeft = (nextPosition.timestamp - now);    // in sec
            int numberOfSteps = round(timeLeft * (float)60.0f);//FRAMES_PER_SECOND);               // TODO: find better way to determine FPS (e.g. GLKit-variable??)
            
            GLKVector3 direction = GLKVector3Subtract(nextPosition.position, self.position);
            
            GLKVector3 step = direction;
            if (numberOfSteps > 0)
                step = GLKVector3DivideScalar(direction, numberOfSteps);
            
            self.position = GLKVector3Add(self.position, step);
        }

    }
    
    float x = (self.position.x * self.scaleFactor) + [UIScreen mainScreen].bounds.size.width/2;
    float y = (self.position.y * self.scaleFactor) + [UIScreen mainScreen].bounds.size.height/2;
    self.realPosition = GLKVector3Make(x, y, self.position.z);
    
    [super update:dt];
}



#pragma mark - actions

-(void)placeAt:(GLKVector3)newPosition
{
    self.position = newPosition;
}

- (void)glideToPosition:(GLKVector3)position withDurationInSeconds:(int)durationInSeconds fromScript:(Script*)script
{
    NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970] + (durationInSeconds);
    PositionAtTime *positionAtTime = [PositionAtTime positionAtTimeWithPosition:position andTimestamp:timeStamp];
    [self.nextPositions setValue:positionAtTime forKey:script.description];                 // TODO: whole description as key??
}

- (void)changeCostume:(Look*)look
{
    NSNumber *index = [NSNumber numberWithUnsignedInteger:[self.lookList indexOfObject:look]];
    self.indexOfCurrentCostumeInArray = index;
}

- (void)nextCostume
{
    if (self.indexOfCurrentCostumeInArray.intValue == [self.costumesArray count]-1)
        self.indexOfCurrentCostumeInArray = [NSNumber numberWithInt:0];
    else
        self.indexOfCurrentCostumeInArray = [NSNumber numberWithInt:self.indexOfCurrentCostumeInArray.intValue + 1];
}

- (void)hide
{
    self.showSprite = NO;
}

- (void)show
{
    self.showSprite = YES;
}

- (void)setXPosition:(float)xPosition
{
    self.position = GLKVector3Make(xPosition, self.position.y, self.position.z);
}

-(void)setYPosition:(float)yPosition
{
    self.position = GLKVector3Make(self.position.x, yPosition, self.position.z);
}

-(void)broadcast:(NSString *)message
{
    [[NSNotificationCenter defaultCenter] postNotificationName:message object:self];
}

-(void)broadcastAndWait:(NSString *)message
{
    if ([[NSThread currentThread] isMainThread]) {
        
        //TODO
        
        NSLog(@" ");
        NSLog(@"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
        NSLog(@"!!                                                                                       !!");
        NSLog(@"!!  ATTENTION: THIS METHOD SHOULD NEVER EVER BE CALLED FROM MAIN-THREAD!!! BUSY WAITING  !!");
        NSLog(@"!!                                                                                       !!");
        NSLog(@"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
        NSLog(@" ");
        abort();
    }
    
    NSString *responseID = [NSString stringWithFormat:@"%@-%d", message, arc4random()%1000000];
    
    if ([self.broadcastWaitDelegate respondsToSelector:@selector(object:isWaitingForAllObserversOfMessage:withResponseID:)]) {
        [self.broadcastWaitDelegate object:self isWaitingForAllObserversOfMessage:message withResponseID:responseID];
    } else {
        NSLog(@"ERROR: BroadcastWaitDelegate not set! abort()");
        abort();
    }
    
    [[NSNotificationCenter defaultCenter]postNotificationName:message object:self userInfo:[NSDictionary dictionaryWithObject:responseID forKey:@"responseID"]];
    
    // TODO: busy waiting...
    while ([self.broadcastWaitDelegate polling4testing__didAllObserversFinishForResponseID:responseID] == NO);
    
    
}

-(void)comeToFront
{
    [self.spriteManagerDelegate bringToFrontSprite:self];
}

-(void)goNStepsBack:(int)n
{
    [self.spriteManagerDelegate bringNStepsBackSprite:self numberOfSteps:n];
}

-(void)changeSizeByN:(float)sizePercentageRate
{
    self.scaleWidth  += sizePercentageRate / 100.0f;
    self.scaleHeight += sizePercentageRate / 100.0f;
    
    [self setSpriteSizeWithWidth:self.scaleWidth*self.originalImageSize.width andHeight:self.scaleHeight*self.originalImageSize.height];
}

-(void)changeXBy:(int)x
{
    self.position = GLKVector3Make(self.position.x + x, self.position.y, self.position.z);
}

-(void)changeYBy:(int)y
{
    self.position = GLKVector3Make(self.position.x, self.position.y + y, self.position.z);
}


-(void)setSizeToPercentage:(float)sizeInPercentage
{
    self.scaleWidth  = sizeInPercentage / 100.0f;
    self.scaleHeight = sizeInPercentage / 100.0f;
    [self setSpriteSizeWithWidth:self.scaleWidth*self.originalImageSize.width andHeight:self.scaleHeight*self.originalImageSize.height];
}

-(void)setTransparency:(float)transparency
{
#warning still valid?? maybe transparency has to be multiplied by 100???
    if(transparency > 100.0f) {
        transparency = 100.0f;
    }
    if(transparency < 0.0f) {
        transparency = 0.0f;
    }
    self.alphaValue = (100.0f-transparency)/100.0f;
}

-(void)changeTransparencyBy:(NSNumber*)increase
{
    self.alphaValue -= increase.floatValue;
    if(self.alphaValue > 1.0f) {
        self.alphaValue = 1.0f;
    }
    if(self.alphaValue < 0.0f) {
        self.alphaValue = 0.0f;
    }
}

- (void)addSound:(AVAudioPlayer *)player
{
    [self.audioPlayerList addObject:player];
    player.delegate = self;
    [player play];
}

-(void)stopAllSounds
{    
    for(AVAudioPlayer* player in self.audioPlayerList)
    {
        [player stop];
    }
    [self.audioPlayerList removeAllObjects];
}


- (void)setVolumeTo:(float)volume
{
    for(AVAudioPlayer* player in self.audioPlayerList)
    {
        player.volume = volume;
    }
}

-(void)changeVolumeBy:(float)percent
{
    for(AVAudioPlayer* player in self.audioPlayerList)
    {
        player.volume += percent;
    }
}

-(void)turnLeft:(float)degrees
{
    self.rotationInDegrees += degrees;
}

-(void)turnRight:(float)degrees
{
    self.rotationInDegrees -= degrees;
}


#pragma mark - description
//- (NSString*)description
//{
//    NSMutableString *ret = [[NSMutableString alloc] init];
//    
//    [ret appendFormat:@"Sprite (0x%@):\n", self];
//    [ret appendFormat:@"\t\t\tName: %@\n", self.name];
//    [ret appendFormat:@"\t\t\tPosition: [%f, %f, %f] (x, y, z)\n", self.position.x, self.position.y, self.position.z];
//    [ret appendFormat:@"\t\t\tContent size: [%f, %f] (x, y)\n", self.contentSize.width, self.contentSize.height];
//    [ret appendFormat:@"\t\t\tCostume index: %d\n", self.indexOfCurrentCostumeInArray.intValue];
//    
//    if ([self.costumesArray count] > 0)
//    {
//        [ret appendString:@"\t\t\tCostumes:\n"];
//        for (Costume *costume in self.costumesArray)
//        {
//            [ret appendFormat:@"\t\t\t\t - %@\n", costume];
//        }
//    }
//    else 
//    {
//        [ret appendString:@"\t\t\tCostumes: None\n"];
//    }
//
//    if ([self.soundList count] > 0)
//    {
//        [ret appendString:@"\t\t\tSounds\n"];
//        for (Sound *sound in self.soundList)
//        {
//            [ret appendFormat:@"\t\t\t\t - %@\n", sound];
//        }
//    }
//    else 
//    {
//        [ret appendString:@"\t\t\tSounds: None\n"];
//    }
//
//    
//    //[ret appendFormat:@"\t\t\tCostumes: %@\n", self.costumesArray];
//    //[ret appendFormat:@"\t\t\tSounds: %@\n", self.soundsArray];    
//    
//    return [[NSString alloc] initWithString:ret];
//}

- (NSString*)description {
    NSMutableString *ret = [[NSMutableString alloc] init];
    //[ret appendFormat:@"Sprite: (0x%@):\n", self];
    [ret appendFormat:@"\r------------------- SPRITE --------------------\r"];
    [ret appendFormat:@"Name: %@\r", self.name];
    [ret appendFormat:@"Look List: \r%@\r\r", self.lookList];
    [ret appendFormat:@"Script List: \r%@\r", self.scriptList];
    [ret appendFormat:@"-------------------------------------------------\r"];

    
    return [NSString stringWithString:ret];
}


- (CGRect)boundingBox
{
    CGSize scaledContentSize = CGSizeMake(self.contentSize.width * self.scaleFactor, self.contentSize.height * self.scaleFactor);
    
    float x = self.position.x * self.scaleFactor + [UIScreen mainScreen].bounds.size.width /2.0f - scaledContentSize.width /2.0f;
    float y = self.position.y * self.scaleFactor + [UIScreen mainScreen].bounds.size.height/2.0f - scaledContentSize.height/2.0f;
    
    CGRect rect = CGRectMake(x, y, scaledContentSize.width, scaledContentSize.height);
    return rect;
}

#pragma mark - script methods
- (void)start
{
    //self.indexOfCurrentCostumeInArray = [NSNumber numberWithInt:0]; // TODO: maybe remove this line??
    
    
    // init BroadcastWait-stuff
    for (Script *script in self.scriptList) {
        if ([script isKindOfClass:[Broadcastscript class]]) {
            Broadcastscript *broadcastScript = script;
            if ([self.broadcastWaitDelegate respondsToSelector:@selector(increaseNumberOfObserversForNotificationMessage:)]) {
                [self.broadcastWaitDelegate increaseNumberOfObserversForNotificationMessage:broadcastScript.receivedMessage];
            } else {
                NSLog(@"ERROR: BroadcastWaitDelegate not set! abort()");
                abort();
            }
            
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(performBroadcastScript:) name:broadcastScript.receivedMessage object:nil];
        }
    }


    for (Script *script in self.scriptList)
    {
        if ([script isKindOfClass:[Startscript class]]) {
            [self.activeScripts addObject:script];
            
            // ------------------------------------------ THREAD --------------------------------------
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [script runScript];
                
                // tell the main thread
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self scriptFinished:script];
                });
            });
            // ------------------------------------------ END -----------------------------------------
        }
    }
}

-(BOOL)isType:(TouchAction)type equalToString:(NSString*)action
{
#warning add other possible action-types
    if (type == kTouchActionTap && [action isEqualToString:@"Tapped"]) {
        return YES;
    } else {
        return NO;
    }
}

- (void)touch:(TouchAction)type
{
    //todo: throw exception if its not a when script
    for (Script *script in self.scriptList)
    {
        if ([script isKindOfClass:[Whenscript class]]) {
            NSLog(@"Performing script with action: %@", script.description);
            if ([self isType:type equalToString:script.action])
            {
                if ([self.activeScripts containsObject:script]) {
                    [script resetScript];
                    [self.nextPositions removeObjectForKey:script.description];
                } else {
                    [self.activeScripts addObject:script];
                    
                    // ------------------------------------------ THREAD --------------------------------------
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        [script runScript];
                        
                        // tell the main thread
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self scriptFinished:script];
                        });
                    });
                    // ------------------------------------------ END -----------------------------------------
                }
            }
        
        }
    }
}

- (void)performBroadcastScript:(NSNotification*)notification
{
    NSLog(@"Notification: %@", notification.name);
    Broadcastscript *script = nil;
    
    for (Script *s in self.scriptList) {
        if ([s isKindOfClass:[Broadcastscript class]]) {
            Broadcastscript *tmp = (Broadcastscript*)s;
            if ([tmp.receivedMessage isEqualToString:notification.name]) {
                script = tmp;
            }
        }
    }
    
    if (script) {
    
        if ([self.activeScripts containsObject:script]) {
            [script resetScript];
            [self.nextPositions removeObjectForKey:script.description];
        } else {
            [self.activeScripts addObject:script];
            
            // -------- ---------------------------------- THREAD --------------------------------------
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [script runScript];
                
                // tell the main thread
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    NSString *responseID = (NSString*)[notification.userInfo valueForKey:@"responseID"];
                    if (responseID != nil) {
                        [[NSNotificationCenter defaultCenter]postNotificationName:responseID object:self];
                    }
                    
                    [self scriptFinished:script];
                });
            });
            // ------------------------------------------ END -----------------------------------------
        }

    }
}

-(void)scriptFinished:(Script *)script
{
    [self.nextPositions removeObjectForKey:script.description];
    [self.activeScripts removeObject:script];
}

-(void)stopAllScripts
{
    for (Script *script in self.activeScripts) {
        [script stopScript];
    }
    self.nextPositions = nil;
    self.activeScripts = nil;
}

#pragma mark AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [self.audioPlayerList removeObject:player];
}


@end
