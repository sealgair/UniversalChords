//
//  MusicExtensions.swift
//  UniversalChords
//
//  Created by Chase Caster on 6/23/16.
//  Copyright © 2016 chasecaster. All rights reserved.
//

import Foundation
import MusicKit

let kSavedNoteDisplayNameType = "kSavedNoteDisplayNameType"
let kSavedNoteDisplayAccidental = "kSavedNoteDisplayAccidental"

enum NoteNameType: Int, CustomStringConvertible {
    case letter = 0
    case solfège = 1
    
    var description: String {
        switch self {
        case .letter: return "Letter"
        case .solfège: return "Solfège"
        }
    }
    
    static func getCurrent() -> NoteNameType {
        return NoteNameType(rawValue: UserDefaults.standard.integer(forKey: kSavedNoteDisplayNameType)) ?? .letter
    }
    
    func setCurrent() {
        UserDefaults.standard.setValue(self.rawValue, forKey: kSavedNoteDisplayNameType)
    }
}

extension Accidental {
    
    static func getCurrent() -> Accidental {
        let acc = Accidental(rawValue: UserDefaults.standard.float(forKey: kSavedNoteDisplayAccidental)) ?? .flat
        if acc == .sharp || acc == .flat {
            return acc
        }
        return .flat
    }
    
    func setCurrent() {
        UserDefaults.standard.setValue(self.rawValue, forKey: kSavedNoteDisplayAccidental)
    }
}

extension Chroma {
    // TODO: would be nice to not have to copy this
    var names: [(LetterName, Accidental)] {
        switch self.rawValue {
        case 0:
            return [(.c, .natural), (.b, .sharp), (.d, .doubleFlat)]
        case 1:
            return [(.c, .sharp), (.d, .flat), (.b, .doubleSharp)]
        case 2:
            return [(.d, .natural), (.c, .doubleSharp), (.e, .doubleFlat)]
        case 3:
            return [(.e, .flat), (.d, .sharp), (.f, .doubleFlat)]
        case 4:
            return [(.e, .natural), (.f, .flat), (.d, .doubleSharp)]
        case 5:
            return [(.f, .natural), (.e, .sharp), (.g, .doubleFlat)]
        case 6:
            return [(.f, .sharp), (.g, .flat), (.e, .doubleSharp)]
        case 7:
            return [(.g, .natural), (.f, .doubleSharp), (.a, .doubleFlat)]
        case 8:
            return [(.a, .flat), (.g, .sharp)]
        case 9:
            return [(.a, .natural), (.g, .doubleSharp), (.b, .doubleFlat)]
        case 10:
            return [(.b, .flat), (.a, .sharp), (.c, .doubleFlat)]
        case 11:
            return [(.b, .natural), (.c, .flat), (.a, .doubleSharp)]
        default:
            return []
        }
    }
    
    public var isNatural: Bool {
        let (_, accidental) = self.names[0]
        return accidental == .natural
    }
    
    func describe(displayName: NoteNameType, displayAccidental: Accidental) -> String {
        for (letterName, accidental) in self.names {
            if accidental == .natural || accidental == displayAccidental {
                return "\(letterName.describe(nameScheme: displayName))\(accidental.description(true))"
            }
        }
        return ""
    }
    
    func describeCurrent() -> String {
        return describe(displayName: NoteNameType.getCurrent(), displayAccidental: Accidental.getCurrent())
    }
}

extension LetterName {
    public var solfège : String {
        switch self {
        case .c: return "Do"
        case .d: return "Re"
        case .e: return "Mi"
        case .f: return "Fa"
        case .g: return "Sol"
        case .a: return "La"
        case .b: return "Si"
        }
    }
    
    func describe(nameScheme: NoteNameType) -> String {
        switch nameScheme {
        case .letter: return description
        case .solfège: return solfège
        }
    }
}

extension ChordQuality {
    var name: String {
        switch self {
        case .Major:
            return "Major"
        case .Minor:
            return "Minor"
        case .Diminished:
            return "dim"
        case .Augmented:
            return "aug"
        default:
            return self.rawValue
        }
    }
}
