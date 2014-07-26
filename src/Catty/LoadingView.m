/**
 *  Copyright (C) 2010-2014 The Catrobat Team
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


#import "LoadingView.h"
#import "UIColor+CatrobatUIColorExtensions.h"
#import "UIDefines.h"
#import <QuartzCore/QuartzCore.h>
#import "LanguageTranslationDefines.h"

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
  }
  return self;
}

- (id)init
{
  if (self = [super initWithFrame:CGRectMake(25, 130, kLoadingBackgroundWidth, kLoadingBackgroundHeight)]) {
    self.tag = kLoadingViewTag;
    self.backgroundColor = [UIColor clearColor];
    self.alpha = 0.80;
    self.layer.cornerRadius = 5;
    [self initLoadingLabel];
    [self initActivityIndicator];
  }
  return self;
}

- (void)hide
{
  [self.activityIndicator stopAnimating];
  self.hidden = YES;
}

- (void)show
{
  [self.activityIndicator startAnimating];
  self.hidden = NO;
  [self.superview bringSubviewToFront:self];
  CGFloat height = (self.superview.bounds.size.height / 2) - (kLoadingBackgroundHeight/2.0);
  CGFloat width = self.superview.bounds.size.width / 2;
  self.center = CGPointMake(width, height);
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
  [super setBackgroundColor:backgroundColor];
  if ([backgroundColor isEqual:[UIColor whiteColor]])
    self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
  else
    self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
}

- (void)initLoadingLabel
{
  self.loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 65, 240, 20)];
  self.loadingLabel.backgroundColor = [UIColor clearColor];
  self.loadingLabel.textColor = [UIColor blueGrayColor];
  NSString* loadingText = [[NSString alloc] initWithFormat:@"%@...", kUILabelTextLoading];
  self.loadingLabel.text = loadingText;
  self.loadingLabel.textAlignment = NSTextAlignmentCenter;
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
