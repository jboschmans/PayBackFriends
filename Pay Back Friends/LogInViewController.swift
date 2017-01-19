//
//  LogInViewController.swift
//  Pay Back Friends
//
//  Created by Joris Boschmans on 28/12/2016.
//  Copyright © 2016 Joris Boschmans. All rights reserved.
//

import UIKit

var loggedInUser = ""

class LogInViewController: UIViewController {
    
    @IBOutlet var lblErrors: UILabel!
    @IBOutlet var username: UITextField!
    @IBOutlet var password: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func logIn(_ sender: Any) {
        var _username:String = username.text!
        var _password:String = password.text!
        
        // Validate Input
        lblErrors.text = ""
        if _username.isEmpty || _username.characters.count < 3 {
            lblErrors.text = "Your username needs to have at least 3 characters"
        } else if _password.isEmpty || _password.characters.count < 6 {
            lblErrors.text = "Your password needs to have at least 6 charcters"
        }
        
        if (lblErrors.text?.isEmpty)!{
            let url = URL(string: "https://paybackfriendsserver.herokuapp.com/login/" + _username + "/" + _password)
            let task = URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
                if error != nil {
                    print(error!)
                } else {
                    if let content = data {
                        do {
                            let jsonResult = try JSONSerialization.jsonObject(with: content, options: JSONSerialization.ReadingOptions.mutableContainers) as! [String:AnyObject]
                            let response = jsonResult["response"]!
                            
                            if response as! String == "username false" {
                                DispatchQueue.main.sync {
                                    self.lblErrors.text = "This username doesn't exist."
                                }
                            } else if response as! String == "password false" {
                                DispatchQueue.main.sync {
                                    self.lblErrors.text = "This password is not correct."
                                }
                            } else if response as! String == "true" {
                                DispatchQueue.main.sync {
                                    print("Login Success")
                                    loggedInUser = _username
                                    self.performSegue(withIdentifier: "logIn", sender: nil)
                                }
                            } else {
                                DispatchQueue.main.sync {
                                    self.lblErrors.text = "Something went wrong."
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
