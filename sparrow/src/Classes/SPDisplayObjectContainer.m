//
//  SPDisplayObjectContainer.m
//  Sparrow
//
//  Created by Daniel Sperl on 15.03.09.
//  Copyright 2011 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import "SPDisplayObjectContainer.h"
#import "SPEnterFrameEvent.h"
#import "SPDisplayObject_Internal.h"
#import "SPMacros.h"
#import "SPEvent_Internal.h"
#import "SPRenderSupport.h"

// --- C functions ---------------------------------------------------------------------------------

static void getChildEventListeners(SPDisplayObject *object, NSString *eventType, 
                                   NSMutableArray *listeners)
{
    // some events (ENTER_FRAME, ADDED_TO_STAGE, etc.) are dispatched very often and traverse
    // the entire display tree -- thus, it pays off handling them in their own c function.
    
    if ([object hasEventListenerForType:eventType])
        [listeners addObject:object];
    
    if ([object isKindOfClass:[SPDisplayObjectContainer class]])
        for (SPDisplayObject *child in (SPDisplayObjectContainer *)object)        
            getChildEventListeners(child, eventType, listeners);
}

// --- class implementation ------------------------------------------------------------------------

@implementation SPDisplayObjectContainer
{
    NSMutableArray *_children;
}

- (id)init
{    
    #if DEBUG    
    if ([[self class] isEqual:[SPDisplayObjectContainer class]]) 
    { 
        [NSException raise:SP_EXC_ABSTRACT_CLASS 
                    format:@"Attempting to instantiate SPDisplayObjectContainer directly."];
        return nil; 
    }    
    #endif
    
    if ((self = [super init])) 
    {
        _children = [[NSMutableArray alloc] init];
    }    
    return self;
}

- (void)addChild:(SPDisplayObject *)child
{
    [self addChild:child atIndex:[_children count]];
}

- (void)addChild:(SPDisplayObject *)child atIndex:(int)index
{
    if (index >= 0 && index <= [_children count])
    {
        [child removeFromParent];
        [_children insertObject:child atIndex:MIN(_children.count, index)];
        child.parent = self;
        
        [child dispatchEventWithType:SP_EVENT_TYPE_ADDED];
        
        if (self.stage)
            [child broadcastEventWithType:SP_EVENT_TYPE_ADDED_TO_STAGE];
    }
    else [NSException raise:SP_EXC_INDEX_OUT_OF_BOUNDS format:@"Invalid child index"]; 
}

- (BOOL)containsChild:(SPDisplayObject *)child
{
    while (child)
    {
        if (child == self) return YES;
        else child = child.parent;
    }
    
    return NO;
}

- (SPDisplayObject *)childAtIndex:(int)index
{
    return _children[index];
}

- (SPDisplayObject *)childByName:(NSString *)name
{
    for (SPDisplayObject *currentChild in _children)
        if ([currentChild.name isEqualToString:name]) return currentChild;
    
    return nil;
}

- (int)childIndex:(SPDisplayObject *)child
{
    int index = [_children indexOfObject:child];
    if (index == NSNotFound) return SP_NOT_FOUND;
    else                     return index;
}

- (void)setIndex:(int)index ofChild:(SPDisplayObject *)child
{
    int oldIndex = [_children indexOfObject:child];
    if (oldIndex == NSNotFound) 
        [NSException raise:SP_EXC_INVALID_OPERATION format:@"Not a child of this container"];
    else
    {
        [_children removeObjectAtIndex:oldIndex];
        [_children insertObject:child atIndex:index];
    }
}

- (void)removeChild:(SPDisplayObject *)child
{
    int childIndex = [self childIndex:child];
    if (childIndex != SP_NOT_FOUND)
        [self removeChildAtIndex:childIndex];
}

- (void)removeChildAtIndex:(int)index
{
    if (index >= 0 && index < [_children count])
    {
        SPDisplayObject *child = _children[index];
        [child dispatchEventWithType:SP_EVENT_TYPE_REMOVED];
        
        if (self.stage)
            [child broadcastEventWithType:SP_EVENT_TYPE_REMOVED_FROM_STAGE];
        
        child.parent = nil; 
        index = [_children indexOfObject:child]; // index might have changed in event handler
        if (index != NSNotFound) [_children removeObjectAtIndex:index];
    }
    else [NSException raise:SP_EXC_INDEX_OUT_OF_BOUNDS format:@"Invalid child index"];        
}

- (void)swapChild:(SPDisplayObject*)child1 withChild:(SPDisplayObject*)child2
{
    int index1 = [self childIndex:child1];
    int index2 = [self childIndex:child2];
    [self swapChildAtIndex:index1 withChildAtIndex:index2];
}

- (void)swapChildAtIndex:(int)index1 withChildAtIndex:(int)index2
{    
    int numChildren = [_children count];    
    if (index1 < 0 || index1 >= numChildren || index2 < 0 || index2 >= numChildren)
        [NSException raise:SP_EXC_INVALID_OPERATION format:@"invalid child indices"];
    [_children exchangeObjectAtIndex:index1 withObjectAtIndex:index2];
}

- (void)sortChildren:(NSComparator)comparator
{
    if ([_children respondsToSelector:@selector(sortWithOptions:usingComparator:)])
        [_children sortWithOptions:NSSortStable usingComparator:comparator];
    else
        [NSException raise:SP_EXC_INVALID_OPERATION 
                    format:@"sortChildren is only available in iOS 4 and above"];
}

- (void)removeAllChildren
{
    for (int i=_children.count-1; i>=0; --i)
        [self removeChildAtIndex:i];
}

- (int)numChildren
{
    return [_children count];
}

- (SPRectangle*)boundsInSpace:(SPDisplayObject*)targetSpace
{    
    int numChildren = [_children count];

    if (numChildren == 0)
    {
        SPMatrix *transformationMatrix = [self transformationMatrixToSpace:targetSpace];
        SPPoint *transformedPoint = [transformationMatrix transformPointWithX:self.x y:self.y];
        return [SPRectangle rectangleWithX:transformedPoint.x y:transformedPoint.y 
                                     width:0.0f height:0.0f];
    }
    else if (numChildren == 1)
    {
        return [_children[0] boundsInSpace:targetSpace];
    }
    else
    {
        float minX = FLT_MAX, maxX = -FLT_MAX, minY = FLT_MAX, maxY = -FLT_MAX;    
        for (SPDisplayObject *child in _children)
        {
            SPRectangle *childBounds = [child boundsInSpace:targetSpace];        
            minX = MIN(minX, childBounds.x);
            maxX = MAX(maxX, childBounds.x + childBounds.width);
            minY = MIN(minY, childBounds.y);
            maxY = MAX(maxY, childBounds.y + childBounds.height);        
        }    
        return [SPRectangle rectangleWithX:minX y:minY width:maxX-minX height:maxY-minY];
    }
}

- (SPDisplayObject*)hitTestPoint:(SPPoint*)localPoint
{
    if (!self.visible || !self.touchable)
        return nil;
    
    for (int i=[_children count]-1; i>=0; --i) // front to back!
    {
        SPDisplayObject *child = _children[i];
        SPMatrix *transformationMatrix = [self transformationMatrixToSpace:child];
        SPPoint  *transformedPoint = [transformationMatrix transformPoint:localPoint];
        SPDisplayObject *target = [child hitTestPoint:transformedPoint];
        if (target) return target;
    }
    
    return nil;
}

- (void)broadcastEvent:(SPEvent *)event
{
    if (event.bubbles) 
        [NSException raise:SP_EXC_INVALID_OPERATION 
                    format:@"Broadcast of bubbling events is prohibited"];
    
    // the event listeners might modify the display tree, which could make the loop crash. 
    // thus, we collect them in a list and iterate over that list instead.
    NSMutableArray *listeners = [[NSMutableArray alloc] init];
    getChildEventListeners(self, event.type, listeners);
    [event setTarget:self];
    [listeners makeObjectsPerformSelector:@selector(dispatchEvent:) withObject:event];
}

- (void)broadcastEventWithType:(NSString *)type
{
    SPEvent *event = [[SPEvent alloc] initWithType:type bubbles:NO];
    [self broadcastEvent:event];
}

- (void)dealloc 
{
    // 'self' is becoming invalid; thus, we have to remove any references to it.    
    [_children makeObjectsPerformSelector:@selector(setParent:) withObject:nil];
}

- (void)render:(SPRenderSupport *)support
{
    for (SPDisplayObject *child in _children)
    {
        if (child.hasVisibleArea)
        {
            [support pushStateWithMatrix:child.transformationMatrix
                                   alpha:child.alpha
                               blendMode:child.blendMode];
            
            [child render:support];
            
            [support popState];
        }
    }
}

#pragma mark NSFastEnumeration

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state
                                  objects:(id __unsafe_unretained *)stackbuf
                                    count:(NSUInteger)len
{
    return [_children countByEnumeratingWithState:state objects:stackbuf count:len];
}

@end
