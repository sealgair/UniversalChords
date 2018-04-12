//
//  MusicExtensions.swift
//  UniversalChords
//
//  Created by Chase Caster on 6/23/16.
//  Copyright © 2016 chasecaster. All rights reserved.
//

import Foundation
import MusicKit

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
    
    public var flatDescription : String {
        for (letterName, accidental) in self.names {
            if accidental == .natural || accidental == .flat {
                return describe(letterName, accidental: accidental)
            }
        }
        return ""
    }
    
    public var sharpDescription : String {
        for (letterName, accidental) in self.names {
            if accidental == .natural || accidental == .sharp {
                return describe(letterName, accidental: accidental)
            }
        }
        return ""
    }
    
    func describe(_ letterName: LetterName, accidental: Accidental) -> String {
        return "\(letterName.description)\(accidental.description(true))"
    }
}
