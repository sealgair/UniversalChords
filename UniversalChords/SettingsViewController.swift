//
//  SettingsViewController.swift
//  UniversalChords
//
//  Created by Chase Caster on 4/18/18.
//  Copyright © 2018 chasecaster. All rights reserved.
//

import UIKit
import MusicKit
import Cartography

let kSavedLefty = "kSavedLefty"

protocol SettingsDelegate {
    func chooseHand()
    func chooseNoteNameScheme()
}

class SettingsViewController: UITableViewController {
    
    var delegate: SettingsDelegate?
    
    lazy var handCell: UITableViewCell = {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "handCell")
        let cell = tableView.dequeueReusableCell(withIdentifier: "handCell")!
        
        let handLabel = UILabel()
        handLabel.text = "set-hand-label".i18n(comment: "settings handedness label")
        handLabel.translatesAutoresizingMaskIntoConstraints = false
        cell.contentView.addSubview(handLabel)
        
        let handPicker = UISegmentedControl(items: [
            "set-hand-left".i18n(comment: "settings left handed"),
            "set-hand-right".i18n(comment: "settings right handed")
            ])
        handPicker.translatesAutoresizingMaskIntoConstraints = false
        handPicker.tintColor = .black
        let lefty = UserDefaults.standard.bool(forKey: kSavedLefty)
        handPicker.selectedSegmentIndex = lefty ? 0 : 1
        handPicker.addTarget(self, action: #selector(chooseHand(sender:)), for: .valueChanged)
        cell.contentView.addSubview(handPicker)
        
        constrain(cell.contentView, handLabel, handPicker) { cell, handLabel, handPicker in
            handLabel.leading == cell.leadingMargin
            handPicker.leading == handLabel.trailing + 10
            
            align(centerY: cell, handLabel, handPicker)
            cell.edges == cell.superview!.edges
        }
        cell.sizeToFit()
        return cell
    }()
    
    let nameSchemes: [NoteNameType] = [.letter, .solfège]
    let accidentals: [Accidental] = [.flat, .sharp]
    lazy var noteNamesCell: UITableViewCell = {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "noteCell")
        let cell = tableView.dequeueReusableCell(withIdentifier: "noteCell")!
        
        let nameLabel = UILabel()
        nameLabel.text = "set-note-names-label".i18n(comment: "settings note names label")
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        cell.contentView.addSubview(nameLabel)
        
        let nameTypePicker = UISegmentedControl(items: nameSchemes.map { n in
            "set-note-\( n.description.lowercased())".i18n(comment: "settings \(n.description) note name scheme")
        })
        let nameScheme = NoteNameType.getCurrent()
        if let index = nameSchemes.index(of: nameScheme) {
            nameTypePicker.selectedSegmentIndex = index
        }
        nameTypePicker.addTarget(self, action: #selector(chooseNoteNameScheme(sender:)), for: .valueChanged)
        nameTypePicker.translatesAutoresizingMaskIntoConstraints = false
        nameTypePicker.tintColor = .black
        cell.contentView.addSubview(nameTypePicker)
        
        let accidentalPicker = UISegmentedControl(items: accidentals.map { a in a.description })
        accidentalPicker.selectedSegmentIndex = 0
        let accidental = Accidental.getCurrent()
        if let index = accidentals.index(of: accidental) {
            accidentalPicker.selectedSegmentIndex = index
        }
        accidentalPicker.addTarget(self, action: #selector(chooseNoteAccidental(sender:)), for: .valueChanged)
        accidentalPicker.translatesAutoresizingMaskIntoConstraints = false
        accidentalPicker.tintColor = .black
        cell.contentView.addSubview(accidentalPicker)
        
        constrain(cell.contentView, nameLabel, nameTypePicker, accidentalPicker) { cell, nameLabel, nameTypePicker, accidentalPicker in
            nameLabel.leading == cell.leadingMargin
            nameTypePicker.leading == nameLabel.trailing + 10
            accidentalPicker.leading == nameTypePicker.trailing + 10
            align(centerY: cell, nameLabel, nameTypePicker, accidentalPicker)
            cell.edges == cell.superview!.edges
        }
        
        return cell
    }()
    
    var rows: [UITableViewCell] {
        return [handCell, noteNamesCell]
    }
    
    override func viewDidLoad() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = rows[indexPath.row]
        return cell
    }
    
    @objc func chooseHand(sender: UISegmentedControl) {
        UserDefaults.standard.set(sender.selectedSegmentIndex == 0, forKey: kSavedLefty)
        delegate?.chooseHand()
    }
    
    @objc func chooseNoteNameScheme(sender: UISegmentedControl) {
        let nameScheme = nameSchemes[sender.selectedSegmentIndex]
        nameScheme.setCurrent()
        delegate?.chooseNoteNameScheme()
    }
    
    @objc func chooseNoteAccidental(sender: UISegmentedControl) {
        let accidental = accidentals[sender.selectedSegmentIndex]
        accidental.setCurrent()
        delegate?.chooseNoteNameScheme()
    }
}
