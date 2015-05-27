//
//  UsersInterfaceController.swift
//  MyApp
//
//  Created by Audrey Li on 5/23/15.
//  Copyright (c) 2015 shomigo.com. All rights reserved.
//

import WatchKit
import Foundation


class UsersInterfaceController: WKInterfaceController {

    @IBOutlet weak var table: WKInterfaceTable!
    
    var messageToSend = ""
    var users:[String] = []
    
    func setupTable(){
        table.setHidden(false)
        table.setNumberOfRows(users.count, withRowType: WKConfig.TableRowType)
        for (index, dataItem) in enumerate(users){
            let row = table.rowControllerAtIndex(index) as TableRowController
            row.cellLabel.setText(dataItem)
        }
    }
    override func table(table: WKInterfaceTable, didSelectRowAtIndex rowIndex: Int) {
        // send the message to the selected user
        WKInterfaceController.openParentApplication(["content":"sendMessage", "userToSend": users[rowIndex], "messageToSend": messageToSend], reply: { (reply, error) -> Void in
            if error == nil {
                if let response = reply as? [String: Bool]{
                    if let content = response["content"] {
                        self.pushControllerWithName(WKConfig.InterfaceControllerIdentifier, context: true)
                    }
                }
            } else {
                println("error sending the message through the iPhone app")
            }
        })
    }
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        if let messageToSend = context as? String {
            self.messageToSend = messageToSend
            
            WKInterfaceController.openParentApplication(["content": "isLoggedIn"], reply: {[unowned self] (reply, error) -> Void in
                if error != nil {
                    println("error getting the reply from parent app \(error)")
                } else {
                    if let isLoggedIn: Bool = reply["isLoggedIn"] as? Bool {
                        if !isLoggedIn {
                           self.popController()
                        } else {
            
                            WKInterfaceController.openParentApplication(["content": "getUsers"], reply: { (reply, error) -> Void in
                                if let response:[String:[String]] = reply as? [String:[String]]{
                                    println("got users, setting up the table. \(reply)")
                                    if response["users"]?.count > 0 {
                                        self.users = response["users"]!
                                        println("users\(self.users)")
                                        self.setupTable()
                                    }
                                }
                            })
                        }
                    }
                }
            })

        }
      
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
