import UIKit
import WebKit


protocol ViewControllerPasswordDelegate: AnyObject {
    func onPasswordDismiss()
}


class ViewControllerPassword: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var txtPrevious: UITextField!{
        didSet {
            txtPrevious!.addDoneCancelToolbar(
                onDone: (target: self, action: #selector(onDonePrevious))
            )
        }
    }
    
    @IBOutlet weak var txtNewPswd: UITextField!{
        didSet {
            txtNewPswd!.addDoneCancelToolbar(
                onDone: (target: self, action: #selector(onDoneNew))
            )
        }
    }
    @IBOutlet weak var txtConfirm: UITextField!{
        didSet {
            txtConfirm!.addDoneCancelToolbar(
                onDone: (target: self, action: #selector(onDoneConfirm))
            )
        }
    }
    @IBOutlet weak var txtCode: UITextField!{
        didSet {
            txtCode!.addDoneCancelToolbar(
                onDone: (target: self, action: #selector(onDoneCode))
            )
        }
    }
    @IBOutlet weak var btnGetCode: UIButton!
    @IBOutlet weak var btnSave: UIButton!

    @IBAction func onTouchUpBack(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    var delegate: ViewControllerPasswordDelegate? = nil

    private var timer    : Timer? = nil
    private var iTimeLeft: Int = 0
    private var bSent    : Bool = false
    private var sCode    : String = ""


    override func viewDidLoad() {
        super.viewDidLoad()
        updateButton()
    }

    @objc func onDonePrevious() {
        txtNewPswd.becomeFirstResponder()
    }
    @objc func onDoneNew() {
        txtConfirm.becomeFirstResponder()
    }
    @objc func onDoneConfirm() {
        txtCode.becomeFirstResponder()
    }
    @objc func onDoneCode() {
        txtCode.resignFirstResponder()
    }

    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        if textField == txtCode {
            let maxLength = 4
            let currentString = (textField.text ?? "") as NSString
            let newString = currentString.replacingCharacters(in: range, with: string) as NSString
            return newString.length <= maxLength
        }
        return true
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

//        if txtPrevious.text == nil { bFilled = false }
//        if txtNewPswd.text == nil  { bFilled = false }
//        if txtConfirm.text == nil  { bFilled = false }
//        if txtCode.text == nil     { bFilled = false }
//
//        if !bFilled {
//            showToast(message: "Please fill in the contents".localized(), completion: nil)
//            return
//        }

        if txtPrevious.text!.isEmpty {
            showAlert(message: "请输入原密码") { (UIAlertAction) in
                self.txtPrevious.becomeFirstResponder()
            }
            return
        }
        if txtNewPswd.text!.isEmpty  {
            showAlert(message: "请输入新密码") { (UIAlertAction) in
                self.txtNewPswd.becomeFirstResponder()
            }
            return
        }
        if txtNewPswd.text!.count < 6 || txtNewPswd.text!.count > 20 {
            showAlert(message: "密码由6-20数字和字母组成") { (UIAlertAction) in
                self.txtNewPswd.becomeFirstResponder()
            }
            return
        }
        
        if txtConfirm.text != txtNewPswd.text  {
            showAlert(message: "请输入正确的确认密码") { (UIAlertAction) in
                self.txtConfirm.becomeFirstResponder()
            }
            return
        }
        
        if txtCode.text!.isEmpty     {
            showAlert(message: "请输入验证码") { (UIAlertAction) in
                self.txtCode.becomeFirstResponder()
            }
            return
        }
        
        btnSave.isEnabled = false
        tryResetPassword()
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
        delegate?.onPasswordDismiss()
    }


    func updateButton() {
        DispatchQueue.main.async {
            if self.iTimeLeft <= 0 {
                self.btnGetCode.backgroundColor = UIColor(
                    red: 255/255, green: 98/255, blue: 0/255, alpha: 1
                )    // Orange
                self.btnGetCode.setTitle("Get Code".localized(), for: .normal)
            }
            else {
                self.btnGetCode.backgroundColor = UIColor(
                    red: 194/255, green: 199/255, blue: 204/255, alpha: 1
                )    // Gray
                self.btnGetCode.setTitle("\(self.iTimeLeft)s", for: .normal)
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


    func tryResetPassword() {
        var stReq: StReqResetPassword = StReqResetPassword()
        stReq.token  = Config.modelUserInfo.sToken
        stReq.mobile = Config.modelUserInfo.sMobile
        stReq.old_password = txtPrevious.text!
        stReq.new_password = txtNewPswd.text!
        stReq.verify_code  = txtCode.text!

        API.instance.resetPassword(stReq: stReq) { result in
            switch result {
                case let .success(stRsp):
                    if stRsp.retcode != Config.RET_SUCCESS {
                        self.showAlert(message: stRsp.msg!) { (UIAlertAction) in
                            DispatchQueue.main.async {
                                switch stRsp.retcode {
                                case ApiResult.PASSWORD_OLD_FAIL:
                                    self.txtPrevious.becomeFirstResponder()
                                case ApiResult.PASSWORD_BLANK, ApiResult.PASSWORD_INVAILD:
                                    self.txtNewPswd.becomeFirstResponder()
                                case ApiResult.VALIDATE_CODE_BLANK, ApiResult.VALIDATE_CODE_FAIL,
                                     ApiResult.VALIDATE_CODE_EXPIRED:
                                    self.txtCode.text = ""
                                    self.txtCode.becomeFirstResponder()
                                default:
                                    break;
                                }
                            }
                        }
                        self.btnSave.isEnabled = true
                        break
                    }
                    Config.pswd = stReq.new_password
                    self.showToast(
                        message   : "密码修改成功",
                        completion: {
                            self.dismiss(animated: true, completion: nil)
                        }
                    )
                    break

                case .failure(_):
                    DispatchQueue.main.async {
                        self.showAlert(message: "密码修改失败")
                        self.btnSave.isEnabled = true
                    }
                    break
            }
        }
    }
}
