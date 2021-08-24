//
//  CacheQueue.swift
//  RealTimeLogCaughter
//
//  Created by StephenFang on 2021/8/20.
//

import Foundation

public class Node<Value> {
    var value: Value
    var next: Node?

    init(value: Value, next: Node? = nil) {
        self.value = value
        self.next = next
    }
}

extension Node: CustomStringConvertible {
    public var description: String {
    guard let next = next else {
            return "\(value)"
        }
        return "\(value) -> " + String(describing: next) + " "
    }
}

public struct LinkedList<Value> {
    var head: Node<Value>?
    var tail: Node<Value>?

    init() {}

    var isEmpty: Bool {
        return head == nil
    }
    
    var isLongerThan2: Bool {
        guard !isEmpty else {
            return false
        }
        return head?.next != nil
    }
}

extension LinkedList: CustomStringConvertible {
    public var description: String {
        guard let head = head else {
            return "Empty List"
        }
        return String(describing: head)
    }
}

extension LinkedList {
    mutating func push(_ value: Value) {
        head = Node(value: value, next: head)
        if tail == nil {
            tail = head
        }
    }
    
    mutating func append(_ value: Value) {
         guard !isEmpty else {
             push(value)
             return
         }
         tail?.next = Node(value: value)
         tail = tail?.next
    }
    
    public mutating func pop() -> Value? {
        defer {
            head = head?.next
            if isEmpty {
                 tail = nil
            }
        }
        return head?.value
   }
    
    public mutating func returnHeadValue() -> Value? {
        return head?.value
    }
}
