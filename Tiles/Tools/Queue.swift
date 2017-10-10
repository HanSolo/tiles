//
//  Queue.swift
//  Tiles
//
//  Created by Gerrit Grunwald on 09.10.17.
//  Copyright © 2017 Gerrit Grunwald. All rights reserved.
//

import UIKit


public struct Queue<T> {
    fileprivate var array = [T?]()
    fileprivate var head = 0
    
    public var isEmpty: Bool { return count == 0 }
    public var count  : Int  { return array.count - head }
    public var first  : T?   { return isEmpty ? nil : array[head] }
    public var last   : T?   { return isEmpty ? nil : array[array.endIndex - 1] }
    
    public mutating func add(_ element: T) { array.append(element) }
    
    public mutating func remove() -> T? {
        guard head < array.count, let element = array[head] else { return nil }
        
        array[head] = nil
        head += 1
        
        let percentage = Double(head)/Double(array.count)
        if array.count > 50 && percentage > 0.25 {
            array.removeFirst(head)
            head = 0
        }
        return element
    }
    
    public subscript(index: Int) -> T {
        get { return array[index]! }
        set(newValue) { array[index]! = newValue }
    }
    
    public mutating func clear() { array.removeAll() }
}
