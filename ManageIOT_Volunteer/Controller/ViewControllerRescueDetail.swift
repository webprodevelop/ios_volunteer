import UIKit
import WebKit


protocol ViewControllerRescueDetailDelegate: AnyObject {
    func onRescueDetailDismiss()
    func onRescueDetailPresent()
    func onRescueDetailPresentRescueProcess()
}


class ViewControllerRescueDetail: UIViewController {


    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblAlertType: UILabel!
    @IBOutlet weak var lblTimeReport: UILabel!
    @IBOutlet weak var lblTimeStart: UILabel!
    @IBOutlet weak var lblTimeEnd: UILabel!
    @IBOutlet weak var lblIntegral: UILabel!

    var delegate: ViewControllerRescueDetailDelegate? = nil
    var iRescueId: Int = 0


    private var vcRescueProcess: ViewControllerRescueProcess? = nil

    private var stRspGetRescueDetailData: StRspGetRescueDetailData? = nil


    override func viewDidLoad() {
        super.viewDidLoad()

        tryGetRescueDetail()
    }


    @IBAction func onTouchUpBtnDetail(_ sender: Any) {
        if vcRescueProcess == nil {
            let storyboard = UIStoryboard(name: "RescueProcess", bundle: nil)
            vcRescueProcess = storyboard.instantiateViewController(withIdentifier: "ViewControllerRescueProcess") as? ViewControllerRescueProcess
        }
        vcRescueProcess!.delegate = self
        vcRescueProcess!.stRspGetRescueDetailData = stRspGetRescueDetailData
        addChildViewController(child: vcRescueProcess!, container: view, frame: view.bounds)
        delegate?.onRescueDetailPresentRescueProcess()
    }


    func onBack() {
        if vcRescueProcess == nil {
            dismissFromParent()
            delegate?.onRescueDetailDismiss()
        }
        else {
            vcRescueProcess?.onBack()
        }
    }


    func dismissChildren() {
        vcRescueProcess?.dismissFromParent()
        vcRescueProcess = nil
    }


    func tryGetRescueDetail() {
        var stReq: StReqGetRescueDetail = StReqGetRescueDetail()
        stReq.token   = Config.modelUserInfo.sToken
        stReq.mobile  = Config.modelUserInfo.sMobile
        stReq.task_id = iRescueId

        API.instance.getRescueDetail(stReq: stReq) { result in
            switch result {
                case let .success(stRsp):
                    if stRsp.retcode != Config.RET_SUCCESS {
                        self.showAlert(message: stRsp.msg!)
                        break
                    }
                    if stRsp.data == nil { break }

                    self.stRspGetRescueDetailData = stRsp.data
                    DispatchQueue.main.async {
                        self.lblName.text       = stRsp.data?.contactName       ?? ""
                        self.lblAlertType.text  = stRsp.data?.task_content      ?? ""
                        self.lblTimeReport.text = stRsp.data?.alarm_create_time ?? ""
                        self.lblTimeStart.text  = stRsp.data?.create_time       ?? ""
                        self.lblTimeEnd.text    = stRsp.data?.finish_time       ?? ""
                        self.lblIntegral.text   = "\(stRsp.data?.point ?? 0)"
                    }
                    break

                case let .failure(error):
                    self.showAlert(message: error.description!)
                    break
            }
        }
    }

}


extension ViewControllerRescueDetail: ViewControllerRescueProcessDelegate {

    func onRescueProcessDismiss() {
        vcRescueProcess = nil
        delegate?.onRescueDetailPresent()
    }

}
