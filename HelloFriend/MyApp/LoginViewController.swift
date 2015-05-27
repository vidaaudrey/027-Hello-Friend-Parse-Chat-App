//
//  ViewController.swift
//  MyApp
//
//  Created by Audrey Li on 5/23/15.
//  Copyright (c) 2015 shomigo.com. All rights reserved.
//

import UIKit
import Parse

class ViewController: UIViewController {

    @IBOutlet weak var signUpLabel: UILabel!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet var signUpBtn: UIButton!
    @IBOutlet weak var loginBtn: UIButton!
    
    var isSignUpMode = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        toggleSignUp(isSignUp: isSignUpMode)
       
    }
    
    override func viewDidAppear(animated: Bool) {
        if PFUser.currentUser() != nil {
            performSegueWithIdentifier(AppConfig.LoggedInSegueIdentifier, sender: self)
        }
    }
 
    func toggleSignUp(isSignUp:Bool = true){
        if isSignUp {
            signUpLabel.text = "Sign Up"
            signUpBtn.setTitle("Sign Up", forState: .Normal)
            loginBtn.setTitle("Login", forState: .Normal)
            emailField.hidden = false
        } else {
            signUpLabel.text = "Login"
            signUpBtn.setTitle("Login", forState: .Normal)
            loginBtn.setTitle("Sign Up", forState: .Normal)
            emailField.hidden = true
        }
        errorLabel.text = ""
    }
    @IBAction func loginBtnPressed(sender: UIButton) {
        isSignUpMode = !isSignUpMode
        toggleSignUp(isSignUp: isSignUpMode)
    }
    
    @IBAction func signUpBtnPressed(sender: UIButton) {
        if usernameField.text.isEmpty {
            errorLabel.text = "Please input username"
        } else if passwordField.text.isEmpty {
            errorLabel.text = "Please input password"
        }
        if isSignUpMode {
            if emailField.text.isEmpty {
                errorLabel.text = "Please input your email address"
            } else {
                userSignUp(usernameField.text, password: passwordField.text, email: emailField.text, phone: nil)
            }
        } else {
            userLogin(usernameField.text, password: passwordField.text)
            
        }
    }
    
    //testing func 

    func userLogin(username:String, password: String) {
        PFUser.logInWithUsernameInBackground(username, password:password) {
            (user: PFUser?, error: NSError?) -> Void in
            if user != nil {
               
                println("login now go to page ")
                self.performSegueWithIdentifier(AppConfig.LoggedInSegueIdentifier, sender: self)
                
            } else if let errorStr:String = error!.userInfo?["error"] as? String {
                self.errorLabel.text = "\(errorStr). Please try again"
            }
        }
    }
    
    func userSignUp(username:String, password: String, email: String, phone:String?) {
        var user = PFUser()
        user.username = username
        user.password = password
        user.email = email
        // other fields can be set just like with PFObject
        if phone != nil {
            user["phone"] = phone
        }

        user.signUpInBackgroundWithBlock {
            (succeeded: Bool, error: NSError?) -> Void in
            if error == nil {
                 println("signed up and logined already ")
                self.userLogin(username, password: password)
            } else if let errorStr:String = error!.userInfo?["error"] as? String {
                self.errorLabel.text = "\(errorStr). Please try again"
            }
        }
    }
    
    func queryUserByName(){
        var query = PFQuery(className:"User")
        query.whereKey("username", containsString: "Audrey")
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]?, error: NSError?) -> Void in
            
            if error == nil {
                println("Successfully retrieved \(objects!.count) users.")
                // Do something with the found objects
                if let objects = objects as? [PFObject] {
                    for object in objects {
                        println(object.objectId)
                        println(object["username"])
                    }
                }
            } else {
                // Log details of the failure
                println("Error: \(error!) \(error!.userInfo!)")
            }
        }
    }
    
    func createUsers(number: Int = 4){
        println("creating\(number) User ")
        for i in 0..<number {
            let user = PFObject(className: "User")
            user["username"] = "Audrey\(i)"
            user.saveInBackground()
        }
    
    }
    
    func createMessages(number: Int = 4) {
        println("creating\(number) Messages ")
        for i in 0..<number {
            let message = PFObject(className: "Messages")
            message["content"] = "How are you?"
            message["from"] = "Audrey\(i)"
            message["to"] = "Audrey\(4 - i)"
            message.saveInBackground()
        }
    }


}

