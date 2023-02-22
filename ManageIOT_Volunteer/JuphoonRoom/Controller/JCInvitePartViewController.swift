//
//  JCInvitePartViewController.swift
//  JuphoonRoom
//
//  Created by 黎芹 on 2020/7/8.
//  Copyright © 2020 沈世达. All rights reserved.
//

import UIKit
import JuphoonCommon
import JCSDKOC

class JCInvitePartViewController: UIViewController {

    @IBOutlet weak var textView: UITextField!
    
    @IBOutlet weak var inviteBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        inviteBtn.layer.cornerRadius = 25
        inviteBtn.layer.masksToBounds = true
        numberChanged()
    }

    @IBAction func numberChanged() {
        let number = self.textView.text
        if number!.isEmpty {
            self.inviteBtn.isEnabled = false
            self.inviteBtn.backgroundColor = kRGB(220, g: 220, b: 220)
        } else {
            self.inviteBtn.isEnabled = true
            self.inviteBtn.backgroundColor = UIColor(red: 255.0 / 255.0, green: 207.0 / 255.0, blue: 0 / 255.0, alpha: 1.0)
        }
    }
    
    
    @IBAction func goBack(_ sender: Any) {
//        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func inviteAction(_ sender: Any) {
        
        let param = NSMutableDictionary()
        if let channelid = JCRoom.shared.mediaChannel?.channelId  as NSString?{
            let channel = channelid.components(separatedBy: "room_").last
            param.setValue(channel!, forKey: "roomName")
        }
        if let pwd = JCRoom.shared.mediaChannel?.password {
            param.setValue(pwd, forKey: "roomPWD")
        }
        if let displayName = JCRoom.shared.client?.displayName {
            param.setValue(displayName, forKey: "selfName")
        }
        
        if let phone = self.textView.text {
//            param.setValue(["room_" + phone], forKey: "audience")
            param.setValue([phone], forKey: "audience")
        }
        
        var isHad = false
        JCRoom.shared.mediaChannel?.participants.forEach({ (obj) in
            let p = obj as! JCMediaChannelParticipant
            if (p.userId == self.textView.text!) {
//            if (p.userId == "room_" + self.textView.text!) {
                isHad = true
                Toast.show(withText: "该成员已在房间中")
                return
            }
        })
        if isHad == true {
            return
        }
        
        JuphoonCommonManager.shareInstance.uploadPushInfo(notiType: .Room_InvitePart, notification: param, success: { (result) in
            Toast.show(withText: "发送成功")
//            self.navigationController?.popViewController(animated: true)
            self.dismiss(animated: true, completion: nil)
        }) { (error) in
            print(error)
            Toast.show(withText: "发送失败")
        }
    }
    override func needHideNav() -> Bool {
        return true
    }
}
