import UIKit
import WebKit


protocol ViewControllerUnbindDelegate: AnyObject {
    func onUnbindSuccess()
}


class ViewControllerUnbind: UIViewController {

    @IBOutlet weak var viewOutside: UIView!

    var type : DeviceType = .SmartWatch
    var model: Any? = nil
    var bClickedConfirm: Bool = false
    var delegate: ViewControllerUnbindDelegate? = nil


    override func viewDidLoad() {
        super.viewDidLoad()

        //-- Gesture lblGetCode
        let gestureOutside = UITapGestureRecognizer(target: self, action: #selector(onTapOutside(_:)))
        viewOutside.addGestureRecognizer(gestureOutside)
        viewOutside.isUserInteractionEnabled = true
    }


    @objc func onTapOutside(_ sender: UIGestureRecognizer) {
        dismiss(animated: false, completion: nil)
    }


    @IBAction func onTouchUpOk(_ sender: Any) {
        if bClickedConfirm { return }
        if type == .SmartWatch {
            tryDelWatch()
        }
        else {
            tryDelSensor()
        }
    }


    @IBAction func onTouchUpCancel(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }


    func tryDelWatch() {
        var stReq: StReqDelWatch = StReqDelWatch()
        stReq.token    = Config.modelUserInfo.sToken
        stReq.mobile   = Config.modelUserInfo.sMobile
        let modelWatch = model as? ModelWatch ?? ModelWatch()
        stReq.id = modelWatch.iId

        bClickedConfirm = true
        API.instance.delWatch(stReq: stReq) { result in
            switch result {
                case let .success(stRsp):
                    if stRsp.retcode != Config.RET_SUCCESS {
                        self.showAlert(message: stRsp.msg!)
                        break
                    }
                    _ = DbManager.instance.deleteWatch(id: stReq.id)
                    self.dismiss(animated: false) {
                        self.delegate?.onUnbindSuccess()
                    }
                    break

                case let .failure(error):
                    self.showAlert(message: error.description!)
                    break
            }
            self.bClickedConfirm = false
        }

    }


    func tryDelSensor() {
        var stReq: StReqDelSensor = StReqDelSensor()
        stReq.token  = Config.modelUserInfo.sToken
        stReq.mobile = Config.modelUserInfo.sMobile
        let modelSensor = model as? ModelSensor ?? ModelSensor()
        stReq.id = modelSensor.iId

        bClickedConfirm = true
        API.instance.delSensor(stReq: stReq) { result in
            switch result {
                case let .success(stRsp):
                    if stRsp.retcode != Config.RET_SUCCESS {
                        self.showAlert(message: stRsp.msg!)
                        break
                    }

                    _ = DbManager.instance.deleteSensor(id: stReq.id)
                    self.dismiss(animated: false) {
                        self.delegate?.onUnbindSuccess()
                    }
                    break

                case let .failure(error):
                    self.showAlert(message: error.description!)
                    break
            }
            self.bClickedConfirm = false
        }

    }

}
