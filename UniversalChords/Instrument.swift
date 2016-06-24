//
//  Instrument.swift
//  UniversalChords
//
//  Created by Chase Caster on 5/16/15.
//  Copyright (c) 2015 chasecaster. All rights reserved.
//

import UIKit
import MusicKit

let fingerCache = NSCache()

struct Instrument {
    let name: String
    let strings: [Chroma]
    
    func nextFingerings(thisString: [Finger], otherStrings: [[Finger]]) -> [Fingering] {
        if otherStrings.count == 0 {
            return thisString.map {f in [f]}
        }
        var fingerings: [Fingering] = []
        for finger in thisString {
            for fingering in nextFingerings(otherStrings[0], otherStrings: Array(otherStrings[1..<otherStrings.count])) {
                fingerings.append([finger] + fingering)
            }
        }
        return fingerings
    }
    
    func fingerings(pitchset: PitchSet) -> [Fingering] {
        let cacheKey = pitchset.description + self.name
        if let wrapper = fingerCache.objectForKey(cacheKey) as? ObjectWrapper<[Fingering]> {
            return wrapper.value
        }
        
        var notes = Set<Chroma>()
        for note in pitchset {
            notes.insert(note.chroma!)
        }
        
        let goodFretsByString: [[Finger]] = strings.map { string in
            let frets = (0...15).filter { i in
                return notes.contains(string + i)
            }
            return frets.map { i in
                return Finger(position: i, string: string)
            }
        }
        
        var fingerings: [Fingering] = nextFingerings(goodFretsByString[0], otherStrings: Array(goodFretsByString[1..<goodFretsByString.count]))
        fingerings = fingerings.filter { fingering in
            if Set(fingering.map { f in f.note }) != notes {
                return false
            }
            let top = fingering.reduce(0) {a, b in max(a, b.position)}
            let bottom = fingering.reduce(12) {a, b in min(a, b.position)}
            if bottom - top > 5 {
                return false
            }
            return true
        }
        fingerCache.setObject(ObjectWrapper(fingerings), forKey: cacheKey)
        return fingerings
    }
}
