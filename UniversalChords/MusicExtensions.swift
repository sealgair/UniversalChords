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
            return [(.C, .Natural), (.B, .Sharp), (.D, .DoubleFlat)]
        case 1:
            return [(.C, .Sharp), (.D, .Flat), (.B, .DoubleSharp)]
        case 2:
            return [(.D, .Natural), (.C, .DoubleSharp), (.E, .DoubleFlat)]
        case 3:
            return [(.E, .Flat), (.D, .Sharp), (.F, .DoubleFlat)]
        case 4:
            return [(.E, .Natural), (.F, .Flat), (.D, .DoubleSharp)]
        case 5:
            return [(.F, .Natural), (.E, .Sharp), (.G, .DoubleFlat)]
        case 6:
            return [(.F, .Sharp), (.G, .Flat), (.E, .DoubleSharp)]
        case 7:
            return [(.G, .Natural), (.F, .DoubleSharp), (.A, .DoubleFlat)]
        case 8:
            return [(.A, .Flat), (.G, .Sharp)]
        case 9:
            return [(.A, .Natural), (.G, .DoubleSharp), (.B, .DoubleFlat)]
        case 10:
            return [(.B, .Flat), (.A, .Sharp), (.C, .DoubleFlat)]
        case 11:
            return [(.B, .Natural), (.C, .Flat), (.A, .DoubleSharp)]
        default:
            return []
        }
    }
    
    public var flatDescription : String {
        for (letterName, accidental) in self.names {
            if accidental == .Natural || accidental == .Flat {
                return describe(letterName, accidental: accidental)
            }
        }
        return ""
    }
    
    public var sharpDescription : String {
        for (letterName, accidental) in self.names {
            if accidental == .Natural || accidental == .Sharp {
                return describe(letterName, accidental: accidental)
            }
        }
        return ""
    }
    
    func describe(letterName: LetterName, accidental: Accidental) -> String {
        return "\(letterName.description)\(accidental.description(true))"
    }
}