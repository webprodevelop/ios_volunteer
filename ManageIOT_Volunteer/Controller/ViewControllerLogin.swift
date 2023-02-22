import UIKit

class ViewControllerLogin: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var txtPhone: UITextField! {
        didSet {
            txtPhone!.addDoneCancelToolbar(
                onDone: (target: self, action: #selector(onDonePhone))
            )
        }
    }
    @IBOutlet weak var txtPswd : UITextField!
    @IBOutlet weak var lblRequirePswd : UILabel!
    @IBOutlet weak var lblRequirePhone: UILabel!
    @IBOutlet weak var lblResult: UILabel!

    @IBOutlet weak var btnCheckSaveAccount: UIButton!
    @IBOutlet weak var btnCheckSavePswd: UIButton!

    @IBOutlet weak var btnLogin : UIButton!

    var sJPush: String = ""
    var bClickedConfirm: Bool = false


    override func viewDidLoad() {
        super.viewDidLoad()

        //-- App Info
        sJPush = JPUSHService.registrationID() ?? ""
        Config.setJPush(value: sJPush)
        Config.loadLoginInfo()

        //-- Bottom Border txtPhone
        let lyrBottomBorderPhone = CALayer()
        lyrBottomBorderPhone.frame = CGRect(
            x: 0.0,
            y: txtPhone.frame.size.height - 1.0,
            width: txtPhone.frame.size.width,
            height: 1.0
        )
        lyrBottomBorderPhone.backgroundColor = UIColor.lightGray.cgColor
        txtPhone.layer.addSublayer(lyrBottomBorderPhone)
        
        //-- Bottom Border txtPswd
        let lyrBottomBorderPswd = CALayer()
        lyrBottomBorderPswd.frame = CGRect(
            x: 0.0,
            y: txtPhone.frame.size.height - 1.0,
            width: txtPhone.frame.size.width,
            height: 1.0
        )
        lyrBottomBorderPswd.backgroundColor = UIColor.lightGray.cgColor
        txtPswd.layer.addSublayer(lyrBottomBorderPswd)
        txtPswd.delegate = self

        //-- Input
        lblResult.isHidden = true

        //-- Buttons for Save
        btnCheckSaveAccount.setImage(UIImage(named: "img_tick_off"), for: .normal)
        btnCheckSaveAccount.setImage(UIImage(named: "img_tick_on"), for: .selected)
        btnCheckSavePswd.setImage(UIImage(named: "img_tick_off"), for: .normal)
        btnCheckSavePswd.setImage(UIImage(named: "img_tick_on"), for: .selected)

        btnCheckSaveAccount.isSelected = false
        btnCheckSavePswd.isSelected = false
        if Config.getWillSavePhone() {
            btnCheckSaveAccount.isSelected = true
            txtPhone.text = Config.phone
        }
        if Config.getWillSavePswd() {
            btnCheckSavePswd.isSelected = true
            txtPswd.text = Config.pswd
        }

        tryGetAppInfo()
    }


    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        txtPhone.text = Config.phone
        txtPswd.text  = Config.pswd
        updateBtnLogin()
    }


    //-- UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return false
    }


    func textFieldDidEndEditing(_ textField: UITextField) {
        updateBtnLogin()
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
            return newString.length <= maxLength
        }

        return true
    }


    @IBAction func onTouchUpBtnCheckSaveAccount(_ sender: Any) {
        btnCheckSaveAccount.isSelected = !btnCheckSaveAccount.isSelected
        Config.setWillSavePhone(value: btnCheckSaveAccount.isSelected)
    }


    @IBAction func onTouchUpBtnSaveAccount(_ sender: Any) {
        btnCheckSaveAccount.isSelected = !btnCheckSaveAccount.isSelected
        Config.setWillSavePhone(value: btnCheckSaveAccount.isSelected)
    }


    @IBAction func onTouchUpBtnCheckSavePswd(_ sender: Any) {
        btnCheckSavePswd.isSelected = !btnCheckSavePswd.isSelected
        Config.setWillSavePswd(value: btnCheckSavePswd.isSelected)
    }


    @IBAction func onTouchUpBtnSavePswd(_ sender: Any) {
        btnCheckSavePswd.isSelected = !btnCheckSavePswd.isSelected
        Config.setWillSavePswd(value: btnCheckSavePswd.isSelected)
    }


    @IBAction func onTouchUpForgot(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Forgot", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ViewControllerForgot")
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }


    @IBAction func onTouchUpSignup(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Register", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ViewControllerRegister") as! ViewControllerRegister
        vc.modalPresentationStyle = .fullScreen
        vc.delegate = self
        present(vc, animated: true, completion: nil)
    }


    @IBAction func onTouchUpLogin(_ sender: Any) {
        if bClickedConfirm { return }

        lblRequirePhone.isHidden = true
        lblRequirePswd.isHidden  = true

        if txtPhone.text == "" {
            lblRequirePhone.isHidden = false
            txtPhone.becomeFirstResponder()
            return
        }
        
        if (txtPhone.text?.count != 11){
            self.showAlert(message: "Phone number is not correct".localized()) { (UIAlertAction) in
                self.txtPhone.becomeFirstResponder()
            }
            return
        }

        if txtPswd.text == "" {
            lblRequirePswd.isHidden = false
            txtPswd.becomeFirstResponder()
            return
        }

        tryLogin()
    }


    @objc func onDonePhone() {
        txtPswd.becomeFirstResponder()
        updateBtnLogin()
    }


    @objc func launchMain() {
        lblResult.isHidden = true

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ViewControllerMain")
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }


    func checkAppInfo() {
        let appVersionStr : String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
        let appVersion : Float = NSString(string: appVersionStr).floatValue
        let newVersion : Float = NSString(string: Config.getAppInfo().sAppVerIos).floatValue

        if newVersion > appVersion {
            DispatchQueue.main.async {
                let storyboard = UIStoryboard(name: "Update", bundle: nil)
                let vcUpdate = (storyboard.instantiateViewController(withIdentifier: "ViewControllerUpdate") as! ViewControllerUpdate)
                vcUpdate.modalPresentationStyle = .overCurrentContext
                self.present(vcUpdate, animated: false, completion: nil)
            }
        }
        else {
            if !Config.login_agree_privacy {
//                Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false, block: { timer in
                    DispatchQueue.main.async {
                        let storyboard = UIStoryboard(name: "LoginAgreePrivacy", bundle: nil)
                        let vc = storyboard.instantiateViewController(withIdentifier: "ViewControllerLoginAgreePrivacy") as! ViewControllerLoginAgreePrivacy
                        vc.modalPresentationStyle = .overCurrentContext
                        vc.modalTransitionStyle = .crossDissolve
                        self.present(vc, animated: true, completion: nil)
                    }
//                })
            }
            else {
                DispatchQueue.main.async {
                    if !(self.txtPhone.text ?? "").isEmpty, !(self.txtPswd.text ?? "").isEmpty {
                        if Config.is_logged_in {
                            self.tryLogin()
                        }
                    }
                }
            }
        }

    }


    func updateBtnLogin() {
        DispatchQueue.main.async {
            if !(self.txtPhone.text?.isEmpty ?? true) || !(self.txtPswd.text?.isEmpty ?? true) {
                self.btnLogin.isEnabled = true;
                self.btnLogin.backgroundColor = UIColor.systemTeal;
//                self.btnLogin.setTitleColor(UIColor.white, for: .normal)
            }
            else {
                self.btnLogin.isEnabled = false;
                self.btnLogin.backgroundColor = UIColor.lightGray;
//                self.btnLogin.setTitleColor(UIColor.lightGray, for: .normal)
            }
            if (self.txtPhone.text?.count ?? 0 > 0){
                self.lblRequirePhone.isHidden = true;
            }
            if (self.txtPswd.text?.count ?? 0 > 0){
                self.lblRequirePswd.isHidden = true;
            }
        }
    }


    func showResult() {
        DispatchQueue.main.async {
            self.lblResult.text = "Success to login!".localized()
            self.lblResult.isHidden = false
            Timer.scheduledTimer(
                timeInterval: 1.0,
                target      : self,
                selector    : #selector(self.launchMain),
                userInfo    : nil,
                repeats     : false
            )
        }
    }


    func tryGetAppInfo() {
        let stReq: StReqGetAppInfo = StReqGetAppInfo()

        API.instance.getAppInfo(stReq: stReq) { result in
            switch result {
                case let .success(stRsp):
                    if stRsp.retcode != Config.RET_SUCCESS {
                        self.showAlert(message: stRsp.msg!)
                        break
                    }
                    let model = ModelAppInfo()
                    if stRsp.data != nil {
                        model.copyFromApiData(data: stRsp.data!)
                        Config.setAppInfo(value: model)
                        self.updateBtnLogin()
                        self.checkAppInfo()
                    }
                    break

                case .failure(_):
                    break
            }
        }
    }


    func tryLogin() {
        var stReq: StReqLogin = StReqLogin()
        stReq.mobile   = txtPhone.text!
        stReq.password = txtPswd.text!
        stReq.registration_id = sJPush

        bClickedConfirm = true
        API.instance.login(stReq: stReq) { result in
            switch result {
                case let .success(stRsp):
                    if stRsp.retcode != Config.RET_SUCCESS {
                        self.showAlert(message: stRsp.msg!) { (UIAlertAction) in
                            DispatchQueue.main.async {
                                switch stRsp.retcode {
                                case ApiResult.PHONE_BLANK, ApiResult.PHONE_INVAILD:
                                    self.txtPhone.becomeFirstResponder()
                                case ApiResult.ACCOUNT_NOT_EXIST:
                                    self.txtPhone.text = ""
                                    self.txtPhone.becomeFirstResponder()
                                case ApiResult.PASSWORD_INVAILD, ApiResult.PASSWORD_FAIL:
                                    self.txtPswd.becomeFirstResponder()
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

                    Config.is_logged_in = true
                    Config.phone = stReq.mobile
                    Config.pswd  = stReq.password
                    Config.saveLoginInfo()

                    self.showResult()

                    break

                case let .failure(error):
                    self.showAlert(message: error.description!)
                    break
            }
            self.bClickedConfirm = false
        }
    }
}


extension ViewControllerLogin: ViewControllerRegisterDelegate {

    func onRegisterSuccess() {
        launchMain()
    }

}
