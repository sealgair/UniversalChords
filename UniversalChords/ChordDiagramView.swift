//
//  ChordDiagramView.swift
//  UniversalChords
//
//  Created by Chase Caster on 5/16/15.
//  Copyright (c) 2015 chasecaster. All rights reserved.
//

import UIKit
import MusicKit

class ChordDiagramView: UIView {
    
    var instrument: Instrument!
    var fingers: [Int]!
    let fretBoard = UIView()
    let fretLabels = (0...4).map {i -> UILabel in
        let label = UILabel()
        label.text = String(i + 1)
        return label
    }
    var stringViews: [UIView] = []
    var stringConstraints: [NSLayoutConstraint] = []
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(frame: CGRect())
        
        fretBoard.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.addSubview(fretBoard)
        
        let nut = UIView()
        nut.backgroundColor = UIColor.blackColor()
        nut.setTranslatesAutoresizingMaskIntoConstraints(false)
        fretBoard.addSubview(nut)
        
        self.addConstraints([
            NSLayoutConstraint(item: nut, attribute: .Top,    relatedBy: .Equal, toItem: fretBoard, attribute: .Top,    multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: nut, attribute: .Left,   relatedBy: .Equal, toItem: fretBoard, attribute: .Left,   multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: nut, attribute: .Right,  relatedBy: .Equal, toItem: fretBoard, attribute: .Right,  multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: nut, attribute: .Height, relatedBy: .Equal, toItem: nil,       attribute: .Height, multiplier: 1.0, constant: 5.0),
            
            NSLayoutConstraint(item: fretBoard, attribute: .Left,   relatedBy: .Equal, toItem: self, attribute: .Left,   multiplier: 1.0, constant: 50.0),
            NSLayoutConstraint(item: fretBoard, attribute: .Top,    relatedBy: .Equal, toItem: self, attribute: .Top,    multiplier: 1.0, constant: 50.0),
            NSLayoutConstraint(item: fretBoard, attribute: .Right,  relatedBy: .Equal, toItem: self, attribute: .Right,  multiplier: 1.0, constant: -20.0),
            NSLayoutConstraint(item: fretBoard, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1.0, constant: -10.0),
        ])
        
        for (i, fretLabel) in enumerate(fretLabels) {
            fretBoard.addSubview(fretLabel)
            fretLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
            let offset = CGFloat(i + 1) / CGFloat(fretLabels.count)
            
            let fretView = UIView()
            fretView.backgroundColor = UIColor.blackColor()
            fretLabel.addSubview(fretView)
            fretView.setTranslatesAutoresizingMaskIntoConstraints(false)
            
            fretBoard.addConstraints([
                NSLayoutConstraint(item: fretLabel, attribute: .Right,   relatedBy: .Equal, toItem: fretBoard, attribute: .Left,   multiplier: 1.0,    constant: -30.0),
                NSLayoutConstraint(item: fretLabel, attribute: .CenterY, relatedBy: .Equal, toItem: fretBoard, attribute: .Bottom, multiplier: offset, constant: 0.0),
                
                NSLayoutConstraint(item: fretView, attribute: .CenterY, relatedBy: .Equal, toItem: fretLabel, attribute: .CenterY, multiplier: 1.0, constant: 0.0),
                NSLayoutConstraint(item: fretView, attribute: .Left,    relatedBy: .Equal, toItem: fretBoard, attribute: .Left,    multiplier: 1.0, constant: 0.0),
                NSLayoutConstraint(item: fretView, attribute: .Right,   relatedBy: .Equal, toItem: fretBoard, attribute: .Right,   multiplier: 1.0, constant: 0.0),
                NSLayoutConstraint(item: fretView, attribute: .Height,  relatedBy: .Equal, toItem: nil,       attribute: .Height,  multiplier: 1.0, constant: 2.0),
            ])
        }
    }
    
    func updateDiagram() {
        self.removeConstraints(stringConstraints)
        stringConstraints = []
        stringViews.map {v in v.removeFromSuperview()}
        stringViews = []
        
        if instrument == nil || fingers == nil {
            return
        }
        
        for (i, string) in enumerate(instrument.strings) {
            let stringContainer = UIView()
            stringViews.append(stringContainer)
            
            let stringLabel = UILabel()
            stringLabel.text = string.description
            stringLabel.font = stringLabel.font.fontWithSize(22)
            stringLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
            stringContainer.addSubview(stringLabel)
            
            let stringView = UIView()
            stringView.backgroundColor = UIColor.blackColor()
            stringView.setTranslatesAutoresizingMaskIntoConstraints(false)
            stringContainer.addSubview(stringView)
            
            stringContainer.setTranslatesAutoresizingMaskIntoConstraints(false)
            fretBoard.addSubview(stringContainer)
            
            let offset = CGFloat(i) / CGFloat(instrument.strings.count - 1)
            let offsetConstraint: NSLayoutConstraint!
            if offset == 0 {
                offsetConstraint = NSLayoutConstraint(item: stringContainer, attribute: .Left, relatedBy: .Equal, toItem: fretBoard, attribute: .Left, multiplier: 1.0, constant: 0.0)
            } else {
                offsetConstraint = NSLayoutConstraint(item: stringContainer, attribute: .CenterX, relatedBy: .Equal, toItem: fretBoard, attribute: .Right, multiplier: offset, constant: 0.0)
            }
            stringConstraints = [
                offsetConstraint,
                NSLayoutConstraint(item: stringContainer, attribute: .Top,    relatedBy: .Equal, toItem: fretBoard, attribute: .Top,    multiplier: 1.0, constant: 0.0),
                NSLayoutConstraint(item: stringContainer, attribute: .Bottom, relatedBy: .Equal, toItem: fretBoard, attribute: .Bottom, multiplier: 1.0, constant: 0.0),
                
                NSLayoutConstraint(item: stringLabel, attribute: .Bottom,  relatedBy: .Equal, toItem: stringContainer, attribute: .Top,     multiplier: 1.0, constant: -5.0),
                NSLayoutConstraint(item: stringLabel, attribute: .CenterX, relatedBy: .Equal, toItem: stringContainer, attribute: .CenterX, multiplier: 1.0, constant: 0.0),
                
                NSLayoutConstraint(item: stringView, attribute: .Top,     relatedBy: .Equal, toItem: stringContainer, attribute: .Top,     multiplier: 1.0, constant: 0.0),
                NSLayoutConstraint(item: stringView, attribute: .Bottom,  relatedBy: .Equal, toItem: stringContainer, attribute: .Bottom,  multiplier: 1.0, constant: 10.0),
                NSLayoutConstraint(item: stringView, attribute: .Width,   relatedBy: .Equal, toItem: nil,             attribute: .Width,   multiplier: 1.0, constant: 4.0),
                NSLayoutConstraint(item: stringView, attribute: .CenterX, relatedBy: .Equal, toItem: stringContainer, attribute: .CenterX, multiplier: 1.0, constant: 0.0),
            ]
            self.addConstraints(stringConstraints)
            
            let fingerIndex = fingers[i]
            if fingerIndex > 0 {
                let fingerChroma = string + fingerIndex
                let fingerRadius: CGFloat = 20.0
                let finger = UILabel()
                finger.text = fingerChroma.description
                finger.backgroundColor = UIColor.blackColor()
                finger.textColor = UIColor.whiteColor()
                finger.textAlignment = .Center
                finger.font = UIFont.boldSystemFontOfSize(16)
                finger.layer.cornerRadius = fingerRadius
                finger.layer.masksToBounds = true
                finger.setTranslatesAutoresizingMaskIntoConstraints(false)
                stringContainer.addSubview(finger)
                
                self.addConstraints([
                    NSLayoutConstraint(item: finger, attribute: .Bottom,  relatedBy: .Equal, toItem: stringView, attribute: .Bottom,  multiplier: CGFloat(fingerIndex) / 5.0, constant: -5.0),
                    NSLayoutConstraint(item: finger, attribute: .CenterX, relatedBy: .Equal, toItem: stringView, attribute: .CenterX, multiplier: 1.0, constant: 0.0),
                    NSLayoutConstraint(item: finger, attribute: .Width,   relatedBy: .Equal, toItem: nil,        attribute: .Width,   multiplier: 1.0, constant: fingerRadius * 2.0),
                    NSLayoutConstraint(item: finger, attribute: .Height,  relatedBy: .Equal, toItem: nil,        attribute: .Height,  multiplier: 1.0, constant: fingerRadius * 2.0),
                ])
            }
        }
    }
}
