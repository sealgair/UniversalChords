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

class ViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, SettingsDelegate {
    
    let chordLabel = UITextField()
    let diagram = ChordDiagramView()
    let instrumentLabel = UITextField()
    let instrumentPicker = UIPickerView()
    let settingsButton = UIButton()
    let sideConstraintGroup = ConstraintGroup()
    let noteNameConstraintGroup = ConstraintGroup()
    
    var chromae: [Chroma] {
        return (0...11).map { i in
            Chroma(rawValue: i)!
        }
    }
    
    lazy var noteButtons: [UIButton] = {
        return chromae.map { chroma in
            UIButton()
        }
    }()
    let notePicker = UIView()

    var lefty: Bool {
        return UserDefaults.standard.bool(forKey: kSavedLefty)
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
        Instrument(name:"pickBanjo".i18n(comment:"pick banjo"), strings:[.d, .g, .b, .d]),
        Instrument(name:"pickGuitar".i18n(comment:"pick guitar"), strings:[.e, .a, .d, .g, .b, .e]),
        Instrument(name:"pickDropD".i18n(comment:"pick drop d guitar"), strings:[.d, .a, .d, .g, .b, .e]),
        Instrument(name:"pick7String".i18n(comment:"pick 7 string guitar"), strings:[.b, .e, .a, .d, .g, .b, .e]),
        Instrument(name:"pickBass".i18n(comment:"pick bass guitar"), strings:[.e, .a, .d, .g]),
        Instrument(name:"pickMando".i18n(comment:"pick mandolin"), strings:[.g, .d, .a, .e]),
        Instrument(name:"pickUke".i18n(comment:"pick soprano ukulele"), strings:[.g, .c, .e, .a]),
        Instrument(name:"pickBariUke".i18n(comment:"pick baritone ukulele"), strings:[.d, .g, .b, .e]),
    ]
    var instrument: Instrument!
    
    let padding: CGFloat = 40
    let circleSize = 100

    override func viewDidLoad() {
        super.viewDidLoad()
        
        for qualityPicker in qualityPickers {
            let qualities = qualityMap[qualityPicker]!
            for (i, quality) in qualities.enumerated() {
                qualityPicker.insertSegment(withTitle: "pick-\(quality.rawValue)".i18n(comment: "Pick Quality \(quality.rawValue)"), at: i, animated: false)
            }
            qualityPicker.selectedSegmentIndex = 0
            qualityPicker.translatesAutoresizingMaskIntoConstraints = false
            qualityPicker.tintColor = UIColor.black
            qualityPicker.addTarget(self, action: #selector(chooseChordQuality(sender:)), for: .valueChanged)
            qualityPicker.apportionsSegmentWidthsByContent = self.traitCollection.horizontalSizeClass == .compact
            view.addSubview(qualityPicker)
        }
        
        let qph = qualityPickers[0].sizeThatFits(UIScreen.main.bounds.size).height
        constrain(qualityPickers) { qualityPickers in
            distribute(by: 0, vertically: qualityPickers)
            align(leading: qualityPickers)
            align(trailing: qualityPickers)
            for qp in qualityPickers {
                qp.height == qph
            }
        }

        chordLabel.font = chordLabel.font?.withSize(32)
        chordLabel.adjustsFontSizeToFitWidth = true
        chordLabel.textAlignment = .center
        view.addSubview(chordLabel)
        
        for (chroma, button) in zip(chromae, noteButtons) {
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setTitleColor(.black, for: .normal)
            button.setBackgroundColor(.black, for: .selected)
            button.setTitleColor(.white, for: .selected)
            button.layer.borderColor = UIColor.black.cgColor
            button.layer.borderWidth = 2
            button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
            button.setTitle(chroma.describeCurrent(), for: .normal)
            button.addTarget(self, action: #selector(chooseChroma(sender:)), for: .touchUpInside)
            if let label = button.titleLabel {
                label.font = label.font.withSize(label.font.pointSize * 1.25)
            }
            button.contentHorizontalAlignment = .left
            notePicker.addSubview(button)
        }
        for (chroma, button) in zip(chromae, noteButtons) {
            if !chroma.isNatural {
                notePicker.bringSubview(toFront: button)
            }
        }
        view.addSubview(notePicker)
        
        let nbh = noteButtons[0].sizeThatFits(UIScreen.main.bounds.size).height * 1.5
        constrain(noteButtons) { noteButtons in
            let notePicker = noteButtons[0].superview!
            var prev: ViewProxy?
            for button in noteButtons {
                if let prev = prev {
                    button.top == prev.bottom - 2
                } else {
                    button.top == notePicker.top
                }
                button.height == nbh
                button.left == notePicker.left
                button.right == notePicker.right
                prev = button
            }
            notePicker.bottom == prev!.bottom
        }

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
        settingsButton.setTitle("⚙", for: .normal)
        settingsButton.tintColor = .black
        settingsButton.sizeToFit()
        settingsButton.addTarget(self, action: #selector(openSettings), for: .touchUpInside)
        view.addSubview(settingsButton)

        chordLabel.translatesAutoresizingMaskIntoConstraints = false
        diagram.translatesAutoresizingMaskIntoConstraints = false
        instrumentLabel.translatesAutoresizingMaskIntoConstraints = false
        
        constrainToSide()
        
        loadState()
        self.chooseInstrument()
        self.chooseHand()
        self.chooseNoteNameScheme()
        self.chooseChord()
    }
    
    func constrainToSide() {
        let firstQPick = qualityPickers[0]
        
        let ilh = instrumentLabel.sizeThatFits(UIScreen.main.bounds.size).height
        let diagramOffset = diagram.stringLabelHeight
        
        constrain(diagram, firstQPick, qualityPickers.last!, chordLabel, instrumentLabel, settingsButton, notePicker, replace: sideConstraintGroup) {
            diagram, firstQPick, lastQPick, chordLabel, instrumentLabel, settingsButton, notePicker in
            
            let view = diagram.superview!
            
            chordLabel.top == view.top + padding
            chordLabel.width == 60
            
            firstQPick.top == view.top + padding
            
            instrumentLabel.bottom == view.bottom - 10
            instrumentLabel.width == diagram.width
            instrumentLabel.height == ilh
            instrumentLabel.centerX == diagram.centerX
            
            diagram.top == lastQPick.bottom + 5
            diagram.bottom == instrumentLabel.top - 10
            notePicker.centerY == diagram.centerY + (diagramOffset/2)
            
            settingsButton.centerY == instrumentLabel.centerY
            
            if lefty {
                chordLabel.left == view.left + 10
                firstQPick.right == view.right - 10
                firstQPick.left == chordLabel.right + 5
                notePicker.left == view.left - 2
                diagram.left == notePicker.right + 10
                diagram.right == view.right - 10
                settingsButton.left == view.left + 10
            } else {
                chordLabel.right == view.right - 10
                firstQPick.left == view.left + 10
                firstQPick.right == chordLabel.left - 5
                notePicker.right == view.right + 2
                diagram.right == notePicker.left - 10
                diagram.left == view.left + 10
                settingsButton.right == view.right - 10
            }
        }
    }
    
    @objc func chooseChroma(sender: UIButton) {
        let _ = noteButtons.map { button in button.isSelected = false }
        sender.isSelected = true
        chooseChord()
    }
    
    @objc func chooseChordQuality(sender: UISegmentedControl) {
        for qpicker in qualityPickers {
            if qpicker != sender {
                qpicker.selectedSegmentIndex = UISegmentedControlNoSegment;
            }
        }
        chooseChord()
    }
    
    func chooseChord() {
        let chromaIndex = noteButtons.index { button in button.isSelected } ?? 0
        let chroma = chromae[chromaIndex]
        
        let picker = qualityPickers.first { picker in picker.selectedSegmentIndex != UISegmentedControlNoSegment }
        let quality: ChordQuality
        if let picker = picker, let qualities = qualityMap[picker] {
            quality = qualities[picker.selectedSegmentIndex]
        } else {
            quality = .Major
        }
        
        let chord = Harmony.create(quality.intervals)
        
        if quality == .Major {
            chordLabel.text = chroma.describeCurrent()
        } else {
            chordLabel.text = "\(chroma.describeCurrent())\(quality.rawValue)"
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
        diagram.lefty = lefty
        constrainToSide()
    }
    
    @objc func chooseNoteNameScheme() {
        for (chroma, button) in zip(chromae, noteButtons) {
            button.setTitle(chroma.describeCurrent(), for: .normal)
        }
        
        constrain(notePicker, replace: noteNameConstraintGroup) { notePicker in
            notePicker.width == noteButtons.map { b in b.titleLabel!.sizeThatFits(UIScreen.main.bounds.size).width }.max()! + 20
        }
        chooseChord()
        diagram.updateFingers()
    }
    
    func choices(_ picker:UIPickerView) -> [[String]] {
        switch picker {
        case instrumentPicker:
            return [instruments.map {i in i.name}]
        default:
            return [[]]
        }
    }
    
    @objc func openSettings() {
        let settingsVC = SettingsViewController(style: .grouped)
        settingsVC.title = "settings-title".i18n(comment: "title of settings view")
        settingsVC.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "menu-close".i18n(comment: "close menu button title"),
                                                                       style: .done, target: self, action: #selector(closeSettings))
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
            let chromaIndex = chromae.index(of: Chroma(rawValue: savedChroma.uintValue) ?? .c) ?? 0
            let _ = noteButtons.map { button in button.isSelected = false }
            noteButtons[chromaIndex].isSelected = true
        }
        if let savedQuality = defaults.object(forKey: kSavedQuality) as? String {
            for (qualityPicker, qualities) in qualityMap {
                if let i = qualities.index(where: { q in q.description == savedQuality }) {
                    qualityPicker.selectedSegmentIndex = i
                } else {
                    qualityPicker.selectedSegmentIndex = UISegmentedControlNoSegment
                }
            }
        }
        chooseChord()
    }
    
    // Mark: UIPickerViewDataSource
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return choices(pickerView).count
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return choices(pickerView)[component].count
    }
    
    // Mark: UIPickerViewDelegate
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let componentChoices = choices(pickerView)[component]
        return componentChoices[row % componentChoices.count]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == instrumentPicker {
            chooseInstrument()
        }
    }
}

