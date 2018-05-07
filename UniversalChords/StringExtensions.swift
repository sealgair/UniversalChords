//
//  StringExtensions.swift
//  UniversalChords
//
//  Created by Chase Caster on 5/5/18.
//  Copyright © 2018 chasecaster. All rights reserved.
//

import Foundation

extension String {
    // MARK: Internationalization
    func i18n(_ formatParams: CVarArg..., key: String? = .none, comment: String) -> String {
        let localized: String
        if let key = key {
            localized = NSLocalizedString(key, value: self, comment: comment)
        } else {
            localized = NSLocalizedString(self, comment: comment)
        }
        
        if formatParams.count > 0 {
            return withVaList(formatParams, { (args: CVaListPointer) -> String in
                return (NSString(format: localized, arguments: args) as String)
            })
        } else {
            return localized
        }
    }
}
