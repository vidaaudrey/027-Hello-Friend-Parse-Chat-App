//
//  MesageTableViewCell.swift
//  MyApp
//
//  Created by Audrey Li on 5/24/15.
//  Copyright (c) 2015 shomigo.com. All rights reserved.
//

import UIKit
import Parse

class MesageTableViewCell: UITableViewCell {
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configCell(data: PFObject){
        contentLabel.text = data["content"] as? String
        fromLabel.text = data["from"] as? String
        let formater = NSDateFormatter()
     
        formater.dateFormat = "yyyy-MM-dd 'at' hh:mm a"
        let timeStr = formater.stringFromDate(data.createdAt!)
        timeLabel.text = timeStr
    }

}
