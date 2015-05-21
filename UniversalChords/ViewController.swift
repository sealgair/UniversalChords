//
//  ViewController.swift
//  UniversalChords
//
//  Created by Chase Caster on 4/21/15.
//  Copyright (c) 2015 chasecaster. All rights reserved.
//

import UIKit
import MusicKit

class ViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    let chordLabel = UITextField()
    let chordPicker = UIPickerView()
    
    let diagram = ChordDiagramView()
    
    let instrumentLabel = UITextField()
    let instrumentPicker = UIPickerView()
    
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
        .Augmented,
        .Diminished,
        .MinorSeventh,
    ]
    var chord: PitchSet!
    
    let instruments = [
        Instrument(name:"Banjo", strings:[.D, .B, .D, .G]),
        Instrument(name:"Guitar", strings:[.E, .A, .D, .G, .B, .E]),
        Instrument(name:"Mandolin", strings:[.G, .D, .A, .E]),
        Instrument(name:"Ukulele", strings:[.G, .C, .E, .A]),
    ]
    var instrument: Instrument!
    
    let padding: CGFloat = 40
    let circleSize = 100

    override func viewDidLoad() {
        super.viewDidLoad()
        
        chordPicker.delegate = self
        chordPicker.dataSource = self
        let chordPickerAccessory = UIToolbar()
        chordPickerAccessory.setItems([
            UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "Pick", style: .Done, target: self, action: "chooseChord")
        ], animated: false)
        
        chordLabel.inputView = chordPicker
        chordLabel.inputAccessoryView = chordPickerAccessory
        chordLabel.font = chordLabel.font.fontWithSize(28)
        chordLabel.textAlignment = .Center
        chordPicker.selectRow(chromae.count * circleSize, inComponent: 0, animated: false)
        self.chooseChord()
        view.addSubview(chordLabel)
        chordPickerAccessory.sizeToFit()
        
        updateDiagram()
        
        instrumentPicker.delegate = self
        instrumentPicker.dataSource = self
        let instrumentPickerAccessory = UIToolbar()
        instrumentPickerAccessory.setItems([
            UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "Pick", style: .Done, target: self, action: "chooseInstrument")
        ], animated: false)
        
        instrumentLabel.inputView = instrumentPicker
        instrumentLabel.inputAccessoryView = instrumentPickerAccessory
        instrumentLabel.font = instrumentLabel.font.fontWithSize(18)
        instrumentLabel.textAlignment = .Center
        instrumentPicker.selectRow(1, inComponent: 0, animated: false)
        self.chooseInstrument()
        view.addSubview(instrumentLabel)
        instrumentPickerAccessory.sizeToFit()
        
        view.addSubview(diagram)
        diagram.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        chordLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        diagram.setTranslatesAutoresizingMaskIntoConstraints(false)
        instrumentLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        view.addConstraints([
            NSLayoutConstraint(item: chordLabel, attribute: .Top,   relatedBy: .Equal, toItem: view, attribute: .Top,   multiplier: 1.0, constant: padding),
            NSLayoutConstraint(item: chordLabel, attribute: .Width, relatedBy: .Equal, toItem: view, attribute: .Width, multiplier: 1.0, constant: 0.0),
            
            NSLayoutConstraint(item: diagram, attribute: .Top,    relatedBy: .Equal, toItem: chordLabel,      attribute: .Bottom, multiplier: 1.0, constant: 10.0),
            NSLayoutConstraint(item: diagram, attribute: .Left,   relatedBy: .Equal, toItem: view,            attribute: .Left,   multiplier: 1.0, constant: 10.0),
            NSLayoutConstraint(item: diagram, attribute: .Right,  relatedBy: .Equal, toItem: view,            attribute: .Right,  multiplier: 1.0, constant: -10.0),
            NSLayoutConstraint(item: diagram, attribute: .Bottom, relatedBy: .Equal, toItem: instrumentLabel, attribute: .Top,    multiplier: 1.0, constant: -10.0),
            
            NSLayoutConstraint(item: instrumentLabel, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1.0, constant: -padding),
            NSLayoutConstraint(item: instrumentLabel, attribute: .Width,  relatedBy: .Equal, toItem: view, attribute: .Width,  multiplier: 1.0, constant: 0.0),
        ])
    }
    
    func chooseChord() {
        let chromaIndex = chordPicker.selectedRowInComponent(0)
        let chroma = chromae[chromaIndex % chromae.count]
        let qualityIndex = chordPicker.selectedRowInComponent(1)
        let quality = qualities[qualityIndex % qualities.count]
        
        let harmony = Harmony.create(quality.intervals)
        chord = harmony(Pitch(chroma: chroma, octave: 1))
        
        chordLabel.text = "\(chroma.flatDescription) \(quality.symbol)"
        chordLabel.resignFirstResponder()
        
        updateDiagram()
    }
    
    func chooseInstrument() {
        let index = instrumentPicker.selectedRowInComponent(0)
        instrument = instruments[index]
        instrumentLabel.text = instrument.name
        instrumentLabel.resignFirstResponder()
        
        updateDiagram()
    }
    
    func choices(picker:UIPickerView) -> [[String]] {
        switch picker {
        case chordPicker:
            return [chromaNames, qualities.map {q in q.symbol}]
        case instrumentPicker:
            return [instruments.map {i in i.name}]
        default:
            return [[]]
        }
    }
    
    func getFingers(notes: PitchSet) -> [Int] {
        if self.instrument == nil {
            return [] // TODO: AAARRGGG
        }
        
        var fingers: [Int] = []
        let notes = Set(notes.map {n in n.chroma!})
        
        for string in self.instrument.strings {
            var i = 0;
            while !notes.contains(string + i) {
                i++
            }
            fingers.append(i)
        }
        return fingers
    }
    
    func updateDiagram() {
        
        let chromaIndex = chordPicker.selectedRowInComponent(0)
        let chroma = chromae[chromaIndex % chromae.count]
        let qualityIndex = chordPicker.selectedRowInComponent(1)
        let quality = qualities[qualityIndex % qualities.count]
        let chord = Harmony.create(quality.intervals)
        let notes = chord(Pitch(chroma: chroma, octave: 1))
        
        diagram.instrument = self.instrument
        diagram.fingers = getFingers(notes)
        diagram.updateDiagram()
        
        var notesText = ""
        for note in notes {
            if let chroma = note.chroma {
                notesText += " " + chroma.description
            } else {
                notesText += " ?"
            }
        }
    }
    
    // Mark: UIPickerViewDataSource
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return choices(pickerView).count
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        var rows = choices(pickerView)[component].count
        if pickerView == chordPicker && component == 0 {
            rows *= 2 * circleSize
        }
        return rows
    }
    
    // Mark: UIPickerViewDelegate
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        let componentChoices = choices(pickerView)[component]
        return componentChoices[row % componentChoices.count]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == chordPicker && component == 0 {
            let componentChoices = choices(pickerView)[component]
            pickerView.selectRow(row % componentChoices.count + circleSize * componentChoices.count, inComponent: component, animated: false)
        }
    }
}

