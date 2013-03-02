//
//  DarkBlueStripesImageCell.h
//  Catty
//
//  Created by Dominik Ziegler on 3/2/13.
//  Copyright (c) 2013 Graz University of Technology. All rights reserved.
//

#import "DarkBlueStripesCell.h"
#import "CatrobatImageCell.h"

@interface DarkBlueStripesImageCell : DarkBlueStripesCell <CatrobatImageCell>

@property (strong, nonatomic) IBOutlet UIImageView *imageView;

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;


@end
