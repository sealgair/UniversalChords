//
//  Finger.swift
//  UniversalChords
//
//  Created by Chase Caster on 5/24/15.
//  Copyright (c) 2015 chasecaster. All rights reserved.
//

import Foundation
import MusicKit

struct Finger {
    let position: Int
    let string: Chroma
    var note: Chroma {
        return self.string + position
    }
}



typealias Fingering = Array<Finger>