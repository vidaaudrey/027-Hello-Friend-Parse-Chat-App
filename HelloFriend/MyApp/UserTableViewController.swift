//
//  UserTableViewController.swift
//  MyApp
//
//  Created by Audrey Li on 6/7/15.
//  Copyright (c) 2015 shomigo.com. All rights reserved.
//

    import UIKit
    import Parse

    class UserTableViewController: UITableViewController {

        var userArray:[String] = []
        override func viewDidLoad() {
            super.viewDidLoad()
             retrieveFriends()
        }
        
//        func retrieveMessages() {
//            var query = PFUser.query()!
//            if let username = PFUser.currentUser()!.username {
//                println(username)
//                query.whereKey("username", equalTo: username)
//                query.findObjectsInBackgroundWithBlock { [weak self]
//                    (objects, error) -> Void in
//                    println(objects)
//                    for object in objects! {
//                        let username:String? = (object as! PFUser).username
//                        if username != nil {
//                            self!.userArray.append(username!)
//                        }
//                    }
//                    self!.tableView.reloadData()
//                }
//                
//            }
//        }
        
        
        //
        func retrieveFriends() {
            var query = PFQuery(className: "Friends")
            if let username = PFUser.currentUser()!.username {
                query.whereKey("from", equalTo: username)
                query.orderByDescending("createdAt")
                query.findObjectsInBackgroundWithBlock({ [weak self] (objects, error) -> Void in
                    if error == nil && objects?.count > 0 {
                        let friends = objects!.map{($0 as! PFObject)["to"]! as! String}
                        println(friends)
                        self!.userArray = friends
                    }
                    println(self!.userArray)
                    self!.tableView.reloadData()
                })
            }
        }
        
        
        
        
        override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

            return userArray.count
        }

        
        override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCellWithIdentifier("userCell", forIndexPath: indexPath) as! UITableViewCell

            cell.textLabel?.text = userArray[indexPath.row]

            return cell
        }
    }
