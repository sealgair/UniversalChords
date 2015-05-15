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
    
    let chord = UITextField()
    let chordPicker = UIPickerView()
    
    let instrument = UITextField()
    let instrumentPicker = UIPickerView()
    
    var chromae: [Chroma] {
        return (0...11).map { i in
            Chroma(rawValue: i)!
        }
    }
    var chromaNames: [String] {
        return chromae.map { chroma in
            chroma.description
        }
    }
    
    let qualities = [
        "Major",
        "Minor",
        "7th",
        "Minor 7th",
        "Diminished",
    ]
    
    let instruments = [
        "Banjo",
        "Guitar",
        "Mandolin",
        "Ukulele",
    ]
    
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
        
        chord.inputView = chordPicker
        chord.inputAccessoryView = chordPickerAccessory
        chord.font = chord.font.fontWithSize(24)
        chord.textAlignment = .Center
        chordPicker.selectRow(chromae.count * circleSize, inComponent: 0, animated: false)
        self.chooseChord()
        view.addSubview(chord)
        chordPickerAccessory.sizeToFit()
        
        instrumentPicker.delegate = self
        instrumentPicker.dataSource = self
        let instrumentPickerAccessory = UIToolbar()
        instrumentPickerAccessory.setItems([
            UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "Pick", style: .Done, target: self, action: "chooseInstrument")
        ], animated: false)
        
        instrument.inputView = instrumentPicker
        instrument.inputAccessoryView = instrumentPickerAccessory
        instrument.font = instrument.font.fontWithSize(18)
        instrument.textAlignment = .Center
        instrumentPicker.selectRow(1, inComponent: 0, animated: false)
        self.chooseInstrument()
        view.addSubview(instrument)
        instrumentPickerAccessory.sizeToFit()
        
        chord.setTranslatesAutoresizingMaskIntoConstraints(false)
        instrument.setTranslatesAutoresizingMaskIntoConstraints(false)
        view.addConstraints([
            NSLayoutConstraint(item: chord, attribute: .Top,   relatedBy: .Equal, toItem: view, attribute: .Top,   multiplier: 1.0, constant: padding),
            NSLayoutConstraint(item: chord, attribute: .Width, relatedBy: .Equal, toItem: view, attribute: .Width, multiplier: 1.0, constant: 0.0),
            
            NSLayoutConstraint(item: instrument, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1.0, constant: -padding),
            NSLayoutConstraint(item: instrument, attribute: .Width,  relatedBy: .Equal, toItem: view, attribute: .Width,  multiplier: 1.0, constant: 0.0),
        ])
    }
    
    func chooseChord() {
        let note = pickerView(chordPicker, titleForRow: chordPicker.selectedRowInComponent(0), forComponent: 0)
        let quality = pickerView(chordPicker, titleForRow: chordPicker.selectedRowInComponent(1), forComponent: 1)
        chord.text = "\(note) \(quality)"
        chord.resignFirstResponder()
    }
    
    func chooseInstrument() {
        instrument.text = instruments[instrumentPicker.selectedRowInComponent(0)]
        instrument.resignFirstResponder()
    }
    
    func choices(picker:UIPickerView) -> [[String]] {
        switch picker {
        case chordPicker:
            return [chromaNames, qualities]
        case instrumentPicker:
            return [instruments]
        default:
            return [[]]
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

