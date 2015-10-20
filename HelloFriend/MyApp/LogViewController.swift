//
//  ViewController.swift
//  MyApp
//
//  Created by Audrey Li on 5/26/15.
//  Copyright (c) 2015 shomigo.com. All rights reserved.
//
//
//import UIKit
//import Parse
//import ParseUI
//
//class LogViewController: UIViewController, PFLogInViewControllerDelegate{
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        if PFUser.currentUser() == nil {
//            var logInController = PFLogInViewController()
//            logInController.delegate = self
//          //  logInController.facebookPermissions = [ "friends_about_me" ]
//            self.presentViewController(logInController, animated:true, completion: nil)
//        }
//    }
//    
//    func logInViewController(logInController: PFLogInViewController, didLogInUser user: PFUser) {
//        dismissViewControllerAnimated(true, completion: nil)
//    }
//    func logInViewControllerDidCancelLogIn(logInController: PFLogInViewController) {
//        dismissViewControllerAnimated(true, completion: nil)
//    }
//    
//}
