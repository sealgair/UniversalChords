//
//  ViewController.swift
//  UniversalChords
//
//  Created by Chase Caster on 4/21/15.
//  Copyright (c) 2015 chasecaster. All rights reserved.
//

import UIKit
import MusicKit
import Cartography

let kSavedInstrumentName = "kSavedInstrumentName"
let kSavedChroma = "kSavedChroma"
let kSavedQuality = "kSavedQuality"
let kSavedLefty = "kSavedLefty"

class ViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    let chordLabel = UITextField()
    let notePicker = UIPickerView()
    
    let diagram = ChordDiagramView()
    
    let instrumentLabel = UITextField()
    let instrumentPicker = UIPickerView()
    let qualityPicker = UISegmentedControl()
    let handSwitch = UISwitch()
    
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
        Instrument(name:"Banjo", strings:[.d, .g, .b, .d]),
        Instrument(name:"Guitar", strings:[.e, .a, .d, .g, .b, .e]),
        Instrument(name:"Drop D Guitar", strings:[.d, .a, .d, .g, .b, .e]),
        Instrument(name:"Mandolin", strings:[.g, .d, .a, .e]),
        Instrument(name:"Soprano Ukulele", strings:[.g, .c, .e, .a]),
        Instrument(name:"Baritone Ukulele", strings:[.d, .g, .b, .e]),
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
        
        for (i, quality) in (qualities).enumerated() {
            qualityPicker.insertSegment(withTitle: quality.rawValue, at: i, animated: false)
        }
        qualityPicker.selectedSegmentIndex = 0
        qualityPicker.translatesAutoresizingMaskIntoConstraints = false
        qualityPicker.tintColor = UIColor.black
        qualityPicker.addTarget(self, action: #selector(ViewController.chooseChord), for: .valueChanged)
        qualityPicker.apportionsSegmentWidthsByContent = self.traitCollection.horizontalSizeClass == .compact
        view.addSubview(qualityPicker)

        chordLabel.font = chordLabel.font?.withSize(25)
        chordLabel.adjustsFontSizeToFitWidth = true
        chordLabel.textAlignment = .left
        notePicker.selectRow(chromae.count * circleSize, inComponent: 0, animated: false)
        view.addSubview(chordLabel)

        instrumentPicker.delegate = self
        instrumentPicker.dataSource = self
        
        instrumentLabel.inputView = instrumentPicker
        instrumentLabel.font = instrumentLabel.font?.withSize(18)
        instrumentLabel.textAlignment = .center
        instrumentPicker.selectRow(1, inComponent: 0, animated: false)
        view.addSubview(instrumentLabel)
        
        view.addSubview(diagram)
        diagram.translatesAutoresizingMaskIntoConstraints = false
        
        handSwitch.translatesAutoresizingMaskIntoConstraints = false
        handSwitch.onTintColor = handSwitch.tintColor
        handSwitch.addTarget(self, action: #selector(ViewController.chooseHand), for: .valueChanged)
        view.addSubview(handSwitch)

        chordLabel.translatesAutoresizingMaskIntoConstraints = false
        diagram.translatesAutoresizingMaskIntoConstraints = false
        instrumentLabel.translatesAutoresizingMaskIntoConstraints = false
        constrain(notePicker, diagram, chordLabel, qualityPicker, instrumentLabel, handSwitch) { notePicker, diagram, chordLabel, qualityPicker, instrumentLabel, handSwitch in
            let view = notePicker.superview!
            
            notePicker.top == view.top - 10
            notePicker.right == view.right - 10
            notePicker.bottom == view.bottom + 10
            notePicker.width == 40
            
            diagram.top == chordLabel.bottom + 10
            diagram.left == view.left + 10
            diagram.right == notePicker.left
            diagram.bottom == instrumentLabel.top - 10
            
            chordLabel.top == view.top + padding
            chordLabel.width == 60
            chordLabel.right == view.right - 10
            
            qualityPicker.top == view.top + padding
            qualityPicker.left == view.left + 10
            qualityPicker.right == chordLabel.left - 10
            
            instrumentLabel.bottom == view.bottom - 10
            instrumentLabel.width == view.width
            
            handSwitch.centerX == notePicker.centerX
            handSwitch.centerY == instrumentLabel.centerY
        }
        loadState()
        self.chooseInstrument()
        self.chooseHand()
        self.chooseChord()
    }
    
    @objc func chooseChord() {
        let chromaIndex = notePicker.selectedRow(inComponent: 0)
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
        
        UserDefaults.standard.set(NSNumber(value: chroma.rawValue as UInt), forKey: kSavedChroma)
        UserDefaults.standard.set(quality.description, forKey: kSavedQuality)
    }
    
    func chooseInstrument() {
        let index = instrumentPicker.selectedRow(inComponent: 0)
        instrument = instruments[index]
        instrumentLabel.text = instrument.name
        instrumentLabel.resignFirstResponder()
        
        diagram.instrument = instrument
        
        UserDefaults.standard.set(instrument.name, forKey: kSavedInstrumentName)
    }
    
    @objc func chooseHand() {
        let lefty = !handSwitch.isOn
        diagram.lefty = lefty
        UserDefaults.standard.set(lefty, forKey: kSavedLefty)
    }
    
    func choices(_ picker:UIPickerView) -> [[String]] {
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
        let defaults = UserDefaults.standard
        if let savedInstrumentName = defaults.object(forKey: kSavedInstrumentName) as? String {
            for (i, instrument) in (instruments).enumerated() {
                if instrument.name == savedInstrumentName {
                    instrumentPicker.selectRow(i, inComponent: 0, animated: false)
                    break
                }
            }
        }
        if let savedLefty = defaults.object(forKey: kSavedLefty) as? Bool {
            handSwitch.isOn = !savedLefty
        }
        if let savedChroma = defaults.object(forKey: kSavedChroma) as? NSNumber {
            notePicker.selectRow(chromae.count * circleSize + savedChroma.intValue, inComponent: 0, animated: false)
        }
        if let savedQuality = defaults.object(forKey: kSavedQuality) as? String {
            for (i, quality) in (qualities).enumerated() {
                if quality.description == savedQuality {
                    qualityPicker.selectedSegmentIndex = i
                    break
                }
            }
        }
    }
    
    // Mark: UIPickerViewDataSource
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return choices(pickerView).count
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        var rows = choices(pickerView)[component].count
        if pickerView == notePicker && component == 0 {
            rows *= 2 * circleSize
        }
        return rows
    }
    
    // Mark: UIPickerViewDelegate
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let componentChoices = choices(pickerView)[component]
        return componentChoices[row % componentChoices.count]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == notePicker {
            chooseChord()
            let componentChoices = choices(pickerView)[component]
            pickerView.selectRow(row % componentChoices.count + circleSize * componentChoices.count, inComponent: component, animated: false)
        } else if pickerView == instrumentPicker {
            chooseInstrument()
        }
    }
}

