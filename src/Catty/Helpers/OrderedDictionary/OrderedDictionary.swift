/**
 *  Copyright (C) 2010-2018 The Catrobat Team
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


public struct OrderedDictionary<Key: Hashable, Value>: MutableCollection, ExpressibleByArrayLiteral, CustomStringConvertible {
    
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
        return _orderedKeys.compactMap { _keysToValues[$0] }
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
    
    public func containsKey(_ key: Key) -> Bool {
        return _orderedKeys.contains(key)
    }

    @discardableResult
    public mutating func updateValue(_ value: Value, forKey key: Key) -> Value? {
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

    @discardableResult
    public mutating func removeValueForKey(_ key: Key) -> Value? {
        if let index = _orderedKeys.index(of: key) {
            guard let currentValue = _keysToValues[key] else {
                fatalError("Inconsistency error occured in OrderedDictionary")
            }
            
            _orderedKeys.remove(at: index)
            _keysToValues[key] = nil
            
            return currentValue
        } else {
            return nil
        }
    }
    
    public mutating func removeAll(keepCapacity: Bool = true) {
        _orderedKeys.removeAll(keepingCapacity: keepCapacity)
        _keysToValues.removeAll(keepingCapacity: keepCapacity)
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
    
    public func indexForKey(_ key: Key) -> Index? {
        return _orderedKeys.index(of: key)
    }
    
    public func elementAtIndex(_ index: Index) -> Element? {
        guard _orderedKeys.indices.contains(index) else { return nil }
        
        let key = _orderedKeys[index]
        
        guard let value = self._keysToValues[key] else {
            fatalError("Inconsistency error occured in OrderedDictionary")
        }
        
        return (key, value)
    }
    
    public mutating func insertElementWithKey(_ key: Key, value: Value, atIndex index: Index) -> Value? {
        return insertElement((key, value), atIndex: index)
    }
    
    public mutating func insertElement(_ newElement: Element, atIndex index: Index) -> Value? {
        guard index >= 0 else {
            fatalError("Negative OrderedDictionary index is out of range")
        }
        
        guard index <= count else {
            fatalError("OrderedDictionary index out of range")
        }
        
        let (key, value) = (newElement.0, newElement.1)
        
        let adjustedIndex: Int
        let currentValue: Value?
        
        if let currentIndex = _orderedKeys.index(of: key) {
            currentValue = _keysToValues[key]
            adjustedIndex = (currentIndex < index - 1) ? index - 1 : index
            
            _orderedKeys.remove(at: currentIndex)
            _keysToValues[key] = nil
        } else {
            currentValue = nil
            adjustedIndex = index
        }
        
        _orderedKeys.insert(key, at: adjustedIndex)
        _keysToValues[key] = value
        
        return currentValue
    }

    @discardableResult
    public mutating func updateElement(_ element: Element, atIndex index: Index) -> Element? {
        guard let currentElement = elementAtIndex(index) else {
            fatalError("OrderedDictionary index out of range")
        }
        
        let (newKey, newValue) = (element.0, element.1)
        
        _orderedKeys[index] = newKey
        _keysToValues[newKey] = newValue
        
        return currentElement
    }
    
    public mutating func removeAtIndex(_ index: Index) -> Element? {
        if let element = elementAtIndex(index) {
            _orderedKeys.remove(at: index)
            _keysToValues.removeValue(forKey: element.0)
            
            return element
        } else {
            return nil
        }
    }

    public func index(after i: Int) -> Int {
        return i + 1
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
    
    public func makeIterator() -> AnyIterator<Element> {
        var nextIndex = 0
        let lastIndex = self.count
        
        return AnyIterator {
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
        let content = map({ "\($0.0): \($0.1)" }).joined(separator: ", ")
        return "[\(content)]"
    }
    
    // ======================================================= //
    // MARK: - Internal Backing Store
    // ======================================================= //
    
    /// The backing store for the ordered keys.
    fileprivate var _orderedKeys = [Key]()
    
    /// The backing store for the mapping of keys to values.
    fileprivate var _keysToValues = [Key: Value]()
    
}
