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

class ViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, SettingsDelegate {
    
    let chordLabel = UITextField()
    let notePicker = UIPickerView()
    
    let diagram = ChordDiagramView()
    
    let instrumentLabel = UITextField()
    let instrumentPicker = UIPickerView()
    let settingsButton = UIButton(type: .infoDark)
    
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
    
    let qualityRows: [[ChordQuality]] = [
        [
            .Major,
            .DominantSeventh,
            .MajorSixth,
            .PowerChord,
            .AddNine,
            .Sus2,
            .Sus4,
        ],
        [
            .Minor,
            .MinorSeventh,
            .MinorSixth,
            .MinorAddNine,
            .Augmented,
            .Diminished,
        ],
    ]
    lazy var qualityPickers: [UISegmentedControl] = {
        return qualityRows.map {row in UISegmentedControl()}
    }()
    var qualityMap: [UISegmentedControl: [ChordQuality]] {
        return Dictionary(uniqueKeysWithValues: zip(qualityPickers, qualityRows))
    }
    
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
        
        for qualityPicker in qualityPickers {
            let qualities = qualityMap[qualityPicker]!
            for (i, quality) in qualities.enumerated() {
                qualityPicker.insertSegment(withTitle: quality.name , at: i, animated: false)
            }
            qualityPicker.selectedSegmentIndex = 0
            qualityPicker.translatesAutoresizingMaskIntoConstraints = false
            qualityPicker.tintColor = UIColor.black
            qualityPicker.addTarget(self, action: #selector(ViewController.chooseChord(sender:)), for: .valueChanged)
            qualityPicker.apportionsSegmentWidthsByContent = self.traitCollection.horizontalSizeClass == .compact
            view.addSubview(qualityPicker)
        }

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
        
        settingsButton.translatesAutoresizingMaskIntoConstraints = false
        settingsButton.tintColor = .black
        settingsButton.addTarget(self, action: #selector(openSettings), for: .touchUpInside)
        view.addSubview(settingsButton)

        chordLabel.translatesAutoresizingMaskIntoConstraints = false
        diagram.translatesAutoresizingMaskIntoConstraints = false
        instrumentLabel.translatesAutoresizingMaskIntoConstraints = false
        let firstQPick = qualityPickers[0]
        constrain(notePicker, diagram, firstQPick, qualityPickers.last!, chordLabel, instrumentLabel, settingsButton) { notePicker, diagram, firstQPick, lastQPick, chordLabel, instrumentLabel, settingsButton in
            let view = notePicker.superview!
            
            notePicker.top == view.top - 10
            notePicker.right == view.right - 10
            notePicker.bottom == view.bottom + 10
            notePicker.width == 40
            
            chordLabel.top == view.top + padding
            chordLabel.width == 70
            chordLabel.right == view.right - 10
            
            firstQPick.top == view.top + padding
            firstQPick.left == view.left + 10
            firstQPick.right == chordLabel.left - 10
            
            diagram.top == lastQPick.bottom + 10
            diagram.left == view.left + 10
            diagram.right == notePicker.left
            diagram.bottom == instrumentLabel.top - 10
            
            instrumentLabel.bottom == view.bottom - 10
            instrumentLabel.width == view.width
            
            settingsButton.centerX == notePicker.centerX
            settingsButton.centerY == instrumentLabel.centerY
        }
        
        constrain(qualityPickers) { qualityPickers in
            distribute(by: 0, vertically: qualityPickers)
            align(leading: qualityPickers)
            align(trailing: qualityPickers)
        }
        
        loadState()
        self.chooseInstrument()
        self.chooseHand()
        self.chooseChord()
    }
    
    func chooseChord() {
        for picker in qualityPickers {
            if picker.selectedSegmentIndex != UISegmentedControlNoSegment {
                chooseChord(sender:picker)
                return
            }
        }
    }
    
    @objc func chooseChord(sender: UISegmentedControl) {
        guard let qualities = qualityMap[sender] else { return }
        let chromaIndex = notePicker.selectedRow(inComponent: 0)
        let chroma = chromae[chromaIndex % chromae.count]
        let qualityIndex = sender.selectedSegmentIndex
        let quality = qualities[qualityIndex]
        let chord = Harmony.create(quality.intervals)
        for qpicker in qualityPickers {
            if qpicker != sender {
                qpicker.selectedSegmentIndex = UISegmentedControlNoSegment;
            }
        }
        
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
        let lefty = UserDefaults.standard.bool(forKey: kSavedLefty)
        diagram.lefty = lefty
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
    
    @objc func openSettings() {
        let settingsVC = SettingsViewController(style: .grouped)
        settingsVC.title = "Settings"
        settingsVC.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Close", style: .done, target: self, action: #selector(closeSettings))
        settingsVC.delegate = self
        
        let settingsNav = UINavigationController(rootViewController: settingsVC)
        settingsNav.modalPresentationStyle = .popover
        present(settingsNav, animated: true)
    }
    
    @objc func closeSettings() {
        self.dismiss(animated: true)
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
        if let savedChroma = defaults.object(forKey: kSavedChroma) as? NSNumber {
            notePicker.selectRow(chromae.count * circleSize + savedChroma.intValue, inComponent: 0, animated: false)
        }
        if let savedQuality = defaults.object(forKey: kSavedQuality) as? String {
            for (qualityPicker, qualities) in qualityMap {
                for (i, quality) in (qualities).enumerated() {
                    if quality.description == savedQuality {
                        qualityPicker.selectedSegmentIndex = i
                        break
                    }
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

