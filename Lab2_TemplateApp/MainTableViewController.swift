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
        self.getMessages()
    }
    
    @IBOutlet weak var navigationBar: UINavigationItem!
    
    @IBAction func refreshData(_ sender: Any) {
        self.getMessages()
    }
    
    @IBAction func addMessage(_ sender: Any) {
        let alertController = UIAlertController(title: NSLocalizedString("new_message", comment: ""), message: NSLocalizedString("state_date", comment: ""), preferredStyle: .alert)
        alertController.addTextField(configurationHandler: { textField in
            textField.placeholder = NSLocalizedString("your_name", comment: "")
        })
        alertController.addTextField(configurationHandler: { textField in
            textField.placeholder = NSLocalizedString("your_message", comment: "")
        })
        let sendAction = UIAlertAction(title: NSLocalizedString("send", comment: ""), style: .default, handler: { action in
            let name = alertController.textFields?[0].text
            let message = alertController.textFields?[1].text
            self.sendMessage(name!, message!)
        })
        alertController.addAction(sendAction)
        let cancelAction = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel, handler: { _ in })
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
                let decoder = JSONDecoder()
                
                do {
                    let response = try decoder.decode(ShoutMessageResponse.self, from: response.data!)
                    self.checkForNewMessages(response.entries);
                    self.messages = response.entries.sorted(by: { $0.timestamp > $1.timestamp });
                    self.tableView.reloadData()
                } catch {
                    print(error)
                }
        }
    }
    
    func checkForNewMessages(_ gotMessages: [ShoutMessage]) {
        let difference = gotMessages.count - self.messages.count;
        var title = NSLocalizedString("no_sth", comment: "")
        if (difference > 0) {
            title = "\(difference)"
        }
        title = title + NSLocalizedString("new_messages", comment: "")
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
        let sender = messages[indexPath.row].name
        let strTimestamp = messages[indexPath.row].timestamp
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let timestamp = dateFormatterGet.date(from: strTimestamp)!
        let components = Calendar.current.dateComponents([.hour, .minute, .second], from: timestamp, to: Date())
        let metadata = NSLocalizedString("by", comment:"") + " \(sender), \(components.hour!) " + NSLocalizedString("hours", comment:"") + ", \(components.minute!) " + NSLocalizedString("minutes", comment:"") + " " + NSLocalizedString("and", comment:"") + " \(components.second!) " + NSLocalizedString("seconds", comment:"") + " " + NSLocalizedString("ago", comment:"")
        
        cell.textLabel!.text = message
        cell.detailTextLabel!.text = metadata
        
        return cell
    }
    
}
