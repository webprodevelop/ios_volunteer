import UIKit
import WebKit


protocol ViewControllerBankForgotDelegate: AnyObject {
    func onBankForgotDismiss()
}


class ViewControllerBankForgot: UIViewController {

    @IBOutlet weak var txtIdCard : UITextField!
    @IBOutlet weak var txtNewPswd: UITextField!
    @IBOutlet weak var txtConfirm: UITextField!
    @IBOutlet weak var txtCode   : UITextField!
    @IBOutlet weak var btnGetCode: UIButton!
    @IBOutlet weak var btnSave   : UIButton!

    var delegate: ViewControllerBankForgotDelegate? = nil

    private var timer    : Timer? = nil
    private var iTimeLeft: Int = 0
    private var bSent    : Bool = false
    private var sCode    : String = ""


    override func viewDidLoad() {
        super.viewDidLoad()
        updateButton()
    }


    @IBAction func onTouchUpBtnGetCode(_ sender: Any) {
        if iTimeLeft > 0 { return }
        iTimeLeft = 60
        timer = Timer.scheduledTimer(
            timeInterval: 1.0,
            target      : self,
            selector    : #selector(onTimer),
            userInfo    : nil,
            repeats     : true
        )
        updateButton()
        tryGetCode()
    }


    @IBAction func onTouchUpBtnSave(_ sender: Any) {
        var bFilled: Bool = true

        if txtNewPswd.text == nil  { bFilled = false }
        if txtConfirm.text == nil  { bFilled = false }
        if txtCode.text == nil     { bFilled = false }

        if !bFilled {
            showToast(message: "Please fill in the contents".localized(), completion: nil)
            return
        }

        if txtNewPswd.text!.isEmpty  { bFilled = false }
        if txtConfirm.text!.isEmpty  { bFilled = false }
        if txtCode.text!.isEmpty     { bFilled = false }

        if !bFilled {
            showToast(message: "Please fill in the contents".localized(), completion: nil)
            return
        }

        if txtNewPswd.text! != txtConfirm.text! {
            showToast(message: "Confirm password is incorrect".localized(), completion: nil)
            return
        }

        if txtCode.text! != sCode {
            showToast(message: "Verify Code is incorrect".localized(), completion: nil)
            return
        }

        tryForgotBankPassword()
    }


    @objc func onTimer() {
        iTimeLeft -= 1
        if iTimeLeft < 0 {
            timer?.invalidate()
            timer = nil
        }
        updateButton()
    }


    func onBack() {
        dismissFromParent()
        delegate?.onBankForgotDismiss()
    }


    func updateButton() {
        DispatchQueue.main.async {
            if self.iTimeLeft <= 0 {
                self.btnGetCode.backgroundColor = UIColor(
                    red: 255/255, green: 98/255, blue: 0/255, alpha: 1
                )    // Orange
                self.btnGetCode.setTitle("Get Code".localized(), for: .normal)
                self.btnSave.isEnabled = false
            }
            else {
                self.btnGetCode.backgroundColor = UIColor(
                    red: 194/255, green: 199/255, blue: 204/255, alpha: 1
                )    // Gray
                self.btnGetCode.setTitle("\(self.iTimeLeft)s", for: .normal)
                self.btnSave.isEnabled = true
            }
        }
    }


    func tryGetCode() {
        var stReq: StReqCode = StReqCode()
        stReq.mobile = Config.modelUserInfo.sMobile

        API.instance.getCode(stReq: stReq) { result in
            switch result {
                case let .success(stRsp):
                    if stRsp.retcode != Config.RET_SUCCESS {
                        self.showAlert(message: stRsp.msg!)
                        self.iTimeLeft = 0
                        self.onTimer()      // Disable timer and next button
                        break
                    }
                    print(stRsp.data?.verify_code ?? "verify_code")
                    self.sCode = stRsp.data?.verify_code ?? ""
                    break
                case let .failure(error):
                    self.showAlert(message: error.description!)
                    self.iTimeLeft = 0
                    self.onTimer()      // Disable timer and next button
                    break
            }
        }
    }


    func tryForgotBankPassword() {
        var stReq: StReqForgotBankPassword = StReqForgotBankPassword()
        stReq.token  = Config.modelUserInfo.sToken
        stReq.mobile = Config.modelUserInfo.sMobile
        stReq.bank_password = txtNewPswd.text!
        stReq.verify_code = txtCode.text!

        bSent = true

        API.instance.forgotBankPassword(stReq: stReq) { result in
            self.bSent = false
            switch result {
                case let .success(stRsp):
                    if stRsp.retcode != Config.RET_SUCCESS {
                        self.showAlert(message: stRsp.msg!)
                        break
                    }

                    self.showToast(
                        message   : "Password has been changed!".localized(),
                        completion: {
                            self.dismissFromParent()
                            self.delegate?.onBankForgotDismiss()
                        }
                    )
                    break
                case let .failure(error):
                    self.showAlert(message: error.description!)
                    break
            }
        }
    }


}
