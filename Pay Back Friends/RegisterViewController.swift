//
//  RegisterViewController.swift
//  Pay Back Friends
//
//  Created by Joris Boschmans on 28/12/2016.
//  Copyright © 2016 Joris Boschmans. All rights reserved.
//

import UIKit
import Foundation

class RegisterViewController: UIViewController {
    
    @IBOutlet var txtFullName: UITextField!
    @IBOutlet var txtUsername: UITextField!
    @IBOutlet var txtPassword: UITextField!
    @IBOutlet var txtConfirmPassword: UITextField!
    @IBOutlet var lblErrors: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

    @IBAction func register(_ sender: Any) {
        var fullName:String = txtFullName.text!;
        var username:String = txtUsername.text!;
        var password:String = txtPassword.text!;
        let confirmPassword:String = txtConfirmPassword.text!;
        
        // Validate Register Input
        var errorMessage:String = ""
        
        if fullName.isEmpty || fullName.characters.count < 3 {
            errorMessage = "Your full name needs to have at least 3 characters."
        } else if username.isEmpty || username.characters.count < 3 {
            errorMessage = "Your username needs to have at least 3 characters."
        } else if password.isEmpty || password.characters.count < 6 {
            errorMessage = "Your password needs to have at least 6 characters."
        } else if password != confirmPassword {
            errorMessage = "Password and confirm password don't match."
        }
        
        //lblErrors.text = errorMessage
        writeErrorMessage(errorMessage)
        
        if errorMessage.isEmpty {
            let url = URL(string: "https://paybackfriendsserver.herokuapp.com/checkuser/" + username)
            let task = URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
                if error != nil {
                    print(error!)
                } else {
                    if let urlContent = data {
                        do {
                            let jsonResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableContainers) as! [String:AnyObject]
                            let exists = jsonResult["response"]!
                            
                            if exists as! String == "true" {
                                DispatchQueue.main.sync {
                                    self.writeErrorMessage("This username is already taken.")
                                }
                            } else {
                                
                                
                                let headers = [
                                    "content-type": "application/x-www-form-urlencoded"
                                ]
                                
                                let postData = NSMutableData(data: "username=\(username)".data(using: String.Encoding.utf8)!)
                                postData.append("&name=\(fullName)".data(using: String.Encoding.utf8)!)
                                postData.append("&password=\(password)".data(using: String.Encoding.utf8)!)
                                
                                let request = NSMutableURLRequest(url: NSURL(string: "https://paybackfriendsserver.herokuapp.com/register")! as URL,
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
                                        if let content = data {
                                            do {
                                                let jsonResult = try JSONSerialization.jsonObject(with: content, options: JSONSerialization.ReadingOptions.mutableContainers) as! [String:AnyObject]
                                                let response = jsonResult["response"]!
                                                
                                                if response as! String == "true" {
                                                    DispatchQueue.main.sync {
                                                        self.performSegue(withIdentifier: "toLogIn", sender: nil)
                                                    }
                                                } else {
                                                    DispatchQueue.main.sync {
                                                        self.writeErrorMessage("Something went wrong...")
                                                    }
                                                }
                                            } catch {
                                                print("JSON Processing 2 failed")
                                            }
                                        }
                                    }
                                })
                                
                                dataTask.resume()
                                
                                
                                
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
    
    func writeErrorMessage(_ message: String){
        lblErrors.text = message
    }
}
