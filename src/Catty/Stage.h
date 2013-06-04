//
//  Game.h
//  AppScaffold
//

#import <Foundation/Foundation.h>
#import <UIKit/UIDevice.h>
#import "SPSprite.h"

@class Program;

@interface Stage : SPSprite

@property (nonatomic, strong) Program *program;


-(void)start;

@end
