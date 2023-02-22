//
//  JCPreview.swift
//  JuphoonRoom
//
//  Created by Home on 2019/11/7.
//  Copyright © 2019 沈世达. All rights reserved.
//

import UIKit

class JCPreview: UIView {
    var roomTitle: UILabel?
    var waitTitle: UILabel?
//    var imageView: UIImageView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.frame.size.width = UIScreen.main.bounds.width
        self.frame.size.height = UIScreen.main.bounds.height
        self.backgroundColor = UIColor.white
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        roomTitle?.text = ""
        waitTitle?.text = "加入中..."
        self.backgroundColor = UIColor.init(red: 0.1, green: 0.11, blue: 0.12, alpha: 1)
//        imageView = UIImageView.init()
//        imageView?.frame = CGRect(x: UIScreen.main.bounds.width/2 - 90, y: UIScreen.main.bounds.height/2 - 90, width: 180, height: 180)
//        imageView?.image = UIImage.init(named: "meeting_voice_head")
//        self.addSubview(imageView!)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
