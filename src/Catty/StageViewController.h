//
//  StageViewController.h
//  Catty
//
//  Created by Mattias Rauter on 03.04.13.
//
//

#import "SPViewController.h"

@class ProgramLoadingInfo;

@interface StageViewController : SPViewController

@property (nonatomic, strong) ProgramLoadingInfo* programLoadingInfo;

- (void)backButtonPressed:(UIButton *)sender;

@end
