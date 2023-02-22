import UIKit
import WebKit

class ViewControllerIapDetail: UIViewController {

    @IBOutlet weak var lblLength: UILabel!
    @IBOutlet weak var lblPeriod: UILabel!
    @IBOutlet weak var lblAmount: UILabel!
    @IBOutlet weak var lblMethod: UILabel!

    var type : DeviceType = .SmartWatch
    var model: Any? = nil
    var iId  : Int = 0
    var iType: Int = 0
    var iOrderId: Int = 0


    override func viewDidLoad() {
        super.viewDidLoad()

        switch type {
            case .SmartWatch:
                let modelWatch = model as! ModelWatch
                iId = modelWatch.iId
                iType = 0
                break
            case .FireSensor:
                let modelSensor = model as! ModelSensor
                iId = modelSensor.iId
                iType = 1
                break
            case .SmokeSensor:
                let modelSensor = model as! ModelSensor
                iId = modelSensor.iId
                iType = 2
                break
        }

        tryInquirePaidService()
    }


    @IBAction func onTouchUpBack(_ sender: Any) {
        if navigationController != nil {
            navigationController?.dismiss(animated: true, completion: nil)
        }
        else {
            dismiss(animated: true, completion: nil)
        }
    }


    @IBAction func onTouchUpContinue(_ sender: Any) {
        if navigationController != nil {
            navigationController?.dismiss(animated: true, completion: nil)
        }
        else {
            dismiss(animated: true, completion: nil)
        }
    }


    @IBAction func onTouchUpRefund(_ sender: Any) {
        let storyboard = UIStoryboard(name: "IapRefund", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ViewControllerIapRefund") as! ViewControllerIapRefund
        vc.modalPresentationStyle = .overCurrentContext
        vc.delegate = self
        //navigationController?.pushViewController(vc, animated: false)
        present(vc, animated: false, completion: nil)       // Use present() to show IapRefund as transparent
    }


    func launchIapRefundComplete() {
        let storyboard = UIStoryboard(name: "IapRefundComplete", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ViewControllerIapRefundComplete")
        vc.modalPresentationStyle = .overCurrentContext
        navigationController?.pushViewController(vc, animated: true)
    }


    func tryInquirePaidService() {
        var stReq = StReqInquirePaidService()
        stReq.token  = Config.modelUserInfo.sToken
        stReq.mobile = Config.modelUserInfo.sMobile
        stReq.item_type = iType
        stReq.item_id   = iId

        API.instance.inquirePaidService(stReq: stReq) { result in
            switch result {
                case let .success(stRsp):
                    if stRsp.retcode != Config.RET_SUCCESS {
                        self.showAlert(message: stRsp.msg!)
                        break
                    }

                    DispatchQueue.main.async {
                        self.lblLength.text = String(stRsp.data?.service_years ?? 0) + "Y".localized()
                        self.lblPeriod.text = (stRsp.data?.service_start ?? "") + " ~ " + (stRsp.data?.service_end ?? "")
                        self.lblAmount.text = String(stRsp.data?.amount ?? 0) + "RMB".localized()
                        self.lblMethod.text = stRsp.data?.pay_type == 0
                            ? "Alipay".localized() : "Wechat".localized()
                        self.iOrderId = stRsp.data?.order_id ?? 0
                    }
                    break

                case let .failure(error):
                    self.showAlert(message: error.description!)
                    break
            }
        }
    }


    func tryCancelPaidService() {
        var stReq = StReqCancelPaidService()
        stReq.token  = Config.modelUserInfo.sToken
        stReq.mobile = Config.modelUserInfo.sMobile
        stReq.item_type = iType
        stReq.item_id   = iId
        stReq.order_id  = iOrderId

        API.instance.cancelPaidService(stReq: stReq) { result in
            switch result {
                case let .success(stRsp):
                    if stRsp.retcode != Config.RET_SUCCESS {
                        self.showAlert(message: stRsp.msg!)
                        break
                    }
                    self.launchIapRefundComplete()
                    break

                case let .failure(error):
                    self.showAlert(message: error.description!)
                    break
            }
        }

    }
}


extension ViewControllerIapDetail: ViewControllerIapRefundDelegate {

    func onIapRefundSuccess() {
        tryCancelPaidService()
    }

}
