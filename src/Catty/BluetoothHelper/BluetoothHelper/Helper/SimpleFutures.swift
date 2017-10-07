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

import Foundation

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Optional
extension Optional {
    
    func flatmap<M>(_ mapping:(Wrapped) -> M?) -> M? {
        switch self {
        case .some(let value):
            return mapping(value)
        case .none:
            return nil
        }
    }
    
    func filter(_ predicate:(Wrapped) -> Bool) -> Wrapped? {
        switch self {
        case .some(let value):
            return predicate(value) ? Optional(value) : nil
        case .none:
            return nil
        }
    }
    
    func foreach(_ apply:(Wrapped) -> Void) {
        switch self {
        case .some(let value):
            apply(value)
        case .none:
            break
        }
    }
    
}

public func flatmap<T,M>(_ maybe:T?, mapping:(T) -> M?) -> M? {
    return maybe.flatmap(mapping)
}

public func foreach<T>(_ maybe:T?, apply:(T) -> Void) {
    maybe.foreach(apply)
}

public func filter<T>(_ maybe:T?, predicate:(T) -> Bool) -> T? {
    return maybe.filter(predicate)
}

public func forcomp<T,U>(_ f:T?, g:U?, apply:(T,U) -> Void) {
    f.foreach {fvalue in
        g.foreach {gvalue in
            apply(fvalue, gvalue)
        }
    }
}
public func flatten<T>(_ maybe:T??) -> T? {
    switch maybe {
    case .some(let value):
        return value
    case .none:
        return nil
    }
}

public func forcomp<T,U,V>(_ f:T?, g:U?, h:V?, apply:(T,U,V) -> Void) {
    f.foreach {fvalue in
        g.foreach {gvalue in
            h.foreach {hvalue in
                apply(fvalue, gvalue, hvalue)
            }
        }
    }
}

public func forcomp<T,U,V>(_ f:T?, g:U?, yield:(T,U) -> V) -> V? {
    return f.flatmap {fvalue in
        g.map {gvalue in
            yield(fvalue, gvalue)
        }
    }
}

public func forcomp<T,U,V, W>(_ f:T?, g:U?, h:V?, yield:(T,U,V) -> W) -> W? {
    return f.flatmap {fvalue in
        g.flatmap {gvalue in
            h.map {hvalue in
                yield(fvalue, gvalue, hvalue)
            }
        }
    }
}

public func forcomp<T,U>(_ f:T?, g:U?, filter:(T,U) -> Bool, apply:(T,U) -> Void) {
    f.foreach {fvalue in
        g.filter{gvalue in
            filter(fvalue, gvalue)
        }.foreach {gvalue in
            apply(fvalue, gvalue)
        }
    }
}

public func forcomp<T,U,V>(_ f:T?, g:U?, h:V?, filter:(T,U,V) -> Bool, apply:(T,U,V) -> Void) {
    f.foreach {fvalue in
        g.foreach {gvalue in
            h.filter{hvalue in
                filter(fvalue, gvalue, hvalue)
            }.foreach {hvalue in
                apply(fvalue, gvalue, hvalue)
            }
        }
    }
}

public func forcomp<T,U,V>(_ f:T?, g:U?, filter:(T,U) -> Bool, yield:(T,U) -> V) -> V? {
    return f.flatmap {fvalue in
        g.filter {gvalue in
            filter(fvalue, gvalue)
        }.map {gvalue in
            yield(fvalue, gvalue)
        }
    }
}

public func forcomp<T,U,V,W>(_ f:T?, g:U?, h:V?, filter:(T,U,V) -> Bool, yield:(T,U,V) -> W) -> W? {
    return f.flatmap {fvalue in
        g.flatmap {gvalue in
            h.filter {hvalue in
                filter(fvalue, gvalue, hvalue)
            }.map {hvalue in
                yield(fvalue, gvalue, hvalue)
            }
        }
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Try
public struct TryError {
    public static let domain = "Wrappers"
    public static let filterFailed = NSError(domain:domain, code:1, userInfo:[NSLocalizedDescriptionKey:"Filter failed"])
}

public enum Try<T> {
    
    case success(T)
    case failure(NSError)
    
    public init(_ value:T) {
        self = .success(value)
    }
    
    public init(_ error:NSError) {
        self = .failure(error)
    }
    
    public func isSuccess() -> Bool {
        switch self {
        case .success:
            return true
        case .failure:
            return false
        }
    }
    
    public func isFailure() -> Bool {
        switch self {
        case .success:
            return false
        case .failure:
            return true
        }
    }
    
    public func map<M>(_ mapping:(T) -> M) -> Try<M> {
        switch self {
        case .success(let value):
            return Try<M>(mapping(value))
        case .failure(let error):
            return Try<M>(error)
        }
    }
    
    public func flatmap<M>(_ mapping:(T) -> Try<M>) -> Try<M> {
        switch self {
        case .success(let value):
            return mapping(value)
        case .failure(let error):
            return Try<M>(error)
        }
    }
    
    public func recover(_ recovery:(NSError) -> T) -> Try<T> {
        switch self {
        case .success(let box):
            return Try(box)
        case .failure(let error):
            return Try<T>(recovery(error))
        }
    }
    
    public func recoverWith(_ recovery:(NSError) -> Try<T>) -> Try<T> {
        switch self {
        case .success(let value):
            return Try(value)
        case .failure(let error):
            return recovery(error)
        }
    }
    
    public func filter(_ predicate:(T) -> Bool) -> Try<T> {
        switch self {
        case .success(let value):
            if !predicate(value) {
                return Try<T>(TryError.filterFailed)
            } else {
                return Try(value)
            }
        case .failure(_):
            return self
        }
    }
    
    public func foreach(_ apply:(T) -> Void) {
        switch self {
        case .success(let value):
            apply(value)
        case .failure:
            return
        }
    }
    
    public func toOptional() -> Optional<T> {
        switch self {
        case .success(let value):
            return Optional<T>(value)
        case .failure(_):
            return nil
        }
    }
    
    public func getOrElse(_ failed:T) -> T {
        switch self {
        case .success(let value):
            return value
        case .failure(_):
            return failed
        }
    }
    
    public func orElse(_ failed:Try<T>) -> Try<T> {
        switch self {
        case .success(let box):
            return Try(box)
        case .failure(_):
            return failed
        }
    }
    
}

public func flatten<T>(_ result:Try<Try<T>>) -> Try<T> {
    switch result {
    case .success(let value):
        return value
    case .failure(let error):
        return Try<T>(error)
    }
}

public func forcomp<T,U>(_ f:Try<T>, g:Try<U>, apply:(T,U) -> Void) {
    f.foreach {fvalue in
        g.foreach {gvalue in
            apply(fvalue, gvalue)
        }
    }
}

public func forcomp<T,U,V>(_ f:Try<T>, g:Try<U>, h:Try<V>, apply:(T,U,V) -> Void) {
    f.foreach {fvalue in
        g.foreach {gvalue in
            h.foreach {hvalue in
                apply(fvalue, gvalue, hvalue)
            }
        }
    }
}

public func forcomp<T,U,V>(_ f:Try<T>, g:Try<U>, yield:(T,U) -> V) -> Try<V> {
    return f.flatmap {fvalue in
        g.map {gvalue in
            yield(fvalue, gvalue)
        }
    }
}

public func forcomp<T,U,V,W>(_ f:Try<T>, g:Try<U>, h:Try<V>, yield:(T,U,V) -> W) -> Try<W> {
    return f.flatmap {fvalue in
        g.flatmap {gvalue in
            h.map {hvalue in
                yield(fvalue, gvalue, hvalue)
            }
        }
    }
}

public func forcomp<T,U>(_ f:Try<T>, g:Try<U>, filter:(T,U) -> Bool, apply:(T,U) -> Void) {
    f.foreach {fvalue in
        g.filter{gvalue in
            filter(fvalue, gvalue)
        }.foreach {gvalue in
            apply(fvalue, gvalue)
        }
    }
}

public func forcomp<T,U,V>(_ f:Try<T>, g:Try<U>, h:Try<V>, filter:(T,U,V) -> Bool, apply:(T,U,V) -> Void) {
    f.foreach {fvalue in
        g.foreach {gvalue in
            h.filter{hvalue in
                filter(fvalue, gvalue, hvalue)
            }.foreach {hvalue in
                apply(fvalue, gvalue, hvalue)
            }
        }
    }
}

public func forcomp<T,U,V>(_ f:Try<T>, g:Try<U>, filter:(T,U) -> Bool, yield:(T,U) -> V) -> Try<V> {
    return f.flatmap {fvalue in
        g.filter {gvalue in
            filter(fvalue, gvalue)
        }.map {gvalue in
            yield(fvalue, gvalue)
        }
    }
}

public func forcomp<T,U,V,W>(_ f:Try<T>, g:Try<U>, h:Try<V>, filter:(T,U,V) -> Bool, yield:(T,U,V) -> W) -> Try<W> {
    return f.flatmap {fvalue in
        g.flatmap {gvalue in
            h.filter {hvalue in
                filter(fvalue, gvalue, hvalue)
            }.map {hvalue in
                yield(fvalue, gvalue, hvalue)
            }
        }
    }
    
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// ExecutionContext
public protocol ExecutionContext {
    
    func execute(_ task:@escaping ()->Void)
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// QueueContext
public struct QueueContext : ExecutionContext {
    
    public static let main =  QueueContext(queue:Queue.main)
    
    public static let global = QueueContext(queue:Queue.global)
    
    let queue:Queue
    
    public init(queue:Queue) {
        self.queue = queue
    }
    
    public func execute(_ task:@escaping () -> Void) {
        queue.async(task)
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Queue
public struct Queue {
    
    public static let main              = Queue(DispatchQueue.main);
    public static let global            = Queue(DispatchQueue.global(qos: DispatchQoS.QoSClass.default))
    
    internal static let simpleFutures       = Queue("us.gnos.simpleFutures")
    internal static let simpleFutureStreams = Queue("us.gnos.simpleFutureStreams")
    
    var queue: DispatchQueue
    
    
    public init(_ queueName:String) {
        self.queue = DispatchQueue(label: queueName, attributes: [])
    }
    
    public init(_ queue:DispatchQueue) {
        self.queue = queue
    }
    
    public func sync(_ block:() -> Void) {
        self.queue.sync(execute: block)
    }
    
    public func sync<T>(_ block:() -> T) -> T {
        var result:T!
        self.queue.sync(execute: {
            result = block();
        });
        return result;
    }
    
    public func async(_ block:@escaping ()->()) {
        self.queue.async(execute: block);
    }
    
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
public struct SimpleFuturesError {
    static let domain = "SimpleFutures"
    static let futureCompleted      = NSError(domain:domain, code:1, userInfo:[NSLocalizedDescriptionKey:"Future has been completed"])
    static let futureNotCompleted   = NSError(domain:domain, code:2, userInfo:[NSLocalizedDescriptionKey:"Future has not been completed"])
}

public struct SimpleFuturesException {
    static let futureCompleted = NSException(name:NSExceptionName(rawValue: "Future complete error"), reason: "Future previously completed.", userInfo:nil)
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Promise
open class Promise<T> {
    
    open let future = Future<T>()
    
    open var completed : Bool {
        return self.future.completed
    }
    
    public init() {
    }
    
    open func completeWith(_ future:Future<T>) {
        self.completeWith(self.future.defaultExecutionContext, future:future)
    }
    
    open func completeWith(_ executionContext:ExecutionContext, future:Future<T>) {
        self.future.completeWith(executionContext, future:future)
    }
    
    open func complete(_ result:Try<T>) {
        self.future.complete(result)
    }
    
    open func success(_ value:T) {
        self.future.success(value)
    }
    
    open func failure(_ error:NSError)  {
        self.future.failure(error)
    }
    
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Future
open class Future<T> {
    
    private var result:Try<T>?
    
    internal let defaultExecutionContext: ExecutionContext  = QueueContext.main
    typealias OnComplete                                    = (Try<T>) -> Void
    private var saveCompletes                               = [OnComplete]()
    
    open var completed : Bool {
        return self.result != nil
    }
    
    public init() {
    }
    
    // should be future mixin
    internal func complete(_ result:Try<T>) {
        Queue.simpleFutures.sync {
            if self.result != nil {
                SimpleFuturesException.futureCompleted.raise()
            }
            self.result = result
            for complete in self.saveCompletes {
                complete(result)
            }
            self.saveCompletes.removeAll()
        }
    }
    
    open func onComplete(_ executionContext:ExecutionContext, complete:@escaping (Try<T>) -> Void) -> Void {
        Queue.simpleFutures.sync {
            let savedCompletion : OnComplete = {result in
                executionContext.execute {
                    complete(result)
                }
            }
            if let result = self.result {
                savedCompletion(result)
            } else {
                self.saveCompletes.append(savedCompletion)
            }
        }
    }
    
    open func onComplete(_ complete:@escaping (Try<T>) -> Void) {
        self.onComplete(self.defaultExecutionContext, complete:complete)
    }
    
    open func onSuccess(_ success:@escaping (T) -> Void) {
        self.onSuccess(self.defaultExecutionContext, success:success)
    }
    
    open func onSuccess(_ executionContext:ExecutionContext, success:@escaping (T) -> Void){
        self.onComplete(executionContext) {result in
            switch result {
            case .success(let value):
                success(value)
            default:
                break
            }
        }
    }
    
    open func onFailure(_ failure:@escaping (NSError) -> Void) -> Void {
        return self.onFailure(self.defaultExecutionContext, failure:failure)
    }
    
    open func onFailure(_ executionContext:ExecutionContext, failure:@escaping (NSError) -> Void) {
        self.onComplete(executionContext) {result in
            switch result {
            case .failure(let error):
                failure(error)
            default:
                break
            }
        }
    }
    
    open func map<M>(_ mapping:@escaping (T) -> Try<M>) -> Future<M> {
        return map(self.defaultExecutionContext, mapping:mapping)
    }
    
    open func map<M>(_ executionContext:ExecutionContext, mapping:@escaping (T) -> Try<M>) -> Future<M> {
        let future = Future<M>()
        self.onComplete(executionContext) {result in
            future.complete(result.flatmap(mapping))
        }
        return future
    }
    
    open func flatmap<M>(_ mapping:@escaping (T) -> Future<M>) -> Future<M> {
        return self.flatmap(self.defaultExecutionContext, mapping:mapping)
    }
    
    open func flatmap<M>(_ executionContext:ExecutionContext, mapping:@escaping (T) -> Future<M>) -> Future<M> {
        let future = Future<M>()
        self.onComplete(executionContext) {result in
            switch result {
            case .success(let value):
                future.completeWith(executionContext, future:mapping(value))
            case .failure(let error):
                future.failure(error)
            }
        }
        return future
    }
    
    open func andThen(_ complete:@escaping (Try<T>) -> Void) -> Future<T> {
        return self.andThen(self.defaultExecutionContext, complete:complete)
    }
    
    open func andThen(_ executionContext:ExecutionContext, complete:@escaping (Try<T>) -> Void) -> Future<T> {
        let future = Future<T>()
        future.onComplete(executionContext, complete:complete)
        self.onComplete(executionContext) {result in
            future.complete(result)
        }
        return future
    }
    
    open func recover(_ recovery: @escaping (NSError) -> Try<T>) -> Future<T> {
        return self.recover(self.defaultExecutionContext, recovery:recovery)
    }
    
    open func recover(_ executionContext:ExecutionContext, recovery:@escaping (NSError) -> Try<T>) -> Future<T> {
        let future = Future<T>()
        self.onComplete(executionContext) {result in
            future.complete(result.recoverWith(recovery))
        }
        return future
    }
    
    open func recoverWith(_ recovery:@escaping (NSError) -> Future<T>) -> Future<T> {
        return self.recoverWith(self.defaultExecutionContext, recovery:recovery)
    }
    
    open func recoverWith(_ executionContext:ExecutionContext, recovery:@escaping (NSError) -> Future<T>) -> Future<T> {
        let future = Future<T>()
        self.onComplete(executionContext) {result in
            switch result {
            case .success(let value):
                future.success(value)
            case .failure(let error):
                future.completeWith(executionContext, future:recovery(error))
            }
        }
        return future
    }
    
    open func withFilter(_ filter:@escaping (T) -> Bool) -> Future<T> {
        return self.withFilter(self.defaultExecutionContext, filter:filter)
    }
    
    open func withFilter(_ executionContext:ExecutionContext, filter:@escaping (T) -> Bool) -> Future<T> {
        let future = Future<T>()
        self.onComplete(executionContext) {result in
            future.complete(result.filter(filter))
        }
        return future
    }
    
    open func foreach(_ apply:@escaping (T) -> Void) {
        self.foreach(self.defaultExecutionContext, apply:apply)
    }
    
    open func foreach(_ executionContext:ExecutionContext, apply:@escaping (T) -> Void) {
        self.onComplete(executionContext) {result in
            result.foreach(apply)
        }
    }
    
    internal func completeWith(_ future:Future<T>) {
        self.completeWith(self.defaultExecutionContext, future:future)
    }
    
    internal func completeWith(_ executionContext:ExecutionContext, future:Future<T>) {
        let isCompleted = Queue.simpleFutures.sync {
            return self.result != nil
        }
        if isCompleted == false {
            future.onComplete(executionContext) {result in
                self.complete(result)
            }
        }
    }
    
    internal func success(_ value:T) {
        self.complete(Try(value))
    }
    
    internal func failure(_ error:NSError) {
        self.complete(Try<T>(error))
    }
    
    // future stream extensions
    open func flatmap<M>(_ capacity:Int, mapping:@escaping (T) -> FutureStream<M>) -> FutureStream<M> {
        return self.flatMapStream(capacity, executionContext:self.defaultExecutionContext, mapping:mapping)
    }
    
    open func flatmap<M>(_ mapping:@escaping (T) -> FutureStream<M>) -> FutureStream<M> {
        return self.flatMapStream(nil, executionContext:self.defaultExecutionContext, mapping:mapping)
    }
    
    open func flatmap<M>(_ capacity:Int, executionContext:ExecutionContext, mapping:@escaping (T) -> FutureStream<M>) -> FutureStream<M>  {
        return self.flatMapStream(capacity, executionContext:self.defaultExecutionContext, mapping:mapping)
    }
    
    open func flatmap<M>(_ executionContext:ExecutionContext, mapping:@escaping (T) -> FutureStream<M>) -> FutureStream<M>  {
        return self.flatMapStream(nil, executionContext:self.defaultExecutionContext, mapping:mapping)
    }
    
    open func recoverWith(_ recovery:@escaping (NSError) -> FutureStream<T>) -> FutureStream<T> {
        return self.recoverWithStream(nil, executionContext:self.defaultExecutionContext, recovery:recovery)
    }
    
    open func recoverWith(_ capacity:Int, recovery:@escaping (NSError) -> FutureStream<T>) -> FutureStream<T> {
        return self.recoverWithStream(capacity, executionContext:self.defaultExecutionContext, recovery:recovery)
    }
    
    open func recoverWith(_ executionContext:ExecutionContext, recovery:@escaping (NSError) -> FutureStream<T>) -> FutureStream<T> {
        return self.recoverWithStream(nil, executionContext:executionContext, recovery:recovery)
    }
    
    open func recoverWith(_ capacity:Int, executionContext:ExecutionContext, recovery:@escaping (NSError) -> FutureStream<T>) -> FutureStream<T> {
        return self.recoverWithStream(capacity, executionContext:executionContext, recovery:recovery)
    }
    
    internal func completeWith(_ stream:FutureStream<T>) {
        self.completeWith(self.defaultExecutionContext, stream:stream)
    }
    
    internal func completeWith(_ executionContext:ExecutionContext, stream:FutureStream<T>) {
        stream.onComplete(executionContext) {result in
            self.complete(result)
        }
    }
    
    internal func flatMapStream<M>(_ capacity:Int?, executionContext:ExecutionContext, mapping:@escaping (T) -> FutureStream<M>) -> FutureStream<M> {
        let stream = FutureStream<M>(capacity:capacity)
        self.onComplete(executionContext) {result in
            switch result {
            case .success(let value):
                stream.completeWith(executionContext, stream:mapping(value))
            case .failure(let error):
                stream.failure(error)
            }
        }
        return stream
    }
    
    internal func recoverWithStream(_ capacity:Int?, executionContext:ExecutionContext, recovery:@escaping (NSError) -> FutureStream<T>) -> FutureStream<T> {
        let stream = FutureStream<T>(capacity:capacity)
        self.onComplete(executionContext) {result in
            switch result {
            case .success(let value):
                stream.success(value)
            case .failure(let error):
                stream.completeWith(executionContext, stream:recovery(error))
            }
        }
        return stream
    }
    
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// create futures
public func future<T>(_ computeResult:@escaping () -> Try<T>) -> Future<T> {
    return future(QueueContext.global, calculateResult:computeResult)
}

public func future<T>(_ executionContext:ExecutionContext, calculateResult:@escaping () -> Try<T>) -> Future<T> {
    let promise = Promise<T>()
    executionContext.execute {
        promise.complete(calculateResult())
    }
    return promise.future
}

public func forcomp<T,U>(_ f:Future<T>, g:Future<U>, apply:@escaping (T,U) -> Void) -> Void {
    return forcomp(f.defaultExecutionContext, f:f, g:g, apply:apply)
}

public func forcomp<T,U>(_ executionContext:ExecutionContext, f:Future<T>, g:Future<U>, apply:@escaping (T,U) -> Void) -> Void {
    f.foreach(executionContext) {fvalue in
        g.foreach(executionContext) {gvalue in
            apply(fvalue, gvalue)
        }
    }
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// for comprehensions
public func forcomp<T,U>(_ f:Future<T>, g:Future<U>, filter:@escaping (T,U) -> Bool, apply:@escaping (T,U) -> Void) -> Void {
    return forcomp(f.defaultExecutionContext, f:f, g:g, filter:filter, apply:apply)
}

public func forcomp<T,U>(_ executionContext:ExecutionContext, f:Future<T>, g:Future<U>, filter:@escaping (T,U) -> Bool, apply:@escaping (T,U) -> Void) -> Void {
    f.foreach(executionContext) {fvalue in
        g.withFilter(executionContext) {gvalue in
            filter(fvalue, gvalue)
        }.foreach(executionContext) {gvalue in
            apply(fvalue, gvalue)
        }
    }
}

public func forcomp<T,U,V>(_ f:Future<T>, g:Future<U>, h:Future<V>, apply:@escaping (T,U,V) -> Void) -> Void {
    return forcomp(f.defaultExecutionContext, f:f, g:g, h:h, apply:apply)
}

public func forcomp<T,U,V>(_ executionContext:ExecutionContext, f:Future<T>, g:Future<U>, h:Future<V>, apply:@escaping (T,U,V) -> Void) -> Void {
    f.foreach(executionContext) {fvalue in
        g.foreach(executionContext) {gvalue in
            h.foreach(executionContext) {hvalue in
                apply(fvalue, gvalue, hvalue)
            }
        }
    }
}

public func forcomp<T,U,V>(_ f:Future<T>, g:Future<U>, h:Future<V>, filter:@escaping (T,U,V) -> Bool, apply:@escaping (T,U,V) -> Void) -> Void {
    return forcomp(f.defaultExecutionContext, f:f, g:g, h:h, filter:filter, apply:apply)
}

public func forcomp<T,U,V>(_ executionContext:ExecutionContext, f:Future<T>, g:Future<U>, h:Future<V>, filter:@escaping (T,U,V) -> Bool, apply:@escaping (T,U,V) -> Void) -> Void {
    f.foreach(executionContext) {fvalue in
        g.foreach(executionContext) {gvalue in
            h.withFilter(executionContext) {hvalue in
                filter(fvalue, gvalue, hvalue)
            }.foreach(executionContext) {hvalue in
                apply(fvalue, gvalue, hvalue)
            }
        }
    }
}

public func forcomp<T,U,V>(_ f:Future<T>, g:Future<U>, yield:@escaping (T,U) -> Try<V>) -> Future<V> {
    return forcomp(f.defaultExecutionContext, f:f, g:g, yield:yield)
}

public func forcomp<T,U,V>(_ executionContext:ExecutionContext, f:Future<T>, g:Future<U>, yield:@escaping (T,U) -> Try<V>) -> Future<V> {
    return f.flatmap(executionContext) {fvalue in
        g.map(executionContext) {gvalue in
            yield(fvalue, gvalue)
        }
    }
}

public func forcomp<T,U,V>(_ f:Future<T>, g:Future<U>, filter:@escaping (T,U) -> Bool, yield:@escaping (T,U) -> Try<V>) -> Future<V> {
    return forcomp(f.defaultExecutionContext, f:f, g:g, filter:filter, yield:yield)
}

public func forcomp<T,U,V>(_ executionContext:ExecutionContext, f:Future<T>, g:Future<U>, filter:@escaping (T,U) -> Bool, yield:@escaping (T,U) -> Try<V>) -> Future<V> {
    return f.flatmap(executionContext) {fvalue in
        g.withFilter(executionContext) {gvalue in
            filter(fvalue, gvalue)
        }.map(executionContext) {gvalue in
            yield(fvalue, gvalue)
        }
    }
}

public func forcomp<T,U,V,W>(_ f:Future<T>, g:Future<U>, h:Future<V>, yield:@escaping (T,U,V) -> Try<W>) -> Future<W> {
    return forcomp(f.defaultExecutionContext, f:f, g:g, h:h, yield:yield)
}

public func forcomp<T,U,V,W>(_ executionContext:ExecutionContext, f:Future<T>, g:Future<U>, h:Future<V>, yield:@escaping (T,U,V) -> Try<W>) -> Future<W> {
    return f.flatmap(executionContext) {fvalue in
        g.flatmap(executionContext) {gvalue in
            h.map(executionContext) {hvalue in
                yield(fvalue, gvalue, hvalue)
            }
        }
    }
}

public func forcomp<T,U, V, W>(_ f:Future<T>, g:Future<U>, h:Future<V>, filter:@escaping (T,U,V) -> Bool, yield:@escaping (T,U,V) -> Try<W>) -> Future<W> {
    return forcomp(f.defaultExecutionContext, f:f, g:g, h:h, filter:filter, yield:yield)
}

public func forcomp<T,U, V, W>(_ executionContext:ExecutionContext, f:Future<T>, g:Future<U>, h:Future<V>, filter:@escaping (T,U,V) -> Bool, yield:@escaping (T,U,V) -> Try<W>) -> Future<W> {
    return f.flatmap(executionContext) {fvalue in
        g.flatmap(executionContext) {gvalue in
            h.withFilter(executionContext) {hvalue in
                filter(fvalue, gvalue, hvalue)
            }.map(executionContext) {hvalue in
                yield(fvalue, gvalue, hvalue)
            }
        }
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// StreamPromise
open class StreamPromise<T> {
    
    open let future : FutureStream<T>
    
    public init(capacity:Int?=nil) {
        self.future = FutureStream<T>(capacity:capacity)
    }
    
    open func complete(_ result:Try<T>) {
        self.future.complete(result)
    }
    
    open func completeWith(_ future:Future<T>) {
        self.completeWith(self.future.defaultExecutionContext, future:future)
    }
    
    open func completeWith(_ executionContext:ExecutionContext, future:Future<T>) {
        future.completeWith(executionContext, future:future)
    }
    
    open func success(_ value:T) {
        self.future.success(value)
    }
    
    open func failure(_ error:NSError) {
        self.future.failure(error)
    }
    
    open func completeWith(_ stream:FutureStream<T>) {
        self.completeWith(self.future.defaultExecutionContext, stream:stream)
    }
    
    open func completeWith(_ executionContext:ExecutionContext, stream:FutureStream<T>) {
        future.completeWith(executionContext, stream:stream)
    }
    
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// FutureStream
open class FutureStream<T> {
    
    private var futures         = [Future<T>]()
    private typealias InFuture  = (Future<T>) -> Void
    private var saveCompletes   = [InFuture]()
    private var capacity        : Int?
    
    internal let defaultExecutionContext: ExecutionContext  = QueueContext.main
    
    open var count : Int {
        return futures.count
    }
    
    public init(capacity:Int?=nil) {
        self.capacity = capacity
    }
    
    // should be future mixin
    internal func complete(_ result:Try<T>) {
        let future = Future<T>()
        future.complete(result)
        Queue.simpleFutureStreams.sync {
            self.addFuture(future)
            for complete in self.saveCompletes {
                complete(future)
            }
        }
    }
    
    open func onComplete(_ executionContext:ExecutionContext, complete:@escaping (Try<T>) -> Void) {
        Queue.simpleFutureStreams.sync {
            let futureComplete : InFuture = {future in
                future.onComplete(executionContext, complete:complete)
            }
            self.saveCompletes.append(futureComplete)
            for future in self.futures {
                futureComplete(future)
            }
        }
    }
    
    open func onComplete(_ complete:@escaping (Try<T>) -> Void) {
        self.onComplete(self.defaultExecutionContext, complete:complete)
    }
    
    open func onSuccess(_ success:@escaping (T) -> Void) {
        self.onSuccess(self.defaultExecutionContext, success:success)
    }
    
    open func onSuccess(_ executionContext:ExecutionContext, success:@escaping (T) -> Void) {
        self.onComplete(executionContext) {result in
            switch result {
            case .success(let value):
                success(value)
            default:
                break
            }
        }
    }
    
    open func onFailure(_ failure:@escaping (NSError) -> Void) {
        self.onFailure(self.defaultExecutionContext, failure:failure)
    }
    
    open func onFailure(_ executionContext:ExecutionContext, failure:@escaping (NSError) -> Void) {
        self.onComplete(executionContext) {result in
            switch result {
            case .failure(let error):
                failure(error)
            default:
                break
            }
        }
    }
    
    open func map<M>(_ mapping:@escaping (T) -> Try<M>) -> FutureStream<M> {
        return self.map(self.defaultExecutionContext, mapping:mapping)
    }
    
    open func map<M>(_ executionContext:ExecutionContext, mapping:@escaping (T) -> Try<M>) -> FutureStream<M> {
        let future = FutureStream<M>(capacity:self.capacity)
        self.onComplete(executionContext) {result in
            future.complete(result.flatmap(mapping))
        }
        return future
    }
    
    open func flatmap<M>(_ mapping:@escaping (T) -> FutureStream<M>) -> FutureStream<M> {
        return self.flatMap(self.defaultExecutionContext, mapping:mapping)
    }
    
    open func flatMap<M>(_ executionContext:ExecutionContext, mapping:@escaping (T) -> FutureStream<M>) -> FutureStream<M> {
        let future = FutureStream<M>(capacity:self.capacity)
        self.onComplete(executionContext) {result in
            switch result {
            case .success(let value):
                future.completeWith(executionContext, stream:mapping(value))
            case .failure(let error):
                future.failure(error)
            }
        }
        return future
    }
    
    open func andThen(_ complete:@escaping (Try<T>) -> Void) -> FutureStream<T> {
        return self.andThen(self.defaultExecutionContext, complete:complete)
    }
    
    open func andThen(_ executionContext:ExecutionContext, complete:@escaping (Try<T>) -> Void) -> FutureStream<T> {
        let future = FutureStream<T>(capacity:self.capacity)
        future.onComplete(executionContext, complete:complete)
        self.onComplete(executionContext) {result in
            future.complete(result)
        }
        return future
    }
    
    open func recover(_ recovery:@escaping (NSError) -> Try<T>) -> FutureStream<T> {
        return self.recover(self.defaultExecutionContext, recovery:recovery)
    }
    
    open func recover(_ executionContext:ExecutionContext, recovery:@escaping (NSError) -> Try<T>) -> FutureStream<T> {
        let future = FutureStream<T>(capacity:self.capacity)
        self.onComplete(executionContext) {result in
            future.complete(result.recoverWith(recovery))
        }
        return future
    }
    
    open func recoverWith(_ recovery:@escaping (NSError) -> FutureStream<T>) -> FutureStream<T> {
        return self.recoverWith(self.defaultExecutionContext, recovery:recovery)
    }
    
    open func recoverWith(_ executionContext:ExecutionContext, recovery:@escaping (NSError) -> FutureStream<T>) -> FutureStream<T> {
        let future = FutureStream<T>(capacity:self.capacity)
        self.onComplete(executionContext) {result in
            switch result {
            case .success(let value):
                future.success(value)
            case .failure(let error):
                future.completeWith(executionContext, stream:recovery(error))
            }
        }
        return future
    }
    
    open func withFilter(_ filter:@escaping (T) -> Bool) -> FutureStream<T> {
        return self.withFilter(self.defaultExecutionContext, filter:filter)
    }
    
    open func withFilter(_ executionContext:ExecutionContext, filter:@escaping (T) -> Bool) -> FutureStream<T> {
        let future = FutureStream<T>(capacity:self.capacity)
        self.onComplete(executionContext) {result in
            future.complete(result.filter(filter))
        }
        return future
    }
    
    open func foreach(_ apply:@escaping (T) -> Void) {
        self.foreach(self.defaultExecutionContext, apply:apply)
    }
    
    open func foreach(_ executionContext:ExecutionContext, apply:@escaping (T) -> Void) {
        self.onComplete(executionContext) {result in
            result.foreach(apply)
        }
    }
    
    internal func completeWith(_ stream:FutureStream<T>) {
        self.completeWith(self.defaultExecutionContext, stream:stream)
    }
    
    internal func completeWith(_ executionContext:ExecutionContext, stream:FutureStream<T>) {
        stream.onComplete(executionContext) {result in
            self.complete(result)
        }
    }
    
    internal func success(_ value:T) {
        self.complete(Try(value))
    }
    
    internal func failure(_ error:NSError) {
        self.complete(Try<T>(error))
    }
    
    // future stream extensions
    open func flatmap<M>(_ mapping:@escaping (T) -> Future<M>) -> FutureStream<M> {
        return self.flatmap(self.defaultExecutionContext, mapping:mapping)
    }
    
    open func flatmap<M>(_ executionContext:ExecutionContext, mapping:@escaping (T) -> Future<M>) -> FutureStream<M> {
        let future = FutureStream<M>(capacity:self.capacity)
        self.onComplete(executionContext) {result in
            switch result {
            case .success(let value):
                future.completeWith(executionContext, future:mapping(value))
            case .failure(let error):
                future.failure(error)
            }
        }
        return future
    }
    
    open func recoverWith(_ recovery:@escaping (NSError) -> Future<T>) -> FutureStream<T> {
        return self.recoverWith(self.defaultExecutionContext, recovery:recovery)
    }
    
    open func recoverWith(_ executionContext:ExecutionContext, recovery:@escaping (NSError) -> Future<T>) -> FutureStream<T> {
        let future = FutureStream<T>(capacity:self.capacity)
        self.onComplete(executionContext) {result in
            switch result {
            case .success(let value):
                future.success(value)
            case .failure(let error):
                future.completeWith(executionContext, future:recovery(error))
            }
        }
        return future
    }
    
    internal func completeWith(_ future:Future<T>) {
        self.completeWith(self.defaultExecutionContext, future:future)
    }
    
    internal func completeWith(_ executionContext:ExecutionContext, future:Future<T>) {
        future.onComplete(executionContext) {result in
            self.complete(result)
        }
    }
    
    internal func addFuture(_ future:Future<T>) {
        if let capacity = self.capacity {
            if self.futures.count >= capacity {
                self.futures.remove(at: 0)
            }
        }
        self.futures.append(future)
    }
    
}

