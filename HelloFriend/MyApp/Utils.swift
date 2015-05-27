//
//  Utils.swift
//  MyApp
//
//  Created by Audrey Li on 5/23/15.
//  Copyright (c) 2015 shomigo.com. All rights reserved.
//

import Foundation
import UIKit

struct AppConfig {
    static let LoggedInSegueIdentifier = "loginSegue"
    static let LoggedOutSegueIdentifier = "signoutSegue"
    static let FriendListToMessageSegueIdentifier = "friendToMessageSegue"
    static let FriendToMessageSegueIdentifier = "showMessage"
    static let FriendCellIdentifier = "friendCell"
    static let FriendListCellIdentifier = "friendListCell"
    static let MessageLeftCellIdentifier = "messageLeftCell"
    static let MessageRightCellIdentifier = "messageRightCell"
   
}
class Utils {
    
}

public extension UIViewController {
    @IBAction public func unwindToViewController (sender: UIStoryboardSegue){}
}