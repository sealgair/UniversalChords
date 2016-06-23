//
//  ViewController.swift
//  UniversalChords
//
//  Created by Chase Caster on 4/21/15.
//  Copyright (c) 2015 chasecaster. All rights reserved.
//

import UIKit
import MusicKit


let kSavedInstrumentName = "kSavedInstrumentName"
let kSavedChroma = "kSavedChroma"
let kSavedQuality = "kSavedQuality"

class ViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    let chordLabel = UITextField()
    let notePicker = UIPickerView()
    
    let diagram = ChordDiagramView()
    
    let instrumentLabel = UITextField()
    let instrumentPicker = UIPickerView()
    let qualityPicker = UISegmentedControl()
    
    var chromae: [Chroma] {
        return (0...11).map { i in
            Chroma(rawValue: i)!
        }
    }
    var chromaNames: [String] {
        return chromae.map { chroma in
            chroma.flatDescription
        }
    }
    
    let qualities: [ChordQuality] = [
        .Major,
        .Minor,
        .DominantSeventh,
        .MinorSeventh,
        .Sus2,
        .Sus4,
        .Augmented,
        .Diminished,
    ]
    var chord: PitchSet!
    
    let instruments = [
        Instrument(name:"Banjo", strings:[.D, .G, .B, .D]),
        Instrument(name:"Guitar", strings:[.E, .A, .D, .G, .B, .E]),
        Instrument(name:"Mandolin", strings:[.G, .D, .A, .E]),
        Instrument(name:"Ukulele", strings:[.G, .C, .E, .A]),
    ]
    var instrument: Instrument!
    
    let padding: CGFloat = 40
    let circleSize = 100

    override func viewDidLoad() {
        super.viewDidLoad()
        
        notePicker.delegate = self
        notePicker.dataSource = self
        notePicker.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(notePicker)
        
        for (i, quality) in (qualities).enumerate() {
            qualityPicker.insertSegmentWithTitle(quality.rawValue, atIndex: i, animated: false)
        }
        qualityPicker.selectedSegmentIndex = 0
        qualityPicker.translatesAutoresizingMaskIntoConstraints = false
        qualityPicker.tintColor = UIColor.blackColor()
        qualityPicker.addTarget(self, action: "chooseChord", forControlEvents: UIControlEvents.ValueChanged)
        qualityPicker.apportionsSegmentWidthsByContent = self.traitCollection.horizontalSizeClass == .Compact
        view.addSubview(qualityPicker)

        chordLabel.font = chordLabel.font?.fontWithSize(25)
        chordLabel.adjustsFontSizeToFitWidth = true
        chordLabel.textAlignment = .Left
        notePicker.selectRow(chromae.count * circleSize, inComponent: 0, animated: false)
        view.addSubview(chordLabel)

        instrumentPicker.delegate = self
        instrumentPicker.dataSource = self
        
        instrumentLabel.inputView = instrumentPicker
        instrumentLabel.font = instrumentLabel.font?.fontWithSize(18)
        instrumentLabel.textAlignment = .Center
        instrumentPicker.selectRow(1, inComponent: 0, animated: false)
        view.addSubview(instrumentLabel)
        
        view.addSubview(diagram)
        diagram.translatesAutoresizingMaskIntoConstraints = false

        chordLabel.translatesAutoresizingMaskIntoConstraints = false
        diagram.translatesAutoresizingMaskIntoConstraints = false
        instrumentLabel.translatesAutoresizingMaskIntoConstraints = false
//        view.addConstraints([
//            NSLayoutConstraint(item: notePicker, attribute: .Top,    relatedBy: .Equal, toItem: view, attribute: .Top,    multiplier: 1.0, constant: -10.0),
//            NSLayoutConstraint(item: notePicker, attribute: .Right,  relatedBy: .Equal, toItem: view, attribute: .Right,  multiplier: 1.0, constant: -10.0),
//            NSLayoutConstraint(item: notePicker, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1.0, constant: 10.0),
//            NSLayoutConstraint(item: notePicker, attribute: .Width,  relatedBy: .Equal, toItem: nil,  attribute: .Width,  multiplier: 1.0, constant: 40.0),
//            
//            NSLayoutConstraint(item: diagram, attribute: .Top,    relatedBy: .Equal, toItem: chordLabel,      attribute: .Bottom, multiplier: 1.0, constant: 10.0),
//            NSLayoutConstraint(item: diagram, attribute: .Left,   relatedBy: .Equal, toItem: view,            attribute: .Left,  multiplier: 1.0, constant: 10.0),
//            NSLayoutConstraint(item: diagram, attribute: .Right,  relatedBy: .Equal, toItem: notePicker,      attribute: .Left,  multiplier: 1.0, constant: 0.0),
//            NSLayoutConstraint(item: diagram, attribute: .Bottom, relatedBy: .Equal, toItem: instrumentLabel, attribute: .Top,    multiplier: 1.0, constant: -10.0),
//            
//            NSLayoutConstraint(item: chordLabel, attribute: .Top,   relatedBy: .Equal, toItem: view,          attribute: .Top,   multiplier: 1.0, constant: padding),
//            NSLayoutConstraint(item: chordLabel, attribute: .Width, relatedBy: .Equal, toItem: nil,           attribute: .Width, multiplier: 1.0, constant: 60.0),
//            NSLayoutConstraint(item: chordLabel, attribute: .Right, relatedBy: .Equal, toItem: view,          attribute: .Right, multiplier: 1.0, constant: -10.0),
//            
//            NSLayoutConstraint(item: qualityPicker, attribute: .Top,   relatedBy: .Equal, toItem: view,       attribute: .Top,  multiplier: 1.0, constant: padding),
//            NSLayoutConstraint(item: qualityPicker, attribute: .Left,  relatedBy: .Equal, toItem: view,       attribute: .Left, multiplier: 1.0, constant: 10.0),
//            NSLayoutConstraint(item: qualityPicker, attribute: .Right, relatedBy: .Equal, toItem: chordLabel, attribute: .Left, multiplier: 1.0, constant: -10.0),
//            
//            NSLayoutConstraint(item: instrumentLabel, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1.0, constant: -10.0),
//            NSLayoutConstraint(item: instrumentLabel, attribute: .Width,  relatedBy: .Equal, toItem: view, attribute: .Width,  multiplier: 1.0, constant: 0.0),
//        ])
//        loadState()
        self.chooseInstrument()
        self.chooseChord()
    }
    
    func chooseChord() {
        let chromaIndex = notePicker.selectedRowInComponent(0)
        let chroma = chromae[chromaIndex % chromae.count]
        let qualityIndex = qualityPicker.selectedSegmentIndex
        let quality = qualities[qualityIndex]
        let chord = Harmony.create(quality.intervals)
        
        if quality == .Major {
            chordLabel.text = chroma.flatDescription
        } else {
            chordLabel.text = "\(chroma.flatDescription) \(quality.rawValue)"
        }
        chordLabel.resignFirstResponder()
        
        diagram.chord = chord(Pitch(chroma: chroma, octave: 1))
        
        NSUserDefaults.standardUserDefaults().setObject(NSNumber(unsignedLong: chroma.rawValue), forKey: kSavedChroma)
        NSUserDefaults.standardUserDefaults().setObject(quality.description, forKey: kSavedQuality)
    }
    
    func chooseInstrument() {
        let index = instrumentPicker.selectedRowInComponent(0)
        instrument = instruments[index]
        instrumentLabel.text = instrument.name
        instrumentLabel.resignFirstResponder()
        
        diagram.instrument = instrument
        
        NSUserDefaults.standardUserDefaults().setObject(instrument.name, forKey: kSavedInstrumentName)
    }
    
    func choices(picker:UIPickerView) -> [[String]] {
        switch picker {
        case notePicker:
            return [chromaNames]
        case instrumentPicker:
            return [instruments.map {i in i.name}]
        default:
            return [[]]
        }
    }
    
    // Mark: NSUserDefaults
    
    func loadState() {
        let defaults = NSUserDefaults.standardUserDefaults()
        if let savedInstrumentName = defaults.objectForKey(kSavedInstrumentName) as? String {
            for (i, instrument) in (instruments).enumerate() {
                if instrument.name == savedInstrumentName {
                    instrumentPicker.selectRow(i, inComponent: 0, animated: false)
                    break
                }
            }
        }
        if let savedChroma = defaults.objectForKey(kSavedChroma) as? NSNumber {
            notePicker.selectRow(chromae.count * circleSize + savedChroma.integerValue, inComponent: 0, animated: false)
        }
        if let savedQuality = defaults.objectForKey(kSavedQuality) as? String {
            for (i, quality) in (qualities).enumerate() {
                if quality.description == savedQuality {
                    qualityPicker.selectedSegmentIndex = i
                    break
                }
            }
        }
    }
    
    // Mark: UIPickerViewDataSource
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return choices(pickerView).count
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        var rows = choices(pickerView)[component].count
        if pickerView == notePicker && component == 0 {
            rows *= 2 * circleSize
        }
        return rows
    }
    
    // Mark: UIPickerViewDelegate
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let componentChoices = choices(pickerView)[component]
        return componentChoices[row % componentChoices.count]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == notePicker {
            chooseChord()
            let componentChoices = choices(pickerView)[component]
            pickerView.selectRow(row % componentChoices.count + circleSize * componentChoices.count, inComponent: component, animated: false)
        } else if pickerView == instrumentPicker {
            chooseInstrument()
        }
    }
}

