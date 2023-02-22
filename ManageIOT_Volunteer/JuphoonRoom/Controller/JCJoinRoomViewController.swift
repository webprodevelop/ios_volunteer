//
//  JCJoinRoomViewController.swift
//  JuphoonRoom
//
//  Created by 沈世达 on 2019/11/7.
//  Copyright © 2019 沈世达. All rights reserved.
//

import UIKit
import JuphoonCommon
import JCSDKOC

class JCJoinRoomViewController: UIViewController {
    
    @IBOutlet weak var roomText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var newWorkLabel: UILabel!
    @IBOutlet weak var joinButton: UIButton!

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.nameLabel.text = JCRoom.shared.client?.displayName
        self.activityIndicator.isHidden = true
        self.activityIndicator.stopAnimating()
        self.joinButton.setTitle("加入房间", for: .normal)
    }

    override func needHideNav() -> Bool {
        return true
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        NotificationCenter.default.addObserver(self, selector: #selector(netWorkChange(_:)), name: NSNotification.Name(rawValue: kNetWorkNotification) , object: nil)

    }

    deinit {
         NotificationCenter.default.removeObserver(self)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.roomText.resignFirstResponder()
        self.passwordText.resignFirstResponder()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.roomText.resignFirstResponder()
        self.passwordText.resignFirstResponder()
        return true
    }

    @objc func netWorkChange(_ note: Notification) {
        newWorkLabel.isHidden = JCNet.shared()?.hasNet ?? true
    }

    @IBAction func joinAction(_ sender: UIButton) {
        if (JCRoom.shared.client?.state != .logined) {
            Toast.show(withText: "网络差 无法加入")
            return
        }
        if self.roomText.text!.isEmpty {
            Toast.show(withText: "请输入房间号")
            return
        }
        if !JCNet.shared()!.hasNet {
            Toast.show(withText: "网络未连接")
            return
        }
        if let pwdText = self.passwordText.text {
            let regex = try! NSRegularExpression(pattern: ".*[^A-Za-z0-9].*", options: .allowCommentsAndWhitespace)
            if regex.firstMatch(in: pwdText, options: .withoutAnchoringBounds, range: NSMakeRange(0, pwdText.count)) != nil  {
                Toast.show(withText: "密码不能包含特殊字符、空格和中文，请重新输入")
                return
            }
        }

//        self.activityIndicator.isHidden = false
//        self.activityIndicator.startAnimating()
//        self.joinButton.setTitle("", for: .normal)
        // TODO
        let roomVc = JCRoomViewController.init()
        roomVc.roomId = self.roomText.text
        roomVc.password = self.passwordText.text
        self.present(roomVc, animated: true)
    }

    @IBAction func numberChanged(_ sender: UITextField) {
        let number = self.roomText.text
        if number!.isEmpty {
            self.joinButton.isEnabled = false
            self.joinButton.backgroundColor = kRGB(220, g: 220, b: 220)
        } else {
            self.joinButton.isEnabled = true
            self.joinButton.backgroundColor = kRGB(255, g: 177, b: 0)
        }
    }

    @IBAction func settingAction(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}
