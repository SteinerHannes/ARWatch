//
//  AtomicInteger.swift
//  ARWatch
//
//  Created by Hannes Steiner on 11.08.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import Foundation

public final class AtomicInteger {
    
    private let lock = DispatchSemaphore(value: 1)
    
    private var _value: Int
    
    public init(value initialValue: Int = 0) {
        _value = initialValue
    }
    
    public var value: Int {
        get {
            lock.wait()
            defer { lock.signal() }
            debugPrint("get value: ", _value)
            return _value
        }
        set {
            lock.wait()
            defer { lock.signal() }
            _value = newValue
            debugPrint("set value: ", _value)
        }
    }
    
    public func decrementAndGet() -> Int {
        lock.wait()
        defer { lock.signal() }
        _value -= 1
        debugPrint("decrementAndGet: ", _value)
        return _value
    }
    
    public func incrementAndGet() -> Int {
        lock.wait()
        defer { lock.signal() }
        _value += 1
        debugPrint("incrementAndGet: ", _value)
        return _value
    }
    
    public func increment() {
        lock.wait()
        defer { lock.signal() }
        _value += 1
        debugPrint("increment: ", _value)
    }
}
