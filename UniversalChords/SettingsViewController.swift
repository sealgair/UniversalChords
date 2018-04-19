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
        
        let leftLabel = UILabel()
        leftLabel.text = "lefty"
        leftLabel.translatesAutoresizingMaskIntoConstraints = false
        handCell.addSubview(leftLabel)
        
        let rightLabel = UILabel()
        rightLabel.text = "righty"
        rightLabel.translatesAutoresizingMaskIntoConstraints = false
        handCell.addSubview(rightLabel)
        
        let handSwitch = UISwitch()
        handSwitch.translatesAutoresizingMaskIntoConstraints = false
        let lefty = UserDefaults.standard.bool(forKey: kSavedLefty)
        handSwitch.isOn = !lefty
        handSwitch.addTarget(self, action: #selector(chooseHand(sender:)), for: .valueChanged)
        handCell.addSubview(handSwitch)
        
        constrain(handCell.contentView, handLabel, leftLabel, rightLabel, handSwitch) { cell, handLabel, leftLabel, rightLabel, handSwitch in
            handLabel.leading == cell.leading + 10
            handSwitch.centerX == cell.centerX
            leftLabel.right == handSwitch.left - 10
            rightLabel.left == handSwitch.right + 10
            
            align(centerY: cell, handLabel, leftLabel, rightLabel, handSwitch)
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
    
    @objc func chooseHand(sender: UISwitch) {
        UserDefaults.standard.set(!sender.isOn, forKey: kSavedLefty)
        if let delegate = delegate {
            delegate.chooseHand()
        }
    }
}
