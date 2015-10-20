//
//  AppDelegate.swift
//  MyApp
//
//  Created by Audrey Li on 5/23/15.
//  Copyright (c) 2015 shomigo.com. All rights reserved.
//

import UIKit

import Bolts
import Parse

// If you want to use any of the UI components, uncomment this line
// import ParseUI

// If you want to use Crash Reporting - uncomment this line
// import ParseCrashReporting

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    //--------------------------------------
    // MARK: - UIApplicationDelegate
    //--------------------------------------
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Enable storing and querying data from Local Datastore.
        // Remove this line if you don't want to use Local Datastore features or want to use cachePolicy.
        Parse.enableLocalDatastore()
        
        // ****************************************************************************
        // Uncomment this line if you want to enable Crash Reporting
        // ParseCrashReporting.enable()
        //
        // Uncomment and fill in with your Parse credentials:
        // Parse.setApplicationId("your_application_id", clientKey: "your_client_key")
        Parse.setApplicationId("iybDxYQoCi9Cx2GCeLDLJ73rucXqXyjjxoAOAqDY",
            clientKey: "votuJwz2mBVRrk0SN3HCN7y0C48K66LW7aoDyxSp")
        //
        // If you are using Facebook, uncomment and add your FacebookAppID to your bundle's plist as
        // described here: https://developers.facebook.com/docs/getting-started/facebook-sdk-for-ios/
        // Uncomment the line inside ParseStartProject-Bridging-Header and the following line here:
        // PFFacebookUtils.initializeFacebook()
        // ****************************************************************************
        
       // PFUser.enableAutomaticUser()
        
        let defaultACL = PFACL();
        
        // If you would like all objects to be private by default, remove this line.
        defaultACL.setPublicReadAccess(true)
        
        PFACL.setDefaultACL(defaultACL, withAccessForCurrentUser:true)
        
        if application.applicationState != UIApplicationState.Background {
            // Track an app open here if we launch with a push, unless
            // "content_available" was used to trigger a background push (introduced in iOS 7).
            // In that case, we skip tracking here to avoid double counting the app-open.
            
            let preBackgroundPush = !application.respondsToSelector("backgroundRefreshStatus")
            let oldPushHandlerOnly = !self.respondsToSelector("application:didReceiveRemoteNotification:fetchCompletionHandler:")
            var noPushPayload = false;
            if let options = launchOptions {
                noPushPayload = options[UIApplicationLaunchOptionsRemoteNotificationKey] != nil;
            }
            if (preBackgroundPush || oldPushHandlerOnly || noPushPayload) {
                PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
            }
        }
//        if application.respondsToSelector("registerUserNotificationSettings:") {
//            let userNotificationTypes = UIUserNotificationType.Alert | UIUserNotificationType.Badge | UIUserNotificationType.Sound
//            let settings = UIUserNotificationSettings(forTypes: userNotificationTypes, categories: nil)
//            application.registerUserNotificationSettings(settings)
//            application.registerForRemoteNotifications()
//        } else {
//            let types = UIRemoteNotificationType.Badge | UIRemoteNotificationType.Alert | UIRemoteNotificationType.Sound
//            application.registerForRemoteNotificationTypes(types)
//        }
        
        if application.respondsToSelector("isRegisteredForRemoteNotifications")
        {
            // iOS 8 Notifications
            application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: (.Badge | .Sound | .Alert), categories: nil));
            application.registerForRemoteNotifications()
        }
//        else
//        {
//            // iOS < 8 Notifications
//            application.registerForRemoteNotificationTypes(.Badge | .Sound | .Alert)
//        }
        
        return true
    }
    
    //--------------------------------------
    // MARK: Push Notifications
    //--------------------------------------
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let installation = PFInstallation.currentInstallation()
        installation.setDeviceTokenFromData(deviceToken)
        installation.saveInBackground()
        
        PFPush.subscribeToChannelInBackground("", block: { (succeeded: Bool, error: NSError?) -> Void in
            if succeeded {
                println("ParseStarterProject successfully subscribed to push notifications on the broadcast channel.");
            } else {
                println("ParseStarterProject failed to subscribe to push notifications on the broadcast channel with error = %@.", error)
            }
        })
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        if error.code == 3010 {
            println("Push notifications are not supported in the iOS Simulator.")
        } else {
            println("application:didFailToRegisterForRemoteNotificationsWithError: %@", error)
        }
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        PFPush.handlePush(userInfo)
        if application.applicationState == UIApplicationState.Inactive {
            PFAnalytics.trackAppOpenedWithRemoteNotificationPayload(userInfo)
        }
    }
    
    ///////////////////////////////////////////////////////////
    // Uncomment this method if you want to use Push Notifications with Background App Refresh
    ///////////////////////////////////////////////////////////
    // func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
    //     if application.applicationState == UIApplicationState.Inactive {
    //         PFAnalytics.trackAppOpenedWithRemoteNotificationPayload(userInfo)
    //     }
    // }
    
    //--------------------------------------
    // MARK: Facebook SDK Integration
    //--------------------------------------
    
    ///////////////////////////////////////////////////////////
    // Uncomment this method if you are using Facebook
    ///////////////////////////////////////////////////////////
    // func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
    //     return FBAppCall.handleOpenURL(url, sourceApplication:sourceApplication, session:PFFacebookUtils.session())
    // }
    
    
    func application(application: UIApplication, handleWatchKitExtensionRequest userInfo: [NSObject : AnyObject]?, reply: (([NSObject : AnyObject]!) -> Void)!) {
        if let message = userInfo as? [String: String] {
                if let content = message["content"] {
                    switch content {
                        
                    case "isLoggedIn":
                        if PFUser.currentUser() != nil {
                                reply(["isLoggedIn": true])
                            } else {
                                 reply(["isLoggedIn": false])
                        }
        
                        
                    case "getMessages":
                        var messages:[String] = []
                        var query = PFQuery(className: "Messages")
                        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
                            if error == nil && objects != nil {
                                for object in objects! {
                                    if let content = object["content"] as? String {
                                        messages.append(content)
                                    }
                                }
                                 reply(["messages": messages])
                            }
                        }
                      
                        
                    case "getPhrases":
                        var phrases:[String] = []
                        var query = PFQuery(className: "Phrases")
                        query.whereKey("username", equalTo: PFUser.currentUser()!.username!)
                        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
                            if error == nil && objects?.count > 0  {
                                if let storedPhrase = objects![0] as? PFObject {
                                    phrases.append((storedPhrase["phrase1"] as? String) ?? "")
                                    phrases.append((storedPhrase["phrase2"] as? String) ?? "")
                                    phrases.append((storedPhrase["phrase3"] as? String) ?? "")
                                    phrases.append((storedPhrase["phrase4"] as? String) ?? "")
                                }
                                reply(["phrases": phrases])
                            }
                        }
                        
                        
                    case "getUsers":
                        var users:[String] = []
                        var query = PFUser.query()!
                        query.whereKey("username", notEqualTo: PFUser.currentUser()!.username!)
                        query.findObjectsInBackgroundWithBlock{ (objects, error) -> Void in
                            if error == nil && objects?.count > 0  {
                                for object in objects! {
                                    if let content = object["username"] as? String {
                                        users.append(content)
                                    }
                                }
                                reply(["users": users])
                            }
                        }
                    
                
                    case "sendMessage":
                        if let userToSend = message["userToSend"] {
                            if let messageToSend = message["messageToSend"]{
                               let newMessage = PFObject(className: "Messages")
                                newMessage["content"] = messageToSend
                                newMessage["from"] = PFUser.currentUser()!.username
                                newMessage["to"] = userToSend
                                newMessage.saveInBackgroundWithBlock({ (success, error) -> Void in
                                    if error == nil {
                                        
                                        // send the push 
                                        var push = PFPush()
                                        push.setMessage("New message from \(PFUser.currentUser()!.username!)")
                                        push.sendPushInBackgroundWithBlock({ (success, error) -> Void in
                                             reply(["content": success])
                                        })
                                        
                    
                                    } else {
                                        reply(["content": false])
                                    }
                                })
                            } else {
                                 reply(["content": false])
                            }
                            
                        } else {
                             reply(["content": false])
                        }
                      
                        
                        
                    case "getNewestMessage":
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
                                    
                                    reply(["from": from, "content": content, "createdAt": createdAt, "objectId": objectId])
                                }
                            } else {
                                reply(["content": false])
                            }
                        })
                        
                        
                        
                        
                    case "markMessageAsRead":
                        let objectId:String = message["objectId"]!
                        var query = PFQuery(className: "Messages")
                        query.getObjectInBackgroundWithId(objectId, block: { (object, error) -> Void in
                            if error != nil {
                                reply(["isMarkedRead": false])
                             } else if let updatingMessage:PFObject = object {
                                updatingMessage["isRead"] = true
                               
                                updatingMessage.saveInBackgroundWithBlock({ (success, error) -> Void in
                                    if error == nil {
                                        reply(["isMarkedRead": success])
                                    } else {
                                        reply(["isMarkedRead": false])
                                    }
                                })
                            }else {
                                reply(["isMarkedRead": false])
                            }
                        })


                        
                        
                    default:
                        reply(["content": "what do you want"])
                    }
            }
            
        }

    }
    
}

