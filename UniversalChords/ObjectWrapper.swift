//
//  ObjectWrapper.swift
//  UniversalChords
//
//  Created by Chase Caster on 8/26/15.
//  Copyright (c) 2015 chasecaster. All rights reserved.
//

import Foundation


@objc class ObjectWrapper<T> : NSObject {
    var _val: [T]
    
    init(_ v: T) {
        _val = [v]
    }
    
    var value : T {
        get {
            return _val[0]
            
        }
        set {
            _val[0] = newValue
        }
    }
}

// Ugly hack that seems to work, as recommended by http://stackoverflow.com/questions/24161563/swift-compile-error-when-subclassing-nsobject-and-using-generics
// Likely works because objective-c only supports generics in container types