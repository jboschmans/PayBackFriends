//
//  MyFriendsMasterTableViewController.swift
//  Pay Back Friends
//
//  Created by Joris Boschmans on 18/01/2017.
//  Copyright © 2017 Joris Boschmans. All rights reserved.
//

import UIKit

class MyFriendsMasterTableViewController: UITableViewController {
    
    var friends=[Friend]()

    override func viewDidLoad() {
        super.viewDidLoad()
        loadFriends()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myFriendCell", for: indexPath)

        cell.textLabel?.text = friends[indexPath.row].username

        return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let detailController = segue.destination as? MyFriendsDetailViewController{
            let selectedIndex = tableView.indexPathForSelectedRow!.row
            detailController.friend = friends[selectedIndex]
        }
    }
    
    public func loadFriends(){
        friends.removeAll()
        let url = URL(string: "https://paybackfriendsserver.herokuapp.com/friends/" + loggedInUser)
        let task = URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
            if error != nil {
                print(error!)
            } else {
                if let content = data {
                    do {
                        let jsonResult = try JSONSerialization.jsonObject(with: content, options: JSONSerialization.ReadingOptions.mutableContainers) as! [String:AnyObject]
                        let response = jsonResult["response"]! as! [Any]
                        
                        var current = 0
                        var temp:[Friend] = []
                        
                        while current < response.count {
                            temp.append(Friend(username: response[current] as! String, owed: response[current+1] as! Float))
                            current += 2
                        }
                        
                        DispatchQueue.main.sync {
                            self.friends = temp
                            self.tableView.reloadData()
                        }
                        
                    } catch {
                        print("JSON Processing failed")
                    }
                }
            }
        })
        task.resume()
    }
    
    @IBAction func reload(_ sender: Any) {
        loadFriends()
    }
    
    

}
