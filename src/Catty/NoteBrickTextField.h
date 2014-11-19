//
//  NoteBrickTextField.h
//  Catty
//
//  Created by Marc Slavec on 11/19/14.
//
//

#import <UIKit/UIKit.h>
#import "BrickCell.h"

@interface NoteBrickTextField : UITextField

@property (nonatomic,strong)BrickCell *cell;

- (id)initWithFrame:(CGRect)frame AndNote:(NSString*)note;
- (void)drawBorder:(BOOL)isActive;
- (void)update;
@end
