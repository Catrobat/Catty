/**
 *  Copyright (C) 2010-2017 The Catrobat Team
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


#import "SceneStartBrick.h"
#import "Scene.h"
#import "Script.h"
#import "NSArray+CustomExtension.h"

NSString * const kStartSceneNotification = @"kStartSceneNotification";

@implementation SceneStartBrick

- (NSString *)brickTitle {
    return [@"Start scene" stringByAppendingString:@"\n%@"];
}

- (void)setDefaultValuesForObject:(SpriteObject *)spriteObject {
    self.sceneName = spriteObject.scene.name;
}

- (void)setSceneName:(NSString *)sceneName forLineNumber:(NSInteger)lineNumber andParameterNumber:(NSInteger)paramNumber {
    self.sceneName = sceneName;
}

- (NSString *)sceneNameForLineNumber:(NSInteger)lineNumber andParameterNumber:(NSInteger)paramNumber {
    return self.sceneName;
}

- (NSInteger)getRequiredResources {
    return kNoResources;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"SceneStartBrick: %@", self.sceneName];
}

@end
