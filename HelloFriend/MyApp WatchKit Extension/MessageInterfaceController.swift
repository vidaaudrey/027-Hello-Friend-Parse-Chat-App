//
//  MessageInterfaceController.swift
//  MyApp
//
//  Created by Audrey Li on 5/23/15.
//  Copyright (c) 2015 shomigo.com. All rights reserved.
//

import WatchKit
import Foundation


class MessageInterfaceController: WKInterfaceController {

    @IBOutlet weak var fromLabel: WKInterfaceLabel!
    @IBOutlet weak var messageLabel: WKInterfaceLabel!
    
    var objectId = ""
    
    // mark the message as read
    @IBAction func doneBtnPressed() {
        WKInterfaceController.openParentApplication(["content": "markMessageAsRead", "objectId": objectId], reply: { (reply, error) -> Void in
            println("send messaget to app to mark message as read. Id:\(self.objectId)")
            if error == nil {
                if let response = reply as? [String: Bool] {
                    let isMarkedRead:Bool = response["isMarkedRead"]!
                    if isMarkedRead {
                        println("message marked read!")
                    } else {
                        println("failed to mark message as read!")
                    }
                }
            }
        })
        popController()
    }
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
       
        // we already did pre-check, so we can safely use casting
        let infoDict:[String: String] = context as [String: String]
        fromLabel.setText("From: " + infoDict["from"]!)
        messageLabel.setText(infoDict["content"]! + " " + infoDict["createdAt"]!)
        objectId = infoDict["objectId"]!
       
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
