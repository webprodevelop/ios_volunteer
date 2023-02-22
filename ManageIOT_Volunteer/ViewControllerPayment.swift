import Foundation
import UIKit


protocol ViewControllerPaymentDelegate: AnyObject {
    func onPaymentDismiss()
    func onPaymentPresent()
    func onPaymentPresentAccountAlipay()
    func onPaymentPresentAccountWechat()
}


class ViewControllerPayment: UIViewController {

    @IBOutlet weak var viewAccountWechat: UIView!
    @IBOutlet weak var viewAccountAlipay: UIView!
    @IBOutlet weak var lblAccountWechat: UILabel!
    @IBOutlet weak var lblAccountAlipay: UILabel!
    @IBOutlet weak var btnBindWechat: UIButton!
    @IBOutlet weak var btnBindAlipay: UIButton!

    private let VC_NONE          : Int = 0
    private let VC_ACCOUNT_ALIPAY: Int = 1
    private let VC_ACCOUNT_WECHAT: Int = 2

    private var vcAccountAlipay: ViewControllerAccountAlipay? = nil
    private var vcAccountWechat: ViewControllerAccountWechat? = nil

    var delegate: ViewControllerPaymentDelegate? = nil

    private var iVcCurrent: Int = 0 /// VC_NONE
    private var sWechatAccountName: String = ""
    private var sWechatAccountId  : String = ""
    private var sWechatCode: String = ""
    private var sWechatLang: String = ""
    private var sWechatToken: String = ""
    private var sWechatOpenId: String = ""
    private var sWechatNickName: String = ""


    override func viewDidLoad() {
        super.viewDidLoad()

        /// Gesture
//        let gestureAccountAlipay   = UITapGestureRecognizer(target: self, action: #selector(onTapAccountAlipay(_:)))
//        let gestureAccountWechat   = UITapGestureRecognizer(target: self, action: #selector(onTapAccountWechat(_:)))

//        viewAccountAlipay.addGestureRecognizer(gestureAccountAlipay)
//        viewAccountWechat.addGestureRecognizer(gestureAccountWechat)

        /// Initial Value
        let sWechatName = Config.modelUserInfo.sWechatName
        let sAlipayName = Config.modelUserInfo.sAlipayName
        lblAccountWechat.text = sWechatName
        lblAccountAlipay.text = sAlipayName

        if sWechatName.isEmpty {
            btnBindWechat.setTitle("Bind".localized(), for: .normal)
        }
        else {
            btnBindWechat.setTitle("Unbind".localized(), for: .normal)
        }
        if sAlipayName.isEmpty {
            btnBindAlipay.setTitle("Bind".localized(), for: .normal)
        }
        else {
            btnBindAlipay.setTitle("Unbind".localized(), for: .normal)
        }
    }


    @IBAction func onTouchUpBtnBindWechat(_ sender: Any) {
        if Config.modelUserInfo.sWechatName.isEmpty {
            /// Bind
            let authReq: SendAuthReq = SendAuthReq()
            authReq.scope = "snsapi_userinfo"
            authReq.state = "wechat_access_token"   /// Can be anything
            WXApi.sendAuthReq(authReq, viewController: self, delegate: self, completion: nil)
        }
        else {
            showViewControllerUnbindPayment(paymentMethod: Config.PAYMENT_WECHAT)
        }
    }


    @IBAction func onTouchUpBtnBindAlipay(_ sender: Any) {
        if Config.modelUserInfo.sAlipayName.isEmpty {
            /// Bind
            if vcAccountAlipay == nil {
                let storyboard = UIStoryboard(name: "AccountAlipay", bundle: nil)
                vcAccountAlipay = storyboard.instantiateViewController(withIdentifier: "ViewControllerAccountAlipay") as? ViewControllerAccountAlipay
            }
            vcAccountAlipay!.modalPresentationStyle = .overCurrentContext
            vcAccountAlipay!.delegate = self
            present(vcAccountAlipay!, animated: false, completion: nil)
        }
        else {
            showViewControllerUnbindPayment(paymentMethod: Config.PAYMENT_ALIPAY)
        }
    }


//    @objc func onTapAccountAlipay(_ sender: UIGestureRecognizer) {
//        if vcAccountAlipay == nil {
//            let storyboard = UIStoryboard(name: "AccountAlipay", bundle: nil)
//            vcAccountAlipay = storyboard.instantiateViewController(withIdentifier: "ViewControllerAccountAlipay") as? ViewControllerAccountAlipay
//        }
//        vcAccountAlipay!.delegate = self
//        addChildViewController(child: vcAccountAlipay!, container: view, frame: view.bounds)
//        iVcCurrent = VC_ACCOUNT_ALIPAY
//        delegate?.onPaymentPresentAccountAlipay()
//    }


//    @objc func onTapAccountWechat(_ sender: UIGestureRecognizer) {
//        if vcAccountWechat == nil {
//            let storyboard = UIStoryboard(name: "AccountWechat", bundle: nil)
//            vcAccountWechat = storyboard.instantiateViewController(withIdentifier: "ViewControllerAccountWechat") as? ViewControllerAccountWechat
//        }
//        vcAccountWechat!.delegate = self
//        addChildViewController(child: vcAccountWechat!, container: view, frame: view.bounds)
//        iVcCurrent = VC_ACCOUNT_WECHAT
//        delegate?.onPaymentPresentAccountWechat()
//    }


    func onBack() {
        switch iVcCurrent {
            case VC_NONE:
                dismissFromParent()
                delegate?.onPaymentDismiss()
                break
            case VC_ACCOUNT_ALIPAY:
                vcAccountAlipay?.onBack()
                break
            case VC_ACCOUNT_WECHAT:
                vcAccountWechat?.onBack()
                break
            default: break
        }
    }


    func dismissChildren() {
        vcAccountAlipay?.dismissFromParent()
        vcAccountWechat?.dismissFromParent()

        vcAccountAlipay = nil
        vcAccountWechat = nil
        iVcCurrent = VC_NONE
    }


    func showViewControllerUnbindPayment(paymentMethod: Int) {
        let storyboard = UIStoryboard(name: "UnbindPayment", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ViewControllerUnbindPayment") as! ViewControllerUnbindPayment
        vc.modalPresentationStyle = .overCurrentContext
        vc.delegate = self
        vc.iPaymentMethod = paymentMethod
        self.present(vc, animated: true, completion: nil)
    }


    func tryGetWechatAccessToken() {
        var stReq: StReqWechatAccessToken = StReqWechatAccessToken()
        stReq.appid = Config.WECHAT_APP_ID
        stReq.secret = Config.WECHAT_APP_SECRET
        stReq.code = sWechatCode
        stReq.grant_type = "authorization_code"

        API.instance.getWechatAccessToken(stReq: stReq) { result in
            switch result {
                case let .success(stRsp):
                    print(stRsp)
                    self.sWechatToken = stRsp.access_token ?? ""
                    self.sWechatOpenId = stRsp.openid ?? ""
                    self.tryGetWechatUserInfo()
                    break

                case let .failure(error):
                    self.showAlert(message: error.description!)
                    break
            }
        }

    }


    func tryGetWechatUserInfo() {
        var stReq: StReqWechatUserInfo = StReqWechatUserInfo()
        stReq.access_token = sWechatToken
        stReq.openid       = sWechatOpenId
        stReq.lang         = sWechatLang

        API.instance.getWechatUserInfo(stReq: stReq) { result in
            switch result {
                case let .success(stRsp):
                    print(stRsp)
                    //stRsp.openid
                    //stRsp.nickname
                    //stRsp.sex
                    //stRsp.province
                    //stRsp.city
                    //stRsp.country
                    //stRsp.headimgurl
                    //stRsp.privilege
                    //stRsp.unionid
                    self.sWechatNickName = stRsp.nickname ?? ""
                    DispatchQueue.main.async {
                        self.lblAccountWechat.text = self.sWechatNickName
                    }
                    self.tryRegisterPayAccount()
                    break

                case let .failure(error):
                    self.showAlert(message: error.description!)
                    break
            }
        }

    }


    func tryRegisterPayAccount() {
        var stReq: StReqRegisterPayAccount = StReqRegisterPayAccount()
        stReq.mobile = Config.modelUserInfo.sMobile
        stReq.token  = Config.modelUserInfo.sToken
        stReq.pay_type = Config.PAYMENT_WECHAT
        stReq.pay_account_name = sWechatAccountName
        stReq.pay_account_id   = sWechatAccountId

        API.instance.registerPayAccount(stReq: stReq) { result in
            switch result {
                case let .success(stRsp):
                    if stRsp.retcode != Config.RET_SUCCESS {
                        self.showAlert(message: stRsp.msg!)
                        break
                    }
                    Config.modelUserInfo.sWechatId   = self.sWechatAccountId
                    Config.modelUserInfo.sWechatName = self.sWechatAccountName
                    self.showToast(message: "Successfully updated!".localized(), completion: nil)
                    break

                case let .failure(error):
                    self.showAlert(message: error.description!)
                    break
            }
        }
    }


    
}


extension ViewControllerPayment: ViewControllerAccountAlipayDelegate {

    func onAccountAlipayDismiss() {
        vcAccountAlipay = nil
        iVcCurrent = VC_NONE
        delegate?.onPaymentPresent()
        lblAccountAlipay.text = Config.modelUserInfo.sAlipayName
        // scott
        if Config.modelUserInfo.sAlipayName.isEmpty {
            btnBindAlipay.setTitle("Bind".localized(), for: .normal)
        }
        else {
            btnBindAlipay.setTitle("Unbind".localized(), for: .normal)
        }
    }

}


extension ViewControllerPayment: ViewControllerAccountWechatDelegate {

    func onAccountWechatDismiss() {
        vcAccountWechat = nil
        iVcCurrent = VC_NONE
        delegate?.onPaymentPresent()
    }

}


extension ViewControllerPayment: ViewControllerUnbindPaymentDelegate {

    func onUnbindPaymentSuccess(paymentMethod: Int, code: String) {
        /// Unbind
        self.showToast(message: "解绑成功", completion: nil)
        if paymentMethod == Config.PAYMENT_WECHAT {
            /// Unbind
            lblAccountWechat.text = ""
            Config.modelUserInfo.sWechatName = ""
            btnBindWechat.setTitle("Bind".localized(), for: .normal)
        }
        else {
            lblAccountAlipay.text = ""
            Config.modelUserInfo.sAlipayName = ""
            btnBindAlipay.setTitle("Bind".localized(), for: .normal)
        }
    }
}


extension ViewControllerPayment: WXApiDelegate {

    func onReq(_ req: BaseReq) {
        print(req)
    }


    func onResp(_ resp: BaseResp) {
        print(resp)
        guard let authResp = resp as? SendAuthResp else {
            showAlert(message: "Wechat")
            return
        }
        sWechatCode = authResp.code ?? ""
        sWechatLang = authResp.lang ?? ""
        tryGetWechatAccessToken()
    }

}
