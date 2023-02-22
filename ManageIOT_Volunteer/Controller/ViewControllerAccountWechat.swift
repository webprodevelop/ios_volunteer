import UIKit
import WebKit

protocol ViewControllerAccountWechatDelegate: AnyObject {
    func onAccountWechatDismiss()
}


class ViewControllerAccountWechat: UIViewController {

    @IBOutlet weak var txtAccountName: UITextField!
    @IBOutlet weak var txtAccountId: UITextField!

    var delegate: ViewControllerAccountWechatDelegate? = nil
    private var sAccountName: String = ""
    private var sAccountId  : String = ""
    private var sCode: String = ""
    private var sLang: String = ""
    private var sAccessToken: String = ""
    private var sOpenId: String = ""
    private var sNickName: String = ""
    private var bClickedModify: Bool = false


    override func viewDidLoad() {
        super.viewDidLoad()

        txtAccountName.text = Config.modelUserInfo.sWechatName
        txtAccountId.text = Config.modelUserInfo.sWechatId
    }


    @IBAction func onTouchUpBtnRefresh(_ sender: Any) {
        let authReq: SendAuthReq = SendAuthReq()
        authReq.scope = "snsapi_userinfo"
        authReq.state = "wechat_access_token"   /// Can be anything
        WXApi.sendAuthReq(authReq, viewController: self, delegate: self, completion: nil)
    }


    @IBAction func onTouchUpBtnModify(_ sender: Any) {
        sAccountName = txtAccountName.text ?? ""
        sAccountId   = txtAccountId.text ?? ""
        if sAccountName.isEmpty || sAccountId.isEmpty {
            showToast(message: "Please fill in fields".localized(), completion: nil)
            return
        }

        if bClickedModify { return }
        bClickedModify = true
        tryRegisterPayAccount()
    }


    func onBack() {
        dismissFromParent()
        delegate?.onAccountWechatDismiss()
    }


    func tryGetWechatAccessToken() {
        var stReq: StReqWechatAccessToken = StReqWechatAccessToken()
        stReq.appid = Config.WECHAT_APP_ID
        stReq.secret = Config.WECHAT_APP_SECRET
        stReq.code = sCode
        stReq.grant_type = "authorization_code"

        API.instance.getWechatAccessToken(stReq: stReq) { result in
            switch result {
                case let .success(stRsp):
                    print(stRsp)
                    self.sAccessToken = stRsp.access_token ?? ""
                    self.sOpenId = stRsp.openid ?? ""
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
        stReq.access_token = sAccessToken
        stReq.openid       = sOpenId
        stReq.lang         = sLang

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
                    self.sNickName = stRsp.nickname ?? ""
                    DispatchQueue.main.async {
                        self.txtAccountId.text = self.sOpenId
                        self.txtAccountName.text = self.sNickName
                    }
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
        stReq.pay_account_name = sAccountName
        stReq.pay_account_id   = sAccountId

        API.instance.registerPayAccount(stReq: stReq) { result in
            switch result {
                case let .success(stRsp):
                    if stRsp.retcode != Config.RET_SUCCESS {
                        self.showAlert(message: stRsp.msg!)
                        break
                    }
                    Config.modelUserInfo.sWechatId   = self.sAccountId
                    Config.modelUserInfo.sWechatName = self.sAccountName
                    self.showToast(message: "Successfully updated!".localized(), completion: nil)
                    break

                case let .failure(error):
                    self.showAlert(message: error.description!)
                    break
            }
            self.bClickedModify = false
        }
    }

}


extension ViewControllerAccountWechat: WXApiDelegate {

    func onReq(_ req: BaseReq) {
        print(req)
    }


    func onResp(_ resp: BaseResp) {
        print(resp)
        guard let authResp = resp as? SendAuthResp else {
            showAlert(message: "Wechat")
            return
        }
        sCode = authResp.code ?? ""
        sLang = authResp.lang ?? ""
        tryGetWechatAccessToken()
    }

}
