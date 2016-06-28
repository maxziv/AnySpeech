//
//  SpeechCel.swift
//  Pronounciate Any Accent
//
//  Created by Maxwell Zhou on 6/27/16.
//  Copyright © 2016 Max. All rights reserved.
//


import UIKit
import AFNetworking

class SpeechCell: UITableViewCell {
    
    @IBOutlet weak var speechNameLabel: UILabel!
    @IBOutlet weak var speakerNameLabel: UILabel!
    @IBOutlet weak var speakerImageView: UIImageView!
    
    var speech: Speech! {
        didSet {
            speechNameLabel.text = speech.speechName
            speakerNameLabel.text = speech.speakerName
            speakerImageView.setImageWith(URL(string: speech!.imageUrlString!)!)
            self.accessoryType = .disclosureIndicator
        }
    }
    
}
