//
//  FriendTableViewCell.swift
//  MyApp
//
//  Created by Audrey Li on 5/26/15.
//  Copyright (c) 2015 shomigo.com. All rights reserved.
//

import UIKit
import Parse

class FriendTableViewCell: UITableViewCell {
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    
    func configCell(data: PFObject){
        contentLabel.text = data["content"] as? String
        
        let currentUserName = PFUser.currentUser()!.username!
        let fromUserName = data["from"] as? String
        let toUserName = data["to"] as? String
        fromLabel.text = currentUserName == fromUserName ? toUserName : fromUserName
        
        let formater = NSDateFormatter()
        formater.dateStyle = NSDateFormatterStyle.ShortStyle
        let timeStr = formater.stringFromDate(data.createdAt!)
        timeLabel.text = timeStr
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
