//
//  ImageExtensions.swift
//  UniversalChords
//
//  Created by Chase Caster on 4/29/18.
//  Copyright © 2018 chasecaster. All rights reserved.
//

import UIKit

extension UIImage {
    static func image(with color: UIColor) -> UIImage? {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        context.setFillColor(color.cgColor)
        context.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsGetImageFromCurrentImageContext()
        return image
    }
}

extension UIButton {
    func setBackgroundColor(_ color: UIColor, for state: UIControlState) {
        self.setBackgroundImage(UIImage.image(with: color), for: state)
    }
}
