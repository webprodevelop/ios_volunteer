import UIKit


protocol ViewControllerRegisterDelegate: AnyObject {
    func onRegisterSuccess()
}


class ViewControllerRegister: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var txtPhone: UITextField! {
        didSet {
            txtPhone!.addDoneCancelToolbar(
                onDone: (target: self, action: #selector(onDonePhone))
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
    @IBOutlet weak var txtPswd   : UITextField!
    {
        didSet {
            txtCode!.addDoneCancelToolbar(
                onDone: (target: self, action: #selector(onDonePswd))
            )
        }
    }
    @IBOutlet weak var txtConfirmPswd: UITextField!
    
    @IBOutlet weak var lblRequirePhone: UILabel!
    @IBOutlet weak var lblRequireAuthCode: UILabel!
    @IBOutlet weak var lblRequirePswd: UILabel!
    @IBOutlet weak var lblRequireConfirmPswd: UILabel!
    
    @IBOutlet weak var lblGetCode: UILabel!
    @IBOutlet weak var lblAgree  : UILabel!
    @IBOutlet weak var lblPrivacy: UILabel!
    @IBOutlet weak var imgAgree  : UIImageView!
    @IBOutlet weak var btnNext   : UIButton!
    @IBOutlet weak var btnCancel : UIButton!

    var delegate : ViewControllerRegisterDelegate? = nil
    var timer    : Timer? = nil
    var iTimeLeft: Int = 0
    var bAgreed  : Bool = false
    var bSent    : Bool = false
    var sCode    : String = ""


    override func viewDidLoad() {
        super.viewDidLoad()

        //-- Bottom Border txtPhone
        let lyrBottomBorderPhone = CALayer()
        lyrBottomBorderPhone.frame = CGRect(
            x: 0.0,
            y: txtPhone.frame.size.height - 1.0,
            width : txtPhone.frame.size.width,
            height: 1.0
        )
        lyrBottomBorderPhone.backgroundColor = UIColor.lightGray.cgColor
        txtPhone.layer.addSublayer(lyrBottomBorderPhone)

        //-- Bottom Border txtCode
        let lyrBottomBorderCode = CALayer()
        lyrBottomBorderCode.frame = CGRect(
            x: 0.0,
            y: txtPhone.frame.size.height - 1.0,
            width : txtPhone.frame.size.width,
            height: 1.0
        )
        lyrBottomBorderCode.backgroundColor = UIColor.lightGray.cgColor
        txtCode.layer.addSublayer(lyrBottomBorderCode)

        //-- Bottom Border txtPswd
        let lyrBottomBorderPswd = CALayer()
        lyrBottomBorderPswd.frame = CGRect(
            x: 0.0,
            y: txtPhone.frame.size.height - 1.0,
            width : txtPhone.frame.size.width,
            height: 1.0
        )
        lyrBottomBorderPswd.backgroundColor = UIColor.lightGray.cgColor
        txtPswd.layer.addSublayer(lyrBottomBorderPswd)

        //-- Bottom Border txtConfirmPswd
        let lyrBottomBorderConfirmPswd = CALayer()
        lyrBottomBorderConfirmPswd.frame = CGRect(
            x: 0.0,
            y: txtPhone.frame.size.height - 1.0,
            width : txtPhone.frame.size.width,
            height: 1.0
        )
        lyrBottomBorderConfirmPswd.backgroundColor = UIColor.lightGray.cgColor
        txtConfirmPswd.layer.addSublayer(lyrBottomBorderConfirmPswd)

        //-- Gesture lblGetCode
        let gestureGetCode = UITapGestureRecognizer(target: self, action: #selector(onTapGetCode(_:)))
        lblGetCode.addGestureRecognizer(gestureGetCode)
        lblGetCode.isUserInteractionEnabled = true

        //-- Gesture imgAgree
        let gestureImgAgree = UITapGestureRecognizer(target: self, action: #selector(onTapImgAgree(_:)))
        imgAgree.addGestureRecognizer(gestureImgAgree)
        imgAgree.isUserInteractionEnabled = true

        //-- Gesture lblAgree
        let gestureLblAgree = UITapGestureRecognizer(target: self, action: #selector(onTapLblAgree(_:)))
        lblAgree.addGestureRecognizer(gestureLblAgree)
        lblAgree.isUserInteractionEnabled = true

        //-- Gesture lblPrivacy
        let gestureLblPrivacy = UITapGestureRecognizer(target: self, action: #selector(onTapLblPrivacy(_:)))
        lblPrivacy.addGestureRecognizer(gestureLblPrivacy)
        lblPrivacy.isUserInteractionEnabled = true

        //-- Delegate
        txtPhone.delegate = self
        txtCode.delegate = self
        txtPswd.delegate = self
        txtConfirmPswd.delegate = self
    }


    //-- UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return false
    }


    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        if textField == txtPhone {
            let maxLength = 11
            let currentString = (textField.text ?? "") as NSString
            let newString = currentString.replacingCharacters(in: range, with: string) as NSString
            if (currentString.length > 0){
                lblRequirePhone.isHidden = true
            }
            return newString.length <= maxLength
        }
        if textField == txtCode {
            let maxLength = 4
            let currentString = (textField.text ?? "") as NSString
            let newString = currentString.replacingCharacters(in: range, with: string) as NSString
            if (currentString.length > 0){
                lblRequireAuthCode.isHidden = true
            }
            return newString.length <= maxLength
        }
        if textField == txtPswd {
            let currentString = (textField.text ?? "") as NSString
            if (currentString.length > 0){
                lblRequirePswd.isHidden = true
            }
        }
        if textField == txtConfirmPswd {
            let currentString = (textField.text ?? "") as NSString
            if (currentString.length > 0){
                lblRequireConfirmPswd.isHidden = true
            }
        }
        return true
    }


    @IBAction func onChangedPhone(_ sender: Any) {
        iTimeLeft = 0
        onTimer()   // Disable timer and next button
    }


    @IBAction func onTouchUpNext(_ sender: Any) {
        if txtPhone.text == ""    {
            lblRequirePhone.isHidden = false
            return }
        if (txtPhone.text?.count != 11){
            self.showAlert(message: "手机号不正确") { (UIAlertAction) in
                self.txtPhone.becomeFirstResponder()
            }
            return
        }
        if txtCode.text  == ""    {
            lblRequireAuthCode.isHidden = false
            return }
        if txtPswd.text  == ""    {
            lblRequirePswd.isHidden = false
            return }
        if txtPswd.text!.count < 6 || txtPswd.text!.count > 20 { self.showAlert(message: "密码由6-20数字和字母组成") { (UIAlertAction) in
            self.txtPswd.becomeFirstResponder()
        }
        return }
        
        if txtConfirmPswd.text  == ""    {
            lblRequireConfirmPswd.isHidden = false
            return }
        
        if (txtConfirmPswd.text != txtPswd.text){
            self.showAlert(message: "请输入正确的确认密码") { (UIAlertAction) in
                self.txtPhone.becomeFirstResponder()
            }
            return
        }
        
        if !bAgreed               { return }
        if bSent                  { return }

        tryRegister()
    }


    @IBAction func onTouchUpCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }


    @objc func onTapGetCode(_ sender: UIGestureRecognizer) {
        if sender.view as? UILabel == nil { return }
        if iTimeLeft > 0 { return }
        if txtPhone.text == "" {
            lblRequirePhone.isHidden = false;
            txtPhone.becomeFirstResponder()
            return
        }
        if txtPhone.text!.count != 11 {
            showAlert(message: "手机号不正确"){ (UIAlertAction) in
                self.txtPhone.becomeFirstResponder()
            }
            return
        }
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


    @objc func onTapImgAgree(_ sender: UIGestureRecognizer) {
        if sender.view as? UIImageView == nil { return }

        bAgreed = !bAgreed
        if bAgreed {
            imgAgree.image = UIImage(named: "img_check_on")
            self.btnNext.isEnabled = true;
            self.btnNext.backgroundColor = UIColor.systemTeal;
        }
        else {
            imgAgree.image = UIImage(named: "img_check_off")
            self.btnNext.isEnabled = false;
            self.btnNext.backgroundColor = UIColor.lightGray;
        }
    }

    
    @objc func onTapLblAgree(_ sender: UIGestureRecognizer) {
        if sender.view as? UILabel == nil { return }

        let storyboard = UIStoryboard(name: "Agree", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ViewControllerAgree")
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)

    }

    
    @objc func onTapLblPrivacy(_ sender: UIGestureRecognizer) {
        if sender.view as? UILabel == nil { return }

        let storyboard = UIStoryboard(name: "Policy", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ViewControllerPolicy")
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }


    @objc func onDonePhone() {
        txtCode.becomeFirstResponder()
    }


    @objc func onDoneCode() {
        txtPswd.becomeFirstResponder()
    }
    
    @objc func onDonePswd() {
        txtConfirmPswd.becomeFirstResponder()
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
        stReq.mobile   = txtPhone.text!

        API.instance.getCode(stReq: stReq) { result in
            switch result {
                case let .success(stRsp):
                    if stRsp.retcode != Config.RET_SUCCESS {
                        self.showAlert(message: stRsp.msg!)
                        self.iTimeLeft = 0
                        self.onTimer()      // Disable timer and next button
                        break
                    }
                    break
                case let .failure(error):
                    self.showAlert(message: error.description!)
                    self.iTimeLeft = 0
                    self.onTimer()      // Disable timer and next button
                    break
            }
        }
    }


    func tryRegister() {
        var stReq: StReqRegister = StReqRegister()
        stReq.mobile      = txtPhone.text!
        stReq.password    = txtPswd.text!
        stReq.verify_code = txtCode.text!

        bSent = true

        API.instance.register(stReq: stReq) { result in
            self.bSent = false
            switch result {
                case let .success(stRsp):
                    if stRsp.retcode != Config.RET_SUCCESS {
                        self.showAlert(message: stRsp.msg!) { (UIAlertAction) in
                            DispatchQueue.main.async {
                                switch stRsp.retcode {
                                case ApiResult.PHONE_BLANK, ApiResult.PHONE_INVAILD:
                                    self.txtPhone.becomeFirstResponder()
                                case ApiResult.PHONE_REGISTERED:
                                    self.txtPhone.text = ""
                                    self.txtCode.text = ""
                                    self.txtPhone.becomeFirstResponder()
                                case ApiResult.PASSWORD_INVAILD:
                                    self.txtPswd.becomeFirstResponder()
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
                    if stRsp.data != nil {
                        Config.modelUserInfo.copyFromApiData(data: stRsp.data!)
                    }
                    Config.phone = stReq.mobile
                    Config.pswd  = stReq.password
                    Config.saveLoginInfo()

                    self.showToast(
                        message   : "注册成功",
                        completion: {
                            self.dismiss(animated: true, completion: nil)
                        }
                    )
                    break
            case .failure(_):
                    self.showToast(
                        message   : "注册失败",
                        completion: {
                            self.dismiss(animated: true, completion: nil)
                        }
                    )
                    break
            }
        }
    }

}
