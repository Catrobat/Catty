//
//  CattyAppDelegate.m
//  Catty
//
//  Created by Christof Stromberger on 07.07.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "Sprite.h"
#import "Costume.h"
#import "Sound.h"
#import "Script.h"
#import "WhenScript.h"
#import "Util.h"
#import "enums.h"

// need CattyViewController to access FRAMES_PER_SECOND    TODO: change
#import "CattyViewController.h"

//test
#import "CattyAppDelegate.h"


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

@implementation PositionAtTime
@synthesize position = _position;
@synthesize timestamp = _timestamp;
+(PositionAtTime*)positionAtTimeWithPosition:(GLKVector3)position andTimestamp:(double)timestamp
{
    PositionAtTime *obj = [[PositionAtTime alloc]init];
    obj.position = position;
    obj.timestamp = timestamp;
    return obj;
}
@end

//////////////////////////////////////////////////////////////////////////////////////////



@interface Sprite()

@property (assign) TexturedQuad quad;
@property (nonatomic, strong) GLKTextureInfo *textureInfo;

@property (assign) GLKVector3 position;        // "Real" position - origin is bottom-left


@property (atomic, strong) NSMutableArray *nextPositions;
@property (strong, nonatomic) NSNumber *indexOfCurrentCostumeInArray;

@property (strong, nonatomic) NSArray *costumesArray;    // tell the compiler: "I want a private setter"
@property (strong, nonatomic) NSArray *soundsArray;
@property (strong, nonatomic) NSArray *startScriptsArray;
@property (strong, nonatomic) NSArray *whenScriptsArray;



@end

@implementation Sprite

// public synthesizes
@synthesize name = _name;
@synthesize costumesArray = _costumesArray;
@synthesize soundsArray = _soundsArray;
@synthesize startScriptsArray = _startScriptsArray;
@synthesize whenScriptsArray = _whenScriptsArray;
@synthesize position = _position;
@synthesize contentSize = _contentSize;
@synthesize effect = _effect;

// private synthesizes
@synthesize quad = _quad;
@synthesize textureInfo = _textureInfo;
@synthesize nextPositions = _nextPositions;
@synthesize indexOfCurrentCostumeInArray = _indexOfCurrentCostumeInArray;


#pragma mark Custom getter and setter
- (NSArray*)costumesArray
{
    if (_costumesArray == nil)
        _costumesArray = [[NSArray alloc] init];

    return _costumesArray;
}

- (NSArray*)soundsArray
{
    if (_soundsArray == nil)
        _soundsArray = [[NSArray alloc] init];
    
    return _soundsArray;
}

- (NSArray*)startScriptsArray
{
    if (_startScriptsArray == nil)
        _startScriptsArray = [[NSArray alloc] init];
    
    return _startScriptsArray;
}

- (NSArray*)whenScriptsArray
{
    if (_whenScriptsArray == nil)
        _whenScriptsArray = [[NSArray alloc] init];
    
    return _whenScriptsArray;
}

- (NSMutableArray*)nextPositions
{
    if (!_nextPositions)
        _nextPositions = [[NSMutableArray alloc]init];
    return _nextPositions;
}

#pragma mark - init methods
- (id)init
{
    if (self = [super init]) 
    {
        _position = GLKVector3Make(0, 0, 0); //todo: change z index
    }
    return self;
}

- (id)initWithEffect:(GLKBaseEffect*)effect
{
    self = [super init];
    if (self)
    {
        self.effect = effect;
    }
    return self;
}

- (void)addCostume:(Costume *)costume
{
    self.costumesArray = [self.costumesArray arrayByAddingObject:costume];
}

- (void)addCostumes:(NSArray *)costumesArray
{
    self.costumesArray = [self.costumesArray arrayByAddingObjectsFromArray:costumesArray];
}

- (void)addSound:(Sound *)sound
{
    self.soundsArray = [self.soundsArray arrayByAddingObject:sound];
}

- (void)addStartScript:(StartScript *)script
{
    self.startScriptsArray = [self.startScriptsArray arrayByAddingObject:script];
}

- (void)addWhenScript:(WhenScript *)script
{
    self.whenScriptsArray = [self.whenScriptsArray arrayByAddingObject:script];
}

- (float)getZIndex
{
    return self.position.z;
}

#pragma mark - costume index SETTER
- (void)setIndexOfCurrentCostumeInArray:(NSNumber*)indexOfCurrentCostumeInArray
{
    _indexOfCurrentCostumeInArray = indexOfCurrentCostumeInArray;
    
    NSString *fileName = ((Costume*)[self.costumesArray objectAtIndex:[self.indexOfCurrentCostumeInArray intValue]]).costumeFileName;
    
    NSDictionary * options = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithBool:YES],
                              GLKTextureLoaderOriginBottomLeft, 
                              nil];
    
    NSError *error;    
    //NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
//    NSBundle *bundle = [NSBundle bundleForClass:[CattyAppDelegate class]];
//    NSString *path = [bundle pathForResource:fileName ofType:nil];
    
//    
//    
//    NSString *mainBundlePath = [[NSBundle mainBundle] resourcePath];
//    NSString *directBundlePath = [[NSBundle bundleForClass:[self class]] resourcePath];
//    NSLog(@"Main Bundle Path: %@", mainBundlePath);
//    NSLog(@"Direct Path: %@", directBundlePath);
//    NSString *mainBundleResourcePath = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
//    NSString *directBundleResourcePath = [[NSBundle bundleForClass:[self class]] pathForResource:fileName ofType:nil];
//    NSLog(@"Main Bundle Path: %@", mainBundleResourcePath);
//    NSLog(@"Direct Path: %@", directBundleResourcePath);    
    
    
//    NSString *newPath = [NSString stringWithFormat:@"%@/imageToLoadNow.png", [path stringByDeletingLastPathComponent]];
//    [[NSFileManager defaultManager] moveItemAtPath:path toPath:newPath error:&error];
//    NSLog(@"Error filemanager: %@", [error localizedDescription]);
//    
//    
    
    NSLog(@"Filename: %@", fileName);
    
    //NSString *pathToImage = [NSString stringWithFormat:@"%@/defaultProject/images/%@", [Util applicationDocumentsDirectory], fileName];
    NSString *pathToImage = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"/defaultProject/images/%@", fileName] ofType:nil];
    
    NSLog(@"Try to load image: %@", pathToImage);
    
    self.textureInfo = [GLKTextureLoader textureWithContentsOfFile:pathToImage options:options error:&error];
    if (self.textureInfo == nil) 
    {
        NSLog(@"Error loading file: %@", [error localizedDescription]);
        return;
    }

    
    self.contentSize = CGSizeMake(self.textureInfo.width, self.textureInfo.height);
    
    //test
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    NSLog(@"self width: %f", self.contentSize.width/2);
    NSLog(@"width: %f, newWidth: %f", width/2, (width/2 - self.contentSize.width/2));
    self.position = GLKVector3Make((width/2 - self.contentSize.width/2), (height/2 - self.contentSize.height/2), 0);
    //end of test
    
    
    TexturedQuad newQuad;
    newQuad.bottomLeftCorner.geometryVertex = CGPointMake(0, 0);
    newQuad.bottomRightCorner.geometryVertex = CGPointMake(self.textureInfo.width, 0);
    newQuad.topLeftCorner.geometryVertex = CGPointMake(0, self.textureInfo.height);
    newQuad.topRightCorner.geometryVertex = CGPointMake(self.textureInfo.width, self.textureInfo.height);

    newQuad.bottomLeftCorner.textureVertex = CGPointMake(0, 0);
    newQuad.bottomRightCorner.textureVertex = CGPointMake(1, 0);
    newQuad.topLeftCorner.textureVertex = CGPointMake(0, 1);
    newQuad.topRightCorner.textureVertex = CGPointMake(1, 1);
    self.quad = newQuad;
}

- (GLKMatrix4) modelMatrix 
{
    GLKMatrix4 modelMatrix = GLKMatrix4Identity;    
    modelMatrix = GLKMatrix4Translate(modelMatrix, self.position.x, self.position.y, self.position.z);
    //modelMatrix = GLKMatrix4Translate(modelMatrix, -self.contentSize.width/2, -self.contentSize.height/2, 0);
    
    return modelMatrix;
}

#pragma mark - graphics
- (void)update:(float)dt
{
    if ([self.nextPositions count] > 0)
    {
        NSTimeInterval now = [[NSDate date]timeIntervalSince1970];
        PositionAtTime *endPosition = [self.nextPositions objectAtIndex:0];
        
        NSLog(@"timediff: %f               %d", endPosition.timestamp - now, [self.nextPositions count]);
        
        if (now >= endPosition.timestamp)
        {
            // "checkpoint" reached
            self.position = endPosition.position;
            NSLog(@"remove object: %@", [self.nextPositions objectAtIndex:0]);
            [self.nextPositions removeObjectAtIndex:0];
        }
        else
        {
            // calculate position
            double timeLeft = (endPosition.timestamp - now);    // in sec
            int numberOfSteps = round(timeLeft * (float)FRAMES_PER_SECOND);               // TODO: find better way to determine FPS (e.g. GLK-variable??)
            
            GLKVector3 direction = GLKVector3Subtract(endPosition.position, self.position);
            
            GLKVector3 step = direction;
            if (numberOfSteps > 0)
                step = GLKVector3DivideScalar(direction, numberOfSteps);
          
            self.position = GLKVector3Add(self.position, step);
            
            NSLog(@"newPosition: %f/%f", self.position.x, self.position.y);
        }
    }
}

- (void)render
{ 
//    if ([self.nextPositions count] > 0)
//    {
//        NSValue *data = [self.nextPositions objectAtIndex:0];
//        GLKVector3 newPosition;
//        [data getValue:&newPosition];
//        self.position = newPosition;
//        
//        [self.nextPositions removeObjectAtIndex:0];
//    }
    
    if (!self.effect)
        NSLog(@"Sprite.m => render => NO effect set!!!");
    
    self.effect.texture2d0.name = self.textureInfo.name;
    self.effect.texture2d0.enabled = YES;
    
    self.effect.transform.modelviewMatrix = self.modelMatrix;
    
    [self.effect prepareToDraw];
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    
    long offset = (long)&_quad;        
    glVertexAttribPointer(GLKVertexAttribPosition, 2, GL_FLOAT, GL_FALSE, sizeof(TexturedVertex), (void *) (offset + offsetof(TexturedVertex, geometryVertex)));
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(TexturedVertex), (void *) (offset + offsetof(TexturedVertex, textureVertex)));
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}



#pragma mark - actions
-(void)placeAt:(GLKVector3)newPosition
{
//    NSLog(@"=====> %f %f", newPosition.x, newPosition.y);

    GLKVector3 position = GLKVector3Add(newPosition, GLKVector3Make(320/2, 460/2, 0));                        // TODO: change constant values
    position = GLKVector3Subtract(position, GLKVector3Make(self.textureInfo.width/2, self.textureInfo.height/2, 0));

    
    if ([self.nextPositions count] > 0)
    {
        [self.nextPositions addObject:[PositionAtTime positionAtTimeWithPosition:position andTimestamp:0]];
    }
    else
    {
        self.position = position;
    }
}

- (void)wait:(int)durationInMilliSecs
{
    GLKVector3 position;
    NSTimeInterval timeStamp;
    if ([self.nextPositions count] > 0)
    {
        PositionAtTime *lastPositionAtTime = [self.nextPositions objectAtIndex:[self.nextPositions count]-1];
        position = lastPositionAtTime.position;
        timeStamp = lastPositionAtTime.timestamp + (durationInMilliSecs/1000.0f);
    }
    else
    {
        position = self.position;
        timeStamp = [[NSDate date] timeIntervalSince1970] + (durationInMilliSecs/1000.0f);
    }
    [self.nextPositions addObject:[PositionAtTime positionAtTimeWithPosition:position andTimestamp:timeStamp]];
}

- (void)glideToPosition:(GLKVector3)position withinDurationInMilliSecs:(int)durationInMilliSecs
{
    // transfer to "origin is in the middle of the screen"-coordinates...
    position = GLKVector3Add(position, GLKVector3Make(320/2, 460/2, 0));                                // TODO: change constant values
    position = GLKVector3Subtract(position, GLKVector3Make(self.textureInfo.width/2, self.textureInfo.height/2, 0));

    NSTimeInterval timeStamp;
    if ([self.nextPositions count] > 0)
    {
        PositionAtTime *lastPositionAtTime = [self.nextPositions objectAtIndex:[self.nextPositions count]-1];
        timeStamp = lastPositionAtTime.timestamp + (durationInMilliSecs/1000.0f);
        NSLog(@"last: %f     new: %f", lastPositionAtTime.timestamp, timeStamp);

    }
    else
    {
        timeStamp = [[NSDate date] timeIntervalSince1970] + (durationInMilliSecs/1000);
    }
    
    PositionAtTime *newPosition = [PositionAtTime positionAtTimeWithPosition:position andTimestamp:timeStamp];
    [self.nextPositions addObject:newPosition];
    
//    // yes, it's an integer-cast
//    int number_of_frames = FRAMES_PER_SECOND / 1000.0f * durationInMilliSecs;
//    
//    position = GLKVector3Add(position, GLKVector3Make(320/2, 460/2, 0));    // TODO: change constant values
//    position = GLKVector3Subtract(position, GLKVector3Make(self.textureInfo.width/2, self.textureInfo.height/2, 0));
//
//    
//    if (self.nextPositions == nil)
//        self.nextPositions = [[NSMutableArray alloc]initWithCapacity:number_of_frames];
//    
//    ////////////////////////////////////////////////////////////////////
//    // TODO: dirty...change asap !!!
//    
//    GLKVector3 lastPosition = self.position;
//    
//    for (int i=1; i<number_of_frames; i++)
//    {
//        float xStep = round((position.x - lastPosition.x) / (float)(number_of_frames+1-i));
//        float yStep = round((position.y - lastPosition.y) / (float)(number_of_frames+1-i));
//        
//        GLKVector3 newPosition = GLKVector3Make(lastPosition.x + xStep, lastPosition.y + yStep, lastPosition.z);
//        NSData *data = [NSValue valueWithBytes:&newPosition objCType:@encode(GLKVector3)];
//        [self.nextPositions addObject:data];
//        
//        lastPosition = newPosition;
//    }
//    [self.nextPositions addObject:[NSValue valueWithBytes:&position objCType:@encode(GLKVector3)]];   // ensure, that final position is defined position
//    // TODO: really...CHANGE IT!!!!!
//    ////////////////////////////////////////////////////////////////////
}

- (void)changeCostume:(NSNumber *)indexOfCostumeInArray
{
    self.indexOfCurrentCostumeInArray = indexOfCostumeInArray;
}

#pragma mark - description
- (NSString*)description
{
    NSMutableString *ret = [[NSMutableString alloc] init];
    
    [ret appendFormat:@"Sprite (0x%x):\n", self];
    [ret appendFormat:@"\t\t\tName: %@\n", self.name];
    [ret appendFormat:@"\t\t\tPosition: [%f, %f, %f] (x, y, z)\n", self.position.x, self.position.y, self.position.z];
    [ret appendFormat:@"\t\t\tContent size: [%f, %f] (x, y)\n", self.contentSize.width, self.contentSize.height];
    [ret appendFormat:@"\t\t\tCostume index: %d\n", self.indexOfCurrentCostumeInArray];
    
    if ([self.costumesArray count] > 0)
    {
        [ret appendString:@"\t\t\tCostumes:\n"];
        for (Costume *costume in self.costumesArray)
        {
            [ret appendFormat:@"\t\t\t\t - %@\n", costume];
        }
    }
    else 
    {
        [ret appendString:@"\t\t\tCostumes: None\n"];
    }

    if ([self.soundsArray count] > 0)
    {
        [ret appendString:@"\t\t\tSounds\n"];
        for (Sound *sound in self.soundsArray)
        {
            [ret appendFormat:@"\t\t\t\t - %@\n", sound];
        }
    }
    else 
    {
        [ret appendString:@"\t\t\tSounds: None\n"];
    }

    
    //[ret appendFormat:@"\t\t\tCostumes: %@\n", self.costumesArray];
    //[ret appendFormat:@"\t\t\tSounds: %@\n", self.soundsArray];    
    
    return [[NSString alloc] initWithString:ret];
}


- (CGRect)boundingBox {
    CGRect rect = CGRectMake(self.position.x, self.position.y, self.contentSize.width, self.contentSize.height);
    return rect;
}

#pragma mark - script methods
- (void)start
{
    for (Script *script in self.startScriptsArray)
    {
        // ------------------------------------------ THREAD --------------------------------------
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [script executeForSprite:self];
        });
        // ------------------------------------------ END -----------------------------------------
    }
}


- (void)touch:(TouchAction)type
{
    //todo: throw exception if its not a when script
    for (WhenScript *script in self.whenScriptsArray)
    {
        NSLog(@"Performing script with action: %@", script.description);
        if (type == script.action)
        {
            // ------------------------------------------ THREAD --------------------------------------
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [script executeForSprite:self];
            });
            // ------------------------------------------ END -----------------------------------------
        }
    }
}


@end
