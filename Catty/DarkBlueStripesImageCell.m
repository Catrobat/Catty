//
//  DarkBlueStripesImageCell.m
//  Catty
//
//  Created by Dominik Ziegler on 3/2/13.
//  Copyright (c) 2013 Graz University of Technology. All rights reserved.
//

#import "DarkBlueStripesImageCell.h"
#import "UIColor+CatrobatUIColorExtensions.h"

@implementation DarkBlueStripesImageCell


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


-(id)initWithCoder:(NSCoder *)aDecoder
{
    if(self = [super initWithCoder:aDecoder]) {
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
