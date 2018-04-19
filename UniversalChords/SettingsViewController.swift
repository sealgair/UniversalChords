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

protocol SettingsDelegate {
    func chooseHand()
}

class SettingsViewController: UITableViewController {
    
    var delegate: SettingsDelegate?
    
    let handCell: UITableViewCell = UITableViewCell(frame: .zero)
    
    var rows: [UITableViewCell] {
        return [handCell]
    }
    
    override func viewDidLoad() {
        let handLabel = UILabel()
        handLabel.text = "Handedness:"
        handLabel.translatesAutoresizingMaskIntoConstraints = false
        handCell.addSubview(handLabel)
        
        let handPicker = UISegmentedControl(items: ["lefty", "righty"])
        handPicker.translatesAutoresizingMaskIntoConstraints = false
        handPicker.tintColor = .black
        let lefty = UserDefaults.standard.bool(forKey: kSavedLefty)
        handPicker.selectedSegmentIndex = lefty ? 0 : 1
        handPicker.addTarget(self, action: #selector(chooseHand(sender:)), for: .valueChanged)
        handCell.addSubview(handPicker)
        
        constrain(handCell.contentView, handLabel, handPicker) { cell, handLabel, handPicker in
            handLabel.leading == cell.leading + 10
            handPicker.leading == handLabel.trailing + 10
            
            align(centerY: cell, handLabel, handPicker)
            cell.edges == cell.superview!.edges
        }
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
        if let delegate = delegate {
            delegate.chooseHand()
        }
    }
}
