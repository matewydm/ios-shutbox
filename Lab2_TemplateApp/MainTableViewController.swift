//
//  MainTableViewController.swift
//  Lab2_TemplateApp
//
//  Created by Sebastian Ernst on 11/01/2019.
//  Copyright © 2019 KIS AGH. All rights reserved.
//

import UIKit
import Alamofire
import NotificationBannerSwift

class MainTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // TODO: load data from server
    }
    
    @IBAction func refreshData(_ sender: Any) {
        // TODO: reload data from server
        self.tableView.reloadData()
    }
    
    @IBAction func addMessage(_ sender: Any) {
        let alertController = UIAlertController(title: "New message", message: "Please state your name ad message", preferredStyle: .alert)
        alertController.addTextField(configurationHandler: { textField in
            textField.placeholder = "Your name"
        })
        alertController.addTextField(configurationHandler: { textField in
            textField.placeholder = "Your message"
        })
        let sendAction = UIAlertAction(title: "Send", style: .default, handler: { action in
            let name = alertController.textFields?[0].text
            let message = alertController.textFields?[1].text
            // TODO: submit data to server
        })
        alertController.addAction(sendAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in })
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // TODO: return actual number of messages instead of random value
        if section == 0 {
            return Int(arc4random_uniform(10)) + 10
        }
        else {
            return 0
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "shoutboxItem", for: indexPath)
        if indexPath.section == 0 {
            // TODO: return actual data instead of random values
            let message = "This is a placeholder message."
            let sender = "Jane Doe"
            let timestamp = Date(timeIntervalSinceNow: -1.0 * Double(Int(arc4random_uniform(4900)) + 10))
            let components = Calendar.current.dateComponents([.hour, .minute, .second], from: timestamp, to: Date())
            let metadata = "by \(sender), \(components.hour!) hour(s), \(components.minute!) minute(s) and \(components.second!) second(s) ago"
            cell.textLabel!.text = message
            cell.detailTextLabel!.text = metadata
        }
        return cell
    }
    
}
