/**
 *  Copyright (C) 2010-2016 The Catrobat Team
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

import Foundation


public struct OrderedDictionary<Key: Hashable, Value>: MutableCollectionType, ArrayLiteralConvertible, CustomStringConvertible {
    
    // ======================================================= //
    // MARK: - Type Aliases
    // ======================================================= //
    
    public typealias Element = (Key, Value)
    
    public typealias Index = Int
    
    // ======================================================= //
    // MARK: - Initialization
    // ======================================================= //
    
    public init() {}
    
    public init(elements: [Element]) {
        for element in elements {
            self[element.0] = element.1
        }
    }
    
    public init(arrayLiteral elements: Element...) {
        self.init(elements: elements)
    }
    
    // ======================================================= //
    // MARK: - Accessing Keys & Values
    // ======================================================= //
    
    public var orderedKeys: [Key] {
        return _orderedKeys
    }
    
    public var orderedValues: [Value] {
        return _orderedKeys.flatMap { _keysToValues[$0] }
    }
    
    // ======================================================= //
    // MARK: - Managing Content Using Keys
    // ======================================================= //
    
    public subscript(key: Key) -> Value? {
        get {
            return _keysToValues[key]
        }
        set(newValue) {
            if let newValue = newValue {
                updateValue(newValue, forKey: key)
            } else {
                removeValueForKey(key)
            }
        }
    }
    
    public func containsKey(key: Key) -> Bool {
        return _orderedKeys.contains(key)
    }
    
    public mutating func updateValue(value: Value, forKey key: Key) -> Value? {
        if _orderedKeys.contains(key) {
            guard let currentValue = _keysToValues[key] else {
                fatalError("Inconsistency error occured in OrderedDictionary")
            }
            
            _keysToValues[key] = value
            
            return currentValue
        } else {
            _orderedKeys.append(key)
            _keysToValues[key] = value
            
            return nil
        }
    }
    
    public mutating func removeValueForKey(key: Key) -> Value? {
        if let index = _orderedKeys.indexOf(key) {
            guard let currentValue = _keysToValues[key] else {
                fatalError("Inconsistency error occured in OrderedDictionary")
            }
            
            _orderedKeys.removeAtIndex(index)
            _keysToValues[key] = nil
            
            return currentValue
        } else {
            return nil
        }
    }
    
    public mutating func removeAll(keepCapacity keepCapacity: Bool = true) {
        _orderedKeys.removeAll(keepCapacity: keepCapacity)
        _keysToValues.removeAll(keepCapacity: keepCapacity)
    }
    
    // ======================================================= //
    // MARK: - Managing Content Using Indexes
    // ======================================================= //
    
    public subscript(index: Index) -> Element {
        get {
            guard let element = elementAtIndex(index) else {
                fatalError("OrderedDictionary index out of range")
            }
            
            return element
        }
        set(newValue) {
            updateElement(newValue, atIndex: index)
        }
    }
    
    public func indexForKey(key: Key) -> Index? {
        return _orderedKeys.indexOf(key)
    }
    
    public func elementAtIndex(index: Index) -> Element? {
        guard _orderedKeys.indices.contains(index) else { return nil }
        
        let key = _orderedKeys[index]
        
        guard let value = self._keysToValues[key] else {
            fatalError("Inconsistency error occured in OrderedDictionary")
        }
        
        return (key, value)
    }
    
    public mutating func insertElementWithKey(key: Key, value: Value, atIndex index: Index) -> Value? {
        return insertElement((key, value), atIndex: index)
    }
    
    public mutating func insertElement(newElement: Element, atIndex index: Index) -> Value? {
        guard index >= 0 else {
            fatalError("Negative OrderedDictionary index is out of range")
        }
        
        guard index <= count else {
            fatalError("OrderedDictionary index out of range")
        }
        
        let (key, value) = (newElement.0, newElement.1)
        
        let adjustedIndex: Int
        let currentValue: Value?
        
        if let currentIndex = _orderedKeys.indexOf(key) {
            currentValue = _keysToValues[key]
            adjustedIndex = (currentIndex < index - 1) ? index - 1 : index
            
            _orderedKeys.removeAtIndex(currentIndex)
            _keysToValues[key] = nil
        } else {
            currentValue = nil
            adjustedIndex = index
        }
        
        _orderedKeys.insert(key, atIndex: adjustedIndex)
        _keysToValues[key] = value
        
        return currentValue
    }
    
    public mutating func updateElement(element: Element, atIndex index: Index) -> Element? {
        guard let currentElement = elementAtIndex(index) else {
            fatalError("OrderedDictionary index out of range")
        }
        
        let (newKey, newValue) = (element.0, element.1)
        
        _orderedKeys[index] = newKey
        _keysToValues[newKey] = newValue
        
        return currentElement
    }
    
    public mutating func removeAtIndex(index: Index) -> Element? {
        if let element = elementAtIndex(index) {
            _orderedKeys.removeAtIndex(index)
            _keysToValues.removeValueForKey(element.0)
            
            return element
        } else {
            return nil
        }
    }
    
    // ======================================================= //
    // MARK: - CollectionType Conformance
    // ======================================================= //
    
    public var startIndex: Index {
        return _orderedKeys.startIndex
    }
    
    public var endIndex: Index {
        return _orderedKeys.endIndex
    }
    
    public func generate() -> AnyGenerator<Element> {
        var nextIndex = 0
        let lastIndex = self.count
        
        return AnyGenerator {
            guard nextIndex < lastIndex else { return nil }
            
            let nextKey = self._orderedKeys[nextIndex]
            
            guard let nextValue = self._keysToValues[nextKey] else {
                fatalError("Inconsistency error occured in OrderedDictionary")
            }
            
            let element = (nextKey, nextValue)
            
            nextIndex += 1
            
            return element
        }
    }
    
    // ======================================================= //
    // MARK: - Description
    // ======================================================= //
    
    public var description: String {
        let content = map({ "\($0.0): \($0.1)" }).joinWithSeparator(", ")
        return "[\(content)]"
    }
    
    // ======================================================= //
    // MARK: - Internal Backing Store
    // ======================================================= //
    
    /// The backing store for the ordered keys.
    private var _orderedKeys = [Key]()
    
    /// The backing store for the mapping of keys to values.
    private var _keysToValues = [Key: Value]()
    
}

public func == <Key: Equatable, Value: Equatable>(lhs: OrderedDictionary<Key, Value>, rhs: OrderedDictionary<Key, Value>) -> Bool {
    return lhs._orderedKeys == rhs._orderedKeys && lhs._keysToValues == rhs._keysToValues
}
