//
//  MainViewController.swift
//  MyApp
//
//  Created by Audrey Li on 5/23/15.
//  Copyright (c) 2015 shomigo.com. All rights reserved.
//

import UIKit
import Parse

class MainViewController: UIViewController {
    @IBOutlet weak var p1Field: UITextField!
    @IBOutlet weak var p2Field: UITextField!
    @IBOutlet weak var p3Field: UITextField!
    @IBOutlet weak var p4Field: UITextField!
    var phrases = PFObject(className: "Phrases")
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBAction func saveBtnPressed(sender: UIButton) {
        phrases["phrase1"] = p1Field.text
        phrases["phrase2"] = p1Field.text
        phrases["phrase3"] = p1Field.text
        phrases["phrase4"] = p1Field.text
    //    phrases.saveInBackground() it will make a copy, so better to update 
        var query = PFQuery(className: "Phrases")
        query.whereKey("username", equalTo: PFUser.currentUser()!.username!)
        query.findObjectsInBackgroundWithBlock { [unowned self] (objects, error) -> Void in
            if error == nil && objects?.count > 0{
                if let storedPhrases = objects![0] as? PFObject {
                    storedPhrases["phrase1"] = self.p1Field.text
                    storedPhrases["phrase2"] = self.p2Field.text
                    storedPhrases["phrase3"] = self.p3Field.text
                    storedPhrases["phrase4"] = self.p4Field.text
                    
                    storedPhrases.saveInBackgroundWithBlock({ (success, error) -> Void in
                        if error == nil {
                            self.errorLabel.text = "Phrases updated"
                        } else {
                            self.handleError(error)
                        }
                    })
                } else {
                    self.errorLabel.text = "There is some problem. Please try again later"
                }
            } else {
                self.handleError(error)
            }
        }
        phrases.pinInBackground()

    }
    
    func handleError(error:NSError?){
        if let errorStr = error?.userInfo?["error"] as? String{
            self.errorLabel.text = errorStr
        } else {
            self.errorLabel.text = "There is some problem. Please try again later"
        }
    }
    func updatePhraseFields(){
        p1Field.text = phrases["phrase1"] as! String
        p2Field.text = phrases["phrase2"] as! String
        p3Field.text = phrases["phrase3"] as! String
        p4Field.text = phrases["phrase4"] as! String
    }
    
    
    func getNewMessage(){
        var query = PFQuery(className: "Messages")
        query.whereKey("to", equalTo: PFUser.currentUser()!.username!)
        query.limit = 1
        query.whereKey("isRead", equalTo: false)
        query.orderByDescending("createdAt")
        query.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
            if error == nil && objects?.count > 0 {
                if let newestMessage = objects![0] as? PFObject {
                    let from:String = newestMessage["from"]! as! String
                    let content:String = newestMessage["content"]! as! String
                    let formater = NSDateFormatter()
                    let dateStr = formater.stringFromDate(newestMessage.createdAt!)
                    let createdAt:String = dateStr
                    let objectId:String = newestMessage.objectId!
                    println(newestMessage)
                }
            } else {
               println("error getting the newest message")
            }
        })
    }
    
    func markMessageAsRead(objectId:String = "sY2957vK7F"){
        var query = PFQuery(className: "Messages")
        query.getObjectInBackgroundWithId(objectId, block: { (object, error) -> Void in
            if error != nil {
                println(error)
            } else if let updatingMessage:PFObject = object {
                updatingMessage["isRead"] = true
                println("marked object as read.")
                updatingMessage.saveInBackground()
            }
        })
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        markMessageAsRead()
        
        getNewMessage()
        
        if PFUser.currentUser() == nil {
            performSegueWithIdentifier(AppConfig.LoggedOutSegueIdentifier, sender: self)
        }
        
        let query = PFQuery(className: "Phrases")
        query.fromLocalDatastore()
        query.whereKey("username", equalTo: PFUser.currentUser()!.username!)
        query.findObjectsInBackgroundWithBlock { [unowned self] (objects, error) -> Void in
            if error == nil && objects?.count > 0 {
                if let object = objects![0] as? PFObject {
                    self.phrases = object
                }
            } else {
                // create phrases 
                self.phrases["username"] = PFUser.currentUser()!.username
                self.phrases["phrase1"] = "I'll be there soon"
                self.phrases["phrase2"] = "I love you?"
                self.phrases["phrase3"] = "Dinner together?"
                self.phrases["phrase4"] = "Where are you?"
                self.phrases.saveInBackground()
                self.phrases.pinInBackground()

            }
            self.updatePhraseFields()
        }
        
    }

    @IBAction func logoutBtnPressed(sender: UIButton) {
        PFUser.logOutInBackground()
        performSegueWithIdentifier(AppConfig.LoggedOutSegueIdentifier, sender: self)
    }
}
