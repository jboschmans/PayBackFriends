//
//  MyFriendsDetailViewController.swift
//  Pay Back Friends
//
//  Created by Joris Boschmans on 18/01/2017.
//  Copyright © 2017 Joris Boschmans. All rights reserved.
//

import UIKit

class MyFriendsDetailViewController: UIViewController {
    
    
    @IBOutlet var lblUsername: UILabel!
    @IBOutlet var lblAmount: UILabel!
    @IBOutlet var txtAmount: UITextField!
    @IBOutlet var btnPayBack: UIButton!
    @IBOutlet var btnLoan: UIButton!
    
    var friend:Friend = Friend(username: "", owed: 0)

    override func viewDidLoad() {
        super.viewDidLoad()
        reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func reloadData(){
        if friend.username.isEmpty {
            setVisibilityItems(false)
        } else {
            setVisibilityItems(true)
        }
        lblUsername?.text = friend.username;
        let a:String
        if friend.owed > 0 {
            a = "+\(friend.owed)"
            lblAmount.textColor = UIColor.green
        } else {
            a = String(friend.owed)
            if friend.owed == 0 {
                lblAmount.textColor = UIColor.black
            } else {
                lblAmount.textColor = UIColor.red
            }
        }
        lblAmount?.text = a
    }
    
    func setVisibilityItems(_ visibility:Bool){
        lblUsername.alpha = visibility ? 1 : 0
        lblAmount.alpha = visibility ? 1 : 0
        txtAmount.alpha = visibility ? 1 : 0
        btnLoan.alpha = visibility ? 1 : 0
        btnPayBack.alpha = visibility ? 1 : 0
    }
    
    @IBAction func payBack(_ sender: Any) {
        changeAmount(Float(txtAmount.text!)!)
    }
    
    @IBAction func loan(_ sender: Any) {
        changeAmount(Float(txtAmount.text!)! * -1)
    }
    
    func changeAmount(_ amount:Float){
        let headers = [
            "content-type": "application/x-www-form-urlencoded"
        ]
        
        let postData = NSMutableData(data: "username=\(loggedInUser)".data(using: String.Encoding.utf8)!)
        postData.append("&friend=\(friend.username)".data(using: String.Encoding.utf8)!)
        postData.append("&amount=\(amount)".data(using: String.Encoding.utf8)!)
        
        let request = NSMutableURLRequest(url: NSURL(string: "https://paybackfriendsserver.herokuapp.com/addmoney")! as URL,
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
                    self.friend.owed = self.friend.owed + amount
                    self.reloadData()
                    
                }
            }
        })
        
        dataTask.resume()
    }
}
