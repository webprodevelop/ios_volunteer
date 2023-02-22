import UIKit
import WebKit


protocol ViewControllerRangeDelegate: AnyObject {
    func onRangeSuccess()
}


class ViewControllerRange: UIViewController {

    @IBOutlet weak var txtMax: UITextField!
    @IBOutlet weak var txtMin: UITextField!

    var bClickedConfirm: Bool = false
    var iMax: Int = 0
    var iMin: Int = 0
    var delegate: ViewControllerRangeDelegate? = nil


    override func viewDidLoad() {
        super.viewDidLoad()
        txtMax.text = ""
        txtMin.text = ""
        if Config.id_watch_monitoring <= 0 { return }

        iMax = Config.modelWatchMonitoring.iHeartRateHigh
        iMin = Config.modelWatchMonitoring.iHeartRateLow
        txtMax.text = "\(iMax)"
        txtMin.text = "\(iMin)"
    }


    @IBAction func onTouchUpCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }


    @IBAction func onTouchUpOk(_ sender: Any) {
        if bClickedConfirm { return }

        if Config.id_watch_monitoring <= 0 {
            dismiss(animated: true, completion: nil)
            return
        }

        iMax = Int(txtMax.text ?? "0") ?? 0
        iMin = Int(txtMin.text ?? "0") ?? 0

        if iMin > iMax {
            showToast(message: "Values are not correct".localized(), completion: nil)
            return
        }

        trySetHeartRate()
    }


    func trySetHeartRate() {
        var stReq: StReqSetHeartRate = StReqSetHeartRate()
        stReq.token    = Config.modelUserInfo.sToken
        stReq.mobile   = Config.modelUserInfo.sMobile
        stReq.id       = Config.id_watch_monitoring
        stReq.heart_rate_high = Int(txtMax.text ?? "0") ?? 0
        stReq.heart_rate_low  = Int(txtMin.text ?? "0") ?? 0

        bClickedConfirm = true
        API.instance.setHeartRate(stReq: stReq) { result in
            switch result {
                case let .success(stRsp):
                    if stRsp.retcode != Config.RET_SUCCESS {
                        self.showAlert(message: stRsp.msg!)
                        break
                    }
                    Config.modelWatchMonitoring.iHeartRateHigh = self.iMax
                    Config.modelWatchMonitoring.iHeartRateLow  = self.iMin
                    DbManager.instance.updateWatch(model: Config.modelWatchMonitoring)

                    self.dismiss(animated: false) {
                        self.delegate?.onRangeSuccess()
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

