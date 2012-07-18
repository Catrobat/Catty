//
//  XMLLevels.h
//  Catty
//
//  Created by Christof Stromberger on 18.07.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#ifndef Catty_XMLLevels_h
#define Catty_XMLLevels_h

typedef enum {
    kContentProject,
    kSpriteList,
    kContentSprite,
    kCostumeDataList,
    kCommonCostumeData,
    kSoundList,
    //specify sound attributes here
    kScriptList,
    kContentStartScript,
    kBrickList,
    kBricksSetCostumeBrick,
    kBricksWaitBrick,
    //add futher bricks here
    kContentWhenScript
} XMLLevels;

#endif
