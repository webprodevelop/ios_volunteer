//
//  JCParticipantTableViewCell.swift
//  JuphoonRoom
//
//  Created by Home on 2019/11/6.
//  Copyright © 2019 沈世达. All rights reserved.
//

import UIKit

class JCParticipantTableViewCell: UITableViewCell {
    
    @IBOutlet weak var displayName: UILabel!
    
    @IBOutlet weak var phoneNumber: UILabel!
    
    @IBOutlet weak var muteImage: UIImageView!
    
    @IBOutlet weak var videoImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
