//    <b>The MIT License (MIT)</b>
//
//    Copyright (c) 2015, Wayne Bishop & Arbutus Software Inc.
//
//    Permission is hereby granted, free of charge, to any person obtaining a copy
//    of this software and associated documentation files (the "Software"), to deal
//    in the Software without restriction, including without limitation the rights
//    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//    copies of the Software, and to permit persons to whom the Software is
//    furnished to do so, subject to the following conditions:
//
//    The above copyright notice and this permission notice shall be included in all
//    copies or substantial portions of the Software.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//    SOFTWARE.

//
//  Stack.swift
//  SwiftStructures
//
//  Created by Wayne Bishop on 8/1/14.
//  Copyright (c) 2014 Arbutus Software Inc. All rights reserved.
//

import Foundation

class CBStack<T> {
    
    private var top: LLNode<T>! = LLNode<T>()

    
    //TODO: Add count computed property
    
    
    //push an item onto the stack
    func push(var key: T) {
        
        
        //check for the instance
        if (top == nil) {
            top = LLNode<T>()
        }
        
        
        //determine if the head node is populated
        if (top.key == nil){
            top.key = key;
            return
        }
        else {
            
            //establish the new item instance
            var childToUse: LLNode<T> = LLNode<T>()
            childToUse.key = key
            
            
            //set newly created item at the top
            childToUse.next = top;
            top = childToUse;
            
         
        }

    }
    
    
    
    //remove an item from the stack
    func pop() -> T? {
     
        //determine if the key or instance exist
        let topitem: T? = self.top?.key
        
        if (topitem == nil){
            return nil
        }
        
        //retrieve and queue the next item
        var queueitem: T? = top.key!
        
        
        //reset the top value
        if let nextitem = top.next {
            top = nextitem
        }
        else {
            top = nil
        }
        
        
        return queueitem

    }
    
    
    
    //retrieve the top most item
    func peek() -> T? {

        
        //determine if the key or instance exist
        if let topitem: T = self.top?.key {
            return topitem
        }
            
        else {
            return nil
        }
        
        
    }
    
    
    
    //check for the presence of a value
    func isEmpty() -> Bool {
        
        //determine if the key or instance exist
        if let topitem: T = self.top?.key {
            return false
        }
            
        else {
            return true
        }
        
    }
    
    
    
    //determine the count of the queue
    func count() -> Int {
        
        var x: Int = 0
        
        
        //determine if the key or instance exist
        let topitem: T? = self.top?.key
        
        if (topitem == nil) {
             return 0
        }
        
        
        var current: LLNode = top
        
        x++
        
        //cycle through the list of items to get to the end.
        while ((current.next) != nil) {
            current = current.next!;
            x++
        }
        
        return x
        
    }
    

}