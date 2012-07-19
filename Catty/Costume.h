//
//  Costume.h
//  Catty
//
//  Created by Mattias Rauter on 17.04.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Costume : NSObject

@property (strong, nonatomic) NSString *costumeFileName;
@property (strong, nonatomic) NSString *costumeName;

- (id)initWithPath:(NSString*)filePath;
- (id)initWithName:(NSString*)name andPath:(NSString*)filePath;


- (NSString*)description;

@end
