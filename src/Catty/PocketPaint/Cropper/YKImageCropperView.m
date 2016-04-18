	//
//  YKImageCropperView.m
//  Copyright (c) 2013 yuyak. All rights reserved.
//

#import "YKImageCropperView.h"

#import "YKImageCropperOverlayView.h"
#import "ImageHelper.h"

typedef NS_ENUM(NSUInteger, OverlayViewPanningMode) {
    OverlayViewPanningModeNone     = 0,
    OverlayViewPanningModeLeft     = 1 << 0,
    OverlayViewPanningModeRight    = 1 << 1,
    OverlayViewPanningModeTop      = 1 << 2,
    OverlayViewPanningModeBottom   = 1 << 3
};

static CGSize minSize = {40, 40};

@interface YKImageCropperView ()

// Remember first touched point
@property (nonatomic, assign) CGPoint firstTouchedPoint;

// Panning mode for oeverlay view
@property (nonatomic, assign) OverlayViewPanningMode OverlayViewPanningMode;

// Returns if panning is for overlay view
@property (nonatomic, assign) BOOL isPanningOverlayView;

// Current scale (up to 1)
@property (nonatomic, assign) CGFloat currentScale;

// Image view
@property (nonatomic, strong) UIImageView *imageView;

// Minimum size for image, maximum size for overlay
@property (nonatomic, assign) CGRect baseRect;

// Overlay view
@property (nonatomic, strong) YKImageCropperOverlayView *overlayView;

@end

@implementation YKImageCropperView

- (id)initWithImage:(UIImage *)image andFrame:(CGRect)frame
{
    self = [super init];
    if (self) {
        self.image = image;
        self.frame = frame;
//        self.backgroundColor = [UIColor yellowColor];

        self.imageView = [[UIImageView alloc] init];
        self.imageView.image = image;

        // Pinch
//        UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self
//                                                                                                     action:@selector(pinchGesture:)];
//        [self addGestureRecognizer:pinchGestureRecognizer];

        // Pan
        UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                               action:@selector(panGesture:)];
        panGestureRecognizer.maximumNumberOfTouches = 1;
        [self addGestureRecognizer:panGestureRecognizer];

        CGRect frames;
        frames.origin = CGPointMake(0, 0);
        frames.size = [self getImageSizeForPreview:image];
        self.imageView.frame = frames;
        self.imageView.center = self.center;
        self.baseRect = self.imageView.frame;
        [self addSubview:self.imageView];

        // Overlay
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        self.overlayView = [[YKImageCropperOverlayView alloc] initWithFrame:CGRectMake(0, 0, screenRect.size.width , screenRect.size.height)];
        
        [self addSubview:self.overlayView];
        UIGraphicsBeginImageContextWithOptions(image.size, NO, 0.0);
        UIImage *blank = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        NSData *imgdata1 = UIImagePNGRepresentation(blank);
        
        NSData *imgdata2 = UIImagePNGRepresentation(image);
        
        if (![imgdata1 isEqualToData:imgdata2]) {
            [self autoCropWithImage:self.image];
        }else{
           [self reset];
        }
    }

    return self;
}

- (UIImage *)editedImage {
    CGFloat scale = self.image.size.width / self.imageView.frame.size.width;
    CGRect rect = self.overlayView.clearRect;
    rect.origin.x = (rect.origin.x - self.imageView.frame.origin.x) * scale;
    rect.origin.y = (rect.origin.y - self.imageView.frame.origin.y) * scale;
    rect.size.width *= scale;
    rect.size.height *= scale;

    UIGraphicsBeginImageContext(rect.size);
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextClipToRect(c, CGRectMake(0, 0, rect.size.width, rect.size.height));
    [self.image drawInRect:CGRectMake(-rect.origin.x, -rect.origin.y, self.image.size.width, self.image.size.height)];
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return result;
}

- (void)reset {
    self.currentScale = 1.0;
    self.imageView.frame = self.baseRect;
    CGRect clearRect = self.baseRect;
    clearRect.origin = CGPointMake((self.frame.size.width - self.baseRect.size.width) / 2.0f,
                                   (self.frame.size.height - self.baseRect.size.height) / 2.0f);
    self.overlayView.clearRect = clearRect;
    [self.overlayView setNeedsDisplay];
}

- (void)square {
    [self setConstrain:CGSizeMake(1, 1)];
}

- (void)setConstrain:(CGSize)size {
    CGFloat constrainRatio = size.width / size.height;
    CGFloat currentRatio = self.overlayView.clearRect.size.width / self.overlayView.clearRect.size.height;
    CGSize newSize = self.overlayView.clearRect.size;

    if (currentRatio > constrainRatio) {
        newSize.width = newSize.height * constrainRatio;
    } else {
        newSize.height = newSize.width * (size.height / size.width);
    }

    // Size should be bigger than min size
    if (newSize.width < minSize.width || newSize.height < minSize.height) {
        if (size.height / size.width > 1) {
            newSize.width = minSize.width;
            newSize.height = minSize.width * size.height / size.width;
        } else {
            newSize.width = minSize.width * size.width / size.height;
            newSize.height = minSize.height;
        }
    }

    CGRect frame = self.overlayView.clearRect;
    frame.size = newSize;
    self.overlayView.clearRect = frame;

    [self.overlayView setNeedsDisplay];
}

- (CGSize)getImageSizeForPreview:(UIImage *)image {
    CGFloat maxWidth = self.frame.size.width - 40, maxHeight = self.frame.size.height - 40;

    CGSize size = image.size;

    if (size.width > maxWidth) {
        size.height *= (maxWidth / size.width);
        size.width = maxWidth;
    }

    if (size.height > maxHeight) {
        size.width *= (maxHeight / size.height);
        size.height = maxHeight;
    }

    if (size.width < minSize.width) {
        size.height *= (minSize.width / size.width);
        size.width = minSize.width;
    }

    if (size.height < minSize.height) {
        size.width *= (minSize.height / size.height);
        size.height = minSize.height;
    }

    return size;
}

- (void)setCurrentScale:(CGFloat)currentScale {
    _currentScale = MAX(1.0f, currentScale);
}

- (BOOL)shouldRevertX {
    CGRect clearRect = self.overlayView.clearRect;
    CGRect imageRect = self.imageView.frame;

    if (CGRectGetMinX(imageRect) > CGRectGetMinX(clearRect)
        || CGRectGetMaxX(imageRect) < CGRectGetMaxX(clearRect)) {
        return YES;
    }

    if (CGRectGetMinX(clearRect) < CGRectGetMinX(self.baseRect)
        || CGRectGetMaxX(clearRect) > CGRectGetMaxX(self.baseRect)) {
        return YES;
    }

    if (clearRect.size.width < minSize.width) {
        return YES;
    }

    return NO;
}

- (BOOL)shouldRevertY {
    CGRect clearRect = self.overlayView.clearRect;
    CGRect imageRect = self.imageView.frame;

    if (CGRectGetMinY(imageRect) > CGRectGetMinY(clearRect)
        || CGRectGetMaxY(imageRect) < CGRectGetMaxY(clearRect)) {
        return YES;
    }

    if (CGRectGetMinY(clearRect) < CGRectGetMinY(self.baseRect)
        || CGRectGetMaxY(clearRect) > CGRectGetMaxY(self.baseRect)) {
        return YES;
    }

    if (clearRect.size.height < minSize.height) {
        return YES;
    }

    return NO;
}

- (void)pinchGesture:(UIPinchGestureRecognizer *)sender {
    CGFloat newScale = self.currentScale * sender.scale;
    CGRect oldImageFrame = self.imageView.frame;
    CGSize newSize = CGSizeMake(newScale * self.baseRect.size.width,
                                newScale * self.baseRect.size.height);

    // Update frame
    CGRect newFrame = self.imageView.frame;
    newFrame.size = newSize;
    self.imageView.frame = newFrame;

    // Move center
    CGPoint d = CGPointMake((oldImageFrame.size.width - newFrame.size.width) / 2.0f,
                            (oldImageFrame.size.height - newFrame.size.height) / 2.0f);
    self.imageView.center = CGPointMake(self.imageView.center.x + d.x,
                                        self.imageView.center.y + d.y);

    if (([self shouldRevertX] || [self shouldRevertY])) {
        self.imageView.frame = oldImageFrame;
    } else {
        self.currentScale = newScale;
    }

    // Reset scale
    sender.scale = 1;
}

- (OverlayViewPanningMode)getOverlayViewPanningModeByPoint:(CGPoint)point {
    if (CGRectContainsPoint(self.overlayView.topLeftCorner, point)) {
        return (OverlayViewPanningModeLeft | OverlayViewPanningModeTop);
    } else if (CGRectContainsPoint(self.overlayView.topRightCorner, point)) {
        return (OverlayViewPanningModeRight | OverlayViewPanningModeTop);
    } else if (CGRectContainsPoint(self.overlayView.bottomLeftCorner, point)) {
        return (OverlayViewPanningModeLeft | OverlayViewPanningModeBottom);
    } else if (CGRectContainsPoint(self.overlayView.bottomRightCorner, point)) {
        return (OverlayViewPanningModeRight | OverlayViewPanningModeBottom);
    } else if (CGRectContainsPoint(self.overlayView.topEdgeRect, point)) {
        return OverlayViewPanningModeTop;
    } else if (CGRectContainsPoint(self.overlayView.rightEdgeRect, point)) {
        return OverlayViewPanningModeRight;
    } else if (CGRectContainsPoint(self.overlayView.bottomEdgeRect, point)) {
        return OverlayViewPanningModeBottom;
    } else if (CGRectContainsPoint(self.overlayView.leftEdgeRect, point)) {
        return OverlayViewPanningModeLeft;
    }

    return OverlayViewPanningModeNone;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];

    if ([touches count] == 1) {
        self.firstTouchedPoint = [(UITouch*)[touches anyObject] locationInView:self];
    }
}

- (void)panGesture:(UIPanGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        CGPoint point = self.firstTouchedPoint;

        if ([self.overlayView isCornerContainsPoint:point] || [self.overlayView isEdgeContainsPoint:point]) {
            // Corner or Edge
            self.isPanningOverlayView = YES;
            self.OverlayViewPanningMode = [self getOverlayViewPanningModeByPoint:point];
        } else {
            // Image
            self.isPanningOverlayView = NO;
        }
    }

    if (self.isPanningOverlayView) {
        [self panOverlayView:sender];
    } else {
        [self panImage:sender];
    }

    // Reset points
    [sender setTranslation:CGPointZero inView:self];
}

- (void)panOverlayView:(UIPanGestureRecognizer *)sender {
    CGPoint d = [sender translationInView:self];
//    CGRect oldClearRect = self.overlayView.clearRect;
    CGRect newClearRect = self.overlayView.clearRect;

    if (self.OverlayViewPanningMode & OverlayViewPanningModeLeft) {
        newClearRect.origin.x += d.x;
        newClearRect.size.width -= d.x;
    } else if (self.OverlayViewPanningMode & OverlayViewPanningModeRight) {
        newClearRect.size.width += d.x;
    }

    if (self.OverlayViewPanningMode & OverlayViewPanningModeTop) {
        newClearRect.origin.y += d.y;
        newClearRect.size.height -= d.y;
    } else if (self.OverlayViewPanningMode & OverlayViewPanningModeBottom) {
        newClearRect.size.height += d.y;
    }

    self.overlayView.clearRect = newClearRect;

    // Check x
//    if ([self shouldRevertX]) {
//        newClearRect.origin.x = oldClearRect.origin.x;
//        newClearRect.size.width = oldClearRect.size.width;
//    }
//
//    // Check y
//    if ([self shouldRevertY]) {
//        newClearRect.origin.y = oldClearRect.origin.y;
//        newClearRect.size.height = oldClearRect.size.height;
//    }
    
    self.overlayView.clearRect = newClearRect;
    [self.overlayView setNeedsDisplay];
}

- (void)panImage:(UIPanGestureRecognizer *)sender {
    CGPoint d = [sender translationInView:self];
//    NSDebug(@"Point: %@", d);
    CGPoint newCenter = CGPointMake(self.imageView.center.x + d.x,
                                    self.imageView.center.y + d.y);
    self.imageView.center = newCenter;

//    // Check x
//    if ([self shouldRevertX]) {
//        newCenter.x -= d.x;
//    }
//
//    // Check y
//    if ([self shouldRevertY]) {
//        newCenter.y -= d.y;
//    }

    self.imageView.center = newCenter;
}

- (void)autoCropWithImage:(UIImage *)image
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGImageRef imageRef = image.CGImage;
    
    NSUInteger img_width = CGImageGetWidth(imageRef);
    NSUInteger img_height = CGImageGetHeight(imageRef);
    NSUInteger bytesPerRow = CGImageGetBytesPerRow(imageRef);
    NSUInteger bitsPerComponent = CGImageGetBitsPerComponent(imageRef);
    NSUInteger bytesPerPixel = CGImageGetBitsPerPixel(imageRef) / 8;
    
    unsigned char *imageData = calloc(img_height*bytesPerRow,4);
    memset(imageData, 0, img_height*bytesPerRow*4);
    
    CGContextRef context = CGBitmapContextCreate(imageData,
                                                 img_width,
                                                 img_height,
                                                 bitsPerComponent,
                                                 bytesPerRow,
                                                 colorSpace,
                                                 CGImageGetBitmapInfo(imageRef));
    
    CGColorSpaceRelease(colorSpace);
    
    CGContextDrawImage(context, CGRectMake(0, 0, img_width, img_height), imageRef);
    
    float firstXValue = 0.0f;
    float firstYValue = 0.0f;
    float lastXValue = 0.0f;
    float lastYValue = 0.0f;
    
    CGFloat scale = self.image.size.width / self.imageView.frame.size.width;

    UIColor *compareColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    const CGFloat *components = CGColorGetComponents(compareColor.CGColor);
    
    int compareRed, compareGreen, compareBlue, compareAlpha;
    compareRed   = compareGreen = compareBlue = components[0] * 255;
    compareAlpha = components[1] * 255;

    unsigned int compare_color = (compareRed << 24) | (compareGreen << 16) | (compareBlue << 8) | compareAlpha;

    for (float y = 0; y < self.image.size.height; y++) {
        for (float x = 0; x < self.image.size.width; x++) {
            NSUInteger byteIndex = (bytesPerRow * y) + x * bytesPerPixel;
            unsigned int color = getColorCodeForAutoCrop(byteIndex, imageData);
            if (!compareColorForAutoCrop(compare_color, color, 0)) {
                firstYValue = y;
                break;
            }
        }
    }
    
    for (float y = self.image.size.height-1; y >= 0; y--) {
        for (float x = 0; x < self.image.size.width; x++) {
            NSUInteger byteIndex = (bytesPerRow * y) + x * bytesPerPixel;
            unsigned int color = getColorCodeForAutoCrop(byteIndex, imageData);
            if (!compareColorForAutoCrop(compare_color, color, 0)) {
                lastYValue = y;
                break;
            }
        }
    }
    for (float x = 0; x < self.image.size.width; x++) {
        for (float y = 0; y < self.image.size.height; y++) {
            NSUInteger byteIndex = (bytesPerRow * y) + x * bytesPerPixel;
            unsigned int color = getColorCodeForAutoCrop(byteIndex, imageData);
            if (!compareColorForAutoCrop(compare_color, color, 0)) {
                firstXValue = x;
                break;
            }
        }
    }
    
    for (float x = self.image.size.width-1; x >= 0; x--) {
        for (float y = 0; y < self.image.size.height; y++) {
            NSUInteger byteIndex = (bytesPerRow * y) + x * bytesPerPixel;
            unsigned int color = getColorCodeForAutoCrop(byteIndex, imageData);
            if (!compareColorForAutoCrop(compare_color, color, 0)) {
                lastXValue = x;
                break;
            }
        }
    }

    self.imageView.frame = self.baseRect;
    
    float diffx = (self.frame.size.width - self.baseRect.size.width) / 2.0f;
    float diffy = (self.frame.size.height - self.baseRect.size.height) / 2.0f;
    float width = (firstXValue - lastXValue) / scale;
    float height = (firstYValue - lastYValue) / scale;
    float start_x = (lastXValue / scale) + diffx;
    float start_y = (lastYValue / scale ) + diffy;
    
    CGRect clearRect = CGRectMake(start_x, start_y, width, height);
    self.overlayView.clearRect = clearRect;
    [self.overlayView setNeedsDisplay];
    
    CGContextRelease(context);
    free(imageData);
    if (width == 0.0f && height == 0.0f) {
        UIGraphicsBeginImageContextWithOptions(image.size, NO, 0.0);
        UIImage *blank = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        self.image = blank;
        [self reset];
    }
    
}

unsigned int getColorCodeForAutoCrop (NSUInteger byteIndex, unsigned char *imageData)
{
    unsigned int red   = imageData[byteIndex];
    unsigned int green = imageData[byteIndex + 1];
    unsigned int blue  = imageData[byteIndex + 2];
    unsigned int alpha = imageData[byteIndex + 3];
    
    return (red << 24) | (green << 16) | (blue << 8) | alpha;
}

bool compareColorForAutoCrop (unsigned int color1, unsigned int color2, int tolorance)
{
    if(color1 == color2)
        return true;
    
    int red1   = ((0xff000000 & color1) >> 24);
    int green1 = ((0x00ff0000 & color1) >> 16);
    int blue1  = ((0x0000ff00 & color1) >> 8);
    int alpha1 =  (0x000000ff & color1);
    
    int red2   = ((0xff000000 & color2) >> 24);
    int green2 = ((0x00ff0000 & color2) >> 16);
    int blue2  = ((0x0000ff00 & color2) >> 8);
    int alpha2 =  (0x000000ff & color2);
    
    if ((red1==0&&green1==0&&blue1==0&&alpha1==0) ||(red2==0&&green2==0&&blue2==0&&alpha2==0)) {
        return false;
    }
    
    int diffRed   = abs(red2   - red1);
    int diffGreen = abs(green2 - green1);
    int diffBlue  = abs(blue2  - blue1);
    int diffAlpha = abs(alpha2 - alpha1);
    
    if( diffRed   > tolorance ||
       diffGreen > tolorance ||
       diffBlue  > tolorance ||
       (diffAlpha > tolorance && diffAlpha < 255)   )
    {
        return false;
    }
    
    return true;
}

@end
