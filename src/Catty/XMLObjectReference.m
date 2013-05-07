//
//  XMLObjectReference.m
//  Catty
//
//  Created by Dominik Ziegler on 5/7/13.
//
//

#import "XMLObjectReference.h"

@implementation XMLObjectReference

-(id)initWithParent:(XMLObjectReference*)parent andObject:(id)object
{
    self = [super init];
    if(self) {
        self.parent = parent;
        self.object = object;
    }
    return self;
}

-(NSString*)description
{
    return [NSString stringWithFormat:@"XMLObjectReference: Parent: %@, Object: %@", self.parent, self.object ];
}

@end
