//
//  InterfaceController.swift
//  MyApp WatchKit Extension
//
//  Created by Audrey Li on 5/23/15.
//  Copyright (c) 2015 shomigo.com. All rights reserved.
//

import WatchKit
import Foundation

struct WKConfig {
    static let TableRowType = "TableRowController"
    static let InterfaceControllerIdentifier = "InterfaceController"
    static let UsersInterfaceControllerIdentifier = "UsersInterfaceController"
    static let MessageInterfaceControllerIdentifier = "MessageInterfaceController"
}


class InterfaceController: WKInterfaceController {
    @IBOutlet weak var loginLabel: WKInterfaceLabel!

    @IBOutlet weak var btn1: WKInterfaceButton!
    @IBOutlet weak var btn2: WKInterfaceButton!
    @IBOutlet weak var btn3: WKInterfaceButton!
    @IBOutlet weak var btn4: WKInterfaceButton!
    @IBOutlet weak var messageSentLabel: WKInterfaceLabel!
    
    var phrases:[String] = ["I love you!", "See you soon!", "Lunch together?", "Movie?"]
    
    @IBAction func btn1Pressed() {
        pushController(0)
    }
    
    @IBAction func btn2Pressed() {
         pushController(1)
    }
    
    @IBAction func btn3Pressed() {
         pushController(2)
    }
    
    @IBAction func btn4Pressed() {
         pushController(3)
    }
    
    func pushController(index:Int){
        pushControllerWithName(WKConfig.UsersInterfaceControllerIdentifier, context: phrases[index])
    }
    
    // trust we'll always get 4 phrases here, can do more checking
    func setupPhrases(){
        btn1.setTitle(phrases[0])
        btn2.setTitle(phrases[1])
        btn3.setTitle(phrases[2])
        btn4.setTitle(phrases[3])
    }
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        setupPhrases()
        
        if let isMessageSent = context as? Bool {
             messageSentLabel.setHidden(false)
            if isMessageSent {
                messageSentLabel.setText("Message sent")
            } else {
               messageSentLabel.setText("Message failed")
            }
        } else {
            messageSentLabel.setText("Choose message to send")
        }
        
        WKInterfaceController.openParentApplication(["content": "isLoggedIn"], reply: {[unowned self] (reply, error) -> Void in
            if error != nil {
                 println("error getting the reply from parent app \(error)")
            } else {
                if let isLoggedIn: Bool = reply["isLoggedIn"] as? Bool {
                    if !isLoggedIn {
                        self.loginLabel.setText("Please login from your iPhone")
                    } else {
                        println("logged in, getting messages from the App")
                        self.loginLabel.setHidden(true)
                        
                        
                        WKInterfaceController.openParentApplication(["content": "getNewestMessage"], reply: { (reply, error) -> Void in
                            if let response:[String:String] = reply as? [String:String]{
                                println("got the newest message \(reply)")
                                if let from:String = response["from"]{
                                    if let content:String = response["content"]{
                                        let createdAt:String = response["createdAt"]!
                                        let objectId:String = response["objectId"]!
                                        println("sending created At \(createdAt)")
                                         self.pushControllerWithName(WKConfig.MessageInterfaceControllerIdentifier, context: ["from": from, "content": content, "createdAt":createdAt, "objectId": objectId])
                                    }
                                }
                            } else {
                                println("did not get the newest message")
                            }
                        })
                        
                        WKInterfaceController.openParentApplication(["content": "getPhrases"], reply: { (reply, error) -> Void in
                            if let response:[String:[String]] = reply as? [String:[String]]{
                                println("got phrases, setting up the buttons. \(reply)")
                                if response["phrases"]?.count > 0 {
                                    self.phrases = response["phrases"]!
                                    self.setupPhrases()
                                }
                            }
                        })
                    }
                }
            }
        })
    }

    
    
    override func willActivate() {
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}



