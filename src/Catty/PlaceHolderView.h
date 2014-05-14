//
//  PlaceHolderView.h
//  Catty
//
//  Created by luca on 07/05/14.
//
//

#import "FBShimmeringView.h"

@interface PlaceHolderView : FBShimmeringView
- (id)initWithTitle:(NSString *)tile;

@property (nonatomic, strong) NSString *title;

@end
