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

#import "ScriptCell.h"

@implementation ScriptCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
      self.contentMode = UIViewContentModeScaleToFill;
      self.clipsToBounds = YES;
    }
    return self;
}

#pragma mark layout

- (void)setupBrickView:(NSDictionary *)labels {
   NSAssert(NO, @"Must be overridden");
}

- (void)layoutSubviews {
  [super layoutSubviews];
  
  if (self.backgroundImage) {
    self.backgroundImage.frame = self.frame;
    [self.contentView addSubview:self.backgroundImage];
    [self.contentView sendSubviewToBack:self.backgroundImage];
  }
}

#pragma mark Background Image

- (UIImageView *)backgroundImage {
  if (!_backgroundImage) {
    _backgroundImage = [UIImageView new];
    return _backgroundImage;
  }
  return nil;
}

- (void)setBackgroundImage:(UIImageView *)backgroundImage withTintColor:(UIColor *)tintColor {
  UIImage *stencilImage = [UIImage imageNamed:@"background_image__brick"];
  stencilImage = [stencilImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
  self.backgroundImage.image = stencilImage;
  self.backgroundImage.tintColor = tintColor;
}

@end
