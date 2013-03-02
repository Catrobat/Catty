//
//  CatrobatImageCell.h
//  Catty
//
//  Created by Dominik Ziegler on 3/2/13.
//  Copyright (c) 2013 Graz University of Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CatrobatImageCell <NSObject>

@required
@property (strong, nonatomic) IBOutlet UIImageView *imageView;

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;

@end
