//
//  FriendsViewController.swift
//  MyApp
//
//  Created by Audrey Li on 5/24/15.
//  Copyright (c) 2015 shomigo.com. All rights reserved.
//

import UIKit
import Parse


class FriendsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    var selectedMessage:PFObject?
    
    var messages:[PFObject] = [] {
        didSet {
            // can optimize more
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if PFUser.currentUser() == nil {
            performSegueWithIdentifier(AppConfig.LoggedOutSegueIdentifier, sender: self)
        } else {
            getAllMessages()
            tableView.dataSource = self
            tableView.delegate = self
        }
        
        
        
    }
    override func viewWillAppear(animated: Bool) {
        getAllMessages()
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let dvc = segue.destinationViewController as? MessageViewController {
            let currentUserName = PFUser.currentUser()!.username!
            let fromUserName = selectedMessage!["from"] as! String
            let toUserName = selectedMessage!["to"] as! String
            println("going to \(fromUserName) and \(toUserName) page now")
            dvc.currentFriend = currentUserName == fromUserName ? toUserName : fromUserName
        }
    }
    
    // tableView
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        let cell: FriendTableViewCell = tableView.dequeueReusableCellWithIdentifier(AppConfig.FriendCellIdentifier, forIndexPath: indexPath) as! FriendTableViewCell
        cell.configCell(message)
        return cell
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedMessage = messages[indexPath.row]
        performSegueWithIdentifier(AppConfig.FriendToMessageSegueIdentifier, sender: self)
    }
    
    
    @IBAction func logoutBtnPressed(sender: UIButton) {
        PFUser.logOutInBackground()
        performSegueWithIdentifier(AppConfig.LoggedOutSegueIdentifier, sender: self)
    }
    

    // DB Func
    func getAllMessages(){
        var messages:[PFObject] = []
        var uniqueUsersSet = NSMutableSet()
        let currentUserName = PFUser.currentUser()!.username!
        let predicate = NSPredicate(format: "to = %@ OR from = %@", currentUserName, currentUserName)
        var query = PFQuery(className: "Messages", predicate: predicate)
        query.orderByDescending("createdAt")
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error == nil && objects!.count > 0 {
                for object in objects! {
                    let message = object as! PFObject
                    // as Parse doesn't support unique query, we have to manually process here. 
                    // Only save unique users to the messages list
                    let fromUserName = message["from"]! as! String
                    let toUserName = message["to"]! as! String
                    
                    if !uniqueUsersSet.containsObject(fromUserName) && !uniqueUsersSet.containsObject(toUserName) {
                        messages.append(message)
                        
                        // only add users who are not current user to the uniqueUsersSet
                        let nameToAdd = fromUserName == currentUserName ? toUserName : fromUserName
                        uniqueUsersSet.addObject(nameToAdd)
                       
                    }
                }
                self.messages = messages
            }
        }
        
    }
    
}