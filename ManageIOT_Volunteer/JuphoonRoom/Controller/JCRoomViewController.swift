//
//  JCRoomViewController.swift
//  Room
//
//  Created by Home on 2019/11/5.
//  Copyright © 2019 沈世达. All rights reserved.
//

import UIKit
import JuphoonCommon
import JCSDKOC

class SubViewRect {
    var x: Float
    var y: Float
    var width: Float
    var height: Float

    init(x: Float, y: Float, width: Float, height: Float) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
    }
}


class MediaCanvas {
    var canvas: JCMediaDeviceVideoCanvas?
    var participant: JCMediaChannelParticipant?
    var subViewRect: SubViewRect?
    var label: UILabel
    var parent: UIView
    var videoOffView: UIImageView

    init() {
        self.parent = UIView.init()
        self.parent.backgroundColor = UIColor.black
        
        self.videoOffView = UIImageView.init()
        self.videoOffView.image = UIImage.init(named: "meeting_voice_head")
        self.videoOffView.contentMode = .center
        self.videoOffView.backgroundColor = UIColor.init(red: 68.0/255.0, green: 68.0/255.0, blue: 68.0/255.0, alpha: 1.0)
        self.videoOffView.isHidden = true
        self.parent.addSubview(self.videoOffView)
        
        self.label = UILabel.init()
        self.label.autoresizingMask = UIView.AutoresizingMask(rawValue: UIView.AutoresizingMask.flexibleLeftMargin.rawValue | UIView.AutoresizingMask.flexibleRightMargin.rawValue)
        self.label.backgroundColor = UIColor.clear
        self.label.font = UIFont.systemFont(ofSize: 13.0)
        self.label.textColor = UIColor.white
        self.label.textAlignment = NSTextAlignment.left
        self.label.numberOfLines = 0
        self.parent.addSubview(self.label)
    }


    func del() {
        self.reset()
        self.parent.removeFromSuperview()
    }


    func reset() {
        if self.canvas != nil {
            if JCRoom.shared.client?.userId != self.participant?.userId {
                JCRoom.shared.mediaChannel?.requestVideo(self.participant!, pictureSize: JCMediaChannelPictureSize.none)
            }
            self.canvas?.videoView.removeFromSuperview()
            JCRoom.shared.mediaDevice?.stopVideo(self.canvas!)
            self.canvas = nil;
        }
    }
}


class JCRoomViewController: UIViewController {
    
    @IBOutlet weak var preview: UIView!
    @IBOutlet weak var roomTitleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var netImage: UIImageView!
    @IBOutlet weak var joiningLabel: UILabel!
    @IBOutlet weak var toolView: UIView!
    @IBOutlet weak var microBtn: UIButton!
    @IBOutlet weak var switchBtn: UIButton!
    @IBOutlet weak var speakerBtn: UIButton!
    @IBOutlet weak var cameraBtn: UIButton!
    @IBOutlet weak var termBtn: UIButton!
    @IBOutlet weak var partpBtn: UIButton!
    @IBOutlet weak var inviteBtn: UIButton!

    public var roomId: String?
    public var password: String?
    private var arrayCanvas = [MediaCanvas]()
    private var dataSource: NSMutableArray = NSMutableArray.init()
    private var participant: NSMutableArray = NSMutableArray.init()
    private var pictureSize: JCMediaChannelPictureSize = JCMediaChannelPictureSize.large
    private var angleIndex: Int = 0
    private var uri: String = ""
    private var timer: Timer?
    private var timeBegin: CLongLong?

    private var joinningView: JCPreview?


    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }


    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    deinit {
        NotificationCenter.default.removeObserver(self)
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black
        self.modalPresentationStyle = .fullScreen
        // Do any additional setup after loading the view.
        self.roomTitleLabel.text = self.roomId
        self.joiningLabel.isHidden = false
        self.timeLabel.isHidden = true
        self.netImage.isHidden = true
        NotificationCenter.default.addObserver(self, selector: #selector(mediachannelLeave(_:)), name: NSNotification.Name(rawValue: kMediaChannelOnLeaveNotification), object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(mediachannelLeave(_:)), name: NSNotification.Name(rawValue: kMediaChannelOnLeaveOverNotification), object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(mediaChannelStateChange(_:)), name: NSNotification.Name(rawValue: kMediaChannelStateChangeNotification) , object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(mediaChannelPropertyChange(_:)), name: NSNotification.Name(rawValue: kMediaChannelOnPropertyChangeNotification) , object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(mediaChannelParticipantJoin(_:)), name: NSNotification.Name(rawValue: kMediaChannelOnParticipantJoinNotification) , object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(mediaChannelParticipantLeft(_:)), name: NSNotification.Name(rawValue: kMediaChannelOnParticipantLeftNotification) , object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(mediaChannelParticipantUpdate(_:)), name: NSNotification.Name(rawValue: kMediaChannelOnParticipantUpdateNotification) , object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(mediaChannelJoinSuccess(_:)), name: NSNotification.Name(rawValue: kMediaChannelOnJoinSuccessNotification) , object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onJoinFail(_:)), name: NSNotification.Name(rawValue: kMediaChannelOnJoinFailNotification) , object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillTerminate), name: UIApplication.willTerminateNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(quitRoom), name: NSNotification.Name(rawValue: kQuitRoomVCNotifacation) , object: nil)
        self.updateControlButtons()
        
        // 请求视频尺寸
        self.pictureSize = JCMediaChannelPictureSize.large
        
        let joinParam = JCMediaChannelJoinParam()
        
        if !self.password!.isEmpty {
            joinParam.capacity = 16
            joinParam.password = self.password!
        }
        
        var maxResValue: Int = 0
        // 设置会议最大分辨率
        if  JuphoonCommonUserDefault.getResolution() == "360P" {
            maxResValue = 0
        }
        else if (JuphoonCommonUserDefault.getResolution() == "720P") {
            maxResValue = 1
        }
        else if (JuphoonCommonUserDefault.getResolution() == "1080P") {
            maxResValue = 2
        }
        joinParam.maxResolution = JCMediaChannelMaxResolution(rawValue: maxResValue)!

        let frameRate: Int = Int(JuphoonCommonUserDefault.getFrameRate())!
        joinParam.framerate = Int32(frameRate)

        // 是否发送音视频
        JCRoom.shared.mediaChannel?.enableUploadAudioStream(true)
        JCRoom.shared.mediaChannel?.enableUploadVideoStream(true)
        // 加入会议
//        JCRoom.shared.mediaChannel?.join("room_" + self.roomId!, joinParam: joinParam)
        JCRoom.shared.mediaChannel?.join(self.roomId!, joinParam: joinParam)
        self.joinningView = JCPreview.init()
        self.view.addSubview(self.joinningView!)
    }


    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }


    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }


    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.toolView.isHidden = !self.toolView.isHidden
        self.roomTitleLabel.isHidden = self.toolView.isHidden
        self.timeLabel.isHidden = self.toolView.isHidden
        self.netImage.isHidden = self.toolView.isHidden
        self.termBtn.isHidden = self.toolView.isHidden
        self.partpBtn.isHidden = self.toolView.isHidden
        self.inviteBtn.isHidden = self.toolView.isHidden
    }


    override func needHideNav() -> Bool {
        return true
    }


    func updateControlButtons() {
        if JCRoom.shared.mediaChannel?.state == JCMediaChannelState.joined {
            self.microBtn.isSelected = !JCRoom.shared.mediaChannel!.uploadLocalAudio
            self.speakerBtn.isSelected = JCRoom.shared.mediaDevice!.isSpeakerOn()
            self.cameraBtn.isSelected = JCRoom.shared.mediaChannel!.uploadLocalVideo
        }
    }


    func caclSubViewRect(width: Int, height: Int, totalNum: Int) -> [SubViewRect] {
        var array = [SubViewRect]()
        if totalNum == 0 {
            return array
        }
        var row: Int = 0
        var column: Int = 0
        if totalNum <= 2 {
            row = totalNum
            column = 1
        }
        else if totalNum <= 4 {
            row = 2
            column = 2
        }
        else if totalNum <= 6 {
            row = 3
            column = 2
        }
        else if totalNum <= 8 {
            row = 4
            column = 2
        }
        else if totalNum <= 10 {
            row = 5
            column = 2
        }
        else if totalNum <= 12 {
            row = 6
            column = 2
        }
        else if totalNum <= 15 {
            row = 5
            column = 3
        }
        else if totalNum <= 18 {
            row = 6
            column = 3
        }
        else if totalNum <= 21 {
            row = 7
            column = 3
        }
        
        let perWidth: Int = width / column
        let perHeight: Int = height / row
        for i in 0..<totalNum {
            array.append(SubViewRect.init(x: Float(perWidth * (i % column)), y: Float(perHeight * (i / column)), width: Float(perWidth), height: Float(perHeight)))
        }
        return array
    }


    func layoutPartp() {
        let partps: NSArray = JCRoom.shared.mediaChannel!.participants as NSArray
        let subViewRects: NSArray = self.caclSubViewRect(width: Int(self.preview.frame.size.width), height: Int(self.preview.frame.size.height), totalNum: partps.count) as NSArray
        var i : Int = 0
        while (true) {
            if i < partps.count {
                let partp: JCMediaChannelParticipant = partps.object(at: i) as! JCMediaChannelParticipant
                let subViewRect: SubViewRect = subViewRects.object(at: i) as! SubViewRect
                var item: MediaCanvas
                if self.arrayCanvas.count <= i {
                    item = MediaCanvas.init()
                    self.arrayCanvas.append(item)
                    self.preview.addSubview(item.parent)
                }
                else {
                    item = self.arrayCanvas[i]
                }
                if item.participant != partp {
                    item.reset()
                    item.participant = partp
                }
                item.subViewRect = subViewRect
                item.parent.frame = CGRect(x: CGFloat(subViewRect.x), y: CGFloat(subViewRect.y), width: CGFloat(subViewRect.width), height: CGFloat(subViewRect.height))
                item.videoOffView.frame = item.parent.bounds
                item.label.frame = CGRect(x: 30, y: item.parent.frame.size.height-35, width: item.parent.frame.size.width, height: 30)
                item.label.text = item.participant!.displayName.isEmpty ? item.participant!.userId : item.participant!.displayName
                if item.canvas != nil {
                    item.canvas?.videoView.frame = CGRect(x: 0, y: 0, width: item.parent.frame.size.width, height: item.parent.frame.size.height)
                }
                i += 1
                continue
            }
            else if i < self.arrayCanvas.count {
                for j in (i..<self.arrayCanvas.count).reversed() {
                    self.arrayCanvas[j].del()
                    self.arrayCanvas.remove(at: j)
                }
            }
            break
        }
        self.updatePartp()
    }


    func updatePartp() {
        for item: MediaCanvas in self.arrayCanvas {
            let partSelf = JCRoom.shared.mediaChannel?.getParticipant((JCRoom.shared.client?.userId)!)
            switch partSelf?.netStatus {
                case .disconnected:
                    self.netImage.image = UIImage.init(named: "meeting_volume1")
                case .bad:
                    self.netImage.image = UIImage.init(named: "meeting_volume2")
                case .good:
                    self.netImage.image = UIImage.init(named: "meeting_volume4")
                case .normal:
                    self.netImage.image = UIImage.init(named: "meeting_volume3")
                case .veryBad:
                    self.netImage.image = UIImage.init(named: "meeting_volume1")
                case .veryGood:
                    self.netImage.image = UIImage.init(named: "meeting_volume5")
                default:
                    self.netImage.image = UIImage.init(named: "meeting_volume3")
            }
            if JCRoom.shared.client!.userId == item.participant!.userId {
                if item.participant!.video {
                    if item.canvas == nil {
                        item.canvas = JCRoom.shared.mediaDevice?.startCameraVideo(.fullScreen)
                        item.canvas?.videoView.frame = CGRect(x: 0, y: 0, width: item.parent.frame.size.width, height: item.parent.frame.size.height)
                        item.parent.insertSubview((item.canvas?.videoView)!, at: 0)
                    }
                }
            }
            else {
                if item.participant!.video {
                    if item.canvas == nil {
                        item.canvas = JCRoom.shared.mediaDevice?.startVideo((item.participant?.renderId)!, renderType: .fullScreen)
                        JCRoom.shared.mediaChannel?.requestVideo(item.participant!, pictureSize: self.pictureSize)
                        item.parent.insertSubview((item.canvas?.videoView)!, at: 0)
                        
                        item.canvas?.videoView.frame = CGRect(x: 0, y: 0, width: item.parent.frame.size.width, height: item.parent.frame.size.height)
                    }
                }
            }
            if !item.participant!.video {
                if item.canvas != nil {
                    item.reset()
                }
            }
            item.videoOffView.isHidden = item.participant!.video;
        }
    }


    func clear() {
        for item: MediaCanvas in self.arrayCanvas {
            item.del()
        }
        self.arrayCanvas.removeAll()
    }


    @IBAction func invitePart(_ sender: Any) {
        let inviteVC = JCInvitePartViewController()
//        self.navigationController?.pushViewController(inviteVC, animated: true)
        self.present(inviteVC, animated: true, completion: nil)
    }
   
    
    @IBAction func clickBtn(_ sender: UIButton) {
        if sender.tag == 1 {
        JCRoom.shared.mediaChannel?.enableUploadAudioStream(!JCRoom.shared.mediaChannel!.uploadLocalAudio)
            self.microBtn.isSelected = !JCRoom.shared.mediaChannel!.uploadLocalAudio
            
        }
        else if sender.tag == 2 {
            JCRoom.shared.mediaDevice?.switchCamera()
        }
        else if sender.tag == 3 {
            JCRoom.shared.mediaDevice?.enableSpeaker(!JCRoom.shared.mediaDevice!.isSpeakerOn())
            self.speakerBtn.isSelected = JCRoom.shared.mediaDevice!.isSpeakerOn()
        }
        else if sender.tag == 4 {
            JCRoom.shared.mediaChannel?.enableUploadVideoStream(!JCRoom.shared.mediaChannel!.uploadLocalVideo)
            self.cameraBtn.isSelected = JCRoom.shared.mediaChannel!.uploadLocalVideo
        }
        else if sender.tag == 5 {
            let alertController = UIAlertController(title: "提示",
                            message: "确定要离开吗？", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
            let okAction = UIAlertAction(title: "离开", style: .default, handler: {
                action in
                if JCRoom.shared.mediaChannel?.participants.count ?? 0 <= 1 {
                    JCRoom.shared.mediaChannel?.stop()
                } else {
                    JCRoom.shared.mediaChannel?.leave()
                }
                self.clear()
                self.dismiss(animated: true, completion: nil)
                self.stopTimer()
                self.roomTitleLabel.text = nil
                self.timeLabel.text = nil
            })
            alertController.addAction(cancelAction)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
        else if sender.tag == 6 {
            let partpVc = JCParticipantViewController.init()
            partpVc.modalPresentationStyle = .fullScreen
            self.present(partpVc, animated: true)
        }
    }
    

    @objc func quitRoom() {
           if JCRoom.shared.mediaChannel?.participants.count ?? 0 <= 1 {
               JCRoom.shared.mediaChannel?.stop()
           }
           else {
               JCRoom.shared.mediaChannel?.leave()
           }
           self.clear()
//           self.navigationController?.popViewController(animated: true)
           self.dismiss(animated: true, completion: nil)
           self.stopTimer()
           self.roomTitleLabel.text = nil
           self.timeLabel.text = nil
    }


    @objc func mediachannelLeave(_ note: Notification) {
        self.quitRoom();
    }


    @objc func mediaChannelStateChange(_ note: Notification)  {
        if JCRoom.shared.mediaChannel?.state == JCMediaChannelState.joined {
            self.uri = JCRoom.shared.mediaChannel!.channelUri!
            self.layoutPartp()
        }
        else if JCRoom.shared.mediaChannel?.state == JCMediaChannelState.idle {
//            self.clear()
//            self.navigationController?.popViewController(animated: true)
        }
        self.updateControlButtons()
    }


    @objc func mediaChannelJoinSuccess(_ note: Notification) {
        self.joinningView?.removeFromSuperview()
        self.joiningLabel.isHidden = true
        self.timeLabel.isHidden = false
        self.netImage.isHidden = false
        self.timeBegin = CLongLong(Date().timeIntervalSince1970*1000)
        self.startTimer()
        self.layoutPartp()
    }


    @objc func mediaChannelPropertyChange(_ note: Notification) {
        self.updateControlButtons()
    }


    @objc func mediaChannelParticipantJoin(_ note: Notification) {
        self.layoutPartp()
    }


    @objc func mediaChannelParticipantLeft(_ note: Notification) {
        self.layoutPartp()
        self.quitRoom()
    }


    @objc func mediaChannelParticipantUpdate(_ note: Notification) {
        self.updatePartp()
    }


    @objc func onJoinFail(_ note: Notification) {
        if JCRoom.shared.mediaChannel?.state != JCMediaChannelState.idle {
            JCRoom.shared.mediaChannel?.leave()
            self.clear()
        }
    }


    @objc func applicationWillTerminate() {
        JCRoom.shared.mediaChannel?.leave()
        self.clear()
    }


    func startTimer() {
        if (self.timer == nil) {
            self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerProc), userInfo: nil, repeats: true)
            self.timer?.fire()
        }
    }


    func stopTimer() {
        if (self.timer != nil) {
            if self.timer!.isValid {
                self.timer!.invalidate()
                self.timer = nil
                self.timeBegin = nil
            }
        }
    }


    @objc func timerProc() {
        if JCRoom.shared.mediaChannel?.state != JCMediaChannelState.idle {
            let timeNow = CLongLong(Date().timeIntervalSince1970*1000)
            let timeInterval = timeNow - self.timeBegin!
            self.timeLabel.text = self.formatTalkingTime(time: timeInterval)
        }
    }


    func formatTalkingTime(time: CLongLong) -> String {
        let minute: CLongLong = time/1000/60
        let minuteValue = minute > 9 ? "\(minute)": "0\(minute)"
        let seconds: CLongLong = time/1000%60
        let secondsValue = seconds > 9 ? "\(seconds)": "0\(seconds)"
        return String.init("\(minuteValue):\(secondsValue)")
    }


}
