//
//  DarkBlueGradientImageCell.m
//  Catty
//
//  Created by Dominik Ziegler on 3/2/13.
//  Copyright (c) 2013 Graz University of Technology. All rights reserved.
//

#import "DarkBlueGradientImageCell.h"
#import "UIColor+CatrobatUIColorExtensions.h"


@implementation DarkBlueGradientImageCell


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

-(void)awakeFromNib
{
    [self configureImageCell];
}

-(void)configureImageCell {
    self.titleLabel.textColor = [UIColor brightBlueColor];
}


@end
