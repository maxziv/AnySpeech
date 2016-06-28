//
//  SpeechListTableViewController.swift
//  Pronounciate Any Accent
//
//  Created by Maxwell Zhou on 6/27/16.
//  Copyright © 2016 Max. All rights reserved.
//

import Foundation
import UIKit

class SpeechListTableViewController: UITableViewController {
    
    var speeches:[Speech] = speechesData
    
    // MARK: - Table view data source
    
    override func viewDidLoad() {
        self.tableView.contentInset = UIEdgeInsetsMake(30, 0, 0, 0)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return speeches.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SpeechCell", for: indexPath)
                as! SpeechCell
            
            let speech = speeches[(indexPath as NSIndexPath).row] as Speech
            cell.speech = speech
            return cell
    }
    
}
