/**
 *  Copyright (C) 2010-2015 The Catrobat Team
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

protocol CBPlayerSchedulingAlgorithmProtocol : class {
    func contextForNextInstruction(lastContext: CBScriptContextAbstract?,
        scheduledContexts: [CBScriptContextAbstract]) -> CBScriptContextAbstract?
}

// implements a RoundRobin-like scheduling algorithm
final class CBPlayerSchedulingRR : CBPlayerSchedulingAlgorithmProtocol {

    func contextForNextInstruction(lastContext: CBScriptContextAbstract?,
        scheduledContexts: [CBScriptContextAbstract]) -> CBScriptContextAbstract?
    {
        assert(scheduledContexts.isEmpty == false) // make sure dict is not empty (as specified!)
        if lastContext == nil {
            return scheduledContexts.first! // take first context
        }
        var takeNextScript = false
        var rounds = 2
        while rounds-- > 0 { // simple trick to get a ring buffer!
            for context in scheduledContexts {
                if takeNextScript {
                    return context
                }
                if context == lastContext {
                    takeNextScript = true
                    continue
                }
            }
        }
        fatalError("This should NEVER happen!")
    }
}

// implements a load balancing scheduling algorithm
final class CBPlayerSchedulingAlgorithmLoadBalancing : CBPlayerSchedulingAlgorithmProtocol {

    struct CBContextElement {
        let context: CBScriptContextAbstract
        var numOfPastInstructions = 0
        init(context: CBScriptContextAbstract) { self.context = context }
    }
    private var _spriteNameScriptContexts = [String:[CBScriptContextAbstract]]()
    private var _priorityQueue = PriorityQueue<CBContextElement>({
        $0.numOfPastInstructions < $1.numOfPastInstructions
    })

    func contextForNextInstruction(lastContext: CBScriptContextAbstract?,
        scheduledContexts: [CBScriptContextAbstract]) -> CBScriptContextAbstract?
    {
        assert(scheduledContexts.isEmpty == false) // make sure dict is not empty (as specified!)
        var runningContexts = [CBScriptContextAbstract]()
        for scheduledContext in scheduledContexts {
            if scheduledContext.state == .Running
            || scheduledContext.state == .RunningMature
            || scheduledContext.state == .RunningBlocking
            {
                runningContexts += scheduledContext
                var spriteNameScriptContexts = _spriteNameScriptContexts[scheduledContext.script.object!.name]
                if spriteNameScriptContexts == nil {
                    spriteNameScriptContexts = [CBScriptContextAbstract]()
                }
                if (spriteNameScriptContexts!).contains(scheduledContext) == false {
                    spriteNameScriptContexts! += scheduledContext
                    _priorityQueue.push(CBContextElement(context: scheduledContext))
                }
                _spriteNameScriptContexts[scheduledContext.script.object!.name] = spriteNameScriptContexts!
            }
        }

        if runningContexts.isEmpty {
            _priorityQueue.removeAll()
            return nil
        }
        while true {
            if var contextElement = _priorityQueue.pop() {
                let context = contextElement.context
                if runningContexts.contains(context) == false || context.isLocked {
                    if var spriteNameScriptContexts = _spriteNameScriptContexts[context.script.object!.name] {
                        spriteNameScriptContexts.removeObject(context)
                        _spriteNameScriptContexts[context.script.object!.name] = spriteNameScriptContexts
                    }
                    continue
                }
                ++contextElement.numOfPastInstructions // current instruction
                _priorityQueue.push(contextElement)
                for element in _priorityQueue.heap {
                    print("\(element.numOfPastInstructions): \(element.context.script.description())")
                }
                assert(context.isLocked == false)
                return context
            } else {
                return nil
            }
        }
    }
}

// implements a priority scheduling algorithm
final class CBPlayerSchedulingAlgorithmPriorityQueue : CBPlayerSchedulingAlgorithmProtocol {

    struct CBContextPriorityElement {
        let context: CBScriptContextAbstract
        var timeStampsOfPastInstructionsWithinLast100ms = CBStack<NSDate>() // helper stack
        var numOfPastInstructionsWithinLast100ms = 0
        init(context: CBScriptContextAbstract) { self.context = context }
    }
    private var _spriteNameScriptContexts = [String:[CBScriptContextAbstract]]()
    private var _priorityQueue = PriorityQueue<CBContextPriorityElement>({
        $0.numOfPastInstructionsWithinLast100ms < $1.numOfPastInstructionsWithinLast100ms
    })

    func contextForNextInstruction(lastContext: CBScriptContextAbstract?,
        scheduledContexts: [CBScriptContextAbstract]) -> CBScriptContextAbstract?
    {
        assert(scheduledContexts.isEmpty == false) // make sure dict is not empty (as specified!)
        var runningContexts = [CBScriptContextAbstract]()
        for scheduledContext in scheduledContexts {
            if scheduledContext.state == .Running
            || scheduledContext.state == .RunningMature
            || scheduledContext.state == .RunningBlocking
            {
                runningContexts += scheduledContext
                var spriteNameScriptContexts = _spriteNameScriptContexts[scheduledContext.script.object!.name]
                if spriteNameScriptContexts == nil {
                    spriteNameScriptContexts = [CBScriptContextAbstract]()
                }
                if (spriteNameScriptContexts!).contains(scheduledContext) == false {
                    spriteNameScriptContexts! += scheduledContext
                    _priorityQueue.push(CBContextPriorityElement(context: scheduledContext))
                }
                _spriteNameScriptContexts[scheduledContext.script.object!.name] = spriteNameScriptContexts!
            }
        }
        if runningContexts.isEmpty {
            _priorityQueue.removeAll()
            return nil
        }
        if var nextContextPriorityElement = _priorityQueue.pop() {
            while runningContexts.contains(nextContextPriorityElement.context) == false {
                let temp = _priorityQueue.pop()
                if temp == nil { return nil }
                nextContextPriorityElement = temp!
            }
            let thresholdDate = NSDate().dateByAddingTimeInterval(-0.1)
            var lastDate: NSDate?
            while true {
                if let date = nextContextPriorityElement.timeStampsOfPastInstructionsWithinLast100ms.pop() {
                    if date < thresholdDate {
                        break
                    } else {
                        lastDate = date
                    }
                } else {
                    break
                }
            }
            nextContextPriorityElement.numOfPastInstructionsWithinLast100ms -= nextContextPriorityElement.timeStampsOfPastInstructionsWithinLast100ms.count()
            ++nextContextPriorityElement.numOfPastInstructionsWithinLast100ms // current instruction
            _priorityQueue.push(nextContextPriorityElement)
            return nextContextPriorityElement.context
        } else {
            fatalError("This should NEVER happen!")
        }
    }
}

// implements a random order scheduling algorithm
final class CBPlayerSchedulingAlgorithmRandomOrder : CBPlayerSchedulingAlgorithmProtocol {

    func contextForNextInstruction(lastContext: CBScriptContextAbstract?,
        scheduledContexts: [CBScriptContextAbstract]) -> CBScriptContextAbstract?
    {
        assert(scheduledContexts.isEmpty == false) // make sure dict is not empty (as specified!)
        var runningContexts = [CBScriptContextAbstract]()
        var runningStartScriptContexts = [CBStartScriptContext]() // start script have higher priority (!)
        for scheduledContext in scheduledContexts {
            if scheduledContext.state == .Running || scheduledContext.state == .RunningMature
                || scheduledContext.state == .RunningBlocking
            {
                if let startScriptContext = scheduledContext as? CBStartScriptContext {
                    runningStartScriptContexts += startScriptContext
                } else {
                    runningContexts += scheduledContext
                }
            }
        }

        if runningStartScriptContexts.isEmpty == false {
            // start scripts should have higher priority (!)
            // => double the chance for them to win this lottery game!
            let numOfRunningStartScripts = runningStartScriptContexts.count
            let prioritizedStartScriptRange = numOfRunningStartScripts * 2
            let prioritizedOtherScriptRange = runningContexts.count

            let range = prioritizedStartScriptRange + prioritizedOtherScriptRange
            let randomIndex = Int(arc4random_uniform(UInt32(range)))
            if randomIndex < prioritizedStartScriptRange {
                return runningStartScriptContexts[randomIndex/2]
            } else {
                return scheduledContexts[randomIndex - prioritizedStartScriptRange]
            }
        }

        if runningContexts.isEmpty {
            return nil
        }
        let randomIndex = Int(arc4random_uniform(UInt32(runningContexts.count)))
        return scheduledContexts[randomIndex]
    }
}



//
//  PriorityQueue.swift
//  Swift-PriorityQueue
//
//  Created by Bouke Haarsma on 12-02-15.
//  Copyright (c) 2015 Bouke Haarsma. All rights reserved.
//

import Foundation

public class PriorityQueue<T> {
    
    private final var _heap: [T]
    private let compare: (T, T) -> Bool
    
    public init(_ compare: (T, T) -> Bool) {
        _heap = []
        self.compare = compare
    }
    
    public func push(newElement: T) {
        _heap.append(newElement)
        siftUp(_heap.endIndex - 1)
    }
    
    public func pop() -> T? {
        if _heap.count == 0 {
            return nil
        }
        swap(&_heap[0], &_heap[_heap.endIndex - 1])
        let pop = _heap.removeLast()
        siftDown(0)
        return pop
    }
    
    private func siftDown(index: Int) -> Bool {
        let left = index * 2 + 1
        let right = index * 2 + 2
        var smallest = index
        
        if left < _heap.count && compare(_heap[left], _heap[smallest]) {
            smallest = left
        }
        if right < _heap.count && compare(_heap[right], _heap[smallest]) {
            smallest = right
        }
        if smallest != index {
            swap(&_heap[index], &_heap[smallest])
            siftDown(smallest)
            return true
        }
        return false
    }
    
    private func siftUp(index: Int) -> Bool {
        if index == 0 {
            return false
        }
        let parent = (index - 1) >> 1
        if compare(_heap[index], _heap[parent]) {
            swap(&_heap[index], &_heap[parent])
            siftUp(parent)
            return true
        }
        return false
    }
}

extension PriorityQueue {
    public var count: Int {
        return _heap.count
    }
    
    public var isEmpty: Bool {
        return _heap.isEmpty
    }
    
    public func update<T2 where T2: Equatable>(element: T2) -> T? {
        assert(element is T)  // How to enforce this with type constraints?
        for (index, item) in _heap.enumerate() {
            if (item as! T2) == element {
                _heap[index] = element as! T
                if siftDown(index) || siftUp(index) {
                    return item
                }
            }
        }
        return nil
    }
    
    public func remove<T2 where T2: Equatable>(element: T2) -> T? {
        assert(element is T)  // How to enforce this with type constraints?
        for (index, item) in _heap.enumerate() {
            if (item as! T2) == element {
                swap(&_heap[index], &_heap[_heap.endIndex - 1])
                _heap.removeLast()
                siftDown(index)
                return item
            }
        }
        return nil
    }
    
    public var heap: [T] {
        return _heap
    }
    
    public func removeAll() {
        _heap.removeAll()
    }
}

extension PriorityQueue: GeneratorType {
    typealias Element = T
    public func next() -> Element? {
        return pop()
    }
}

extension PriorityQueue: SequenceType {
    typealias Generator = PriorityQueue
    public func generate() -> Generator {
        return self
    }
}
