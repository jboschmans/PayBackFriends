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
        if cellContent.count == 0 || cellContent[0].isEmpty {
            return 0
        }
        return cellContent.count
    }
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "Cell")
        cell.textLabel?.text = cellContent[indexPath.row]
        return cell
    }
    
    internal func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedUser = cellContent[indexPath.row]
        
        let refreshAlert = UIAlertController(title: "Add Friend", message: "Are you sure that you want to add " + selectedUser + " as your friend?", preferredStyle: UIAlertControllerStyle.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            tableView.deselectRow(at: indexPath, animated: true)
            
            let headers = [
                "content-type": "application/x-www-form-urlencoded"
            ]
            
            let postData = NSMutableData(data: "username=\(loggedInUser)".data(using: String.Encoding.utf8)!)
            postData.append("&friend=\(selectedUser)".data(using: String.Encoding.utf8)!)
            
            let request = NSMutableURLRequest(url: NSURL(string: "https://paybackfriendsserver.herokuapp.com/addfriend")! as URL,
                                              cachePolicy: .useProtocolCachePolicy,
                                              timeoutInterval: 10.0)
            request.httpMethod = "POST"
            request.allHTTPHeaderFields = headers
            request.httpBody = postData as Data
            
            //let session = URLSession.shared
            let dataTask = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
                if (error != nil) {
                    print(error!)
                } else {
                    DispatchQueue.main.sync {
                        self.cellContent.remove(at: indexPath.row)
                        self.table.reloadData()
                    }
                }
            })
            
            dataTask.resume()
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            print("Canceled")
        }))
        
        present(refreshAlert, animated: true, completion: nil)
    }
    
    @IBAction func searchUsers(_ sender: Any) {
        let _username = txtUsername.text
        
        if (!(_username?.isEmpty)!){
            let url = URL(string: "https://paybackfriendsserver.herokuapp.com/search/" + _username! + "/" + loggedInUser)
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
}
