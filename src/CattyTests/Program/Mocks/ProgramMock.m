/**
 *  Copyright (C) 2010-2019 The Catrobat Team
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

#import "ProgramMock.h"

@interface ProgramMock()
@property(nonatomic, assign) NSInteger mockedRequiredResources;
@end

@implementation ProgramMock

- (instancetype)init {
    return [self initWithWidth:300 andHeight:400];
}

- (instancetype)initWithRequiredResources:(NSInteger)requiredResources {
    return [self initWithWidth:300 andHeight:400 andRequiredResources:requiredResources];
}

- (instancetype)initWithWidth:(CGFloat)width andHeight:(CGFloat)height {
    return [self initWithWidth:width andHeight:height andRequiredResources:kNoResources];
}

    
- (instancetype)initWithWidth:(CGFloat)width andHeight:(CGFloat)height andRequiredResources:(NSInteger)requiredResources {
    self = [super init];
    
    if (self != nil) {
        self.header = [[Header alloc] init];
        self.header.screenWidth = [[NSNumber alloc] initWithFloat:width];
        self.header.screenHeight = [[NSNumber alloc] initWithFloat:height];
        self.mockedRequiredResources = requiredResources;
    }
    
    return self;
}

- (NSInteger)getRequiredResources {
    return self.mockedRequiredResources;
}

@end
