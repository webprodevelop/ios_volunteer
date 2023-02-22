import UIKit
import WebKit


protocol ViewControllerAccountDelegate: AnyObject {
    func onAccountSuccess()
}


class ViewControllerAccount: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var lblCurrent: UILabel!
    @IBOutlet weak var btnCode: UIButton!
    @IBOutlet weak var txtNew : UITextField! {
        didSet {
            txtNew!.addDoneCancelToolbar(
                onDone: (target: self, action: #selector(onDoneNew))
            )
        }
    }
    @IBOutlet weak var txtCode: UITextField! {
        didSet {
            txtCode!.addDoneCancelToolbar(
                onDone: (target: self, action: #selector(onDoneCode))
            )
        }
    }

    var delegate : ViewControllerAccountDelegate? = nil
    var bClickedConfirm = false
    var sCode    : String = ""
    var timer    : Timer? = nil
    var iTimeLeft: Int = 0


    override func viewDidLoad() {
        super.viewDidLoad()

        lblCurrent.text = Config.modelUserInfo.sMobile
    }


    @IBAction func onTouchUpBack(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }


    @IBAction func onTouchUpGetCode(_ sender: Any) {
        if txtNew.text?.isEmpty ?? false {
            showAlert(message: "请输入新的手机号码") { (UIAlertAction) in
                self.txtNew.becomeFirstResponder()
            }
            return
        }
        
        if txtNew.text!.count != 11 {
            showAlert(message: "手机号不正确") { (UIAlertAction) in
                self.txtNew.becomeFirstResponder()
            }
            return
        }

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


    @IBAction func onTouchUpConfirm(_ sender: Any) {
        if bClickedConfirm { return }
        if txtNew.text?.isEmpty ?? false {
            showAlert(message: "请输入新的手机号码") { (UIAlertAction) in
                self.txtNew.becomeFirstResponder()
            }
            return
        }
        
        if txtNew.text!.count != 11 {
            showAlert(message: "手机号不正确") { (UIAlertAction) in
                self.txtNew.becomeFirstResponder()
            }
            return
        }
        if txtCode.text?.isEmpty ?? false {
            showAlert(message: "请输入验证码") { (UIAlertAction) in
                self.txtCode.becomeFirstResponder()
            }
            return
        }
        trySetMobile()
    }


    @objc func onTimer() {
        iTimeLeft -= 1
        if iTimeLeft < 0 {
            timer?.invalidate()
            timer = nil
        }
        updateButton()
    }


    @objc func onDoneNew() {
        txtCode.becomeFirstResponder()
    }


    @objc func onDoneCode() {
        txtCode.resignFirstResponder()
    }

    //-- UITextFieldDelegate
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        if textField == txtNew {
            let maxLength = 11
            let currentString = (textField.text ?? "") as NSString
            let newString = currentString.replacingCharacters(in: range, with: string) as NSString
            return newString.length <= maxLength
        }
        if textField == txtCode {
            let maxLength = 4
            let currentString = (textField.text ?? "") as NSString
            let newString = currentString.replacingCharacters(in: range, with: string) as NSString
            return newString.length <= maxLength
        }

        return true
    }


    func updateButton() {
        DispatchQueue.main.async {
            if self.iTimeLeft <= 0 {
                self.btnCode.backgroundColor = UIColor(
                    red: 255/255, green: 98/255, blue: 0/255, alpha: 1
                )    // Orange
                self.btnCode.setTitle("Get Code".localized(), for: .normal)
            }
            else {
                self.btnCode.backgroundColor = UIColor(
                    red: 194/255, green: 199/255, blue: 204/255, alpha: 1
                )    // Gray
                self.btnCode.setTitle("\(self.iTimeLeft)秒", for: .normal)
            }
        }
    }


    func tryGetCode() {
        var stReq: StReqUpdateUserInfoCode = StReqUpdateUserInfoCode()
        stReq.mobile = txtNew.text!
        API.instance.getUpdateUserInfoCode(stReq: stReq) { result in
            switch result {
                case let .success(stRsp):
                    if stRsp.retcode != Config.RET_SUCCESS {
                        self.showAlert(message: stRsp.msg!)
                        self.iTimeLeft = 0
                        self.onTimer()
                        break
                    }
                    
                    // print(stRsp.data?.verify_code ?? "verify_code")
                    break

                case let .failure(error):
                    self.showAlert(message: error.description!)
                    self.iTimeLeft = 0
                    self.onTimer()      // Disable timer and next button
                    break
            }
        }
    }


    func trySetMobile() {
        var stReq: StReqSetMobile = StReqSetMobile()
        stReq.mobile = Config.modelUserInfo.sMobile
        stReq.token  = Config.modelUserInfo.sToken
        stReq.new_mobile  = txtNew.text ?? ""
        stReq.verify_code = txtCode.text ?? ""
        
        bClickedConfirm = true
        API.instance.setMobile(stReq: stReq) { result in
            switch result {
                case let .success(stRsp):
                    if stRsp.retcode != Config.RET_SUCCESS {
                        self.showAlert(message: stRsp.msg!) { (UIAlertAction) in
                            DispatchQueue.main.async {
                                switch stRsp.retcode {
                                case ApiResult.PHONE_BLANK, ApiResult.PHONE_INVAILD:
                                    self.txtNew.becomeFirstResponder()
                                case ApiResult.PHONE_REGISTERED:
                                    self.txtNew.text = ""
                                    self.txtCode.text = ""
                                    self.txtNew.becomeFirstResponder()
                                case ApiResult.VALIDATE_CODE_BLANK, ApiResult.VALIDATE_CODE_FAIL,
                                     ApiResult.VALIDATE_CODE_EXPIRED:
                                self.txtCode.text = ""
                                self.txtCode.becomeFirstResponder()
                                default:
                                    break;
                                }
                            }
                        }
                        break
                    }
                    Config.modelUserInfo.sMobile = stReq.new_mobile
                    Config.phone = stReq.new_mobile
                    self.showToast(message: "修改账号成功") {
                        self.dismiss(animated: true, completion: nil)
                    }
                    break

                case .failure(_):
                    self.showAlert(message: "修改账号失败")
                    break
            }
            self.bClickedConfirm = false
        }
    }


}
