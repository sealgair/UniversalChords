//
//  ChordDiagramView.swift
//  UniversalChords
//
//  Created by Chase Caster on 5/16/15.
//  Copyright (c) 2015 chasecaster. All rights reserved.
//

import UIKit
import MusicKit
import Cartography
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class ChordDiagramView: UIView, UIScrollViewDelegate {
    let fretColor = UIColor.orange
    let stringColor = UIColor.gray
    
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
    let fretHeight: CGFloat = 70
    
    var stringViews: [UIView] = []
    var fingerViews: [UIView] = []
    var stringConstraints: [NSLayoutConstraint] = []
    var topFret = 0
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(frame: CGRect())
        self.isUserInteractionEnabled = true
        self.clipsToBounds = true
        
        fretScroll.clipsToBounds = false
        fretScroll.translatesAutoresizingMaskIntoConstraints = false
        fretScroll.delegate = self
        fretScroll.showsHorizontalScrollIndicator = false
        fretScroll.showsVerticalScrollIndicator = false
        
        self.addSubview(fretScroll)

        fretBoard.translatesAutoresizingMaskIntoConstraints = false
        fretScroll.addSubview(fretBoard)
        
        stringLabels.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(stringLabels)
        stringLabels.backgroundColor = UIColor.white
        
        let nut = UIView()
        nut.backgroundColor = UIColor.black
        nut.translatesAutoresizingMaskIntoConstraints = false
        fretBoard.addSubview(nut)
        
        constrain(self, nut, fretScroll, fretBoard, stringLabels) { view, nut, fretScroll, fretBoard, stringLabels in
            nut.top == fretBoard.top
            nut.left == fretBoard.left
            nut.right == fretBoard.right
            nut.height == 5
            
            fretScroll.left == view.left + 50
            fretScroll.top == view.top + 50
            fretScroll.right == view.right - 20
            fretScroll.bottom == view.bottom - 10
            
            fretBoard.edges == fretScroll.edges
            fretBoard.width == fretScroll.width
            fretBoard.height == fretLabels.count * fretHeight
            
            stringLabels.top == fretScroll.top - 50
            stringLabels.left == view.left
            stringLabels.right == view.right
            stringLabels.bottom == fretScroll.top
            
            fretBoard.edges == fretBoard.superview!.edges
        }
        
        for (i, fretLabel) in fretLabels.enumerated() {
            fretBoard.addSubview(fretLabel)
            fretLabel.translatesAutoresizingMaskIntoConstraints = false
            
            let fretView = UIView()
            fretView.backgroundColor = fretColor
            fretLabel.addSubview(fretView)
            fretView.translatesAutoresizingMaskIntoConstraints = false
            
            constrain(fretLabel, fretView, fretBoard) { fretLabel, fretView, fretBoard in
                fretLabel.right == fretBoard.left - 30
                fretLabel.centerY == fretBoard.top + ((i + 1) * fretHeight)
                
                fretView.centerY == fretLabel.centerY
                fretView.left == fretBoard.left
                fretView.right == fretBoard.right
                fretView.height == 3
            }
        }
    }
    
    func updateDiagram() {
        removeConstraints(stringConstraints)
        stringConstraints = []
        let _ = stringViews.map { v in v.removeFromSuperview() }
        stringViews = []
        
        if instrument == nil || chord == nil {
            return
        }
        
        for sl in stringLabels.subviews {
            sl.removeFromSuperview()
        }

        for (i, string) in (instrument.strings).enumerated() {
            let stringContainer = UIView()
            stringContainer.tag = i
            stringViews.append(stringContainer)
            
            let stringLabel = UILabel()
            stringLabel.text = string.description
            stringLabel.font = stringLabel.font.withSize(22)
            stringLabels.addSubview(stringLabel)
            
            let stringView = UIView()
            stringView.backgroundColor = stringColor
            stringContainer.addSubview(stringView)
            
            fretBoard.addSubview(stringContainer)
            
            constrain(fretBoard, stringContainer, stringLabel, stringLabels, stringView) { fretBoard, stringContainer, stringLabel, stringLabels, stringView in
                let offset = CGFloat(i) / CGFloat(instrument.strings.count - 1)
                if offset == 0 {
                    stringContainer.left == fretBoard.left
                } else {
                    stringContainer.centerX == fretBoard.right * offset
                }
                
                stringContainer.top == fretBoard.top
                stringContainer.bottom == fretBoard.bottom
                
                stringLabel.bottom == stringLabels.bottom
                stringLabel.centerX == stringContainer.centerX
                
                stringView.top == stringContainer.top
                stringView.bottom == stringContainer.bottom + 10
                stringView.width == 4
                stringView.centerX == stringContainer.centerX
            }
            
            self.addConstraints(stringConstraints)
        }
        updateFingers(true)
    }
    
    func updateFingers(_ force: Bool = false) {
        if instrument == nil || chord == nil {
            return
        }
        if stringViews.count <= 0 {
            self.updateDiagram()
            return
        }

        var absoluteOffset: CGFloat!
        var newTopFret = 0
        for i in 0..<fretLabels.count {
            let fretFrame = self.convert(CGRect(x: 0, y: CGFloat(i) * fretHeight, width: 0, height: 0), from: fretScroll)
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
                finger.backgroundColor = UIColor.black
                finger.textColor = UIColor.white
                finger.textAlignment = .center
                finger.font = UIFont.boldSystemFont(ofSize: 16)
                finger.layer.cornerRadius = fingerRadius
                finger.layer.masksToBounds = true
                stringContainer.addSubview(finger)
                fingerViews.append(finger)
                
                constrain(finger, fretBoard, stringContainer) { finger, fretBoard, stringContainer in
                    finger.bottom == fretBoard.top + (fingerData.position * fretHeight) - 5
                    finger.centerX == stringContainer.centerX
                    finger.width == fingerRadius * 2
                    finger.height == fingerRadius * 2
                }
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateFingers()
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        updateFingers()
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updateFingers()
    }
}

func *(left: CGFloat, right: Int) -> CGFloat {
    return left * CGFloat(right)
}

func *(left: Int, right: CGFloat) -> CGFloat {
    return right * left
}
