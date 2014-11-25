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

#import <UIKit/UIKit.h>
typedef enum{
    TimerLabelTypeStopWatch,
    TimerLabelTypeTimer
}TimerLabelType;

 
@class TimerLabel;
@protocol TimerLabelDelegate <NSObject>
@optional
-(void)timerLabel:(TimerLabel*)timerLabel finshedCountDownTimerWithTime:(NSTimeInterval)countTime;
-(void)timerLabel:(TimerLabel*)timerLabel countingTo:(NSTimeInterval)time timertype:(TimerLabelType)timerType;
-(NSString*)timerLabel:(TimerLabel*)timerLabel customTextToDisplayAtTime:(NSTimeInterval)time;
@end

@interface TimerLabel : UILabel;

@property (nonatomic, weak) id<TimerLabelDelegate> delegate;

@property (nonatomic,copy) NSString *timeFormat;


@property (nonatomic,strong) UILabel *timeLabel;


@property (assign) TimerLabelType timerType;

@property (assign,readonly) BOOL counting;


@property (assign) BOOL resetTimerAfterFinish;


-(id)initWithTimerType:(TimerLabelType)theType;
-(id)initWithLabel:(UILabel*)theLabel andTimerType:(TimerLabelType)theType;
-(id)initWithLabel:(UILabel*)theLabel;


-(void)start;
#if NS_BLOCKS_AVAILABLE
-(void)startWithEndingBlock:(void(^)(NSTimeInterval countTime))end; //use it if you are not going to use delegate
#endif
-(void)pause;
-(void)reset;

-(void)setCountDownTime:(NSTimeInterval)time;
-(void)setStopWatchTime:(NSTimeInterval)time;
-(void)setCountDownToDate:(NSDate*)date;

-(void)addTimeCountedByTime:(NSTimeInterval)timeToAdd;

- (NSTimeInterval)getTimeCounted;


@end


