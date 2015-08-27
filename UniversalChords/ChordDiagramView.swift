//
//  ChordDiagramView.swift
//  UniversalChords
//
//  Created by Chase Caster on 5/16/15.
//  Copyright (c) 2015 chasecaster. All rights reserved.
//

import UIKit
import MusicKit

class ChordDiagramView: UIView, UIScrollViewDelegate {
    let fretColor = UIColor.orangeColor()
    let stringColor = UIColor.grayColor()
    
    var instrument: Instrument! {
        didSet {
            updateDiagram()
        }
    }
    var chord: PitchSet! {
        didSet {
            updateDiagram()
        }
    }
    let fretScroll = UIScrollView()
    let fretBoard = UIView()
    let stringLabels = UIView()
    let fretLabels = (0...15).map {i -> UILabel in
        let label = UILabel()
        label.text = String(i + 1)
        return label
    }
    var stringViews: [UIView] = []
    var fingerViews: [UIView] = []
    var stringConstraints: [NSLayoutConstraint] = []
    var topFret = 0
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(frame: CGRect())
        self.userInteractionEnabled = true
        self.clipsToBounds = true
        
        fretScroll.clipsToBounds = false
        fretScroll.setTranslatesAutoresizingMaskIntoConstraints(false)
        fretScroll.delegate = self
        fretScroll.showsHorizontalScrollIndicator = false
        fretScroll.showsVerticalScrollIndicator = false
        
        self.addSubview(fretScroll)
        
        fretBoard.setTranslatesAutoresizingMaskIntoConstraints(false)
        fretScroll.addSubview(fretBoard)
        
        stringLabels.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.addSubview(stringLabels)
        stringLabels.backgroundColor = UIColor.whiteColor()
        
        let nut = UIView()
        nut.backgroundColor = UIColor.blackColor()
        nut.setTranslatesAutoresizingMaskIntoConstraints(false)
        fretBoard.addSubview(nut)
        
        self.addConstraints([
            NSLayoutConstraint(item: nut, attribute: .Top,    relatedBy: .Equal, toItem: fretBoard, attribute: .Top,    multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: nut, attribute: .Left,   relatedBy: .Equal, toItem: fretBoard, attribute: .Left,   multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: nut, attribute: .Right,  relatedBy: .Equal, toItem: fretBoard, attribute: .Right,  multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: nut, attribute: .Height, relatedBy: .Equal, toItem: nil,       attribute: .Height, multiplier: 1.0, constant: 5.0),
            
            NSLayoutConstraint(item: fretScroll, attribute: .Left,   relatedBy: .Equal, toItem: self, attribute: .Left,   multiplier: 1.0, constant: 50.0),
            NSLayoutConstraint(item: fretScroll, attribute: .Top,    relatedBy: .Equal, toItem: self, attribute: .Top,    multiplier: 1.0, constant: 50.0),
            NSLayoutConstraint(item: fretScroll, attribute: .Right,  relatedBy: .Equal, toItem: self, attribute: .Right,  multiplier: 1.0, constant: -20.0),
            NSLayoutConstraint(item: fretScroll, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1.0, constant: -10.0),

            NSLayoutConstraint(item: fretBoard, attribute: .Top,    relatedBy: .Equal, toItem: fretScroll, attribute: .Top,    multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: fretBoard, attribute: .Left,   relatedBy: .Equal, toItem: fretScroll, attribute: .Left,   multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: fretBoard, attribute: .Bottom, relatedBy: .Equal, toItem: fretScroll, attribute: .Bottom, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: fretBoard, attribute: .Right,  relatedBy: .Equal, toItem: fretScroll, attribute: .Right,  multiplier: 1.0, constant: 0.0),
            
            NSLayoutConstraint(item: fretBoard, attribute: .Width,  relatedBy: .Equal, toItem: fretScroll, attribute: .Width,  multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: fretBoard, attribute: .Height, relatedBy: .Equal, toItem: fretScroll, attribute: .Height, multiplier: 1.0, constant: 600.0),
            
            NSLayoutConstraint(item: stringLabels, attribute: .Top,    relatedBy: .Equal, toItem: fretScroll, attribute: .Top,   multiplier: 1.0, constant: -50.0),
            NSLayoutConstraint(item: stringLabels, attribute: .Left,   relatedBy: .Equal, toItem: self,       attribute: .Left,  multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: stringLabels, attribute: .Right,  relatedBy: .Equal, toItem: self,       attribute: .Right, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: stringLabels, attribute: .Bottom, relatedBy: .Equal, toItem: fretScroll, attribute: .Top,   multiplier: 1.0, constant: 0.0),
        ])
        
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]|", options: NSLayoutFormatOptions(0), metrics: [:], views: ["view": fretBoard]))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]|", options: NSLayoutFormatOptions(0), metrics: [:], views: ["view": fretBoard]))
        
        for (i, fretLabel) in enumerate(fretLabels) {
            fretBoard.addSubview(fretLabel)
            fretLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
            let offset = CGFloat(i + 1) / CGFloat(fretLabels.count)
            
            let fretView = UIView()
            fretView.backgroundColor = fretColor
            fretLabel.addSubview(fretView)
            fretView.setTranslatesAutoresizingMaskIntoConstraints(false)
            
            fretBoard.addConstraints([
                NSLayoutConstraint(item: fretLabel, attribute: .Right,   relatedBy: .Equal, toItem: fretBoard, attribute: .Left,   multiplier: 1.0,    constant: -30.0),
                NSLayoutConstraint(item: fretLabel, attribute: .CenterY, relatedBy: .Equal, toItem: fretBoard, attribute: .Bottom, multiplier: offset, constant: 0.0),
                
                NSLayoutConstraint(item: fretView, attribute: .CenterY, relatedBy: .Equal, toItem: fretLabel, attribute: .CenterY, multiplier: 1.0, constant: 0.0),
                NSLayoutConstraint(item: fretView, attribute: .Left,    relatedBy: .Equal, toItem: fretBoard, attribute: .Left,    multiplier: 1.0, constant: 0.0),
                NSLayoutConstraint(item: fretView, attribute: .Right,   relatedBy: .Equal, toItem: fretBoard, attribute: .Right,   multiplier: 1.0, constant: 0.0),
                NSLayoutConstraint(item: fretView, attribute: .Height,  relatedBy: .Equal, toItem: nil,       attribute: .Height,  multiplier: 1.0, constant: 3.0),
            ])
        }
    }
    
    func updateDiagram() {
        removeConstraints(stringConstraints)
        stringConstraints = []
        stringViews.map {v in v.removeFromSuperview()}
        stringViews = []
        
        if instrument == nil || chord == nil {
            return
        }
        
        for sl in stringLabels.subviews {
            sl.removeFromSuperview()
        }
        
        for (i, string) in enumerate(instrument.strings) {
            let stringContainer = UIView()
            stringContainer.tag = i
            stringViews.append(stringContainer)
            
            let stringLabel = UILabel()
            stringLabel.text = string.description
            stringLabel.font = stringLabel.font.fontWithSize(22)
            stringLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
            stringLabels.addSubview(stringLabel)
            
            let stringView = UIView()
            stringView.backgroundColor = stringColor
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
                
                NSLayoutConstraint(item: stringLabel, attribute: .Bottom,  relatedBy: .Equal, toItem: stringLabels,    attribute: .Bottom,  multiplier: 1.0, constant: -5.0),
                NSLayoutConstraint(item: stringLabel, attribute: .CenterX, relatedBy: .Equal, toItem: stringContainer, attribute: .CenterX, multiplier: 1.0, constant: 0.0),
                
                NSLayoutConstraint(item: stringView, attribute: .Top,     relatedBy: .Equal, toItem: stringContainer, attribute: .Top,     multiplier: 1.0, constant: 0.0),
                NSLayoutConstraint(item: stringView, attribute: .Bottom,  relatedBy: .Equal, toItem: stringContainer, attribute: .Bottom,  multiplier: 1.0, constant: 10.0),
                NSLayoutConstraint(item: stringView, attribute: .Width,   relatedBy: .Equal, toItem: nil,             attribute: .Width,   multiplier: 1.0, constant: 4.0),
                NSLayoutConstraint(item: stringView, attribute: .CenterX, relatedBy: .Equal, toItem: stringContainer, attribute: .CenterX, multiplier: 1.0, constant: 0.0),
            ]
            self.addConstraints(stringConstraints)
        }
        updateFingers(force: true)
    }
    
    func updateFingers(force: Bool = false) {
        if instrument == nil || chord == nil {
            return
        }
        if stringViews.count <= 0 {
            self.updateDiagram()
            return
        }
        
        let fretHeight = fretBoard.frame.height / CGFloat(fretLabels.count)
        var absoluteOffset: CGFloat!
        var newTopFret = 0
        for i in 0..<fretLabels.count {
            let fretFrame = self.convertRect(CGRect(x: 0, y: CGFloat(i) * fretHeight, width: 0, height: 0), fromView: fretScroll)
            let fretOffset = fretFrame.maxY - stringLabels.frame.maxY
            if absoluteOffset == nil {
                absoluteOffset = fretOffset
            }
            if absoluteOffset > -10 || fretOffset > 45 {
                newTopFret = i
                break
            }
        }
        if !force && newTopFret == topFret {
            return
        }
        topFret = newTopFret
        for finger in fingerViews {
            finger.removeFromSuperview()
        }
        fingerViews = []
        
        let fingerings = instrument.fingerings(chord)
        var fingers = fingerings[0]
        for fingering in fingerings {
            var goodFret = true
            for finger in fingering {
                if finger.position < topFret {
                    goodFret = false
                    break
                }
            }
            if goodFret {
                fingers = fingering
                break
            }
        }
        for stringContainer in stringViews {
            let fingerData = fingers[stringContainer.tag]
            if fingerData.position > 0 {
                let fingerChroma = fingerData.note
                let fingerRadius: CGFloat = 20.0
                let finger = UILabel()
                finger.text = fingerChroma.flatDescription
                finger.backgroundColor = UIColor.blackColor()
                finger.textColor = UIColor.whiteColor()
                finger.textAlignment = .Center
                finger.font = UIFont.boldSystemFontOfSize(16)
                finger.layer.cornerRadius = fingerRadius
                finger.layer.masksToBounds = true
                finger.setTranslatesAutoresizingMaskIntoConstraints(false)
                stringContainer.addSubview(finger)
                fingerViews.append(finger)
                
                self.addConstraints([
                    NSLayoutConstraint(item: finger, attribute: .Bottom,  relatedBy: .Equal, toItem: fretBoard, attribute: .Bottom,  multiplier: CGFloat(fingerData.position) / CGFloat(fretLabels.count), constant: -5.0),
                    NSLayoutConstraint(item: finger, attribute: .CenterX, relatedBy: .Equal, toItem: stringContainer, attribute: .CenterX, multiplier: 1.0, constant: 0.0),
                    NSLayoutConstraint(item: finger, attribute: .Width,   relatedBy: .Equal, toItem: nil,        attribute: .Width,   multiplier: 1.0, constant: fingerRadius * 2.0),
                    NSLayoutConstraint(item: finger, attribute: .Height,  relatedBy: .Equal, toItem: nil,        attribute: .Height,  multiplier: 1.0, constant: fingerRadius * 2.0),
                ])
            }
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        updateFingers()
    }
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        updateFingers()
    }
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        updateFingers()
    }
}
