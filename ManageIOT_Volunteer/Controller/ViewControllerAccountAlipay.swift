import UIKit
import WebKit

protocol ViewControllerAccountAlipayDelegate: AnyObject {
    func onAccountAlipayDismiss()
}


class ViewControllerAccountAlipay: UIViewController {

    @IBOutlet weak var viewOutside: UIView!
    @IBOutlet weak var txtAccountName: UITextField!{
        didSet{
            txtAccountName!.addDoneCancelToolbar(
                onDone: (target: self, action: #selector(onDoneName))
            )
        }
    }
    @IBOutlet weak var txtAccountId: UITextField!{
        didSet{
            txtAccountId!.addDoneCancelToolbar(
                onDone: (target: self, action: #selector(onDoneId))
            )
        }
    }
    
    @objc func onDoneName() {
        txtAccountId.becomeFirstResponder()
    }
    @objc func onDoneId() {
        txtAccountId.resignFirstResponder()
    }

    var delegate: ViewControllerAccountAlipayDelegate? = nil

    private var sAccountName: String = ""
    private var sAccountId  : String = ""
    private var bClickedModify: Bool = false


    override func viewDidLoad() {
        super.viewDidLoad()

        txtAccountName.text = ""
        txtAccountId.text = ""

        //-- Gesture lblGetCode
        let gestureOutside = UITapGestureRecognizer(target: self, action: #selector(onTapOutside(_:)))
        viewOutside.addGestureRecognizer(gestureOutside)
        viewOutside.isUserInteractionEnabled = true
    }


    @IBAction func onTouchUpBtnModify(_ sender: Any) {
        sAccountName = txtAccountName.text ?? ""
        sAccountId   = txtAccountId.text ?? ""
        if sAccountName.isEmpty {
            showAlert(message: "请输入支付宝名字") { (UIAlertAction) in
                self.txtAccountName.becomeFirstResponder()
            }
            return
        }
        if sAccountId.isEmpty {
            showAlert(message: "请输入支付宝ID") { (UIAlertAction) in
                self.txtAccountId.becomeFirstResponder()
            }
            return
        }

        if bClickedModify { return }
        bClickedModify = true
        tryRegisterPayAccount()
    }


    @objc func onTapOutside(_ sender: UIGestureRecognizer) {
        dismiss(animated: false, completion: nil)
    }

    @IBAction func onCancel(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }
    
    func onBack() {
        dismissFromParent()
        delegate?.onAccountAlipayDismiss()
    }


    func tryRegisterPayAccount() {
        var stReq: StReqRegisterPayAccount = StReqRegisterPayAccount()
        stReq.mobile = Config.modelUserInfo.sMobile
        stReq.token  = Config.modelUserInfo.sToken
        stReq.pay_type = Config.PAYMENT_ALIPAY
        stReq.pay_account_name = sAccountName
        stReq.pay_account_id   = sAccountId

        API.instance.registerPayAccount(stReq: stReq) { result in
            switch result {
                case let .success(stRsp):
                    if stRsp.retcode != Config.RET_SUCCESS {
                        self.showAlert(message: stRsp.msg!)
                        break
                    }
                    Config.modelUserInfo.sAlipayId   = self.sAccountId
                    Config.modelUserInfo.sAlipayName = self.sAccountName
                    DispatchQueue.main.async {
                        self.delegate?.onAccountAlipayDismiss()
                        self.showToast(message: "Successfully updated!".localized(), completion: {
                            self.dismiss(animated: false, completion: nil)
                        })
                    }
                    break

                case let .failure(error):
                    self.showAlert(message: error.description!)
                    break
            }
            self.bClickedModify = false
        }
    }

}
