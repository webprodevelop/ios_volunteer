//
//  JCParticipantViewController.swift
//  JuphoonRoom
//
//  Created by Home on 2019/11/6.
//  Copyright © 2019 沈世达. All rights reserved.
//

import UIKit
import JuphoonCommon
import JCSDKOC

class JCParticipantViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var titleLabel: UILabel!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.parts = JCRoom.shared.mediaChannel?.participants as! [JCMediaChannelParticipant]
        self.titleLabel.text = "参与者(\(self.parts.count))"
        return self.parts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PartpCell", for: indexPath) as! JCParticipantTableViewCell
        let partp: JCMediaChannelParticipant = self.parts[indexPath.row]

        // 判断昵称不等于 nil
        cell.displayName.text = partp.displayName.isEmpty ? partp.userId : partp.displayName
        if partp.userId == JCRoom.shared.client?.userId {
            cell.displayName.text = partp.displayName.isEmpty ? partp.userId : partp.displayName + "-我"
        }
        cell.phoneNumber.text = partp.userId
        cell.muteImage.image = partp.audio ? UIImage.init(named: "participant_unmute") : UIImage.init(named: "participant_mute")
        cell.videoImage.image = partp.video ? UIImage.init(named: "participant_video") : UIImage.init(named: "participant_novideo")
        return cell
    }
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var parts = [JCMediaChannelParticipant]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.parts = JCRoom.shared.mediaChannel?.participants as! [JCMediaChannelParticipant]
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.parts = JCRoom.shared.mediaChannel?.participants as! [JCMediaChannelParticipant]
        // Do any additional setup after loading the view.
        // 注册 Cell
        let nib = UINib(nibName: "JCParticipantTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "PartpCell")
        self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        self.tableView.tableFooterView =  UIView.init(frame: CGRect.zero)
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: NSNotification.Name(rawValue: kMediaChannelOnParticipantUpdateNotification) , object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(mediaChannelStateChange(_:)), name: NSNotification.Name(rawValue: kMediaChannelStateChangeNotification) , object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(mediaChannelParticipantJoin(_:)), name: NSNotification.Name(rawValue: kMediaChannelOnParticipantJoinNotification) , object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(mediaChannelParticipantLeft(_:)), name: NSNotification.Name(rawValue: kMediaChannelOnParticipantLeftNotification) , object: nil)
        
    }
    

    
    @objc func mediaChannelStateChange(_ note: Notification)  {
        if JCRoom.shared.mediaChannel?.state == JCMediaChannelState.idle {
            if !JCNet.shared()!.hasNet {
                Toast.show(withText: "网络已断开")
//                self.navigationController?.popToRootViewController(animated: true)
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @objc func mediaChannelParticipantJoin(_ note: Notification) {
         self.tableView.reloadData()
     }

     @objc func mediaChannelParticipantLeft(_ note: Notification) {
         self.tableView.reloadData()
     }
    
     @objc func mediaChannelParticipantUpdate(_ note: Notification) {
         self.tableView.reloadData()
     }
    
    @objc func reloadData() {
        self.tableView.reloadData()
    }
    
    @IBAction func addPart(_ sender: Any) {
        let inviteVC = JCInvitePartViewController()
//        self.navigationController?.pushViewController(inviteVC, animated: true)
        self.present(inviteVC, animated: true, completion: nil)
    }
    @IBAction func backAction(_ sender: UIButton) {
//        self.navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    override func needHideNav() -> Bool {
        return true
    }
}
