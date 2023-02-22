import UIKit
import WebKit
import SwiftyJSON
import MarqueeLabel


protocol ViewControllerTaskAlertDelegate {
    func onTaskAlertDismiss(isConfirmed: Bool)
}


class ViewControllerTaskAlert: UIViewController {

    @IBOutlet weak var viewOutside: UIView!
    @IBOutlet weak var viewContent: UIView!

    @IBOutlet weak var lblType: MarqueeLabel!
    @IBOutlet weak var lblState: MarqueeLabel!
    @IBOutlet weak var lblLocation: MarqueeLabel!
    @IBOutlet weak var lblTime: MarqueeLabel!
    @IBOutlet weak var lblSeconds: UILabel!
    @IBOutlet weak var txtDescription: UITextView!

    /// Variable
    var delegate: ViewControllerTaskAlertDelegate? = nil

    private var timer: Timer? = nil
    private var iTimeCount: Int = 16


    override func viewDidLoad() {
        super.viewDidLoad()

        viewOutside.backgroundColor = UIColor.clear

        //-- Gesture lblGetCode
//        let gestureOutside = UITapGestureRecognizer(target: self, action: #selector(onTapOutside(_:)))
//        viewOutside.addGestureRecognizer(gestureOutside)
//        viewOutside.isUserInteractionEnabled = true

        //-- Border of viewContent
        viewContent.backgroundColor = .white
        viewContent.layer.borderWidth = 1
        viewContent.layer.borderColor = UIColor.gray.cgColor

        //-- Init Value
        lblType.text        = Config.stTaskDetail?.info?.title       ?? ""
        lblState.text       = Config.stTaskDetail?.info?.content     ?? ""
        lblLocation.text    = Config.stTaskDetail?.info?.place       ?? ""
        lblTime.text        = Config.stTaskDetail?.info?.create_time ?? ""
        txtDescription.text = "任务内容：" + (Config.stTaskDetail?.task_content ?? "")

        //-- Animate Content
        Timer.scheduledTimer(
            timeInterval: 0.5,
            target      : self,
            selector    : #selector(self.animateViewContent),
            userInfo    : nil,
            repeats     : false
        )
        //-- Timer
        iTimeCount = 16
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { timer in
            self.iTimeCount -= 1
            if self.iTimeCount < 0 {
                self.onTouchUpBtnReject(timer)
            }
            else {
                DispatchQueue.main.async {
                    self.lblSeconds.text = "(\(self.iTimeCount)秒)"
                }
            }
        })
    }

    @objc func animateViewContent() {
        DispatchQueue.main.async {
            self.viewContent.isHidden = false
            UIView.animate(withDuration: 1.0) {
                var frameContent = self.viewContent.frame
                frameContent.origin.y = 70
                self.viewContent.frame = frameContent
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        viewContent.isHidden = true
        viewContent.frame.origin.y = -viewContent.frame.size.height
    }


    override func viewWillDisappear(_ animated: Bool) {
        timer?.invalidate()
        timer = nil
    }

/*
    @objc func onTapOutside(_ sender: UIGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
*/

    @IBAction func onTouchUpBtnBegin(_ sender: Any) {
        tryAcceptTask()
    }


    @IBAction func onTouchUpBtnReject(_ sender: Any) {
        tryCancelTask()
    }


    private func tryAcceptTask() {
        var stReq: StReqAcceptTask = StReqAcceptTask()
        stReq.token  = Config.modelUserInfo.sToken
        stReq.mobile = Config.modelUserInfo.sMobile
        stReq.task_id = Config.modelUserInfo.iIdTask

        API.instance.acceptTask(stReq: stReq) { result in
            switch result {
                case let .success(stRsp):
                    if stRsp.retcode != Config.RET_SUCCESS {
                        self.showAlert(message: stRsp.msg!)
                        break
                    }
                    Config.modelUserInfo.sStatus = Config.USER_STATUS_WORKING
                    Config.stTaskDetail?.task_status = Config.TASK_STATUS_PENDING

                    DispatchQueue.main.async {
                        self.dismiss(animated: false, completion: {
                            self.delegate?.onTaskAlertDismiss(isConfirmed: true)
                        })
                    }
                    break

                case let .failure(error):
                    self.showAlert(message: error.description!)
                    break
            }
        }
    }


    private func tryCancelTask() {
        var stReq: StReqCancelTask = StReqCancelTask()
        stReq.token  = Config.modelUserInfo.sToken
        stReq.mobile = Config.modelUserInfo.sMobile
        stReq.task_id = Config.modelUserInfo.iIdTask

        API.instance.cancelTask(stReq: stReq) { result in
            switch result {
                case let .success(stRsp):
                    if stRsp.retcode != Config.RET_SUCCESS {
                        self.showAlert(message: stRsp.msg!)
                        break
                    }
                    Config.modelUserInfo.iIdTask = 0
                    if (Config.modelUserInfo.sStatus == Config.USER_STATUS_WORKING){
                        Config.modelUserInfo.sStatus = Config.USER_STATUS_READY
                    }
                    DispatchQueue.main.async {
                        self.dismiss(animated: false, completion: {
                            self.delegate?.onTaskAlertDismiss(isConfirmed: false)
                        })
                    }
                    break

                case let .failure(error):
                    self.showAlert(message: error.description!)
                    break
            }
        }
    }
}
