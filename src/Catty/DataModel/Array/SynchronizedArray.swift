/**
 *  Copyright (C) 2010-2024 The Catrobat Team
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

public class SynchronizedArray<Element> {
    private let queue = DispatchQueue(label: "SynchronizedArray", attributes: .concurrent)
    private var array = [Element]()

    var count: Int {
        var result = 0
        queue.sync { result = self.array.count }
        return result
    }

    var isEmpty: Bool {
        var result = false
        queue.sync { result = self.array.isEmpty }
        return result
    }

    var startIndex: Int {
        var result = 0
        queue.sync { result = self.array.startIndex }
        return result
    }

    var endIndex: Int {
        var result = 0
        queue.sync { result = self.array.endIndex }
        return result
    }

    var first: Element? {
        var result: Element?
        queue.sync { result = self.array.first }
        return result
    }

    var last: Element? {
        var result: Element?
        queue.sync { result = self.array.last }
        return result
    }

    subscript(index: Int) -> Element? {
         get {
             var result: Element?
             queue.sync {
                 guard self.array.startIndex..<self.array.endIndex ~= index else { return }
                 result = self.array[index]
             }
             return result
         }
         set {
             guard let newValue = newValue else { return }
             queue.async(flags: .barrier) {
                 self.array[index] = newValue
             }
         }
    }

    public func append(_ element: Element) {
        queue.async(flags: .barrier) {
            self.array.append(element)
        }
    }

    public func remove(at index: Int) {
        queue.async(flags: .barrier) {
            self.array.remove(at: index)
        }
    }

    public func removeAll() {
        queue.async(flags: .barrier) {
            self.array.removeAll()
        }
    }

    public func removeSubrange(_ bounds: Range<Int>) {
        queue.async(flags: .barrier) {
            self.array.removeSubrange(bounds)
        }
    }

    public func insert(_ element: Element, at index: Int) {
        queue.async(flags: .barrier) {
            self.array.insert(element, at: index)
        }
    }

    public func firstIndex(where predicate: (Element) -> Bool) -> Int? {
        var result: Int?
        queue.sync {
            result = self.array.firstIndex(where: predicate)
        }
        return result
     }

    public func index(after index: Array<Element>.Index) -> Array<Element>.Index {
        var result = 0
        queue.sync {
            result = self.array.index(after: index)
        }
        return result
    }

    public func index( i: Int, offsetBy distance: Int) -> Int {
         var result = 0
         queue.sync {
             result = self.array.index(i, offsetBy: distance)
         }
         return result
     }

    public func enumerated() -> EnumeratedSequence<[Element]> {
        var result: EnumeratedSequence<[Element]>?
        queue.sync {
            result = self.array.enumerated()
        }
        return result!
    }

    public func contains(where predicate: (Element) throws -> Bool) rethrows -> Bool {
        var result = false
         do {
            try queue.sync {
                do {
                    result = try self.array.contains(where: predicate)
                } catch {
                    throw error
                }
            }
        } catch {
            throw error
        }
        return result
    }

    func isEqual(_ object: SynchronizedArray) -> Bool {
        var result = true
        queue.sync {
            let count = self.array.count
            if count == object.count {
                for index in 0..<count where !Util.isEqual(self.array[index], to: object[index]) {
                    result = false
                    break
                }
            } else {
               result = false
            }
        }
        return result
    }
}

public extension SynchronizedArray where Element: Equatable {
    func contains(_ element: Element) -> Bool {
        var result = false
        queue.sync { result = self.array.contains(element) }
        return result
    }
}

extension SynchronizedArray where Element: UserDataProtocol {
    func remove(name: String) {
        queue.async(flags: .barrier) {
            for index in 0..<self.array.count where name == self.array[index].name {
                self.array.remove(at: index)
                break
            }
        }
    }
}

extension SynchronizedArray where Element: Equatable {
    func remove(element: Element) {
        queue.async(flags: .barrier) {
            self.array.removeObject(element)
        }
    }
}
