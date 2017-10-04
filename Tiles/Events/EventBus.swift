//
//  EventBus.swift
//  Tiles
//
//  Created by Gerrit Grunwald on 02.10.17.
//  Copyright © 2017 Gerrit Grunwald. All rights reserved.
//

import UIKit

class EventBus {
    // using NSMutableArray as Swift arrays can't change size inside dictionaries (yet, probably)
    var subscribers = Dictionary<String, NSMutableArray>()
    
    func subscribeTo(eventName:String, action: @escaping (()->())) {
        let newListener = EventListenerAction(callback: action)
        addSubscriber(eventName: eventName, newEventListener: newListener)
    }
    
    func subscribeTo(eventName:String, action: @escaping ((Any?)->())) {
        let newListener = EventListenerAction(callback: action)
        addSubscriber(eventName: eventName, newEventListener: newListener)
    }
    
    
    internal func addSubscriber(eventName:String, newEventListener:EventListenerAction) {
        if let subscriberArray = self.subscribers[eventName] {
            subscriberArray.add(newEventListener)
        } else {
            self.subscribers[eventName] = [newEventListener] as NSMutableArray
        }
    }
    
    func unsubscribe(eventNameToRemoveOrNil:String?) {
        if let eventNameToRemove = eventNameToRemoveOrNil {
            if let actionArray = self.subscribers[eventNameToRemove] {
                actionArray.removeAllObjects()
            }
        } else {
            self.subscribers.removeAll(keepingCapacity: false)
        }
    }
    
    func fireEvent(eventName:String, information:Any? = nil) {
        if let actionObjects = self.subscribers[eventName] {
            for actionObject in actionObjects {
                if let actionToPerform = actionObject as? EventListenerAction {
                    if let methodToCall = actionToPerform.actionExpectsInfo {
                        methodToCall(information)
                    } else if let methodToCall = actionToPerform.action {
                        methodToCall()
                    }
                }
            }
        }
    }
}

// Class to hold actions to live in NSMutableArray
class EventListenerAction {
    let action           :(() -> ())?
    let actionExpectsInfo:((Any?) -> ())?
    
    init(callback: @escaping (() -> ()) ) {
        self.action            = callback
        self.actionExpectsInfo = nil
    }
    
    init(callback: @escaping ((Any?) -> ()) ) {
        self.actionExpectsInfo = callback
        self.action            = nil
    }
}
