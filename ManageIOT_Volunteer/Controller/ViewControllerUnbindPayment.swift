import UIKit
import WebKit


protocol ViewControllerUnbindPaymentDelegate: AnyObject {
    func onUnbindPaymentSuccess(paymentMethod: Int, code: String)
}


class ViewControllerUnbindPayment: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var viewOutside: UIView!
    @IBOutlet weak var lblGetCode: UILabel!
    @IBOutlet weak var txtCode: UITextField!
    
    var delegate: ViewControllerUnbindPaymentDelegate? = nil
    var timer    : Timer? = nil
    var iPaymentMethod: Int = Config.PAYMENT_ALIPAY
    var iTimeLeft: Int = 0


    override func viewDidLoad() {
        super.viewDidLoad()

        //-- Gesture lblGetCode
        let gestureGetCode = UITapGestureRecognizer(target: self, action: #selector(onTapGetCode(_:)))
        lblGetCode.addGestureRecognizer(gestureGetCode)
        lblGetCode.isUserInteractionEnabled = true
        // tab outside
        let gestureOutside = UITapGestureRecognizer(target: self, action: #selector(onTapOutside(_:)))
        viewOutside.addGestureRecognizer(gestureOutside)
        viewOutside.isUserInteractionEnabled = true
        
        
        txtCode.delegate = self
        
//        iTimeLeft = 60
//        timer = Timer.scheduledTimer(
//            timeInterval: 1.0,
//            target      : self,
//            selector    : #selector(onTimer),
//            userInfo    : nil,
//            repeats     : true
//        )
//
//        tryGetCode()
    }


    @IBAction func onTouchUpOk(_ sender: Any) {
        let code = txtCode.text ?? ""
        if code == "" {
            showAlert(message: "请输入验证码", handler: { (UIAlertAction) in
                self.txtCode.becomeFirstResponder()
            })
            return
        }
        
        tryRemovePayAccount(paymentMethod: self.iPaymentMethod, code: code)
    }

    func tryRemovePayAccount(paymentMethod: Int, code: String) {
        var stReq: StReqRemovePayAccount = StReqRemovePayAccount()
        stReq.mobile = Config.modelUserInfo.sMobile
        stReq.token  = Config.modelUserInfo.sToken
        stReq.pay_type = paymentMethod
        stReq.verify_code = code

        API.instance.removePayAccount(stReq: stReq) { result in
            switch result {
                case let .success(stRsp):
                    if stRsp.retcode != Config.RET_SUCCESS {
                        self.showAlert(message: stRsp.msg!) { (UIAlertAction) in
                            DispatchQueue.main.async {
                                switch stRsp.retcode {
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
                    
                    DispatchQueue.main.async {
//                        self.showToast(message: "解绑成功", completion: {
//                            self.dismiss(animated: false, completion: {
//                                self.delegate?.onUnbindPaymentSuccess(paymentMethod: paymentMethod, code: code)
//                            })
//                        })
                        
                        self.dismiss(animated: false, completion: {
                            self.delegate?.onUnbindPaymentSuccess(paymentMethod: paymentMethod, code: code)
                        })
                    }
                    break

                case let .failure(error):
                    self.showAlert(message: error.description!)
                    break
            }
        }
    }
    

    @IBAction func onTouchUpCancel(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }

    @objc func onTapOutside(_ sender: UIGestureRecognizer) {
        dismiss(animated: false, completion: nil)
    }


    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        let maxLength = 1
//        let currentString: NSString = (textField.text ?? "") as NSString
//        let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
//        if newString.length > maxLength {
//            return false
//        }
        if textField == txtCode {
            let maxLength = 4
            let currentString = (textField.text ?? "") as NSString
            let newString = currentString.replacingCharacters(in: range, with: string) as NSString
            return newString.length <= maxLength
        }
//
//        let disallowed = NSCharacterSet(charactersIn: "0123456789").inverted
//        if string.rangeOfCharacter(from: disallowed) != nil {
//            return true
//        }
//
//        if string.isEmpty {
//            return true
//        }
//
//        /// Make current text empty, so after replace, length will be always 1
//        textField.text = ""

        return true
    }
    
    @objc func onTapGetCode(_ sender: UIGestureRecognizer) {
        if sender.view as? UILabel == nil { return }
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
    
    @objc func onTimer() {
        iTimeLeft -= 1
        if iTimeLeft < 0 {
            timer?.invalidate()
            timer = nil
        }
        updateButton()
    }

    func updateButton() {
        DispatchQueue.main.async {
            if self.iTimeLeft <= 0 {
                self.lblGetCode.backgroundColor = UIColor(
                    red: 255/255, green: 98/255, blue: 0/255, alpha: 1
                )    // Orange
                self.lblGetCode.text = "获取验证码"
            }
            else {
                self.lblGetCode.backgroundColor = UIColor(
                    red: 194/255, green: 199/255, blue: 204/255, alpha: 1
                )    // Gray
                self.lblGetCode.text = "\(self.iTimeLeft)秒"
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
                    print(stRsp.data?.verify_code ?? "")
                    //self.sCode = stRsp.data?.verify_code ?? ""
                    break
                case let .failure(error):
                    self.showAlert(message: error.description!)
                    self.iTimeLeft = 0
                    self.onTimer()      // Disable timer and next button
                    break
            }
        }
    }

}
