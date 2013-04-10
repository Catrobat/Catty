//
//  LoadingView.m
//  Catty
//
//  Created by Dominik Ziegler on 3/25/13.
//  Copyright (c) 2013 Graz University of Technology. All rights reserved.
//

#import "LoadingView.h"
#import "UIColor+CatrobatUIColorExtensions.h"

#import <QuartzCore/QuartzCore.h>

#define kLoadingBackgroundHeight 100
#define kLoadingBackgroundWidth 270

@interface LoadingView()

@property(nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property(nonatomic, strong) UILabel *loadingLabel;

@end

@implementation LoadingView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)init
{
    if (self = [super initWithFrame:CGRectMake(25, 130, kLoadingBackgroundWidth, kLoadingBackgroundHeight)]) {
        
        self.backgroundColor = [UIColor clearColor];
        self.alpha = 0.80;
        self.layer.cornerRadius = 5;
        

        [self initLoadingLabel];
        [self initActivityIndicator];
        
    }
    
    return self;
}


-(void) hide
{
    [self.activityIndicator stopAnimating];
    self.hidden = YES;
}

-(void) show
{
    [self.activityIndicator startAnimating];
    self.hidden = NO;
    [self.superview bringSubviewToFront:self];
    CGFloat height = (self.superview.bounds.size.height / 2) - (kLoadingBackgroundHeight/2.0);
    CGFloat width = self.superview.bounds.size.width / 2;
    self.center = CGPointMake(width, height);
}

- (void)initLoadingLabel
{
    self.loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 65, 240, 20)];
    self.loadingLabel.backgroundColor = [UIColor clearColor];
    self.loadingLabel.textColor = [UIColor blueGrayColor];
    NSString* loadingText = [[NSString alloc] initWithFormat:@"%@...", NSLocalizedString(@"Loading", nil) ];
    self.loadingLabel.text = loadingText;
    self.loadingLabel.textAlignment = UITextAlignmentCenter;
    self.loadingLabel.font = [UIFont boldSystemFontOfSize:16];
    self.loadingLabel.adjustsFontSizeToFitWidth = YES;
    
    [self addSubview:self.loadingLabel];
}

- (void)initActivityIndicator
{
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.activityIndicator.frame = CGRectMake(115, 15, 40, 40);
    
    [self addSubview:self.activityIndicator];
}


- (void)dealloc
{
    self.activityIndicator = nil;
    self.loadingLabel = nil;
}



@end
