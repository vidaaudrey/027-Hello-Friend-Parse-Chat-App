

//
//  MessageViewController.swift
//  MyApp
//
//  Created by Audrey Li on 5/24/15.
//  Copyright (c) 2015 shomigo.com. All rights reserved.
//

import UIKit
import Parse

class MessageViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var newMessageField: UITextField!
    var currentFriend = ""
    var messages:[PFObject] = [] {
        didSet {
            // can optimize more
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 60
        
        getAllMessages()
        tableView.dataSource = self
        tableView.delegate = self 
        
    }
    @IBAction func sendBtnPressed(sender: UIButton) {
        if !newMessageField.text.isEmpty {
            let newMessage = PFObject(className: "Messages")
            newMessage["from"] = PFUser.currentUser()!.username!
            newMessage["to"] = currentFriend
            newMessage["content"] = newMessageField.text
            newMessage.saveInBackgroundWithBlock({ (success, error) -> Void in
                if error == nil {
                    let query = PFQuery(className: "Messages")
                    query.limit = 1
                    query.orderByDescending("createdAt")
                    query.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                        println("got the last message \(objects)")
                        if error == nil && objects?.count > 0 {
                            let newOnlineMessage = objects![0] as PFObject
                             self.messages.append(newMessage)
                        } else {
                            println("failed to retrieve message")
                        }
                    })
                    
                } else {
                    println("failed to send message")
                }
            })
        }
        newMessageField.resignFirstResponder()
    }
    
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        newMessageField.resignFirstResponder()
    }
    
    
    //TableView
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        if message["from"]! as String == PFUser.currentUser()!.username! {
            let cell: MesageRightTableViewCell = tableView.dequeueReusableCellWithIdentifier(AppConfig.MessageRightCellIdentifier, forIndexPath: indexPath) as MesageRightTableViewCell
            cell.configCell(message)
            return cell
        } else {
            let cell:MesageTableViewCell = tableView.dequeueReusableCellWithIdentifier(AppConfig.MessageLeftCellIdentifier, forIndexPath: indexPath) as MesageTableViewCell
            cell.configCell(message)
            return cell
        }
    }
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    // note that the user can only delete their own message now. Further work needed if this is a real production app 
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let messageToDelete = messages[indexPath.row]
            messages.removeAtIndex(indexPath.row)
            messageToDelete.deleteInBackgroundWithBlock({ (success, error) -> Void in
                if error != nil {
                    println("failed to delete message at server")
                    self.messages.insert(messageToDelete, atIndex: indexPath.row)
                    self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                } else {
                    println("deleted message \(messageToDelete)")
                }
            })
        }
    }

    
    // DB Func
    func getAllMessages(){
        var messages:[PFObject] = []

        let currentUserName = PFUser.currentUser()!.username!
        println("getting from db of \(currentFriend)")
        let predicate = NSPredicate(format: "(from = %@ AND to = %@) OR (from = %@ AND to = %@)", currentUserName, currentFriend, currentFriend, currentUserName)
        
        var query = PFQuery(className: "Messages", predicate: predicate)
        query.orderByAscending("createdAt")
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error == nil && objects != nil {
                for object in objects! {
                    messages.append(object as PFObject)
                }
                self.messages = messages
            }
        }

    }

}
