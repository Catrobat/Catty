//
//  NoteBrick.m
//  Catty
//
//  Created by Dominik Ziegler on 5/22/13.
//
//

#import "NoteBrick.h"

@implementation Notebrick

-(void)performFromScript:(Script *)script
{
    NSLog(@"NoteBrick should not be executed!");
    abort();
}

-(NSString*)description
{
    return [NSString stringWithFormat:@"NoteBrick: %@", self.note];
}
@end
