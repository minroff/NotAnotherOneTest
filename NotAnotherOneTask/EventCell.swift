//
//  EventCell.swift
//  NotAnotherOneTask
//
//  Created by Энди on 12.08.16.
//  Copyright © 2016 Andrew. All rights reserved.
//

import UIKit

class EventCell: UITableViewCell {
    
    
    @IBOutlet weak var bandImage: UIImageView!
    @IBOutlet weak var bandName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
