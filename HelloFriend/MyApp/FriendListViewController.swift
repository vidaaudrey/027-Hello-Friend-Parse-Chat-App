//
//  FriendListViewController.swift
//  MyApp
//
//  Created by Audrey Li on 5/26/15.
//  Copyright (c) 2015 shomigo.com. All rights reserved.
//

import UIKit
import Parse
class FriendListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    var selectedUserName: String?
    var users:[PFUser] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        getAllUsers()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let dvc = segue.destinationViewController as? MessageViewController {
            println("going to \(selectedUserName) page now")
            dvc.currentFriend = selectedUserName!
        }
    }
    
    //DB func
    func getAllUsers(){
        var users:[PFUser] = []
        var query = PFUser.query()
        query!.whereKey("username", notEqualTo: PFUser.currentUser()!.username!)
        query!.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error == nil && objects?.count > 0 {
                for object in objects! {
                    users.append(object as! PFUser)
                }
                self.users = users
            }
        }
    }
    
    // tableView
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let user = users[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(AppConfig.FriendListCellIdentifier, forIndexPath: indexPath) as! UITableViewCell
        cell.textLabel?.text = user.username
        println(user.username)
        return cell
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedUserName = users[indexPath.row].username
        performSegueWithIdentifier(AppConfig.FriendListToMessageSegueIdentifier, sender: self)
    }

}
