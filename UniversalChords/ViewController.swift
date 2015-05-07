//
//  ViewController.swift
//  UniversalChords
//
//  Created by Chase Caster on 4/21/15.
//  Copyright (c) 2015 chasecaster. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    let chord = UITextField()
    let chordPicker = UIPickerView()
    
    let notes = [
        "A♭",
        "A",
        "B♭",
        "B",
        "C",
        "D♭",
        "D",
        "E♭",
        "E",
        "F",
        "G♭",
        "G",
    ]
    
    let qualities = [
        "Major",
        "Minor",
        "7th",
        "Minor 7th",
        "Diminished",
    ]
    
    let padding: CGFloat = 40

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
        chordPicker.selectRow(4, inComponent: 0, animated: false)
        self.chooseChord()
        view.addSubview(chord)
        chordPickerAccessory.sizeToFit()
        
        chord.setTranslatesAutoresizingMaskIntoConstraints(false)
        view.addConstraints([
            NSLayoutConstraint(item: chord, attribute: .Top,   relatedBy: .Equal, toItem: view, attribute: .Top,   multiplier: 1.0, constant: padding),
            NSLayoutConstraint(item: chord, attribute: .Width, relatedBy: .Equal, toItem: view, attribute: .Width, multiplier: 1.0, constant: padding),
        ])
    }
    
    func chooseChord() {
        let note = notes[chordPicker.selectedRowInComponent(0)]
        let quality = qualities[chordPicker.selectedRowInComponent(1)]
        chord.text = "\(note) \(quality)"
        chord.resignFirstResponder()
    }
    
    func choices(picker:UIPickerView) -> [[String]] {
        switch picker {
        case chordPicker:
            return [notes, qualities]
        default:
            return [[]]
        }
    }
    
    // Mark: UIPickerViewDataSource
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return choices(pickerView).count
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return choices(pickerView)[component].count
    }
    
    // Mark: UIPickerViewDelegate
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return choices(pickerView)[component][row]
    }
}

