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
    
    var messages = [ShoutMessage]()
    let url = URL(string: "https://home.agh.edu.pl/~ernst/shoutbox.php?secret=ams2018")
    let name = "Mateusz Wydmanski"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.title = self.name
        self.getMessages()
    }
    
    @IBOutlet weak var navigationBar: UINavigationItem!
    
    @IBAction func refreshData(_ sender: Any) {
        self.getMessages()
        self.tableView.reloadData()
    }
    
    @IBAction func addMessage(_ sender: Any) {
        let alertController = UIAlertController(title: "New message", message: "Please state your name and message", preferredStyle: .alert)
        alertController.addTextField(configurationHandler: { textField in
            textField.placeholder = "Your name"
        })
        alertController.addTextField(configurationHandler: { textField in
            textField.placeholder = "Your message"
        })
        let sendAction = UIAlertAction(title: "Send", style: .default, handler: { action in
            let name = alertController.textFields?[0].text
            let message = alertController.textFields?[1].text
            self.sendMessage(name!, message!)
        })
        alertController.addAction(sendAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in })
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true)
    }
    
    func sendMessage(_ name: String, _ message: String) {
        Alamofire.request(url!, method: .post, parameters: ["name": name, "message": message], encoding: JSONEncoding.default, headers: nil).responseJSON { response in
            switch response.result {
            case .success:
                self.refreshData("")
                break
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func getMessages() {
        Alamofire.request(url!, method: .get)
            .validate()
            .responseJSON { response in
                guard response.result.isSuccess
                    else {
                        print("Error while fetching remote rooms: \(String(describing: response.result.error))")
                        return
                }
                guard let response = response.result.value as? [ShoutMessage]
                    else {
                        print("Malformed data received from fetchAllRooms service")
                        return
                }
                self.checkForNewMessages(response);
                self.messages = response.sorted(by: { $0.timestamp > $1.timestamp });
        }
    }
    
    func checkForNewMessages(_ gotMessages: [ShoutMessage]) {
        let difference = gotMessages.count - self.messages.count;
        var title = "No new messages"
        if (difference > 0) {
            title = "\(difference) new messages"
        }
        let banner = StatusBarNotificationBanner(title: title, style: .success)
        banner.show()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "shoutboxItem", for: indexPath)
        
        let message = messages[indexPath.row].message
        let sender = messages[indexPath.row].sender
        let timestamp = messages[indexPath.row].timestamp
        let components = Calendar.current.dateComponents([.hour, .minute, .second], from: timestamp, to: Date())
        let metadata = "by \(sender), \(components.hour!) hour(s), \(components.minute!) minute(s) and \(components.second!) second(s) ago"
        
        cell.textLabel!.text = message
        cell.detailTextLabel!.text = metadata
        
        return cell
    }
    
}
