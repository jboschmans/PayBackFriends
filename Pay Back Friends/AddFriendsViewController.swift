//
//  AddFriendsViewController.swift
//  Pay Back Friends
//
//  Created by Joris Boschmans on 09/01/2017.
//  Copyright © 2017 Joris Boschmans. All rights reserved.
//

import UIKit

class AddFriendsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var txtUsername: UITextField!
    @IBOutlet var table: UITableView!
    
    
    var cellContent = [""]

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if cellContent[0].isEmpty {
            return 0
        }
        return cellContent.count
    }
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "Cell")
        cell.textLabel?.text = cellContent[indexPath.row]
        return cell
    }
    
    @IBAction func searchUsers(_ sender: Any) {
        let _username = txtUsername.text
        
        if (!(_username?.isEmpty)!){
            let url = URL(string: "https://paybackfriendsserver.herokuapp.com/search/" + _username!)
            let task = URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
                if error != nil {
                    print(error!)
                } else {
                    if let content = data {
                        do {
                            let jsonResult = try JSONSerialization.jsonObject(with: content, options: JSONSerialization.ReadingOptions.mutableContainers) as! [String:AnyObject]
                            let response = jsonResult["response"]!
                            
                            if response is String && response as! String == "false" {
                                DispatchQueue.main.sync {
                                    self.cellContent = ["No user was found"]
                                    self.table.reloadData()
                                }
                            } else {
                                DispatchQueue.main.sync {
                                    self.cellContent = response as! [String]
                                    for (index, value) in self.cellContent.enumerated(){
                                        if loggedInUser == value {
                                            self.cellContent.remove(at: index)
                                            break;
                                        }
                                    }
                                    if self.cellContent.count < 1 {
                                        self.cellContent.append("No user was found")
                                    }
                                    self.cellContent.sort()
                                    self.table.reloadData()
                                }
                            }
                        } catch {
                            print("JSON Processing failed")
                        }
                    }
                }
            })
            task.resume()
        }
    }
    
}
