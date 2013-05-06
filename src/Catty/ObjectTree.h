//
//  ObjectTree.h
//  Catty
//
//  Created by Dominik Ziegler on 5/6/13.
//
//

#import <Foundation/Foundation.h>

@interface ObjectTree : NSObject

@property (nonatomic, weak) id parent;
@property (nonatomic, strong) NSArray* children;

@end
