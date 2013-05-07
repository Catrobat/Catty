//
//  XMLObjectReference.h
//  Catty
//
//  Created by Dominik Ziegler on 5/7/13.
//
//

#import <Foundation/Foundation.h>

@interface XMLObjectReference : NSObject

@property (nonatomic, weak) XMLObjectReference* parent;
@property (nonatomic, weak) id object;


-(id)initWithParent:(XMLObjectReference*)parent andObject:(id)object;

@end
